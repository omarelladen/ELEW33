// -std=c99
// MicroC/OS-II RTOS and Altera NicheStack TCP/IP Stack

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


#define IP    "192.168.15.2"
#define PORT  8003
#define LCD_TEXT  "Proj - Omar"

#define HW_BASE  0x00  // USER_0_BASE

// Avalon slave register offsets
// #define ADDR_OFFSET  0
#define DATA_OFFSET  4
// #define CTRL_OFFSET  8

// Avalon control register bit masks
// #define CTRL_WE_BIT  (1 << 0)
// #define CTRL_RE_BIT  (1 << 1)

#define IMG_SIZE  (500*500)  // (800*600)  // max 66512 (?)
#define BUF_SIZE  2000
#define FLAG_RESPOND  0x01

void SendTask(void *task_data);
void RecvTask(void *task_data);


int SocketFD;

uint8_t img_sdram[IMG_SIZE];  // full img
uint32_t idx_img = 0;

// Task stack for the initial task
OS_STK SSSInitialTaskStk[TASK_STACKSIZE];

// Static task object used by NicheStack during operation
TK_OBJECT(to_recvtask);
TK_OBJECT(to_sendtask);

// Entry point of the task
TK_ENTRY(RecvTask);
TK_ENTRY(SendTask);

OS_FLAG_GRP *flag_grp;

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


    INT8U err;
    flag_grp = OSFlagCreate(0x00, &err);  // event flags


    SocketFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

    struct sockaddr_in sa;
    memset(&sa, 0, sizeof sa);
    sa.sin_family = AF_INET;
    sa.sin_port = htons(PORT);
    (void)inet_pton(AF_INET, IP, &sa.sin_addr);

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
    char buf[BUF_SIZE];
    INT8U err;

    while (1)
    {
        // Wait for server str
        int pixels_recv = recv(SocketFD, buf, BUF_SIZE, 0);

        if (pixels_recv <= 0)
        {
            perror("recv()");
            break;  // exit(EXIT_FAILURE)
        }

        // Copy received pixels to img buffer in SDRAM
        for (uint32_t i=0; i < pixels_recv; i++)
        {
            img_sdram[idx_img+i] = buf[i];
        }
        idx_img += pixels_recv;

        printf("%d\n", idx_img);

        // Received the full image (check received h & w)
        if (idx_img >= IMG_SIZE)  // >= IMG_SIZE
        {
            // Notify SendTask
            err = OSFlagPost(flag_grp, FLAG_RESPOND, OS_FLAG_SET, &err);
            printf("Received all pixels. idx_img=%d\n", idx_img);

            idx_img = 0;
        }
    }

    close(SocketFD);
    INT8U error_code = OSTaskDel(OS_PRIO_SELF);
    alt_uCOSIIErrorHandler(error_code, 0);
    while (1);
}

void SendTask(void *task_data)
{
    INT8U err;

    while (1)
    {
        // Wait for RecvTask notification
        OS_FLAGS value = OSFlagPend(flag_grp,
                                    FLAG_RESPOND,
                                    OS_FLAG_WAIT_SET_ALL + OS_FLAG_CONSUME,
                                    0,
                                    &err);
        puts("Flag set");

        char *msg = "ok";
        int res = send(SocketFD, msg, strlen(msg), 0);

        if (res < 0)
        {
            perror("send()");
            break;  // exit(EXIT_FAILURE);
        }
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
