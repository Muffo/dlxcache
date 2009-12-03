----------------------------------------------------------------------------------
-- Company: Gruppo 2
-- Engineer: Grandi, Malaguti, Mattetti, Morlini, Ricci
-- 
-- Create Date:    10:29:02 12/01/2009 
-- Design Name: 
-- Module Name:    Cache_cmp - Behavioral 
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

alias addr_tag is ch_baddr(OFFSET_BIT + INDEX_BIT + TAG_BIT - 1 downto OFFSET_BIT + INDEX_BIT);
alias addr_index is ch_baddr(OFFSET_BIT + INDEX_BIT - 1 downto OFFSET_BIT);
alias addr_offset is ch_baddr(OFFSET_BIT - 1 downto 0);

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
			
			-- per test
			cache(0)(0).status <= MESI_E;
			cache(0)(0).data(0)(7 downto 0) <= (others => '1');
			cache(0)(0).data(1)(7 downto 0) <= (others => '0');
			cache(0)(0).data(2)(7 downto 0) <= (others => '1');
			cache(0)(0).data(3)(7 downto 0) <= (others => '1');
		end if;
	end process cache_reset;
	
	cache_read: process(ch_memrd) is
		variable word : STD_LOGIC_VECTOR (31 downto 0) := (others => '1');
	begin
		if(ch_memrd = '1') then
			for i in 0 to NWAY - 1 loop
				if(cache(conv_integer(addr_index))(i).status /= MESI_I and cache(conv_integer(addr_index))(i).tag = addr_tag) then -- HIT
					word(7 downto 0) := cache(conv_integer(addr_index))(i).data(conv_integer(addr_offset));
					word(15 downto 8) := cache(conv_integer(addr_index))(i).data(conv_integer(addr_offset + 1));
					word(23 downto 16) := cache(conv_integer(addr_index))(i).data(conv_integer(addr_offset + 2));
					word(31 downto 24) := cache(conv_integer(addr_index))(i).data(conv_integer(addr_offset + 3));
				end if;
			end loop;
			ch_bdata <= word;
		end if;
	end process cache_read;

end Behavioral;	

