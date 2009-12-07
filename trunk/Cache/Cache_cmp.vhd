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
signal RAM: ram_type(0 to 1024) := (others => X"00");

alias addr_tag is ch_baddr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

-- NON FUNZIONA
--function line_status( cache : cache_type(0 to 2**INDEX_BIT - 1); addr_index: STD_LOGIC_VECTOR(INDEX_BIT-1 to 0); way_num: natural) return integer is
--begin
--	return conv_integer(cache(conv_integer(addr_index))(way_num).status);
--end;

begin

	ch_debug_cache <= cache;

	cache_reset: process (ch_reset)
	begin
		if (ch_reset = '1') then
			for index in 0 to 2**INDEX_BIT -1 loop
				for way in 0 to NWAY - 1 loop
					cache(index)(way).status <= MESI_I;
					cache(index)(way).lru_counter <= NWAY - 1;
				end loop;
			end loop;
			
			-- Inserisco alcuni dati nella cache per effettuare test
			cache(0)(0).status <= MESI_E;
			cache(0)(0).lru_counter <= 0;
			cache(0)(0).data(0)(7 downto 0) <= (others => '1');
			cache(0)(0).data(1)(7 downto 0) <= (others => '0');
			cache(0)(0).data(2)(7 downto 0) <= (others => '1');
			cache(0)(0).data(3)(7 downto 0) <= "10101010";
			cache(0)(0).tag(TAG_BIT-1 downto 0) <= (others => '0');
		end if;
	end process cache_reset;
	
	cache_read: process(ch_memrd) is
		variable word : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
		variable curr_index : natural := 0;
		variable curr_offset : natural := 0;
		variable hit : boolean := false;
--		variable data_block : data_line := (others => "00000000");
--		variable data_block_addr : STD_LOGIC_VECTOR (31 downto 0);
		
	begin
		if(ch_memrd = '1') then
			curr_index := conv_integer(addr_index); -- salvo direttamente i valori convertiti così il codice è più leggibile
			curr_offset := conv_integer(addr_offset);
			
			hit := false; -- lo uso come flag per terminare...da chiarire
		
			for way in 0 to NWAY - 1 loop
				if((cache(curr_index)(way).status /= MESI_I) and (cache(curr_index)(way).tag = addr_tag)) then -- HIT
					word(7 downto 0) := cache(curr_index)(way).data(curr_offset);
					word(15 downto 8) := cache(curr_index)(way).data(curr_offset + 1);
					word(23 downto 16) := cache(curr_index)(way).data(curr_offset + 2);
					word(31 downto 24) := cache(curr_index)(way).data(curr_offset + 3);
					hit := true;
					exit; -- esce dal ciclo quando ha trovato un dato
				end if;
			end loop;
			
--			if (not hit) then -- MISS -> applico la politica di rimpiazzamento
--				for way in 0 to NWAY - 1 loop
--					if(cache(curr_index)(way).lru_counter = NWAY - 1) then -- lru_counter = 3 -> se ci sono linee invalide trova una di queste,
--																							 -- altrimenti trova la linee più vecchia
--						
--						if(cache(curr_index)(way).status = MESI_M) then
--							-- TODO: scaricare il dato più vecchio sulla RAM e caricare il nuovo
--						end if;
--						
--						for i in 0 to 2**OFFSET_BIT - 1 loop
--							data_block_addr := addr_tag & addr_index & (0 to OFFSET_BIT - 1 => '0');
--							data_block(i) := RAM(conv_integer(data_block_addr) + i);
--						end loop;
--						
--						word(7 downto 0) := data_block(curr_offset);
--						word(15 downto 8) := data_block(curr_offset + 1);
--						word(23 downto 16) := data_block(curr_offset + 2);
--						word(31 downto 24) := data_block(curr_offset + 3);
--						
--						cache(curr_index)(way).data <= data_block;
--						exit; 
--					end if;
--				end loop;			
--			end if;
			
			-- TODO: operazioni per la politica di invecchiamento
			
			ch_ready <= '1'; --debug
			ch_bdata <= word;
		end if;
	end process cache_read;

end Behavioral;	

