-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.std_logic_unsigned.ALL;
  USE ieee.numeric_std.ALL;
  USE work.BlockRamLibrary.all;
	
  ENTITY BlockRam_test IS
  END BlockRam_test;

  ARCHITECTURE behavior OF BlockRam_test IS 

  --- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BlockRam_cmp
    port(
		reset : in std_logic;
		addr : in std_logic_vector (ADDR_BIT-1 downto 0);  -- address Input
		clk : in std_logic;
		br_clk : in std_logic;
		bdata_in : in mem_line;
		memrd : in std_logic;                                 
		memwr : in std_logic; 
		en : in std_logic;			-- Ram Enable
		bdata_out : out mem_line;
		addr_m : out std_logic_vector (ADDR_BIT-1 downto 0);
		ready : out	std_logic
);

    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal addr : std_logic_vector(ADDR_BIT-1 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal br_clk : std_logic := '0';
   signal bdata_in : mem_line;
   signal memrd : std_logic := '0';
   signal memwr : std_logic := '0';
   signal en : std_logic := '0';

 	--Outputs
   signal bdata_out : mem_line;
   signal ready : std_logic;
	signal addr_m: std_logic_vector (ADDR_BIT-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 100ns;
   constant br_clk_period : time := 5ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BlockRam_cmp PORT MAP (
          reset => reset,
          addr => addr,
			 addr_m => addr_m,
          clk => clk,
          br_clk => br_clk,
          bdata_in => bdata_in,
          bdata_out => bdata_out,
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
 
   br_clk_process :process
   begin
		br_clk <= '0';
		wait for br_clk_period/2;
		br_clk <= '1';
		wait for br_clk_period/2;
   end process;
	
	
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 10ns;	
		-- insert stimulus here 
		en<='1';
      wait for clk_period;
		--scrittura linea in memoria
		memwr <= '1';
		memrd <= '0';
		addr <= "00000000000";
		bdata_in <= (0=>"00000001",1=>"00000010",2=>"00000011", 3=>"00000100", 4=>"00000101", 5=>"00000110", 6=>"00000111", 7=>"00001000");
      wait for clk_period;
		memwr <= '0';
		memrd <= '0';
		en <= '0';
		
		wait for clk_period;
		en <= '1';
		--lettura della linea di memoria scritto in precedenza
		wait for clk_period;
		memwr <= '0';
		memrd <= '1';
		addr <= "00000000000";
		bdata_in <= (others => "UUUUUUUU");
		wait for clk_period*3;
		en <= '0';
		memwr <= '0';
		memrd <= '0';
      wait;
   end process;

  END;
