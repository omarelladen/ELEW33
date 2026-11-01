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
#define CTRL_WE_BIT  (1 << 0)
#define CTRL_RE_BIT  (1 << 1)

#define HW_BASE  USER_0_BASE

#define NUM_WR  1024


void write_byte(uint32_t mem_addr, uint8_t data)
{
    IOWR_32DIRECT(HW_BASE, ADDR_OFFSET, mem_addr);
    IOWR_32DIRECT(HW_BASE, DATA_OFFSET, data);
    IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, CTRL_WE_BIT);
}

uint8_t read_byte(uint32_t mem_addr)
{
    IOWR_32DIRECT(HW_BASE, ADDR_OFFSET, mem_addr);
    IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, CTRL_RE_BIT);

    return (uint8_t)IORD_32DIRECT(HW_BASE, DATA_OFFSET);  // 7..0
    // (DATA_OFFSET and CTRL_RE_BIT not needed in rd)
}


int main(void)
{
    const char *name = "OMAR +++--+++ ";
    uint32_t name_len = strlen(name);

    printf("\n==============================\n");
    printf("Name: %s\n", name);
    printf("Length: %u bytes\n", name_len);


    uint32_t sequence_sw = 0;

    while (1)
    {
        // Send
        uint8_t checksum_sw = 0;
        for (uint32_t i=0; i < NUM_WR; i++)
        {
            uint8_t char_wr = (uint8_t)name[i % name_len];
            write_byte(i, char_wr);
            checksum_sw += char_wr;
        }

        // Handshake
        // 31..24       23..16
        // sequence_sw  checksum_sw
        IOWR_32DIRECT(HW_BASE, CTRL_OFFSET, sequence_sw << 24 |
                                            checksum_sw << 16);


        // Read HW checksum
        const uint32_t ctrl_status = IORD_32DIRECT(HW_BASE, CTRL_OFFSET);
        // (CTRL_OFFSET not needed in rd)

        // 31..24       23..16       15
        // sequence_hw  checksum_hw  match_chk_hw
        const uint8_t sequence_hw  = (ctrl_status >> 24) & 0xFF;
        const uint8_t checksum_hw  = (ctrl_status >> 16) & 0xFF;
        const bool    match_chk_hw = (ctrl_status >> 15) & 0x01;


        printf("\n------------------------------\n");
        printf("sequence_hw: %u\n", sequence_hw);
        printf("sequence_sw: %u\n", sequence_sw);
        printf("checksum_sw: 0x%02X\n", checksum_sw);
        printf("checksum_hw: 0x%02X\n", checksum_hw);
        printf("match_chk_hw: %s\n", match_chk_hw ? "true" : "false");


        for (uint32_t i=0; i < NUM_WR; i++)
        {
            volatile uint8_t char_rd = read_byte(i);
            printf("%c", char_rd);
        }

        sequence_sw++;
    }

    return 0;
}
