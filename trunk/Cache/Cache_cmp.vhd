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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CacheLibrary.all;
use work.Global.all;

entity Cache_cmp is
    port ( ch_memrd : in  STD_LOGIC;
           ch_memwr : in  STD_LOGIC;
           ch_baddr : in  STD_LOGIC_VECTOR (31 downto 0);
           ch_bdata_in : in  STD_LOGIC_VECTOR (31 downto 0);
			  ch_bdata_out : out  STD_LOGIC_VECTOR (31 downto 0);
           ch_reset : in  STD_LOGIC;
           ch_ready : out  STD_LOGIC;
			  ch_hit : out STD_LOGIC;
			  ch_hitm : out STD_LOGIC;
			  ch_inv : in STD_LOGIC;
			  ch_eads : in STD_LOGIC;
			  ch_wtwb : in STD_LOGIC;
			  ch_flush : in STD_LOGIC;
			  ch_debug_cache : out cache_type(0 to 2**INDEX_BIT - 1));
end Cache_cmp;

architecture Behavioral of Cache_cmp is

shared variable cache : cache_type (0 to 2**INDEX_BIT - 1);
shared variable RAM: ram_type(0 to 1023) := (others => X"00");

alias addr_tag is ch_baddr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

procedure cache_reset is
begin
	for index in 0 to 2**INDEX_BIT -1 loop
		for way in 0 to NWAY - 1 loop
			cache(index)(way).status := MESI_I;
			cache(index)(way).lru_counter := way;
		end loop;
	end loop;
end procedure cache_reset;

-- In caso di MISS restituisce un valore negativo
procedure get_way(index : in natural; tag : in STD_LOGIC_VECTOR; selected_way : out natural) is
begin
	selected_way := -1;
	for way in 0 to NWAY - 1 loop
		if((cache(index)(way).status /= MESI_I) and (cache(index)(way).tag = tag)) then -- HIT
			selected_way := way;
			exit;
		end if;
	end loop;
end procedure get_way;

procedure ram_write(tag : in STD_LOGIC_VECTOR; index : in STD_LOGIC_VECTOR; way : in natural) is
	variable temp_addr : STD_LOGIC_VECTOR (PARALLELISM - 1 downto OFFSET_BIT) := (others => '0');
begin
	temp_addr := tag & index;
	for i in 0 to 2**OFFSET_BIT - 1 loop
		RAM((conv_integer(temp_addr) + i)) := cache(conv_integer(index))(way).data(i);
	end loop;
end procedure ram_write;

procedure cache_replace_line(selected_way : out natural) is
	variable curr_index : natural := 0;
	variable temp_addr : STD_LOGIC_VECTOR (PARALLELISM - 1 downto OFFSET_BIT) := (others => '0');
begin
	curr_index := conv_integer(addr_index);
	for way in 0 to NWAY - 1 loop
		-- lru_counter = NWAY-1 -> se ci sono linee invalide trova una di queste, altrimenti trova la linee più vecchia
		if(cache(curr_index)(way).lru_counter = NWAY - 1) then
			selected_way := way;	
			
			-- Se modificato, scarico il dato più vecchio sulla RAM
			if(cache(curr_index)(way).status = MESI_M) then
				ram_write(addr_tag, addr_index, way);
			end if;
			
			-- Carico il blocco nuovo
			temp_addr(PARALLELISM - 1 downto OFFSET_BIT) := addr_tag & addr_index;
			for i in 0 to 2**OFFSET_BIT - 1 loop
				cache(curr_index)(way).data(i) := RAM((conv_integer(temp_addr) + i));
			end loop;
			cache(curr_index)(way).tag := addr_tag;
			if(ch_wtwb = '1') then
				cache(curr_index)(way).status := MESI_S;
			else
				cache(curr_index)(way).status := MESI_E;
			end if;
			exit; 
		end if;
	end loop;
end procedure cache_replace_line;

procedure cache_hit_on(hit_index : in natural; hit_way : in natural) is
begin
	-- Operazioni per la politica di invecchiamento
	for way in 0 to NWAY - 1 loop
		if(way /= hit_way and cache(hit_index)(way).lru_counter < cache(hit_index)(hit_way).lru_counter) then
			cache(hit_index)(way).lru_counter := cache(hit_index)(way).lru_counter + 1;
		end if;
	end loop;
	cache(hit_index)(hit_way).lru_counter := 0;
end procedure cache_hit_on;

procedure cache_inv_on(inv_index : in natural; inv_way : in natural) is
begin
	for way in 0 to NWAY - 1 loop
		if(way /= inv_way and cache(inv_index)(way).lru_counter > cache(inv_index)(inv_way).lru_counter) then
			cache(inv_index)(way).lru_counter := cache(inv_index)(way).lru_counter - 1;
		end if;
	end loop;
	cache(inv_index)(inv_way).lru_counter := NWAY - 1;
end procedure cache_inv_on;

procedure cache_read(word : out STD_LOGIC_VECTOR) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
begin
	curr_index := conv_integer(addr_index);
	curr_offset := conv_integer(addr_offset);	

	get_way(curr_index, addr_tag, curr_way);
	
	--In caso di MISS applico la politica di rimpiazzamento
	if (curr_way < 0) then 			
		cache_replace_line(curr_way);
	end if;	
	
	word(7 downto 0) := cache(curr_index)(curr_way).data(curr_offset);
	word(15 downto 8) := cache(curr_index)(curr_way).data(curr_offset + 1);
	word(23 downto 16) := cache(curr_index)(curr_way).data(curr_offset + 2);
	word(31 downto 24) := cache(curr_index)(curr_way).data(curr_offset + 3);
	
	--Aggiornamento dei contatori
	cache_hit_on(curr_index, curr_way);
end procedure cache_read;

procedure cache_write(word : in STD_LOGIC_VECTOR) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
	variable temp_addr : STD_LOGIC_VECTOR (PARALLELISM - 1 downto OFFSET_BIT) := (others => '0');
begin
	curr_index := conv_integer(addr_index);
	curr_offset := conv_integer(addr_offset);
	
	get_way(curr_index, addr_tag, curr_way);
	
	-- In caso di MISS applico la politica di rimpiazzamento
	if (curr_way < 0) then 
		cache_replace_line(curr_way);
	end if;	
	
	cache(curr_index)(curr_way).data(curr_offset) := word(7 downto 0);
	cache(curr_index)(curr_way).data(curr_offset + 1) := word(15 downto 8);
	cache(curr_index)(curr_way).data(curr_offset + 2) := word(23 downto 16);
	cache(curr_index)(curr_way).data(curr_offset + 3) := word(31 downto 24);
	
	if(cache(curr_index)(curr_way).status = MESI_E) then
		cache(curr_index)(curr_way).status := MESI_M;
	elsif(cache(curr_index)(curr_way).status = MESI_S) then
		cache(curr_index)(curr_way).status := MESI_E;
		ram_write(addr_tag, addr_index, curr_way);
	end if;
	
	--Aggiornamento dei contatori
	cache_hit_on(curr_index, curr_way);
end procedure cache_write;

procedure cache_snoop(hit : out STD_LOGIC; hit_m : out STD_LOGIC) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
begin
	curr_index := conv_integer(addr_index);
	curr_offset := conv_integer(addr_offset);
	hit := '0';
	hit_m := '0';

	get_way(curr_index, addr_tag, curr_way);
	
	if(curr_way >= 0) then
		if(cache(curr_index)(curr_way).status /= MESI_M) then
			hit_m := '1';
			ram_write(addr_tag, addr_index, curr_way);
			cache(curr_index)(curr_way).status := MESI_S;
		else
			hit := '1';
			cache(curr_index)(curr_way).status := MESI_S;
		end if;
	end if;
	
	if(ch_inv = '1') then
		cache(curr_index)(curr_way).status := MESI_I;
		
		--Aggiornamento dei contatori
		cache_inv_on(curr_index, curr_way);
	end if;
end procedure cache_snoop;

begin

	cache_process: process (ch_reset, ch_memrd, ch_memwr, ch_eads) is
		variable word : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
		variable hit : STD_LOGIC;
		variable hit_m : STD_LOGIC;
	begin
		if (ch_reset = '1') then -- reset
			cache_reset;
			
			-- Inizializzazione cache e ram per il debug			
			for i in 0 to 1023 loop
				RAM(i) := conv_std_logic_vector(i mod 256, 8);
			end loop;
		else
			if(ch_memrd = '1' and ch_memwr = '0') then -- memrd
				cache_read(word);
				ch_bdata_out <= word;
			elsif(ch_memrd = '0' and not ch_memwr'event and not ch_reset'event) then -- fine memrd
				ch_bdata_out <= (others => 'Z');
			end if;
				
			if(ch_memwr = '1' and ch_memrd = '0') then -- memwr
				word := ch_bdata_in;
				cache_write(word);
			end if;
				
			if(ch_eads = '1') then -- snoop
				cache_snoop(hit, hit_m);
				ch_hit <= hit;
				ch_hitm <= hit_m;
			end if;
		end if;
		
		ch_debug_cache <= cache;
		
	end process cache_process;

end Behavioral;	

