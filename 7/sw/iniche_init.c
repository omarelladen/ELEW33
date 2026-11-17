// -std=c99

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
// #include <stdbool.h>
// #include <ctype.h>

// #include <io.h>
// #include <fcntl.h>

#include "io.h"
#include "system.h"

#include "LCD.h"
#include "dm9000a.h"
#include "basic_io.h"
#include "altera_avalon_pio_regs.h"
// #include "alt_error_handler.h"

/* Simple Socket Server definitions */
#include "simple_socket_server.h"

/* MicroC/OS-II definitions */
// #include "../simple_socket_bsp/HAL/inc/includes.h"
// #include "../simple_socket_bsp/system.h"

/* NicheStack definitions */
#include "../simple_socket_bsp/iniche/src/h/nios2/ipport.h"
#include "../simple_socket_bsp/iniche/src/h/tcpport.h"
// #include "../simple_socket_bsp/iniche/src/h/libport.h"
#include "../simple_socket_bsp/iniche/src/nios2/osport.h"


#define IP    "192.168.15.2"
#define PORT  8003

#define LCD_TEXT "Lab7 - Omar"

#define HW_BASE  USER_0_BASE

// Avalon slave register offsets
// #define ADDR_OFFSET  0
#define DATA_OFFSET  4
// #define CTRL_OFFSET  8

// Avalon control register bit masks
// #define CTRL_WE_BIT  (1 << 0)
// #define CTRL_RE_BIT  (1 << 1)


/* Definition of task stack for the initial task which will initialize the NicheStack
 * TCP/IP Stack and then initialize the rest of the Simple Socket Server example tasks.
 */
OS_STK SSSInitialTaskStk[TASK_STACKSIZE];

/* Declarations for creating a task with TK_NEWTASK.
 * All tasks which use NicheStack (those that use sockets) must be created this way.
 * TK_OBJECT macro creates the static task object used by NicheStack during operation.
 * TK_ENTRY macro corresponds to the entry point, or defined function name, of the task.
 * inet_taskinfo is the structure used by TK_NEWTASK to create the task.
 */
TK_OBJECT(to_ssstask);
TK_ENTRY(SSSSimpleSocketServerTask);

struct inet_taskinfo ssstask = {
    &to_ssstask,
    "simple socket server",
    SSSSimpleSocketServerTask,
    4,
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


/* SSSInitialTask will initialize the NicheStack
 * TCP/IP Stack and then initialize the rest of the Simple Socket Server example
 * RTOS structures and tasks.
 */
void SSSInitialTask(void *task_data)
{
    INT8U error_code;

    /*
    * Initialize Altera NicheStack TCP/IP Stack - Nios II Edition specific code.
    * NicheStack is initialized from a task, so that RTOS will have started, and
    * I/O drivers are available.  Two tasks are created:
    *    "Inet main"  task with priority 2
    *    "clock tick" task with priority 3
    */
    alt_iniche_init();
    netmain();

    /* Wait for the network stack to be ready before proceeding.
    * iniche_net_ready indicates that TCP/IP stack is ready, and IP address is obtained.
    */
    while (!iniche_net_ready)
        TK_SLEEP(1);

    /* Now that the stack is running, perform the application initialization steps */

    /* Application Specific Task Launching Code Block Begin */

    printf("\nSimple Socket Server starting up\n");

    /* Create the main simple socket server task. */
    //TK_NEWTASK(&ssstask);

    /*create os data structures */
    //SSSCreateOSDataStructs();

    /* create the other tasks */
    //SSSCreateTasks();

    /* Application Specific Task Launching Code Block End */

    /*This task is deleted because there is no need for it to run again */
    //error_code = OSTaskDel(OS_PRIO_SELF);
    //alt_uCOSIIErrorHandler(error_code, 0);

    char p1[16];
    char p2[16];

    struct sockaddr_in sa;
    char buf[2000];


    int SocketFD = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    memset(&sa, 0, sizeof sa);
    sa.sin_family = AF_INET;
    sa.sin_port = htons(PORT);
    int res = inet_pton(AF_INET, IP, &sa.sin_addr);

    LCD_Init();
    LCD_Show_Text(LCD_TEXT);


    if (connect(SocketFD, (struct sockaddr *)&sa, sizeof sa) == -1)
    {
        perror("Failed to connect");
        close(SocketFD);
        exit(EXIT_FAILURE);
    }

    while (1)
    {
        char hw_str[101];

        // Wait for server str
        int str_len = recv(SocketFD, buf, sizeof(buf) - 1, 0);
        if (str_len <= 0)
        {
            perror("recv()");
            break;  // exit(EXIT_FAILURE)
        }
        buf[str_len] = '\0';
        printf("Str received from form: %s\n", buf);

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

        // Send hw str to server
        if (send(SocketFD, hw_str, str_len, 0) < 0)
        {
            perror("send()");
            break;  // exit(EXIT_FAILURE);
        }
        printf("hw_str sent to server: %s\n", hw_str);

        msleep(5000);
    }
}


/* Main creates a single task, SSSInitialTask, and starts task scheduler. */
int main (int argc, char* argv[], char* envp[])
{

    INT8U error_code;

    DM9000A_INSTANCE(DM9000A_0, dm9000a_0);
    DM9000A_INIT(DM9000A_0, dm9000a_0);

    /* Clear the RTOS timer */
    OSTimeSet(0);

    /* SSSInitialTask will initialize the NicheStack
    * TCP/IP Stack and then initialize the rest of the Simple Socket Server example
    * RTOS structures and tasks.
    */
    error_code = OSTaskCreateExt(SSSInitialTask,
                                 NULL,
                                 (void *)&SSSInitialTaskStk[TASK_STACKSIZE],
                                 SSS_INITIAL_TASK_PRIORITY,
                                 SSS_INITIAL_TASK_PRIORITY,
                                 SSSInitialTaskStk,
                                 TASK_STACKSIZE,
                                 NULL,
                                 0);
    alt_uCOSIIErrorHandler(error_code, 0);

    /*
    * As with all MicroC/OS-II designs, once the initial thread(s) and
    * associated RTOS resources are declared, we start the RTOS. That's it!
    */
    OSStart();

    while(1);  /* Correct Program Flow never gets here. */

    return -1;
}
