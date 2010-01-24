

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.CacheLibrary.all;
use work.Global.all;
 
ENTITY Cache_test_ReadAndReplacement IS
END Cache_test_ReadAndReplacement;

  ARCHITECTURE behavior OF Cache_test_ReadAndReplacement IS 

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
		--prima fase: 
		--	vengono richieste dei dati presenti in diversi blocchi di memoria quindi:
		-- occupo la prima via di ogni indice (0) (1) (2) (3)
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
		ch_baddr <= "00000000000000000000000001000000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000001100000";
		ch_memrd <= '1';
		wait for 10 ns;
		
		--seconda fase: occupo la seconda via di ogni indice 
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000100100100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 10 ns; 
		ch_baddr <= "00000000000000000000000100000000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000101000000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000101100000";
		ch_memrd <= '1';
		wait for 10 ns;
		
		-- a questo punto la cache è piena se richiederò un dato presente in cache avrò un hit(in questo caso nel indice [1] e via [0]):
		--	che implica il portare il contatore della via contenete il blocco con il dato al valore 0
		-- mentre l'altra via andrà allo stato 1,
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000100100100";
		ch_memrd <= '1';
		wait for 10 ns;
		-- se faccio quindi la richiestà di un dato presente in un blocco avente stesso indice,
		-- verrà rimpiazzata la via con contatore al valore 1.
		ch_memrd <= '0';
		wait for 20 ns;
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000100001100100100";
		ch_memrd <= '1';
		wait for 10 ns;
		--	problemi:
		-- oltre l'indirizzo -->"0000000000000000011111111xxxxxxx" out of bound exception
		--problema nella gestione del TAG
		wait;
   end process;

END;