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

procedure cache_read(signal cache : inout cache_type; signal RAM : inout ram_type; word : out STD_LOGIC_VECTOR) is
	variable curr_index : natural := 0;
	variable curr_offset : natural := 0;
	variable curr_way : natural := 0;
	variable hit : boolean := false;
	variable data_block : data_line := (others => "00000000");
	variable data_block_addr : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
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
		for way in 0 to NWAY - 1 loop
			if(cache(curr_index)(way).lru_counter = NWAY - 1) then -- lru_counter = NWAY-1 -> se ci sono linee invalide trova una di queste, altrimenti trova la linee pi� vecchia
				curr_way := way;	
				
				-- Se modificato, scarico il dato pi� vecchio sulla RAM
				if(cache(curr_index)(way).status = MESI_M) then
					data_block_addr(TAG_BIT + INDEX_BIT + OFFSET_BIT - 1 downto OFFSET_BIT) := cache(curr_index)(way).tag & addr_index;
					for i in 0 to 2**OFFSET_BIT - 1 loop
						RAM(conv_integer(data_block_addr) + i) <= cache(curr_index)(way).data(i);
					end loop;
				end if;
				
				-- Carico il blocco nuovo
				data_block_addr(TAG_BIT + INDEX_BIT + OFFSET_BIT - 1 downto OFFSET_BIT) := addr_tag & addr_index;
				for i in 0 to 2**OFFSET_BIT - 1 loop
					data_block(i) := RAM(conv_integer(data_block_addr) + i);
				end loop;
				
				-- Seleziono il dato richiesto
				word(7 downto 0) := data_block(curr_offset);
				word(15 downto 8) := data_block(curr_offset + 1);
				word(23 downto 16) := data_block(curr_offset + 2);
				word(31 downto 24) := data_block(curr_offset + 3);
				
				-- Sovrascrivo il vecchio blocco con il nuovo
				cache(curr_index)(way).tag <= addr_tag;
				cache(curr_index)(way).data <= data_block;
				cache(curr_index)(way).status <= MESI_E; -- Incompleto: bisogna verificare se lo stato � E oppure S
				exit; 
			end if;
		end loop;			
	end if;
	
	-- Operazioni per la politica di invecchiamento
	for way in 0 to NWAY - 1 loop
		if(way /= curr_way and cache(curr_index)(way).lru_counter < cache(curr_index)(curr_way).lru_counter) then
			cache(curr_index)(way).lru_counter <= cache(curr_index)(way).lru_counter + 1;
		end if;
	end loop;
	cache(curr_index)(curr_way).lru_counter <= 0;
end procedure cache_read;

begin

	ch_debug_cache <= cache;

	cache_process: process (ch_reset, ch_memrd) is
		variable word : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
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
		end if;
	end process cache_process;

end Behavioral;	
