library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

PACKAGE BlockRamLibrary IS

CONSTANT ADDR_BIT : natural := 11;
CONSTANT RAM_DEPTH : natural := 2**ADDR_BIT; -- abbiamo la Block Ram RAMB16_S9
CONSTANT DATA_WIDTH : natural := 8;
CONSTANT PARITY_WIDTH : natural := 1;
END PACKAGE BlockRamLibrary;