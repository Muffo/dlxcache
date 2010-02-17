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

-- TAG, INDEX e OFFSET provenienti dal DLX.
alias addr_tag is ch_baddr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

-- TAG e OFFSET provenienti dal controllore di memoria.
alias snoop_tag is ch_snoop_addr(PARALLELISM - 1 downto OFFSET_BIT + INDEX_BIT);
alias snoop_index is ch_snoop_addr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);

-- Procedura per l'inizializzazione della cache.
procedure cache_reset is
begin
	for index in 0 to 2**INDEX_BIT -1 loop
		for way in 0 to NWAY - 1 loop
			cache(index)(way).status:= MESI_I;
			cache(index)(way).lru_counter:= way;
		end loop;
	end loop;
end procedure cache_reset;

-- Procedura che ricerca una linea nella cache:
-- 	in caso di MISS restituisce un valore negativo;
-- 	in caso di HIT restituisce il numero della via che contiene la linea.
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

-- Procedura per applicare le politiche di invecchiamento in caso HIT
procedure cache_hit_on(hit_index: in natural; hit_way: in natural) is
begin
	for way in 0 to NWAY - 1 loop
		if(way /= hit_way and cache(hit_index)(way).lru_counter < cache(hit_index)(hit_way).lru_counter) then
			cache(hit_index)(way).lru_counter:= cache(hit_index)(way).lru_counter + 1;
		end if;
	end loop;
	cache(hit_index)(hit_way).lru_counter:= 0;
end procedure cache_hit_on;

-- Procedura per applicare le politiche di invecchiamento in caso INVALIDAZIONE
procedure cache_inv_on(inv_index: in natural; inv_way: in natural) is
begin
	for way in 0 to NWAY - 1 loop
		if(way /= inv_way and cache(inv_index)(way).lru_counter > cache(inv_index)(inv_way).lru_counter) then
			cache(inv_index)(way).lru_counter:= cache(inv_index)(way).lru_counter - 1;
		end if;
	end loop;
	cache(inv_index)(inv_way).lru_counter:= NWAY - 1;
end procedure cache_inv_on;
	
	-- Segnali per la comunicazione interna alla cache:
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
	signal cache_debug_update : std_logic;
	
begin
	
	-- segnale di richiesta di scrittura al processo cache_ram
	write_line <= '1' when (replace_write = '1' or snoop_write = '1' or write_through = '1') else '0';
	
	-- segnale di richiesta di lettura al processo cache_ram
	read_line <= '1' when (replace_read = '1') else '0';
	
	-- VIA interessata nel trasferimento con la RAM
	selected_way <= replace_way when (replace_write = '1' or read_line = '1') else
						 snoop_way   when (snoop_write = '1') else
						 wt_way   when (write_through = '1') else
						 -1;		
						 
	-- INDEX interessato nel trasferimento con la RAM
	selected_index <= snoop_index when (snoop_write = '1') else
							addr_index;
	
	-- Processo per la comunicazine con il DLX:
	-- 	in caso di lettura restituisce il dato al DLX;
	-- 	in caso di scrittura scrive sulla cache;
	-- 	se necessario attiva il processo cache_replace per il rimpiazzamento
	--		in caso di write-through attiva il processo cache_ram per la scrittura in RAM
	cache_dlx_process : process (ch_memrd, ch_memwr, ch_reset, line_ready, rdwr_done, cache_debug_update) is
		variable way: integer;
		variable waiting_replace: boolean := false;
		variable waiting_wt: boolean := false;
		variable word: std_logic_vector(31 downto 0);
	begin
		if (ch_reset = '1') then
			ch_ready <= '0';
			cache_reset;
		elsif (ch_memrd = '1' and ch_memwr = '0') then
			-- Richiesta di lettura
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
			-- Richiesta di scrittura
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
					write_through <= '1'; -- attiva la propagazione della modifica in RAM
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
		
		-- DEBUG: aggiornamento del segnale cache_debug
		ch_debug_cache <= cache;
	end process cache_dlx_process;
	
	-- Processo che gestisce il rimpiazzameto di una linea nella cache:
	-- 	richiede la lettura al processo cache_ram;
	-- 	in caso di necessità, prima della lettura, richiede al processo cache_ram una scrittura
	cache_replace: process(replace_line, rdwr_done) is
		variable step : integer := 0;
	begin
		if(replace_line = '0') then
			step := 0;
			line_ready <= '0';
		elsif(step = 0 and replace_line = '1') then
			for way in 0 to NWAY - 1 loop
				-- ciclo che ricerca una lnea con lru_counter = NWAY-1 -> se ci sono linee invalide trova una di queste, 
				-- altrimenti trova la linee più vecchia
				if(cache(conv_integer(addr_index))(way).lru_counter = NWAY - 1) then
					replace_way <= way;
					if(cache(conv_integer(addr_index))(way).status = MESI_M) then
						step := 1;
						replace_write <= '1'; -- attiva la scrittura in RAM
					else
						step := 2;
						replace_read <= '1'; -- attiva la lettura dalla RAM
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
	
	-- Processo che richiede letture a scrittura alla RAM:
	-- 	al termine dell'operazione attiva il segnale interno rdwr_done per risvegliare li processo chiamante
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
			rdwr_done <= '1'; -- comunica la terminazione dell'operazione di srittura
			waiting_write := false;
		elsif(waiting_read and ram_ready = '1') then
			cache(conv_integer(selected_index))(selected_way).data := ram_data_in;
			cache(conv_integer(selected_index))(selected_way).tag:= addr_tag;
			if(ch_wtwb = '1') then
				cache(conv_integer(selected_index))(selected_way).status:= MESI_S;
			else
				cache(conv_integer(selected_index))(selected_way).status:= MESI_E;
			end if;
			rdwr_done <= '1'; -- comunica la terminazione dell'operazione di lettura
			waiting_read := false;
		elsif(not waiting_write and not waiting_read) then
			if(write_line = '1') then
				waiting_write := true;
				ram_address <= cache(conv_integer(selected_index))(selected_way).tag & selected_index;
				ram_data_out <= cache(conv_integer(selected_index))(selected_way).data;
				ram_we <= '1'; -- attiva la scrittura in RAM
			elsif(read_line = '1') then
				waiting_read := true;
				ram_address <= addr_tag & selected_index;
				ram_oe <= '1'; -- attiva la lettura dalla RAM
			end if;
		end if;
	end process cache_ram;
	
	-- Processo di comunicazione con il controllore di memoria:
	-- 	permette di eseguire cicli di snoop;
	-- 	permette di aggiornare lo stato di linee in caso di sistemi multiprocessore;
	-- 	permette di invalidare una linea di cache.
	cache_snoop: process(ch_eads, rdwr_done)
		variable way: integer;
		variable waiting_write: boolean := false;
	begin	
		if(ch_eads = '0') then
			snoop_write <= '0';
		elsif(waiting_write and rdwr_done = '1') then
			waiting_write := false;
		elsif(not waiting_write and ch_eads = '1') then
			get_way(conv_integer(snoop_index), snoop_tag, way);

			if(way >= 0) then
				if(cache(conv_integer(snoop_index))(way).status = MESI_M) then
					waiting_write := true;
					snoop_way <= way;
					snoop_write <= '1';
					ch_hitm <= '1'; -- linea presente in stato MESI_M
				else
					ch_hit <= '1'; -- linea presente in stato MESI_S o MESI_E
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
		
		--DEBUG: segnale commutato per forzare l'aggiornamento del segnale cache_debug
		if(cache_debug_update = '0')then
			cache_debug_update <= '1';
		else
			cache_debug_update <= '0';
		end if;
	end process cache_snoop;

end Behavioral;	