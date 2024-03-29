----------------------------------------------------------------------------------
-- Company: Gruppo 2
-- Engineer: Grandi, Malaguti, Mattetti, Morlini, Ricci
-- 
-- Create Date:    10:29:02 12/01/2009 
-- Design Name: 
-- Module Name:    Cache_test_ReadAndReplacement
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

-- In questo file di test si vuole verificare il corretto funzinamento della politica 
-- di rimpiazzamento mediante contatori.
----------------------------------------------------------------------------------
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
         -- segnali di comunicazione con il DLX
			ch_memrd: in  STD_LOGIC;
			ch_memwr: in  STD_LOGIC;
			ch_baddr: in  STD_LOGIC_VECTOR (31 downto 0);
			ch_bdata_in: in  STD_LOGIC_VECTOR (31 downto 0);
			ch_bdata_out: out  STD_LOGIC_VECTOR (31 downto 0);
			ch_reset: in  STD_LOGIC;
			ch_ready: out  STD_LOGIC;
			-- segnali di comunicazione con il controllore di memoria
			ch_hit: out STD_LOGIC;
			ch_hitm: out STD_LOGIC;
			ch_inv: in STD_LOGIC;
			ch_eads: in STD_LOGIC;
			ch_wtwb: in STD_LOGIC;
			ch_snoop_addr: in std_logic_vector (31 downto 0);
			-- segnali di comunicazione con la RAM
			ram_address : out    std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
			ram_data_out: out    data_line;
			ram_data_in : in    data_line;
			ram_we      : out    std_logic;
			ram_oe      : out    std_logic;
			ram_ready	: in	 std_logic;
			-- segnali di debug
			ch_debug_cache: out cache_type
        );
    END COMPONENT;
   
	component ram_cmp is
	port (
		reset : in std_logic;
		address :in    std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);  -- address Input
		data_in: in data_line;
		data_out: out data_line;
		we      :in    std_logic;                                 -- Write Enable/Read Enable
		oe      :in    std_logic;                                 -- Output Enable
		ready	 :out	  std_logic;
		ram_debug: out RAM (0 to RAM_DEPTH-1)
	);
	end component;
	
   --Inputs
   signal ch_memrd : std_logic := '0';
   signal ch_memwr : std_logic := '0';
   signal ch_baddr : std_logic_vector(31 downto 0) := (others => '0');
   signal ch_reset : std_logic := '0';
   signal ch_inv : std_logic := '0';
   signal ch_eads : std_logic := '0';
	signal ch_snoop_addr: std_logic_vector (31 downto 0);
	signal ch_wtwb : std_logic := '0';
	signal ram_data_in : data_line;
	signal ram_ready	: std_logic := '0';

	--BiDirs
   signal ch_bdata_in : std_logic_vector(31 downto 0);
	signal ch_bdata_out : std_logic_vector(31 downto 0);
 	--Outputs
   signal ch_ready : std_logic := '0';
   signal ch_hit : std_logic := '0';
   signal ch_hitm : std_logic := '0';
	signal ch_debug_cache : cache_type ;
	signal ram_address : std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
	signal ram_data_out: data_line;
	signal ram_we      : std_logic := '0';
	signal ram_oe      : std_logic := '0';
	signal ram_debug: RAM (0 to RAM_DEPTH-1);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   cache_inst: Cache_cmp PORT MAP (
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
		ch_snoop_addr => ch_snoop_addr,
		ch_debug_cache => ch_debug_cache,
		ram_address => ram_address,
		ram_data_out => ram_data_out,
		ram_data_in => ram_data_in,
		ram_we => ram_we,
		ram_oe => ram_oe,
		ram_ready => ram_ready
	); 
		  
	ram_inst: Ram_cmp 
	port map (
		reset => ch_reset,
		address => ram_address,
		data_in => ram_data_out,
		data_out => ram_data_in,
		we => ram_we,
		oe => ram_oe,
		ready => ram_ready,
		ram_debug => ram_debug
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
		
		-- occupo la seconda via di ogni indice 
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000100100100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns; 
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
		ch_memrd <= '0';
		wait for 20 ns;
		
		-- seconda fase: INVALIDAZIONE di un blocco:
		ch_snoop_addr <= "00000000000000000000000101000000";
		ch_eads<='1';
		ch_inv<='1';
		wait for 10 ns;
		
		-- terza fase: RIMPIAZZAMENTO:
		
		-- a questo punto la cache � piena se richieder� un dato presente in cache avr� un hit(in questo caso nel indice [1] e via [0]):
		--	che implica il portare il contatore della via contenete il blocco con il dato al valore 0
		-- mentre l'altra via andr� allo stato 1,
		
		--caso 1: una lettura di un blocco presente e poi di un blocco non presente(RIMPIAZZAMENTO):
		ch_eads<='0';
		ch_inv <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000000100100";
		ch_memrd <= '1';
		wait for 10 ns;
		-- se faccio quindi la richiest� di un dato presente in un blocco avente stesso indice ma non presente in cache(miss),
		-- verr� rimpiazzata la via con contatore al valore 1 in questo caso quella con TAG="0".
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000110100100";
		ch_memrd <= '1';
		wait for 10 ns;
		
		--caso 2: se richiedo un dato contenuto in un blocco non presente in cache 
		-- ma nel quale set c'� una via invalidata
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000001101000000";
		ch_memrd <= '1';
		wait for 10 ns;
		
		--caso 3: pi� letture di blocchi presenti per verificare il funzionamento dei contatori: 
		
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000100100100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000001000000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <=  "00000000000000000000000001100000";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000000000000";
		ch_memrd <= '1';
		wait for 10 ns;
		-- e poi di blocchi non presenti: se faccio quindi la richiest� di un dato presente in un blocco avente stesso indice ma non presente in cache(miss),
		-- verr� rimpiazzata la via con contatore al valore 1, che dovrebbe essere quella con TAG="0".
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000011100100100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		ch_baddr <= "00000000000000000000111111111100";
		ch_memrd <= '1';
		wait for 10 ns;
		
		
		
		
		-- osservazioni:
		--1) gli ultimi due bit dell'offset si presumono sempre a 0 altrimenti avrei una lettura non allineate
		--		a lato pratico si pu� avere un out of bound exception nel caso volgia dati a indirizzi di offset maggiori di 28.
		-- 2) oltre l'indirizzo -->"0000000000000000000011111xxxxxxx" out of bound exception (0 to 127)
		--		in quanto la RAM nel nostro caso ha dimensione limitata a 128 linee(128*32Byte=4KB).
		wait;
   end process;

END;