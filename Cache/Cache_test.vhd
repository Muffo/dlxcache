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
 
ENTITY Cache_test IS
END Cache_test;
 
ARCHITECTURE behavior OF Cache_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Cache_cmp
    PORT(
         ch_memrd : IN  std_logic;
         ch_memwr : IN  std_logic;
         ch_baddr : IN  std_logic_vector(31 downto 2);
         ch_bdata : INOUT  std_logic_vector(31 downto 0);
         ch_reset : IN  std_logic;
         ch_ready : OUT  std_logic;
         ch_hit : OUT  std_logic;
         ch_hitm : OUT  std_logic;
         ch_inv : IN  std_logic;
         ch_eads : IN  std_logic;
			ch_wtwb : in STD_LOGIC;
         ch_flush : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal ch_memrd : std_logic := '0';
   signal ch_memwr : std_logic := '0';
   signal ch_baddr : std_logic_vector(31 downto 2) := (others => '0');
   signal ch_reset : std_logic := '0';
   signal ch_inv : std_logic := '0';
   signal ch_eads : std_logic := '0';
   signal ch_flush : std_logic := '0';
	signal ch_wtwb : std_logic := '0';

	--BiDirs
   signal ch_bdata : std_logic_vector(31 downto 0);

 	--Outputs
   signal ch_ready : std_logic;
   signal ch_hit : std_logic;
   signal ch_hitm : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Cache_cmp PORT MAP (
          ch_memrd => ch_memrd,
          ch_memwr => ch_memwr,
          ch_baddr => ch_baddr,
          ch_bdata => ch_bdata,
          ch_reset => ch_reset,
          ch_ready => ch_ready,
          ch_hit => ch_hit,
          ch_hitm => ch_hitm,
          ch_inv => ch_inv,
          ch_eads => ch_eads,
			 ch_wtwb => ch_wtwb,
          ch_flush => ch_flush
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
--   constant <clock>_period := 1ns;
-- 
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
 
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 10 ns;	

      -- wait for <clock>_period*10;

      -- insert stimulus here 


		ch_reset <= '1';
      wait;
   end process;

END;
