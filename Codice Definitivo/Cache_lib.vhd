library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Global.all;

PACKAGE CacheLibrary IS

CONSTANT OFFSET_BIT : natural := 5;
CONSTANT INDEX_BIT : natural := 2;
CONSTANT TAG_BIT : natural := PARALLELISM - INDEX_BIT - OFFSET_BIT;
CONSTANT NWAY : natural := 2;

CONSTANT MESI_M : natural := 3;
CONSTANT MESI_E : natural := 2;
CONSTANT MESI_S : natural := 1;
CONSTANT MESI_I : natural := 0;

CONSTANT RAM_DEPTH :integer := 128;    --numero di linee che costituiscono la ram

TYPE data_line IS ARRAY (0 to 2**OFFSET_BIT - 1) of STD_LOGIC_VECTOR (7 downto 0);
TYPE RAM IS ARRAY  (integer range <>)of data_line;

TYPE cache_line IS 
	RECORD
		data : data_line;
		status : natural;
		tag : STD_LOGIC_VECTOR (TAG_BIT-1 downto 0);
		lru_counter : natural;
	END RECORD;

TYPE set_ways IS ARRAY (0 to NWAY - 1) of cache_line;
		
TYPE cache_type IS ARRAY (0 to 2**INDEX_BIT - 1) of set_ways;
	
END PACKAGE CacheLibrary;
