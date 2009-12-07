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
signal RAM_inst: ram_type(0 to 1024) := (others => X"00");

alias addr_tag is ch_baddr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

-- NON FUNZIONA
--function line_status(signal addr_index: bit_vector(INDEX_BIT-1 to 0), signal way_num: natural) return bit_vector(1 to 0) is
--begin
--	return cache(conv_integer(addr_index))(way_num).status;
--end;


begin

	ch_debug_cache <= cache;

	cache_reset: process (ch_reset)
	begin
		if (ch_reset = '1') then
			for index in 0 to 2**INDEX_BIT -1 loop
				for j in 0 to NWAY - 1 loop
					cache(index)(j).status <= MESI_I;
					cache(index)(j).lru_counter <= (others => '1');
				end loop;
			end loop;
			
			-- Inserisco alcuni dati nella cache per effettuare test
			cache(0)(0).status <= MESI_E;
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
		
		variable curr_way : natural := 0;
		variable hit : boolean := false;
		
	begin
		if(ch_memrd = '1') then
			curr_index := conv_integer(addr_index); -- salvo direttamente i valori convertiti così il codice è più leggibile
			curr_offset := conv_integer(addr_offset);
			
			hit := false; -- lo uso come flag per gestire il flusso di elaborazione
			curr_way := 0;
		
			for way in 0 to NWAY - 1 loop
				if((cache(curr_index)(way).status /= MESI_I) and (cache(curr_index)(way).tag = addr_tag)) then -- HIT
					curr_way := way;
					hit := true;
					exit; -- esce dal ciclo quando ha trovato un dato
				end if;
			end loop;
			
			if (hit = false) then -- MISS
				for way in 0 to NWAY - 1 loop
					if(cache(curr_index)(way).status = MESI_I) then -- trovata una linea libera
						
						-- IL CODICE QUI SOTTO CAUSA UN ERRORE: da controllare
						
						-- TODO: caricare il dato dalla RAM e metterlo nel posto giusto
						-- Note: per calcolare l'indirizzo iniziale bisogna tralasciare i bit di offset
						
						-- cache(curr_index)(way).status <= MESI_E; -- si deve guardare WTWB per decidere tra S ed E?
						-- cache(curr_index)(way).tag(TAG_BIT-1 downto 0) <= addr_tag;
						
						-- for data_i in 0 to 2**OFFSET_BIT - 1 loop
							-- 5 zeri perché ci sono 5 bit di offset
							-- cache(curr_index)(way).data(data_i)(7 downto 0) <= RAM_inst(conv_integer(addr_tag & addr_index & "00000") + data_i);
						-- end loop;
								
						curr_way := way;
						hit := true;
						exit; 
					end if;
				end loop;			
			end if;
			
			
			if (hit = false) then -- MISS ma con rimpiazzamento
				-- TODO: scaricare il dato più vecchio sulla RAM e caricare il nuovo
				hit := true;
			end if;
			
			
			word(7 downto 0) := cache(curr_index)(curr_way).data(curr_offset);
			word(15 downto 8) := cache(curr_index)(curr_way).data(curr_offset + 1);
			word(23 downto 16) := cache(curr_index)(curr_way).data(curr_offset + 2);
			word(31 downto 24) := cache(curr_index)(curr_way).data(curr_offset + 3);

			-- TODO: operazioni per la politica di invecchiamento
			
			ch_ready <= '1'; --debug
			ch_bdata <= word;
		end if;
	end process cache_read;

end Behavioral;	

