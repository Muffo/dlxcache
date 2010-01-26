--------------------------------------------------------------------------------------
-- Dettagli relativi alla implementazione del DLX Pipelined in VHDL in:
-- 
-- "Progetto di Processore Pipelined in VHDL", Andrea Bucaletti, AA 2008/09
-- "Gestione su scheda FPGA di processore pipelined", Domenico Di Carlo, AA 2008/09
--
--------------------------------------------------------------------------------------

 

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use work.Global.all;
use work.CacheLibrary.all;
use work.Float_32.all;

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
		mem_dest_register: inout std_logic_vector(4 downto 0); -- numero rd per forwarding unit
		mem_dest_register_data: inout std_logic_vector(PARALLELISM-1 downto 0); -- dati registro destinazione per 
																										-- forwarding unit
		-- cache
		cache_memrd: inout std_logic;
		cache_memwr: inout std_logic;
		cache_ready: inout std_logic;
		cache_baddr: inout std_logic_vector (31 downto 0);  -- indirizzi allineati (ultimi due bit non emessi)
		cache_bdata_in: inout std_logic_vector (31 downto 0);
		cache_bdata_out: inout std_logic_vector (31 downto 0);
		cache_reset: in std_logic;
		cache_hit: out std_logic;
		cache_hitm: out std_logic;
		cache_inv: in std_logic;
		cache_eads: in std_logic;
		cache_wtwb: in std_logic;
		cache_flush: in std_logic;
		debug_cache: out cache_type(0 to 2**INDEX_BIT - 1);
		
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
	
	signal clk: std_logic:= '0';
	signal reset: std_logic:= '0';
	
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
	
	signal cache_memrd: std_logic;
   signal cache_memwr: std_logic;
	signal cache_ready: std_logic;
   signal cache_baddr: std_logic_vector (31 downto 0); 
   signal cache_bdata_in: std_logic_vector (31 downto 0);
   signal cache_bdata_out: std_logic_vector (31 downto 0);
   signal cache_reset: std_logic;
   signal cache_hit: std_logic;
	signal cache_hitm: std_logic;
	signal cache_inv: std_logic;
	signal cache_eads: std_logic;
	signal cache_wtwb: std_logic;
	signal cache_flush: std_logic;
	signal debug_cache: cache_type(0 to 2**INDEX_BIT - 1);
	
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
				
				cache_memrd => cache_memrd,
				cache_memwr => cache_memwr,
				cache_baddr => cache_baddr,
				cache_bdata_in => cache_bdata_in,
				cache_bdata_out => cache_bdata_out,
				cache_ready => cache_ready,
				cache_reset => cache_reset,
				cache_hit => cache_hit,
				cache_hitm => cache_hitm,
				cache_inv => cache_inv,
				cache_eads => cache_eads,
				cache_wtwb => cache_wtwb,
				cache_flush => cache_flush,
				debug_cache => debug_cache,
					
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
