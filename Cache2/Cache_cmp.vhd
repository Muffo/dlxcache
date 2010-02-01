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
		ch_flush: in std_logic;
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
	signal line_ready : std_logic := '0';
	signal replace_line : std_logic := '0';
	signal selected_way : integer;
	signal replace_write : std_logic := '0';
	signal write_line: std_logic := '0';
	signal read_line: std_logic := '0';
	signal rdwr_done: std_logic := '0';
	
begin
	
	write_line <= replace_write;
	
	cache_dlx_process : process (ch_memrd, ch_memwr, ch_reset, line_ready) is
		variable way: integer;
		variable waiting: boolean := false;
		variable word: std_logic_vector(31 downto 0);
	begin
		if (ch_reset = '1') then
			ch_ready <= '0';
			cache_reset;
		elsif (ch_memrd = '1' and ch_memwr = '0') then
			--lettura
			way := -1;
			if(waiting and line_ready = '1') then
				way := selected_way;
				waiting := false;
			elsif(not waiting) then 
				get_way(conv_integer(addr_index), addr_tag, way);
				if(way < 0) then --not hit
					waiting := true;
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
			if(waiting and line_ready = '1') then
				way := selected_way;
				waiting := false;
			elsif(not waiting) then 
				get_way(conv_integer(addr_index), addr_tag, way);
				if(way < 0) then --not hit
					waiting := true;
					replace_line <= '1'; -- attiva il rimpiazzamento di una linea
				end if;
			end if;
			if (way >= 0) then
				cache_hit_on(conv_integer(addr_index), way);
				cache(conv_integer(addr_index))(way).status := MESI_M;
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset)) := ch_bdata_in(7 downto 0);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 1) := ch_bdata_in(15 downto 8);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 2) := ch_bdata_in(23 downto 16);
				cache(conv_integer(addr_index))(way).data(conv_integer(addr_offset) + 3) := ch_bdata_in(31 downto 24);
				ch_ready <= '1';
			end if;
		elsif (ch_memrd = '0' and ch_memwr = '0') then
			ch_ready <= '0';
			replace_line <= '0';
		end if;
		
		ch_debug_cache <= cache;
	end process cache_dlx_process;
	
	cache_replace: process(replace_line, rdwr_done) is
		variable step : integer := 0;
	begin
		if(replace_line = '0') then
			step := 0;
			line_ready <= '0';
		elsif(step = 2 and rdwr_done = '1') then
			line_ready <= '1';
			step := 3;
			read_line <= '0';
		elsif(step = 1 and rdwr_done = '1') then
			step := 2;
			replace_write <= '0';
		elsif (step = 2 and rdwr_done = '0') then
			read_line <= '1';
		elsif(step = 0 and replace_line = '1') then
			for way in 0 to NWAY - 1 loop
				-- lru_counter = NWAY-1 -> se ci sono linee invalide trova una di queste, altrimenti trova la linee più vecchia
				if(cache(conv_integer(addr_index))(way).lru_counter = NWAY - 1) then
					selected_way <= way;
					if(cache(conv_integer(addr_index))(way).status = MESI_M) then
						step := 1;
						replace_write <= '1';
					else
						step := 2;
						read_line <= '1';
						exit; 
					end if;
				end if;
			end loop;
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
			cache(conv_integer(addr_index))(selected_way).data := ram_data_in;
			cache(conv_integer(addr_index))(selected_way).tag:= addr_tag;
			if(ch_wtwb = '1') then
				cache(conv_integer(addr_index))(selected_way).status:= MESI_S;
			else
				cache(conv_integer(addr_index))(selected_way).status:= MESI_E;
			end if;
			rdwr_done <= '1';
			waiting_read := false;
		elsif(not waiting_write and not waiting_read) then
			if(write_line = '1') then
				waiting_write := true;
				ram_address <= cache(conv_integer(addr_index))(selected_way).tag & addr_index;
				ram_data_out <= cache(conv_integer(addr_index))(selected_way).data;
				ram_we <= '1';
			elsif(read_line = '1') then
				waiting_read := true;
				ram_address <= addr_tag & addr_index;
				ram_oe <= '1';
			end if;
		end if;
	end process cache_ram;

end Behavioral;	