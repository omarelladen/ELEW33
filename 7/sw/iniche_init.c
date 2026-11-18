// -std=c99
// MicroC/OS-II and Altera NicheStack TCP/IP Stack

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "system.h"

#include "basic_io.h"
#include "dm9000a.h"
#include "LCD.h"

// Simple Socket Server definitions
#include "simple_socket_server.h"
#include "alt_error_handler.h"

#include "altera_avalon_pio_regs.h"  // drivers/inc/

#include "io.h"  // HAL/inc/

// MicroC/OS-II definitions
#include "includes.h"  // HAL/inc/

// NicheStack definitions
#include "osport.h"   // iniche/src/nios2/
#include "ipport.h"   // iniche/src/h/nios2/
#include "libport.h"  // iniche/src/h/
#include "tcpport.h"  // iniche/src/h/



#define IP    "192.168.15.3"
#define PORT  8003

#define LCD_TEXT  "Lab7 - Omar"

#define HW_BASE  USER_0_BASE

// Avalon slave register offsets
// #define ADDR_OFFSET  0
#define DATA_OFFSET  4
// #define CTRL_OFFSET  8

// Avalon control register bit masks
// #define CTRL_WE_BIT  (1 << 0)
// #define CTRL_RE_BIT  (1 << 1)


void SendTask(void *task_data);
void RecvTask(void *task_data);


int SocketFD;
char hw_str[101];

// All tasks which use NicheStack (use sockets) are created with TK_NEWTASK

// Task stack for the initial task
OS_STK SSSInitialTaskStk[TASK_STACKSIZE];

// Static task object used by NicheStack during operation
TK_OBJECT(to_recvtask);
TK_OBJECT(to_sendtask);

// Entry point of the task
TK_ENTRY(RecvTask);
TK_ENTRY(SendTask);

OS_EVENT *hw_mbox;

// Structure used by TK_NEWTASK to create the task
struct inet_taskinfo recvtask = {
    &to_recvtask,
    "recv task",
    RecvTask,
    10,
    APP_STACK_SIZE,
};
struct inet_taskinfo sendtask = {
    &to_sendtask,
    "send task",
    SendTask,
    6,
    APP_STACK_SIZE,
};

void wr_hw_32bits(uint32_t data)
{
    // IOWR_32DIRECT(HW_BASE, ADDR_OFFSET, 0);
    IOWR_32DIRECT(HW_BASE, DATA_OFFSET, data);
    // IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, CTRL_WE_BIT);
}

uint32_t rd_hw_32bits()
{
    // IOWR_32DIRECT(HW_BASE, ADDR_OFFSET, 0);
    // IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, CTRL_RE_BIT);

    return IORD_32DIRECT(HW_BASE, DATA_OFFSET);
}


void SSSInitialTask(void *task_data)
{
    /*
    * Initialize Altera NicheStack TCP/IP Stack - Nios II Edition specific code.
    * NicheStack is initialized from a task, so that RTOS will have started, and
    * I/O drivers are available.  Two tasks are created:
    *    "Inet main"  task with priority 2
    *    "clock tick" task with priority 3
    */
    alt_iniche_init();
    netmain();

    // Wait for the network stack to be ready, and IP address is obtained
    while (!iniche_net_ready)
        TK_SLEEP(1);

    printf("\nSimple Socket Server starting up\n");


    LCD_Init();
    LCD_Show_Text(LCD_TEXT);

    hw_mbox  = OSMboxCreate(NULL);  // mailbox


    SocketFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

    struct sockaddr_in sa;
    memset(&sa, 0, sizeof sa);
    sa.sin_family = AF_INET;
    sa.sin_port = htons(PORT);
    int res = inet_pton(AF_INET, IP, &sa.sin_addr);

    if (connect(SocketFD, (struct sockaddr *)&sa, sizeof sa) == -1)
    {
        perror("Failed to connect");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }

    // Create tasks
    TK_NEWTASK(&recvtask);
    TK_NEWTASK(&sendtask);

    // Create OS data structures
    SSSCreateOSDataStructs();

    // Create the other tasks
    SSSCreateTasks();


    // Delete this task
    INT8U error_code = OSTaskDel(OS_PRIO_SELF);
    alt_uCOSIIErrorHandler(error_code, 0);
    while (1);  // never reached
}

void RecvTask(void *task_data)
{
    char buf[2000];

    while (1)
    {
        // Wait for server str
        int str_len = recv(SocketFD, buf, sizeof(hw_str)-1, 0);

        if (str_len <= 0)
        {
            perror("recv()");
            break;  // exit(EXIT_FAILURE)
        }
        buf[str_len] = '\0';
        printf("Str received from server: %s\n", buf);

        // Send 4 chars at a time
        for (uint32_t i=0; i < str_len; i += 4)
        {
            uint32_t word = 0;
            for (uint32_t j=0; j < 4 && i+j < str_len; j++)
                word |= buf[i+j] << (8*j);

            wr_hw_32bits(word);
            uint32_t hw_word = rd_hw_32bits();

            for (uint32_t j=0; j < 4 && i+j < str_len; j++)
                hw_str[i+j] = (char)((hw_word >> (8*j)) & 0xFF);
        }
        hw_str[str_len] = '\0';

        OSMboxPost(hw_mbox, (void *)hw_str);
    }


    close(SocketFD);
    INT8U error_code = OSTaskDel(OS_PRIO_SELF);
    alt_uCOSIIErrorHandler(error_code, 0);
    while (1);  // never reached
}

void SendTask(void *task_data)
{
    INT8U err;

    while (1)
    {
        // Wait for RecvTask to post to mailbox
        char *msg = (char *)OSMboxPend(hw_mbox, 0, &err);

        int res = send(SocketFD, msg, strlen(msg), 0);

        if (res < 0)
        {
            perror("send()");
            break;  // exit(EXIT_FAILURE);
        }
        printf("hw_str sent to server: %s\n", msg);
    }

    INT8U error_code = OSTaskDel(OS_PRIO_SELF);
    alt_uCOSIIErrorHandler(error_code, 0);
    while (1);
}


int main (int argc, char* argv[], char* envp[])
{
    // Initialize the DM9000A Ethernet Controller
    DM9000A_INSTANCE(DM9000A_0, dm9000a_0);
    DM9000A_INIT    (DM9000A_0, dm9000a_0);

    // Clear the RTOS timer
    OSTimeSet(0);

    // SSSInitialTask is the initial task which will initialize the NicheStack
    // TCP/IP Stack and initialize the ROTS structures and other tasks
    INT8U error_code = OSTaskCreateExt(SSSInitialTask,
                                       NULL,
                                       (void *)&SSSInitialTaskStk[TASK_STACKSIZE],
                                       SSS_INITIAL_TASK_PRIORITY,
                                       SSS_INITIAL_TASK_PRIORITY,
                                       SSSInitialTaskStk,
                                       TASK_STACKSIZE,
                                       NULL,
                                       0);
    alt_uCOSIIErrorHandler(error_code, 0);

    // Start the RTOS (scheduler)
    OSStart();

    while(1);  // never reached

    return -1;
}
