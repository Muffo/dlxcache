----------------------------------------------------------------------------------
-- Company: Gruppo 2
-- Engineer: Grandi, Malaguti, Mattetti, Morlini, Ricci
-- 
-- Create Date:    10:29:02 12/01/2009 
-- Design Name: 
-- Module Name:    Cache_test_ReadAndWrite 
-- Project Name: 	 Cache
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- in questo file di test si vuole verificare il corretto funzionamento del meccanismo MESI in caso 
-- di eventuale scritture in memoria
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.CacheLibrary.all;
use work.Global.all;
 
ENTITY Cache_test_ReadAndWrite IS
END Cache_test_ReadAndWrite;

  ARCHITECTURE behavior OF Cache_test_ReadAndWrite IS 

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
		
		ch_wtwb <= '0';
		
		--significato bit:T:tag,I:index
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		--
		--prima fase LETTURE: 
		--	vengono richieste dei dati presenti in diversi blocchi di memoria quindi:
		-- occupo la prima via degli indici (0) (1)
		wait for 10 ns; 
		ch_baddr <= "00000000000000000000000000000000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000000100100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		
		--seconda fase: SCRITTURE
		--caso 1: il dato è contenuto in un blocco già presente in cache,viene aggiornato il blocco e lo stato(-> MESI_M(11))
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000000101100";
		ch_bdata_in <= "11111111111111111111111111111111";
		ch_memwr <= '1';
		wait for 10 ns;
		ch_memwr <= '0';
		wait for 20 ns;
		--caso 2: dato contenuto in blocco non ancora presente in cache, il dato verrà caricato dalla RAM e a quel punto
		--			il dato verra modificato e il blocco posto in stato MESI_M(11)
		ch_baddr <= "00000000000000000000000100000000";
		ch_bdata_in <= "11111111111110001110011010010111";
		ch_memwr <= '1';
		wait for 10 ns;
		ch_memwr <= '0';
		ch_memwr <= '0';
		wait for 20 ns;
		--terza fase LETTURE: 
		
		--           rileggo i dati  scritti per verificre l'effettiva scrittura in cache
		ch_baddr <= "00000000000000000000000000101100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000100000000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		
		wait;
		
		
		wait;
   end process;

END;