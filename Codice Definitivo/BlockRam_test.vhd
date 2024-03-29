-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.std_logic_unsigned.ALL;
  USE ieee.numeric_std.ALL;
  USE work.BlockRamLibrary.all;
  USE work.CacheLibrary.all;
	
  ENTITY BlockRam_test IS
  END BlockRam_test;

  ARCHITECTURE behavior OF BlockRam_test IS 

  --- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BlockRam_cmp
    port(
		addr : in std_logic_vector (ADDR_BIT-1 downto 0);  -- address Input
		clk : in std_logic;
		bdata_in : in data_line;
		memrd : in std_logic;                                 
		memwr : in std_logic; 
		en : in std_logic;			-- Ram Enable
		bdata_out : out data_line;
		outd: out std_logic_vector (DATA_WIDTH-1 downto 0);
		addr_m : out std_logic_vector (ADDR_BIT-1 downto 0);
		ready : out	std_logic
);

    END COMPONENT;
    

   --Inputs
   signal addr : std_logic_vector(ADDR_BIT-1 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   --signal br_clk : std_logic := '0';
   signal bdata_in : data_line;
   signal memrd : std_logic := '0';
   signal memwr : std_logic := '0';
   signal en : std_logic := '0';

 	--Outputs
   signal bdata_out : data_line;
   signal ready : std_logic;
	signal addr_m: std_logic_vector (ADDR_BIT-1 downto 0);
	signal br_out: std_logic_vector (DATA_WIDTH-1 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10ns;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BlockRam_cmp PORT MAP (
          addr => addr,
			 addr_m => addr_m,
          clk => clk,
          bdata_in => bdata_in,
          bdata_out => bdata_out,
			 outd => br_out,
          memrd => memrd,
          memwr => memwr,
          en => en,
          ready => ready
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
      wait for 50ps;
		-- insert stimulus here 
		en<='1';
      wait for clk_period;
		--scrittura linea in memoria
		memwr <= '1';
		memrd <= '0';
		addr <= "00000000000";
		bdata_in <= (0=>"00000001",1=>"00000010",2=>"00000011", 3=>"00000100", 4=>"00000101", 5=>"00000110", 6=>"00000111", 7=>"00001000", others => "00000000");
      
		wait for clk_period*(2**OFFSET_BIT)*2 + clk_period;
		memwr <= '0';
		memrd <= '0';
		en <= '0';
		
		wait for clk_period*5;
		en <= '1';
		--lettura della linea di memoria scritto in precedenza
		
		wait for clk_period;
		memwr <= '0';
		memrd <= '1';
		addr <= "00000000000";
		bdata_in <= (others => "UUUUUUUU");
		wait for clk_period*(2**OFFSET_BIT)*2 + clk_period;
		en <= '0';
		memwr <= '0';
		memrd <= '0';
      wait;
   end process;

  END;
