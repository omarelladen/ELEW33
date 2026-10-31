// -std=c99

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "io.h"
#include "system.h"


// Avalon slave register offsets
#define ADDR_OFFSET  0
#define DATA_OFFSET  4
#define CTRL_OFFSET  8

// Avalon control register bit masks
#define MEM_WR_BIT   (1 << 0)
#define MEM_RD_BIT   (1 << 1)
#define CHK_RST_BIT  (1 << 2)

#define HW_BASE  USER_0_BASE

#define NUM_WR  1024


void delay(uint32_t iterations)
{
    for (volatile uint32_t k=0; k < iterations; k++) {}
}

void write_byte(uint32_t memory_idx, uint8_t byte_val)
{
    IOWR_32DIRECT(HW_BASE, ADDR_OFFSET, memory_idx);
    IOWR_32DIRECT(HW_BASE, DATA_OFFSET, byte_val);
    IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, MEM_WR_BIT);
}

uint8_t read_byte(uint32_t memory_idx)
{
    IOWR_32DIRECT(HW_BASE, ADDR_OFFSET, memory_idx);
    IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, MEM_RD_BIT);

    delay(50);

    return (uint8_t)IORD_32DIRECT(HW_BASE, DATA_OFFSET);
}


int main(void)
{
    const char *name = "OMAR +++--+++ ";
    uint32_t name_len = strlen(name);

    printf("Name: %s\n", name);
    printf("Length: %u bytes\n", name_len);


    uint32_t sequence = 1;

    // Reset the registers
    IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, CHK_RST_BIT);

    while (1)
    {
        // Send
        uint8_t checksum = 0;
        for (uint32_t i=0; i < NUM_WR; i++)
        {
            uint8_t char_wr = (uint8_t)name[i % name_len];
            write_byte(i, char_wr);
            checksum += char_wr;
        }

        // Handshake
        // 31..24   23..16
        // sequence checksum
        IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, sequence << 24 | checksum << 16);

        delay(100);  // wair for HW checksum


        // Read HW checksum
        const uint32_t ctrl_status = IORD_32DIRECT(HW_BASE, CTRL_OFFSET);

        const uint8_t checksum_hw = (ctrl_status >> 8) & 0xFF;  // 15..0
        const bool    match_hw    = (ctrl_status >> 7) & 0x01;  // bit 7


        printf("------------------------------\n");
        printf("sequence : %u\n", sequence);
        printf("checksum : 0x%02X\n", checksum);
        printf("checksum_hw : 0x%02X\n", checksum_hw);
        printf("match_hw : %s\n", match_hw ? "true" : "false");


        for (uint32_t i=0; i < NUM_WR; i++)
        {
            volatile uint8_t char_rd = read_byte(i);
            printf("%c", char_rd);
        }

        sequence++;
    }

    return 0;
}
