library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

PACKAGE BlockRamLibrary IS

CONSTANT ADDR_BIT : natural := 11;
CONSTANT RAM_DEPTH : natural := 2**ADDR_BIT; -- abbiamo la Block Ram RAMB16_S9
CONSTANT DATA_WIDTH : natural := 8;
CONSTANT PARITY_WIDTH : natural := 1;
CONSTANT nbyte_line : natural := 8; --n byte che compongono una linea di memoria
TYPE mem_line IS ARRAY (0 to nbyte_line-1) of STD_LOGIC_VECTOR (7 downto 0);
END PACKAGE BlockRamLibrary;