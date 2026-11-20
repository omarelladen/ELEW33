# VGA

The analog pixel values are sent row by row (left to right) and top to bottom.

# DE-15 Connector

```
---------------------------
\    5   4   3   2   1    /
 \    10  9   8   7   6  /
  \ 15  14  13  12  11  /
   ---------------------
```

Pin | Function |
--- | -------- |
1   | RED      |
2   | GRN      |
3   | BLU      |
4   | -        |
5   | GND      |
6   | GND      |
7   | GND      |
8   | GND      |
9   | -        |
10  | GND      |
11  | -        |
12  | -        |
13  | HS       |
14  | VS       |
15  | -        |

- HS: Horizontal Sync
- VS: Vertical   Sync

# Temporization

Format         | Pixel Clk (MHz) | B: H Sync Pulse (px) | P: V Sync Pulse (px) | C: H Back Porch (px) | Q: V Back Porch (px) | E: H Front Porch (px) | S: V Front Porch (px) | D: H Active Video (px) | R: V Active Video (px) |
-------------- | --------------- | -------------------- | -------------------- | -------------------- | -------------------- | --------------------- | --------------------- | ---------------------- | ---------------------- |
640x480, 60 Hz | 25.175          | 96                   | 2                    | 48                   | 31                   | 16                    | 11                    | 640                    | 480                    |
800x600, 72 Hz | 50              | 120                  | 6                    | 64                   | 23                   | 56                    | 37                    | 800                    | 600                    |

- A: Scanline    time = B+C+D+E
- Q: Total frame time = P+Q+R+S

# Synchronization

Horizontal:

```

____       ___________________________________________________________
    |     |                                                           |     |
    |_____|                                                           |_____|

    |--B--|---C---|-------------------------D-------------------------|--E--|
```

Vertical:

```

____       ___________________________________________________________
    |     |                                                           |     |
    |_____|                                                           |_____|

    |--P--|---Q---|-------------------------R-------------------------|--S--|
```

## DAC

The EP2C35 FPGA in the DE2 board is connected to the ADV7123 DAC,
which converts the 10-bit RGB channels to 0-0.7V.

VGA_BLANK and VGA_SYNC DAC inputs use negative logic.

## References

- https://embarcados.com.br/controlador-vga-parte-1/
- https://embarcados.com.br/controlador-vga-parte-2/
- https://embarcados.com.br/caracteres-ascii-com-controlador-vga-parte-3/
