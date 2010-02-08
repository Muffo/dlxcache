----------------------------------------------------------------------------------
-- Company: Gruppo 2
-- Engineer: Grandi, Malaguti, Mattetti, Morlini, Ricci
-- 
-- Create Date:    10:29:02 12/01/2009 
-- Design Name: 
-- Module Name:    Cache_cmp - Behavioral 
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
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use work.CacheLibrary.all;
use work.Global.all;

entity Cache_cmp is
	port ( 
		-- segnali di comunicazione con il DLX
		ch_memrd: in std_logic;
		ch_memwr: in std_logic;
		ch_baddr: in std_logic_vector (31 downto 0);
		ch_bdata_in: in std_logic_vector (31 downto 0);
		ch_bdata_out: out std_logic_vector (31 downto 0);
		ch_reset: in std_logic;
		ch_ready: out std_logic;
		-- segnali di comunicazione con il controllore di memoria
		ch_hit: out std_logic;
		ch_hitm: out std_logic;
		ch_inv: in std_logic;
		ch_eads: in std_logic;
		ch_wtwb: in std_logic;
		ch_snoop_addr: in std_logic_vector (31 downto 0);
		-- segnali di comunicazione con la RAM
		ram_address: out std_logic_vector (TAG_BIT + INDEX_BIT - 1 downto 0);
		ram_data_out: out data_line;
		ram_data_in: in data_line;
		ram_we: out std_logic;
		ram_oe: out std_logic;
		ram_ready: in std_logic;
		-- segnali di debug
		ch_debug_cache: out cache_type(0 to 2**INDEX_BIT - 1)
	);
end Cache_cmp;

architecture Behavioral of Cache_cmp is

shared variable cache: cache_type (0 to 2**INDEX_BIT - 1);

alias addr_tag is ch_baddr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

alias snoop_tag is ch_snoop_addr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias snoop_index is ch_snoop_addr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);

procedure cache_reset is
begin
	for index in 0 to 2**INDEX_BIT -1 loop
		for way in 0 to NWAY - 1 loop
			cache(index)(way).status:= MESI_I;
			cache(index)(way).lru_counter:= way;
		end loop;
	end loop;
end procedure cache_reset;

-- In caso di MISS restituisce un valore negativo
procedure get_way(index: in natural; tag: in std_logic_vector; selected_way: out integer) is
begin
	selected_way:= -1;
	for way in 0 to NWAY - 1 loop
		if((cache(index)(way).status /= MESI_I) and (cache(index)(way).tag = tag)) then -- HIT
			selected_way:= way;
			exit;
		end if;
	end loop;
end procedure get_way;

procedure cache_hit_on(hit_index: in natural; hit_way: in natural) is
begin
	-- Operazioni per la politica di invecchiamento
	for way in 0 to NWAY - 1 loop
		if(way /= hit_way and cache(hit_index)(way).lru_counter < cache(hit_index)(hit_way).lru_counter) then
			cache(hit_index)(way).lru_counter:= cache(hit_index)(way).lru_counter + 1;
		end if;
	end loop;
	cache(hit_index)(hit_way).lru_counter:= 0;
end procedure cache_hit_on;

procedure cache_inv_on(inv_index: in natural; inv_way: in natural) is
begin
	for way in 0 to NWAY - 1 loop
		if(way /= inv_way and cache(inv_index)(way).lru_counter > cache(inv_index)(inv_way).lru_counter) then
			cache(inv_index)(way).lru_counter:= cache(inv_index)(way).lru_counter - 1;
		end if;
	end loop;
	cache(inv_index)(inv_way).lru_counter:= NWAY - 1;
end procedure cache_inv_on;
	
	-- segnali interni:
	signal replace_line : std_logic := '0';
	signal write_through: std_logic := '0';
	signal wt_way : integer;
	
	signal line_ready : std_logic := '0';
	signal replace_write : std_logic := '0';
	signal replace_read: std_logic := '0';
	signal replace_way : integer;
	
	signal selected_way : integer;
	signal selected_index : std_logic_vector(INDEX_BIT - 1 downto 0);
	signal read_line: std_logic := '0';
	signal write_line: std_logic := '0';
	signal rdwr_done: std_logic := '0';
	
	signal snoop_write: std_logic := '0';
	signal snoop_way : integer;
	
begin
	
	write_line <= '1' when (replace_write = '1' or snoop_write = '1' or write_through = '1') else '0';
	
	read_line <= '1' when (replace_read = '1') else '0';
	
	selected_way <= replace_way when (replace_write = '1' or read_line = '1') else
						 snoop_way   when (snoop_write = '1') else
						 wt_way   when (write_through = '1') else
						 -1;		
						 
	selected_index <= snoop_index when (snoop_write = '1') else
							addr_index;
	
	cache_dlx_process : process (ch_memrd, ch_memwr, ch_reset, line_ready, rdwr_done) is
		variable way: integer;
		variable waiting_replace: boolean := false;
		variable waiting_wt: boolean := false;
		variable word: std_logic_vector(31 downto 0);
	begin
		if (ch_reset = '1') then
			ch_ready <= '0';
			cache_reset;
		elsif (ch_memrd = '1' and ch_memwr = '0') then
			--lettura
			way := -1;
			if(waiting_replace and line_ready = '1') then
				way := selected_way;
				waiting_replace := false;
			elsif(not waiting_replace) then 
				get_way(conv_integer(addr_index), addr_tag, way);
				if(way < 0) then --not hit
					waiting_replace := true;
					replace_line <= '1'; -- attiva il rimpiazzamento di una linea
				end if;
			end if;
			if (way >= 0) then
				cache_hit_on(conv_integer(addr_index), way);
				word(7 downto 0) := cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset));
				word(15 downto 8) := cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 1);
				word(23 downto 16) := cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 2);
				word(31 downto 24) := cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 3);
				ch_bdata_out <= word;
				ch_ready <= '1';
			end if;
		elsif (ch_memrd = '0' and ch_memwr = '1') then
			-- scrittura
			way := -1;
			if(waiting_wt and rdwr_done = '1') then
				cache(conv_integer(addr_index))(wt_way).status := MESI_E;
				waiting_wt := false;
				ch_ready <= '1';
			elsif(waiting_replace and line_ready = '1') then
				way := selected_way;
				waiting_replace := false;
			elsif(not waiting_replace) then 
				get_way(conv_integer(addr_index), addr_tag, way);
				if(way < 0) then --not hit
					waiting_replace := true;
					replace_line <= '1'; -- attiva il rimpiazzamento di una linea
				end if;
			end if;
			if (way >= 0) then
				cache_hit_on(conv_integer(addr_index), way);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset)) := ch_bdata_in(7 downto 0);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 1) := ch_bdata_in(15 downto 8);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 2) := ch_bdata_in(23 downto 16);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 3) := ch_bdata_in(31 downto 24);
				
				if(cache(conv_integer(addr_index))(way).status = MESI_S) then
					waiting_wt := true;
					wt_way <= way;
					write_through <= '1';
				else
					cache(conv_integer(addr_index))(way).status := MESI_M;
					ch_ready <= '1';
				end if;
			end if;
		elsif (ch_memrd = '0' and ch_memwr = '0') then
			ch_ready <= '0';
			replace_line <= '0';
			write_through <= '0';
		end if;
		
		ch_debug_cache <= cache;
	end process cache_dlx_process;
	
	cache_replace: process(replace_line, rdwr_done) is
		variable step : integer := 0;
	begin
		if(replace_line = '0') then
			step := 0;
			line_ready <= '0';
		elsif(step = 0 and replace_line = '1') then
			for way in 0 to NWAY - 1 loop
				-- lru_counter = NWAY-1 -> se ci sono linee invalide trova una di queste, altrimenti trova la linee pi� vecchia
				if(cache(conv_integer(addr_index))(way).lru_counter = NWAY - 1) then
					replace_way <= way;
					if(cache(conv_integer(addr_index))(way).status = MESI_M) then
						step := 1;
						replace_write <= '1';
					else
						step := 2;
						replace_read <= '1';
						exit; 
					end if;
				end if;
			end loop;
		elsif(step = 1 and rdwr_done = '1') then
			step := 2;
			replace_write <= '0';
		elsif (step = 2 and rdwr_done = '0') then
			replace_read <= '1';
		elsif(step = 2 and rdwr_done = '1') then
			line_ready <= '1';
			step := 3;
			replace_read <= '0';
		end if;
	end process cache_replace;
	
	cache_ram: process(read_line, write_line, ch_reset, ram_ready) is
		variable waiting_read : boolean := false;
		variable waiting_write : boolean := false;
	begin
		if(ch_reset = '1') then
			ram_we <= '0';
			ram_oe <= '0';
		elsif(write_line = '0' and read_line = '0' and ram_ready = '1') then
			ram_we <= '0';
			ram_oe <= '0';
		elsif(write_line = '0' and read_line = '0' and ram_ready = '0') then
			rdwr_done <= '0';
		elsif(waiting_write and ram_ready = '1') then
			rdwr_done <= '1';
			waiting_write := false;
		elsif(waiting_read and ram_ready = '1') then
			cache(conv_integer(selected_index))(selected_way).data := ram_data_in;
			cache(conv_integer(selected_index))(selected_way).tag:= addr_tag;
			if(ch_wtwb = '1') then
				cache(conv_integer(selected_index))(selected_way).status:= MESI_S;
			else
				cache(conv_integer(selected_index))(selected_way).status:= MESI_E;
			end if;
			rdwr_done <= '1';
			waiting_read := false;
		elsif(not waiting_write and not waiting_read) then
			if(write_line = '1') then
				waiting_write := true;
				ram_address <= cache(conv_integer(selected_index))(selected_way).tag & selected_index;
				ram_data_out <= cache(conv_integer(selected_index))(selected_way).data;
				ram_we <= '1';
			elsif(read_line = '1') then
				waiting_read := true;
				ram_address <= addr_tag & selected_index;
				ram_oe <= '1';
			end if;
		end if;
	end process cache_ram;
	
	cache_snoop: process(ch_eads, rdwr_done)
		variable way: integer;
		variable waiting_write: boolean := false;
	begin
		if(ch_eads = '0') then
			snoop_write <= '0';
		elsif(waiting_write and rdwr_done = '1') then
			ch_hitm <= '1';
			waiting_write := false;
		elsif(not waiting_write and ch_eads = '1') then
			get_way(conv_integer(snoop_index), snoop_tag, way);

			if(way >= 0) then
				if(cache(conv_integer(snoop_index))(way).status = MESI_M) then
					waiting_write := true;
					snoop_way <= way;
					snoop_write <= '1';
				else
					ch_hit <= '1';
				end if;
				cache(conv_integer(snoop_index))(way).status:= MESI_S;
			else
				ch_hit <= '0';
				ch_hitm <= '0';
			end if;

			if(ch_inv = '1') then
				cache(conv_integer(snoop_index))(way).status:= MESI_I;				
				--Aggiornamento dei contatori
				cache_inv_on(conv_integer(snoop_index), way);
			end if;
		end if;
	end process cache_snoop;

end Behavioral;	