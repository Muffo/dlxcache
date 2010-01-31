
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CacheLibrary.all;
use work.Global.all;


entity DLXPipelined is
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
		mem_load_memory_data_register: inout std_logic_vector (PARALLELISM-1 downto 0);
		mem_memory_address_register: inout std_logic_vector (PARALLELISM-1 downto 0);
		mem_store_memory_data_register: inout std_logic_vector(PARALLELISM-1 downto 0);
		mem_dest_register: inout std_logic_vector(4 downto 0); -- numero rd per forwarding unit
		mem_dest_register_data: inout std_logic_vector(PARALLELISM-1 downto 0); -- dati registro destinazione per 
							
		-- cache
		cache_memrd: inout std_logic;
		cache_memwr: inout std_logic;
		cache_ready: inout std_logic;
		cache_hit: out std_logic;
		cache_hitm: out std_logic;
		cache_inv: in std_logic;
		cache_eads: in std_logic;
		cache_wtwb: in std_logic;
		cache_flush: in std_logic;
		debug_cache: out cache_type(0 to 2**INDEX_BIT - 1);	

		-- ram
		ram_bdata_in: inout data_line;
		ram_bdata_out: inout data_line;
		ram_baddr: inout std_logic_vector (PARALLELISM - 1 downto OFFSET_BIT);
      ram_write: inout std_logic;
		ram_read: inout std_logic;
      ram_ready: inout std_logic;
		debug_ram: out work.CacheLibrary.ram_type;
		
		-- stadio di writeback
		wb_instruction_format: inout std_logic_vector(2 downto 0);
		wb_dest_register: inout std_logic_vector(4 downto 0);
		wb_dest_register_data: inout std_logic_vector(PARALLELISM-1 downto 0);
		wb_dest_register_type: inout std_logic;
		
		-- uscite di debug
		register_file_debug: out register_file_type;
		fp_register_file_debug: out register_file_type
	);
end DLXPipelined;

architecture Arch1_DLXPipelined of DLXPipelined is
	component Fetch_Stage
		port (
			-- uscite standard
			clk: in std_logic;
			reset: in std_logic;
			force_jump: in std_logic;
			pc_for_jump: in std_logic_vector(PC_BITS-1 downto 0);
			instruction: out std_logic_vector(PARALLELISM-1 downto 0);
			pc: out std_logic_vector(PC_BITS-1 downto 0)
		);	
	end component;
	
	component Decode_Stage
		port (
			-- porte standard
			clk: in std_logic;
			reset: in std_logic;
			data_from_WB: in std_logic_vector(PARALLELISM-1 downto 0); -- dati da scrivere provenienti dallo stadio di WB
			dest_register_from_WB: in std_logic_vector(REGISTER_ADDR_LEN-1 downto 0); -- registro di destinazione del write_back
			dest_register_type_WB: in std_logic;
			pc_in: in std_logic_vector(PC_BITS-1 downto 0);
			pc_out: out std_logic_vector(PC_BITS-1 downto 0);
			instruction_out: out std_logic_vector(PARALLELISM-1 downto 0);
			instruction_in: in std_logic_vector(PARALLELISM-1 downto 0);
			instruction_format: out std_logic_vector(2 downto 0);
			register_a: out std_logic_vector(PARALLELISM-1 downto 0);
			register_b: out std_logic_vector(PARALLELISM-1 downto 0);
			force_jump: in std_logic;
			
			-- porte di debug
			register_file_debug: out register_file_type;
			fp_register_file_debug: out register_file_type			
		);	
	end component;
	
	component Execute_Stage
		port (
			clk: in std_logic;
			pc_in: in std_logic_vector(PC_BITS-1 downto 0);
			pc_out: out std_logic_vector(PC_BITS-1 downto 0);
			instruction_format_in: in std_logic_vector(2 downto 0);
			instruction_format_out: out std_logic_vector(2 downto 0);
			instruction_in: in std_logic_vector(PARALLELISM-1 downto 0);
			instruction_out: out std_logic_vector(PARALLELISM-1 downto 0);
			register_a_in: in std_logic_vector(PARALLELISM-1 downto 0);
			register_b_in: in std_logic_vector(PARALLELISM-1 downto 0);
			alu_exit: out std_logic_vector(PARALLELISM-1 downto 0);
			register_b_out: out std_logic_vector(PARALLELISM-1 downto 0);
			force_jump: out std_logic;
			pc_for_jump: out std_logic_vector(PC_BITS-1 downto 0);
			
			-- forwaring unit 
			rd_mem: in std_logic_vector(4 downto 0);
			rd_wb: in std_logic_vector(4 downto 0);
			register_data_from_mem: in std_logic_vector(PARALLELISM-1 downto 0);
			register_data_from_wb: in std_logic_vector(PARALLELISM-1 downto 0);
			instruction_format_mem: in std_logic_vector(2 downto 0);
			instruction_format_wb: in std_logic_vector(2 downto 0)
		);
	end component;
	
	component Memory_Stage
		port (
			clk: in std_logic;
			ready: in std_logic;
			memrd: out std_logic;
			memwr: out std_logic;
			pc_in: in std_logic_vector(PC_BITS-1 downto 0);
			pc_out: out std_logic_vector(PC_BITS-1 downto 0);
			instruction_format_in: in std_logic_vector(2 downto 0);
			instruction_format_out: out std_logic_vector(2 downto 0);
			instruction_in: in std_logic_vector(PARALLELISM-1 downto 0);
			instruction_out: out std_logic_vector(PARALLELISM-1 downto 0);			
			store_memory_data_register: out std_logic_vector(PARALLELISM-1 downto 0);
			load_memory_data_register: in std_logic_vector(PARALLELISM-1 downto 0);
			memory_address_register: out std_logic_vector(PARALLELISM-1 downto 0);
			memory_data_register: in std_logic_vector(PARALLELISM-1 downto 0);
			alu_exit_in: in std_logic_vector(PARALLELISM-1 downto 0);
			data_out: out std_logic_vector(PARALLELISM-1 downto 0);
			
			-- forwarding unit
			dest_register: out std_logic_vector(4 downto 0);
			dest_register_data: out std_logic_vector(PARALLELISM-1 downto 0)
		);	
	end component;
	
	component Cache_cmp is
    port ( 
			  ch_memrd: in  std_logic;
           ch_memwr: in  std_logic;
           ch_baddr: in  std_logic_vector (31 downto 0); 
           ch_bdata_in: in  std_logic_vector (31 downto 0);
			  ch_bdata_out: out  std_logic_vector (31 downto 0);
			  ch_ready: out  std_logic;
           ch_reset: in  std_logic;
			  ch_hit: out std_logic;
			  ch_hitm: out std_logic;
			  ch_inv: in std_logic;
			  ch_eads: in std_logic;
			  ch_wtwb: in std_logic;
			  ch_flush: in std_logic;
			  ch_bdata_ram_in: in data_line;
			  ch_bdata_ram_out: out data_line;
			  ch_baddr_ram: out std_logic_vector (PARALLELISM - 1 downto OFFSET_BIT);
		 	  ch_ramwr: out std_logic;
			  ch_ramrd: out std_logic;
		 	  ch_ram_ready: in std_logic;
			  ch_debug_cache: out cache_type(0 to 2**INDEX_BIT - 1)
		);
	end component;
	
	component Ram_cmp is
    port (
        address : in std_logic_vector (PARALLELISM - 1 downto OFFSET_BIT); 
        bdata_in : in data_line;				  		
        bdata_out : out data_line;		
        write_enable : in std_logic;                               
        read_enable : in std_logic;
		  ram_ready : out std_logic;
		  ram_debug : out work.CacheLibrary.ram_type (0 to RAM_DEPTH)
    );
	end component;

	component WriteBack_Stage
		port (
			clk: in std_logic;
			pc_in: in std_logic_vector(PC_BITS-1 downto 0);
			pc_out: out std_logic_vector(PC_BITS-1 downto 0);
			instruction_format_in: in std_logic_vector(2 downto 0);
			instruction_format_out: out std_logic_vector(2 downto 0);
			instruction_in: in std_logic_vector(PARALLELISM-1 downto 0);
			instruction_out: out std_logic_vector(PARALLELISM-1 downto 0);
			data_in: in std_logic_vector(PARALLELISM-1 downto 0);
		
			-- forwarding unit & registro da scrivere
			dest_register: out std_logic_vector(REGISTER_ADDR_LEN-1 downto 0);
			dest_register_data: out std_logic_vector(PARALLELISM-1 downto 0);
			dest_register_type: out std_logic
		);
	end component;
	-- SEGNALI DELLO STADIO DI FETCH

	-- SEGNALI DELLO STATO DI DECODE

	
	begin
		Fetch_Stage_inst: Fetch_Stage
			port map (
				clk => clk,
				reset => reset,
				force_jump => exe_force_jump,
				pc_for_jump => exe_pc_for_jump,
				instruction => instruction_fetch,
				pc => pc_fetch
			);
		
		Decode_Stage_inst: Decode_Stage
			port map (
				clk => clk,
				reset => reset,
				data_from_WB => wb_dest_register_data,
				dest_register_from_WB => wb_dest_register,
				dest_register_type_WB => wb_dest_register_type,
				pc_in => pc_fetch,
				pc_out => pc_decode,
				instruction_in => instruction_fetch,
				instruction_out => instruction_decode,
				instruction_format => dec_instruction_format,
				register_a => dec_register_a,
				register_b => dec_register_b,
				force_jump => exe_force_jump,
				register_file_debug => register_file_debug,
				fp_register_file_debug => fp_register_file_debug
			);
		
		Execute_Stage_inst: Execute_Stage
			port map (
				clk => clk,
				pc_in => pc_decode,
				pc_out => pc_execute,
				instruction_format_in => dec_instruction_format,
				instruction_format_out => exe_instruction_format,
				instruction_in => instruction_decode,
				instruction_out => instruction_execute,
				register_a_in => dec_register_a,
				register_b_in => dec_register_b,
				alu_exit => exe_alu_exit,
				register_b_out => exe_register_b,
				force_jump => exe_force_jump,
				pc_for_jump => exe_pc_for_jump,
				
				-- forwaring unit 
				rd_mem => mem_dest_register,
				rd_wb => wb_dest_register,
				register_data_from_mem => mem_dest_register_data,
				register_data_from_wb => wb_dest_register_data,
				instruction_format_mem => mem_instruction_format,
				instruction_format_wb => wb_instruction_format			
			);
		
		Memory_Stage_inst: Memory_Stage
			port map (
				clk => clk,
				ready => cache_ready,
				pc_in => pc_execute,
				pc_out => pc_memory,
				memrd => cache_memrd,
				memwr => cache_memwr,
				instruction_format_in => exe_instruction_format,
				instruction_format_out => mem_instruction_format,
				instruction_in => instruction_execute,
				instruction_out => instruction_memory,	
				store_memory_data_register => mem_store_memory_data_register,
				load_memory_data_register => mem_load_memory_data_register,
				memory_address_register => mem_memory_address_register,
				memory_data_register => exe_register_b,
				alu_exit_in => exe_alu_exit,
				data_out => mem_data_out,
				
				-- forwarding unit
				dest_register => mem_dest_register,
				dest_register_data => mem_dest_register_data
			);
			
		Cache_cmp_inst: Cache_cmp
			port map(
				ch_memrd => cache_memrd,
				ch_memwr => cache_memwr,
				ch_baddr => mem_memory_address_register,
				ch_bdata_in => mem_store_memory_data_register,
				ch_bdata_out => mem_load_memory_data_register,
				ch_ready => cache_ready,
				ch_reset => reset,
				ch_hit => cache_hit,
				ch_hitm => cache_hitm,
				ch_inv => cache_inv,
				ch_eads => cache_eads,
				ch_wtwb => cache_wtwb,
				ch_flush => cache_flush,
				ch_bdata_ram_in => ram_bdata_out,
				ch_bdata_ram_out => ram_bdata_in,
			   ch_baddr_ram => ram_baddr,
            ch_ramwr => ram_write,
			   ch_ramrd => ram_read,
            ch_ram_ready => ram_ready,
			   ch_debug_cache => debug_cache
			);
		
		Ram_cmp_inst: Ram_cmp
			port map(
			  address => ram_baddr,
			  bdata_in => ram_bdata_in,
			  bdata_out => ram_bdata_out,
           write_enable => ram_write,                             
           read_enable => ram_read,
		     ram_ready => ram_ready,
		     ram_debug => debug_ram 
			);
			
		WriteBack_Stage_inst: WriteBack_Stage
		port map (
			clk => clk,
			pc_in => pc_memory,
			pc_out => pc_writeback,
			instruction_format_in => mem_instruction_format,
			instruction_format_out => wb_instruction_format,
			instruction_in => instruction_memory,
			instruction_out => instruction_writeback,
			data_in => mem_data_out,
		
			-- forwarding unit & registro da scrivere
			dest_register => wb_dest_register,
			dest_register_data => wb_dest_register_data,
			dest_register_type => wb_dest_register_type
		);
	end Arch1_DLXPipelined;

