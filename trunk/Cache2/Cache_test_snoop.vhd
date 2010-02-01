
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
-- di eventuali snoop
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.CacheLibrary.all;
use work.Global.all;
 
ENTITY Cache_test_snoop IS
END Cache_test_snoop;
 
ARCHITECTURE behavior OF Cache_test_snoop IS 
 
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
			ch_flush: in STD_LOGIC;
			-- segnali di comunicazione con la RAM
			ram_address : out    std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
			ram_data_out: out    data_line;
			ram_data_in : in    data_line;
			ram_we      : out    std_logic;
			ram_oe      : out    std_logic;
			ram_ready	: in	 std_logic;
			-- segnali di debug
			ch_debug_cache: out cache_type(0 to 2**INDEX_BIT - 1)
        );
    END COMPONENT;
   
	component ram_cmp is
	generic(
		ADDR_WIDTH: integer
	);
	port (
		reset : in std_logic;
		address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);  -- address Input
		data_in: in data_line;
		data_out: out data_line;
		we      :in    std_logic;                                 -- Write Enable/Read Enable
		oe      :in    std_logic;                                 -- Output Enable
		ready	 :out	  std_logic
	);
	end component;
	
   --Inputs
   signal ch_memrd : std_logic := '0';
   signal ch_memwr : std_logic := '0';
   signal ch_baddr : std_logic_vector(31 downto 0) := (others => '0');
   signal ch_reset : std_logic := '0';
   signal ch_inv : std_logic := '0';
   signal ch_eads : std_logic := '0';
   signal ch_flush : std_logic := '0';
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
	signal ch_debug_cache : cache_type (0 to 2**INDEX_BIT - 1);
	signal ram_address : std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
	signal ram_data_out: data_line;
	signal ram_we      : std_logic := '0';
	signal ram_oe      : std_logic := '0';
 
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
		ch_flush => ch_flush,
		ch_debug_cache => ch_debug_cache,
		ram_address => ram_address,
		ram_data_out => ram_data_out,
		ram_data_in => ram_data_in,
		ram_we => ram_we,
		ram_oe => ram_oe,
		ram_ready => ram_ready
	); 
		  
	ram_inst: Ram_cmp 
	generic map(ADDR_WIDTH => 10)
	port map (
		reset => ch_reset,
		address => ram_address(9 downto 0),
		data_in => ram_data_out,
		data_out => ram_data_in,
		we => ram_we,
		oe => ram_oe,
		ready => ram_ready
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
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		ch_baddr <= "00000000000000000000000000100100";
		ch_memrd <= '1';
		wait for 10 ns;
		ch_memrd <= '0';
		wait for 20 ns;
		
		--seconda fase: SCRITTURE
		--il dato � contenuto in un blocco gi� presente in cache,viene aggiornato il blocco e lo stato(-> MESI_M(11))
		wait for 20 ns;
		ch_baddr <= "00000000000000000000000000101100";
		ch_bdata_in <= "11111111111111111111111111111111";
		ch_memwr <= '1';
		wait for 10 ns;
		ch_memwr <= '0';
		ch_eads<='0';
		wait for 20 ns;
		
		
		
		
		--terza fase snoop: 
		
		--caso 1: blocco non presente in cache-> nessuna modifica in cache
		ch_baddr <= "00000000000000001111110000001100";
		ch_eads<='1';
		wait for 10 ns;
		ch_eads<='0';
		wait for 20 ns;
		
		--caso 2: blocco presente in cache in MESI_E(10)-> si porta in MESI_S (01)
		ch_baddr <= "00000000000000000000000000000000";
		ch_eads<='1';
		wait for 10 ns;
		ch_eads<='0';
		wait for 20 ns;
		--caso 3: blocco presente in stato MESI_M(11) -> scrittura in livello superiore e si porta in MESI_S (01)
		ch_baddr <= "00000000000000000000000000101100";
		ch_eads<='1';
		wait for 10 ns;
		ch_eads<='0';
		wait for 20 ns;
		
		--quarta fase scrittura su blocco in stato MESI_S-> scrittura su livello superiore(invalidazione..) e si porta blocco in stato MESI_E
		ch_baddr <= "00000000000000000000000000000000";
		ch_bdata_in <= "11000111111111100011111111111111";
		ch_memwr <= '1';
		wait for 10 ns;
		ch_memwr <= '0';
		wait for 20 ns;
		
		wait;
   end process;

END;