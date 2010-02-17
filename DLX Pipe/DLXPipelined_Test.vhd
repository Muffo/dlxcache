--------------------------------------------------------------------------------------
-- Dettagli relativi alla implementazione del DLX Pipelined in VHDL in:
-- 
-- "Progetto di Processore Pipelined in VHDL", Andrea Bucaletti, AA 2008/09
-- "Gestione su scheda FPGA di processore pipelined", Domenico Di Carlo, AA 2008/09
--
--------------------------------------------------------------------------------------

 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Global.all;
use work.Float_32.all;
use work.CacheLibrary.all;

entity DLXPipelined_Test is
end DLXPipelined_Test;

architecture Test of DLXPipelined_Test is
	component DLXPipelined
	port (
		-- clock e reset
		clk: in std_logic;
		reset: in std_logic;
		
		-- pc lungo la pipe
		pc_fetch: inout std_logic_vector(PC_BITS-1 downto 0);
		pc_decode: inout std_logic_vector(PC_BITS-1 downto 0);
		pc_execute: inout std_logic_vector(PC_BITS-1 downto 0);
		pc_memory: inout std_logic_vector(PC_BITS-1 downto 0);
		pc_writeback: inout std_logic_vector(PC_BITS-1 downto 0);
		
		-- istruzioni lungo la pipe
		instruction_fetch: inout std_logic_vector(PARALLELISM-1 downto 0);
		instruction_decode: inout std_logic_vector(PARALLELISM-1 downto 0);
		instruction_execute: inout std_logic_vector(PARALLELISM-1 downto 0);		
		instruction_memory: inout std_logic_vector(PARALLELISM-1 downto 0);		
		instruction_writeback: inout std_logic_vector(PARALLELISM-1 downto 0);
		
		-- stadio di fetch
		
		-- stadio di decode
		dec_instruction_format: inout std_logic_vector(2 downto 0);
		dec_register_a: inout std_logic_vector(PARALLELISM-1 downto 0);
		dec_register_b: inout std_logic_vector(PARALLELISM-1 downto 0);
		
		-- stadio di execute
		exe_instruction_format: inout std_logic_vector(2 downto 0);
		exe_alu_exit: inout std_logic_vector(PARALLELISM-1 downto 0);
		exe_register_b: inout std_logic_vector(PARALLELISM-1 downto 0);
		exe_force_jump: inout std_logic;
		exe_pc_for_jump: inout std_logic_vector(PC_BITS-1 downto 0);
		
		-- stadio di memory
		mem_instruction_format: inout std_logic_vector(2 downto 0);
		mem_data_out: inout std_logic_vector(PARALLELISM-1 downto 0);
		mem_load_memory_data_register: inout std_logic_vector(PARALLELISM-1 downto 0); 
		mem_store_memory_data_register: inout std_logic_vector(PARALLELISM-1 downto 0); 
		mem_memory_address_register: inout std_logic_vector(PARALLELISM-1 downto 0); 
		mem_dest_register: inout std_logic_vector(4 downto 0); -- numero rd per forwarding unit
		mem_dest_register_data: inout std_logic_vector(PARALLELISM-1 downto 0); -- dati registro destinazione per 
																										-- forwarding unit
		
		-- cache
		cache_memrd: inout std_logic;
		cache_memwr: inout std_logic;
		cache_ready: inout std_logic;
		cache_hit: out std_logic;
		cache_hitm: out std_logic;
		cache_inv: in std_logic;
		cache_eads: in std_logic;
		cache_wtwb: in std_logic;
		cache_snoop_addr: in std_logic_vector (31 downto 0);
		debug_cache: out cache_type;

		-- ram
      ram_address : inout std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
      ram_data_in: inout data_line;
		ram_data_out: inout data_line;
      ram_we: inout std_logic;
      ram_oe: inout std_logic;
		ram_ready: inout std_logic;
		ram_debug: out RAM (0 to RAM_DEPTH-1);
		  
		-- stadio di writeback
		wb_dest_register: inout std_logic_vector(4 downto 0);
		wb_dest_register_data: inout std_logic_vector(PARALLELISM-1 downto 0);
		wb_dest_register_type: inout std_logic;
		wb_instruction_format: inout std_logic_vector(2 downto 0);
		
		-- uscite di debug
		register_file_debug: out register_file_type;
		fp_register_file_debug: out register_file_type
	);
	end component;
	
	signal clk: std_logic := '0';
	signal reset: std_logic := '0';
	
	signal pc_fetch: std_logic_vector(PC_BITS-1 downto 0);
	signal pc_decode: std_logic_vector(PC_BITS-1 downto 0);
	signal pc_execute: std_logic_vector(PC_BITS-1 downto 0);
	signal pc_memory: std_logic_vector(PC_BITS-1 downto 0);
	signal pc_writeback: std_logic_vector(PC_BITS-1 downto 0);
	
	signal instruction_fetch: std_logic_vector(PARALLELISM-1 downto 0);
	signal instruction_decode: std_logic_vector(PARALLELISM-1 downto 0);
	signal instruction_execute: std_logic_vector(PARALLELISM-1 downto 0);
	signal instruction_memory: std_logic_vector(PARALLELISM-1 downto 0);
	signal instruction_writeback: std_logic_vector(PARALLELISM-1 downto 0);
	
	signal dec_instruction_format: std_logic_vector(2 downto 0);
	signal dec_register_a: std_logic_vector(PARALLELISM-1 downto 0);
	signal dec_register_b: std_logic_vector(PARALLELISM-1 downto 0);
	
	signal exe_instruction_format: std_logic_vector(2 downto 0);
	signal exe_alu_exit: std_logic_vector(PARALLELISM-1 downto 0);
	signal exe_register_b: std_logic_vector(PARALLELISM-1 downto 0);
	signal exe_force_jump: std_logic;
	signal exe_pc_for_jump: std_logic_vector(PC_BITS-1 downto 0);
	
	signal mem_instruction_format: std_logic_vector(2 downto 0);
	signal mem_data_out: std_logic_vector(PARALLELISM-1 downto 0);
	signal mem_dest_register: std_logic_vector(4 downto 0);
	signal mem_dest_register_data: std_logic_vector(PARALLELISM-1 downto 0); 
	signal mem_load_memory_data_register: std_logic_vector(PARALLELISM-1 downto 0); 
	signal mem_store_memory_data_register: std_logic_vector(PARALLELISM-1 downto 0); 
	signal mem_memory_address_register: std_logic_vector(PARALLELISM-1 downto 0); 

	signal cache_ready: std_logic;
   signal cache_hit: std_logic;
	signal cache_hitm: std_logic;
	signal cache_memrd: std_logic;
   signal cache_memwr: std_logic;
	signal debug_cache: cache_type;
   signal cache_inv: std_logic:= '0';
   signal cache_eads: std_logic:= '0';
   signal cache_snoop_addr: std_logic_vector (31 downto 0);
	signal cache_wtwb: std_logic:= '0';
	
	-- ram
   signal ram_address: std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);  -- address Input
   signal ram_data_in: data_line;
	signal ram_data_out: data_line;
   signal ram_we: std_logic;                                 -- Write Enable/Read Enable
   signal ram_oe: std_logic;                                 -- Output Enable
	signal ram_ready: std_logic;
	signal ram_debug: RAM (0 to RAM_DEPTH-1);
	
	signal wb_dest_register: std_logic_vector(4 downto 0);
	signal wb_dest_register_data: std_logic_vector(PARALLELISM-1 downto 0);
	signal wb_dest_register_type: std_logic;
	signal wb_instruction_format: std_logic_vector(2 downto 0);
	
	signal register_file_debug: register_file_type;
	signal fp_register_file_debug: register_file_type;
	
	-- segnali HR
	
	type real_array is array(integer range <>) of real;
	signal fp_register_file_debug_HR: real_array(fp_register_file_debug'low to fp_register_file_debug'high); 
	
	begin
		DLXPipelined_uut: DLXPipelined
			port map (
				clk => clk,
				reset => reset,
				
				pc_fetch => pc_fetch,
				pc_decode => pc_decode,
				pc_execute => pc_execute,
				pc_memory => pc_memory,
				pc_writeback => pc_writeback,
				
				instruction_fetch => instruction_fetch,
				instruction_decode => instruction_decode,
				instruction_execute => instruction_execute,
				instruction_memory => instruction_memory,
				instruction_writeback => instruction_writeback,
				
				dec_instruction_format => dec_instruction_format,
				dec_register_a => dec_register_a,
				dec_register_b => dec_register_b,
				
				exe_instruction_format => exe_instruction_format,
				exe_alu_exit => exe_alu_exit,
				exe_register_b => exe_register_b,				
				exe_force_jump => exe_force_jump,
				exe_pc_for_jump => exe_pc_for_jump,
				
				mem_instruction_format => mem_instruction_format,
				mem_data_out => mem_data_out,
				mem_dest_register => mem_dest_register,
				mem_dest_register_data => mem_dest_register_data,
				mem_load_memory_data_register => mem_load_memory_data_register,
				mem_store_memory_data_register => mem_store_memory_data_register,
				mem_memory_address_register => mem_memory_address_register,
				
				cache_memrd => cache_memrd,
				cache_memwr => cache_memwr,
				cache_ready => cache_ready,
				cache_hit => cache_hit,
				cache_hitm => cache_hitm,
				cache_inv => cache_inv,
				cache_eads => cache_eads,
				cache_wtwb => cache_wtwb,
				cache_snoop_addr => cache_snoop_addr,
				debug_cache => debug_cache,
	
				ram_address => ram_address,
				ram_data_in => ram_data_in,
				ram_data_out => ram_data_out,
				ram_we => ram_we,
				ram_oe => ram_oe,
				ram_ready => ram_ready,
				ram_debug => ram_debug,
				
				wb_dest_register => wb_dest_register,
				wb_dest_register_data => wb_dest_register_data,
				wb_dest_register_type => wb_dest_register_type,
				wb_instruction_format => wb_instruction_format,
				
				register_file_debug => register_file_debug,
				fp_register_file_debug => fp_register_file_debug
			);
		
		clk_process: process begin
			clk <= '0';
			wait for TIME_UNIT/2;
			clk <= '1';
			wait for TIME_UNIT/2;
		end process;
		
		stimulus_process: process begin
			reset <= '1';
			wait for TIME_UNIT*2.25;
			reset <= '0';
			wait;
		end process;
		
		signals: process(fp_register_file_debug) begin
			for i in fp_register_file_debug_HR'low to fp_register_file_debug_HR'high loop
				fp_register_file_debug_HR(i) <= to_real(fp_register_file_debug(i));
			end loop;
		end process;
		
	end Test;
