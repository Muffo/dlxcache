-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.std_logic_unsigned.ALL;
  USE ieee.numeric_std.ALL;
  USE work.BlockRamLibrary.all;
  USE work.Global.all;
  USE work.CacheLibrary.all;
	
  ENTITY BlockRam_test IS
  END BlockRam_test;

  ARCHITECTURE behavior OF BlockRam_test IS 

  --- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BlockRam_cmp
    port(
		reset : in std_logic;
		addr : in std_logic_vector (ADDR_BIT-1 downto 0);  -- address Input
		clk : in std_logic;
		bdata_in : in data_line;
		memrd : in std_logic;                                 
		memwr : in std_logic; 
		en : in std_logic;			-- Ram Enable
		bdata_out : out data_line;
		addr_m : out std_logic_vector (ADDR_BIT-1 downto 0);
		ready : out	std_logic
);

    END COMPONENT;
	 
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
	signal ch_debug_cache : cache_type;
	signal ram_address : std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
	signal ram_data_out: data_line;
	signal ram_we      : std_logic := '0';
	signal ram_oe      : std_logic := '0';
	signal ram_debug: RAM (0 to 2048-1);

   --Inputs
   signal clk : std_logic := '0';
   --signal br_clk : std_logic := '0';
   signal en : std_logic := '0';

 	--Outputs
	signal addr_m: std_logic_vector (ADDR_BIT-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 30 ns;

 
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
	
	-- Instantiate the Unit Under Test (UUT)
   uut: BlockRam_cmp PORT MAP (
          reset => ch_reset,
          addr => ram_address(ADDR_BIT-1 downto 0),
			 addr_m => addr_m,
          clk => clk,
          bdata_in => ram_data_out,
          bdata_out => ram_data_in,
          memrd => ram_oe,
          memwr => ram_we,
          en => en,
          ready => ram_ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process; 
	
   -- Stimulus process
   stim_proc: process
   begin				
		wait for 20 ns;
		ch_reset <= '1';
		en <= '1';
      wait for 20 ns;
		ch_reset <= '0';
		
		ch_wtwb <= '0';
		
		--significato bit:T:tag,I:index
		--           TTTTTTTTTTTTTTTTTTTTTTTTTiiOOOOO
		--
		--prima fase LETTURE: 
		--caso wb) carico blocchi in modalità write back
		--	vengono richieste dei dati presenti in diversi blocchi di memoria quindi:
		-- occupo la prima via degli indici (0) (1)
		wait for 20 ns; 
		ch_baddr <= "00000000000000000000000000000000";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_baddr <= "00000000000000000000000000100100";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		ch_wtwb <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		----caso wt) carico blocchi in modalità write through(MESI_S)
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_baddr <= "00000000000000000000000001000100";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		ch_wtwb <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		
		--seconda fase: SCRITTURE
		--caso 1: dato contenuto in blocco non ancora presente in cache, il dato verrà caricato dalla RAM e a quel punto
		--			il dato verra modificato e il blocco posto in stato MESI_M(11)
		ch_baddr <= "00000000000000000000000100000110";
		ch_bdata_in <= "11111111111110001110011010010111";
		ch_memwr <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memwr <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		--caso 2: il dato è contenuto in un blocco già presente in cache,viene aggiornato il blocco e lo stato(-> MESI_M(11))
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_baddr <= "00000000000000000000000000100000";
		ch_bdata_in <= "11111111111111111111111111111111";
		ch_memwr <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memwr <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		
		--caso 3: dato contenuto in blocco in modalità write through, devo riscriverlo sul livello superiore(RAM) e mi pongo in MESI_E
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_baddr <= "00000000000000000000000001000110";
		ch_bdata_in <= "11111111111111111111111111111111";
		ch_memwr <= '1';
	--	ch_wtwb <= '1'; 	--(e mi mantengo in stato MESI_S)
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memwr <= '0';
	--	ch_wtwb <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		
		--quarta fase LETTURE: 
		
		-- caso 1:   rileggo i dati  scritti per verificre l'effettiva scrittura in cache
		ch_baddr <= "00000000000000000000000000100000";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_baddr <= "00000000000000000000000100000110";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		-- caso 2: Letture dato salvato in ram:
		--oblligo a far salvare in memoria blocco modificato
		ch_baddr <= "00000000000000000000000100101100";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_baddr <= "00000000000000000000000110101100";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		--ricarico blocco precendetemente modificato
		ch_baddr <= "00000000000000000000000000100000";
		ch_memrd <= '1';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		ch_memrd <= '0';
		wait for clk_period*(nbyte_line)*2 + clk_period;
		wait;
   end process;

  END;
