--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:22:15 12/02/2009
-- Design Name:   
-- Module Name:   C:/DLXCache/Cache/Cache_test.vhd
-- Project Name:  Cache
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Cache_cmp
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.CacheLibrary.all;
use work.Global.all;
 
ENTITY Cache_test IS
END Cache_test;
 
ARCHITECTURE behavior OF Cache_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Cache_cmp
    PORT(
         ch_memrd : IN  std_logic;
         ch_memwr : IN  std_logic;
         ch_baddr : IN  std_logic_vector(31 downto 0);
         ch_bdata_in : IN  std_logic_vector(31 downto 0);
			ch_bdata_out : OUT  std_logic_vector(31 downto 0);
         ch_reset : IN  std_logic;
         ch_ready : OUT  std_logic;
         ch_hit : OUT  std_logic;
         ch_hitm : OUT  std_logic;
         ch_inv : IN  std_logic;
         ch_eads : IN  std_logic;
			ch_wtwb : in STD_LOGIC;
         ch_flush : IN  std_logic;
			ch_debug_cache : out cache_type(0 to 2**INDEX_BIT - 1)
        );
    END COMPONENT;
    

   --Inputs
   signal ch_memrd : std_logic := '0';
   signal ch_memwr : std_logic := '0';
   signal ch_baddr : std_logic_vector(31 downto 0) := (others => '0');
   signal ch_reset : std_logic := '0';
   signal ch_inv : std_logic := '0';
   signal ch_eads : std_logic := '0';
   signal ch_flush : std_logic := '0';
	signal ch_wtwb : std_logic := '0';

	--BiDirs
   signal ch_bdata_in : std_logic_vector(31 downto 0);
	signal ch_bdata_out : std_logic_vector(31 downto 0);
 	--Outputs
   signal ch_ready : std_logic;
   signal ch_hit : std_logic;
   signal ch_hitm : std_logic;
	signal ch_debug_cache : cache_type (0 to 2**INDEX_BIT - 1);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Cache_cmp PORT MAP (
          ch_memrd => ch_memrd,
          ch_memwr => ch_memwr,
          ch_baddr => ch_baddr,
          ch_bdata_in => ch_bdata_in,
			 ch_bdata_out => ch_bdata_out,
          ch_reset => ch_reset,
          ch_ready => ch_ready,
          ch_hit => ch_hit,
          ch_hitm => ch_hitm,
          ch_inv => ch_inv,
          ch_eads => ch_eads,
			 ch_wtwb => ch_wtwb,
          ch_flush => ch_flush,
			 ch_debug_cache => ch_debug_cache
        ); 
 
   -- Stimulus process
   stim_proc: process
   begin			
		wait for 10 ns;
		ch_reset <= '1';
      wait for 20 ns;
		ch_reset <= '0';
		--significato bit:T:tag,I:index
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		wait for 100 ns; 
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000000000000";
		ch_memrd <= '1';
		wait for 100 ns;
		ch_memrd <= '0';-- mi aspetto prima via occupata per indice "00"
		
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000000100100";
		ch_memrd <= '1';
		wait for 100 ns;
		ch_memrd <= '0';-- mi aspetto prima via occupata per indice "01"
		
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000010000100";
		ch_memrd <= '1';
		wait for 100 ns;
		ch_memrd <= '0';-- mi aspetto seconda via occupata per indice "00"
		
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000100001100";
		ch_memrd <= '1';
		wait for 100 ns;
		ch_memrd <= '0';-- mi aspetto prima via occupata con contatore a 0 per indice "00"
		
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000100011100";
		ch_memrd <= '1';
		wait for 100 ns;
		ch_memrd <= '0';-- mi aspetto prima via occupata con contatore a 0 per indice "00"
		
		-- SCRITTURE
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000100000000";
		ch_bdata_in <= "11111111111111111111111111111111";
		ch_memwr <= '1';
		wait for 100 ns;
		ch_memwr <= '0';-- mi aspetto prima via occupata con contatore a 0 e stato in M(11) e dato agiornato per indice "00"
		
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000101000100";
		ch_bdata_in <= "11111111111111111111111111111111";
		ch_memwr <= '1';
		wait for 100 ns;
		ch_memwr <= '0';-- mi aspetto prima via occupata con contatore a 0 e stato in M(11) e dato agiornato per indice "10"
		wait;
   end process;

END;