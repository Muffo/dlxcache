----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:29:02 12/01/2009 
-- Design Name: 
-- Module Name:    Cache_cmp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
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
	
END PACKAGE;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.ChacheLibrary.all;
use work.Global.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Cache_cmp is
    Port ( ch_memrd : in  STD_LOGIC;
           ch_memwr : in  STD_LOGIC;
           ch_baddr : in  STD_LOGIC_VECTOR (31 downto 2);
           ch_bdata : inout  STD_LOGIC_VECTOR (31 downto 0);
           ch_reset : in  STD_LOGIC;
           ch_ready : in  STD_LOGIC;
			  ch_hit : out STD_LOGIC;
			  ch_hitm : out STD_LOGIC;
			  ch_inv : in STD_LOGIC;
			  ch_eads : in STD_LOGIC;
			  ch_flush : in STD_LOGIC);
end Cache_cmp;

architecture Behavioral of Cache_cmp is

shared variable cache : cache_type (0 to 2**INDEX_BIT);

begin



end Behavioral;

