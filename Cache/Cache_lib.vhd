library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Global.all;

PACKAGE ChacheLibrary IS

CONSTANT OFFSET_BIT : natural := 5;
CONSTANT INDEX_BIT : natural := 2;
CONSTANT TAG_BIT : natural := PARALLELISM - INDEX_BIT - OFFSET_BIT;
CONSTANT NWAY : natural := 2;

CONSTANT MESI_I : STD_LOGIC_VECTOR (1 downto 0) := "00";
CONSTANT MESI_M : STD_LOGIC_VECTOR (1 downto 0) := "11";
CONSTANT MESI_E : STD_LOGIC_VECTOR (1 downto 0) := "01";
CONSTANT MESI_S : STD_LOGIC_VECTOR (1 downto 0) := "10";

TYPE data_line IS ARRAY (0 to 2**OFFSET_BIT) of STD_LOGIC_VECTOR (7 downto 0);

TYPE cache_line IS 
	RECORD
		data : data_line;
		status : STD_LOGIC_VECTOR (1 downto 0);
		tag : STD_LOGIC_VECTOR (TAG_BIT-1 downto 0);
		lru_counter : STD_LOGIC_VECTOR (1 downto 0);
	END RECORD;

TYPE set_ways IS ARRAY (0 to NWAY) of cache_line;

TYPE cache_set IS 
		RECORD
			index : STD_LOGIC_VECTOR (INDEX_BIT-1 downto 0);
			ways	: set_ways;
		END RECORD;
		
TYPE cache_type IS ARRAY (natural range <>) of cache_set;
	
END PACKAGE ChacheLibrary;
