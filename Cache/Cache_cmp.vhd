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
           ch_bdata : inout  STD_LOGIC_VECTOR (31 downto 0);
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

signal cache : cache_type (0 to 2**INDEX_BIT - 1);
signal RAM: ram_type(0 to 1023) := (others => X"00");

alias addr_tag is ch_baddr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

procedure cache_reset(signal cache : inout cache_type) is
begin
	for index in 0 to 2**INDEX_BIT -1 loop
		for way in 0 to NWAY - 1 loop
			cache(index)(way).status <= MESI_I;
			cache(index)(way).lru_counter <= NWAY - 1;
		end loop;
	end loop;
end procedure cache_reset;


procedure cache_replace_line(signal cache : inout cache_type; signal RAM : inout ram_type; selected_way : out natural; data_block : inout data_line) is
	variable curr_index : natural := 0;
	variable data_block_addr : STD_LOGIC_VECTOR (PARALLELISM - 1 downto OFFSET_BIT) := (others => '0');
begin
	curr_index := conv_integer(addr_index);
	for way in 0 to NWAY - 1 loop
		-- lru_counter = NWAY-1 -> se ci sono linee invalide trova una di queste, altrimenti trova la linee più vecchia
		if(cache(curr_index)(way).lru_counter = NWAY - 1) then
			selected_way := way;	
			
			-- Se modificato, scarico il dato più vecchio sulla RAM
			if(cache(curr_index)(way).status = MESI_M) then
				data_block_addr(PARALLELISM - 1 downto OFFSET_BIT) := cache(curr_index)(way).tag & addr_index;
				for i in 0 to 2**OFFSET_BIT - 1 loop
					-- in questa linea c'è un warning perché la RAM ha 1023 locazioni ma l'indirizzo ne ha potenzialmente molte di più
					RAM((conv_integer(data_block_addr) + i) mod 1023) <= cache(curr_index)(way).data(i);
				end loop;
			end if;
			
			-- Carico il blocco nuovo
			data_block_addr(TAG_BIT + INDEX_BIT + OFFSET_BIT - 1 downto OFFSET_BIT) := addr_tag & addr_index;
			for i in 0 to 2**OFFSET_BIT - 1 loop
				data_block(i) := RAM((conv_integer(data_block_addr) + i) mod 1023);
			end loop;
			
			-- Sovrascrivo il vecchio blocco con il nuovo
			cache(curr_index)(way).tag <= addr_tag;
			cache(curr_index)(way).data <= data_block;
			cache(curr_index)(way).status <= MESI_E; -- Incompleto: bisogna verificare se lo stato è E oppure S
			exit; 
		end if;
	end loop;
end procedure cache_replace_line;


procedure cache_hit_on(signal cache : inout cache_type; hit_index : in natural; hit_way : in natural) is
begin
	-- Operazioni per la politica di invecchiamento
	for way in 0 to NWAY - 1 loop
		if(way /= hit_way and cache(hit_index)(way).lru_counter < cache(hit_index)(hit_way).lru_counter) then
			cache(hit_index)(way).lru_counter <= cache(hit_index)(way).lru_counter + 1;
		end if;
	end loop;
	cache(hit_index)(hit_way).lru_counter <= 0;
end procedure cache_hit_on;


procedure cache_read(signal cache : inout cache_type; signal RAM : inout ram_type; word : out STD_LOGIC_VECTOR) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
	variable hit : boolean := false;
	variable data_block : data_line := (others => "00000000");
begin
	curr_index := conv_integer(addr_index);
	curr_offset := conv_integer(addr_offset);	
	hit := false;

	for way in 0 to NWAY - 1 loop
		if((cache(curr_index)(way).status /= MESI_I) and (cache(curr_index)(way).tag = addr_tag)) then -- HIT
			curr_way := way;
			
			word(7 downto 0) := cache(curr_index)(way).data(curr_offset);
			word(15 downto 8) := cache(curr_index)(way).data(curr_offset + 1);
			word(23 downto 16) := cache(curr_index)(way).data(curr_offset + 2);
			word(31 downto 24) := cache(curr_index)(way).data(curr_offset + 3);
			hit := true;
			exit;
		end if;
	end loop;
	
	-- In caso di MISS applico la politica di rimpiazzamento
	if (not hit) then 			
		cache_replace_line(cache, RAM, curr_way, data_block);
		
		-- Seleziono il dato richiesto
		word(7 downto 0) := data_block(curr_offset);
		word(15 downto 8) := data_block(curr_offset + 1);
		word(23 downto 16) := data_block(curr_offset + 2);
		word(31 downto 24) := data_block(curr_offset + 3);
	end if;	
	
	cache_hit_on(cache, curr_index, curr_way);
end procedure cache_read;

procedure cache_write(signal cache : inout cache_type; signal RAM : inout ram_type; word : in STD_LOGIC_VECTOR) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
	variable hit : boolean := false;
	variable data_block : data_line := (others => "00000000");
begin
	curr_index := conv_integer(addr_index);
	curr_offset := conv_integer(addr_offset);	
	hit := false;

	for way in 0 to NWAY - 1 loop
		if((cache(curr_index)(way).status /= MESI_I) and (cache(curr_index)(way).tag = addr_tag)) then -- HIT
			curr_way := way;
			hit := true;
--			cache(curr_index)(way).data(curr_offset) <= ch_bdata(7 downto 0);
--			cache(curr_index)(way).data(curr_offset + 1) <= ch_bdata(15 downto 8);
--			cache(curr_index)(way).data(curr_offset + 2) <= ch_bdata(23 downto 16);
--			cache(curr_index)(way).data(curr_offset + 3) <= ch_bdata(31 downto 24);
--			cache(curr_index)(way).status <= MESI_M;
			exit;
		end if;
	end loop;
	
	-- In caso di MISS applico la politica di rimpiazzamento
	if (not hit) then 
		cache_replace_line(cache, RAM, curr_way, data_block);
--		cache(curr_index)(curr_way).data(curr_offset) <= ch_bdata(7 downto 0);
--		cache(curr_index)(curr_way).data(curr_offset + 1) <= ch_bdata(15 downto 8);
--		cache(curr_index)(curr_way).data(curr_offset + 2) <= ch_bdata(23 downto 16);
--		cache(curr_index)(curr_way).data(curr_offset + 3) <= ch_bdata(31 downto 24);
--		cache(curr_index)(curr_way).status <= MESI_M;
	end if;	
	
	cache(curr_index)(curr_way).data(curr_offset) <= word(7 downto 0);
	cache(curr_index)(curr_way).data(curr_offset + 1) <= word(15 downto 8);
	cache(curr_index)(curr_way).data(curr_offset + 2) <= word(23 downto 16);
	cache(curr_index)(curr_way).data(curr_offset + 3) <= word(31 downto 24);
	cache(curr_index)(curr_way).status <= MESI_M;
	
	cache_hit_on(cache, curr_index, curr_way);
end procedure cache_write;

procedure cache_snoop(signal cache : inout cache_type; hit : out STD_LOGIC) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
	variable hit_flag : boolean := false;
begin
	curr_index := conv_integer(addr_index);
	curr_offset := conv_integer(addr_offset);	
	hit_flag := false;

	for way in 0 to NWAY - 1 loop
		if((cache(curr_index)(way).status /= MESI_I) and (cache(curr_index)(way).tag = addr_tag)) then -- HIT
			curr_way := way;
			hit_flag := true;
			
			if(cache(curr_index)(way).status /= MESI_M) then
				hit := '1'; -- quando lo resettiamo questo bit?
			else
				hit := '1';
			end if;
			
			if (ch_inv = '1') then  -- ricevuto comando di invalidazione (lo mettiamo qui?)
				cache(curr_index)(way).status <= MESI_I;
			end if;
			exit;
		end if;
	end loop;
	
	-- !!!! In caso di MISS cosa facciamo?? Max aveva proposto un altro segnale in out per segnalare questa condizione
--	if (not hit_flag) then 
--		
--	end if;	
--	
	-- !!!! cosa ci fa questo qui? > cache_hit_on(cache, curr_index, curr_way);
end procedure cache_snoop;

begin

	ch_debug_cache <= cache;

	cache_process: process (ch_reset, ch_memrd, ch_memwr, ch_eads) is
		variable word : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
		variable hit : STD_LOGIC;
	begin
		if (ch_reset = '1') then -- reset
			cache_reset(cache);
			
			-- Inizializzazione cache e ram per il debug			
			for i in 0 to 1023 loop
				RAM(i) <= conv_std_logic_vector(i mod 256, 8);
			end loop;
		elsif(ch_memrd = '1') then -- memrd
			cache_read(cache, RAM, word);
			ch_bdata <= word;
		elsif(ch_memwr = '1') then -- memwr
			word := ch_bdata;
			cache_write(cache, RAM, word);
		elsif(ch_eads = '1') then -- snoop
			cache_snoop(cache, hit);
			ch_hit <= hit;
		end if;
	end process cache_process;

end Behavioral;	

