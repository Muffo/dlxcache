----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:38:06 02/01/2010 
-- Design Name: 
-- Module Name:    CacheRam - Arch_CacheRam 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CacheLibrary.all;
use work.Global.all;


entity CacheRam is
	port (
	-- cache
		cache_memrd: inout std_logic;
		cache_memwr: inout std_logic;
		cache_baddr: in std_logic_vector (31 downto 0); 
		cache_bdata_in : in std_logic_vector (31 downto 0); 
		cache_bdata_out : out std_logic_vector (31 downto 0); 
		cache_ready: inout std_logic;
		cache_hit: out std_logic;
		cache_hitm: out std_logic;
		cache_inv: in std_logic;
		cache_eads: in std_logic;
		cache_wtwb: in std_logic;
		cache_flush: in std_logic;
		debug_cache: out cache_type(0 to 2**INDEX_BIT - 1);	
		cache_reset: in std_logic;
		-- ram
		ram_bdata_in: inout data_line;
		ram_bdata_out: inout data_line;
		ram_baddr: inout std_logic_vector (PARALLELISM - 1 downto OFFSET_BIT);
      ram_write: inout std_logic;
		ram_read: inout std_logic;
      ram_ready: inout std_logic;
		debug_ram: out work.CacheLibrary.ram_type
	);
end CacheRam;
architecture Arch_CacheRam of CacheRam is
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
begin
Cache_cmp_inst: Cache_cmp
			port map(
				ch_memrd => cache_memrd,
				ch_memwr => cache_memwr,
				ch_baddr => cache_baddr,
				ch_bdata_in => cache_bdata_in,
				ch_bdata_out => cache_bdata_out,
				ch_ready => cache_ready,
				ch_reset => cache_reset,
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
end Arch_CacheRam;
