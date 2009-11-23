
-- VHDL Instantiation Created from source file Fetch_Stage.vhd -- 12:52:03 11/03/2009
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT Fetch_Stage
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		force_jump : IN std_logic;
		pc_for_jump : IN std_logic_vector(29 downto 0);          
		instruction : OUT std_logic_vector(31 downto 0);
		pc : OUT std_logic_vector(29 downto 0)
		);
	END COMPONENT;

	Inst_Fetch_Stage: Fetch_Stage PORT MAP(
		clk => ,
		reset => ,
		force_jump => ,
		pc_for_jump => ,
		instruction => ,
		pc => 
	);


