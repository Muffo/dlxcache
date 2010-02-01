library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CacheLibrary.all;

entity ram_cmp is
    generic (
        ADDR_WIDTH :integer := 8
    );
    port (
		  reset: in std_logic;
        address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);  -- address Input
        data_in: in data_line;
		  data_out: out data_line;
        we      :in    std_logic;                                 -- Write Enable/Read Enable
        oe      :in    std_logic;                                 -- Output Enable
		  ready	 :out	  std_logic
    );
end entity;

architecture Behavioral of ram_cmp is
    ----------------Internal variables----------------
    constant RAM_DEPTH :integer := 2**ADDR_WIDTH;

    type RAM is array (integer range <>)of data_line;
    shared variable mem : RAM (0 to RAM_DEPTH-1);
begin

    ----------------Code Starts Here------------------

	process (we, oe, reset) begin
		if(reset = '1') then
			for i in 0 to RAM_DEPTH-1 loop
				for j in 0 to 2**OFFSET_BIT - 1 loop
					mem(i)(j) := conv_std_logic_vector(j, 8);
				end loop;
			end loop;
		elsif (we = '1' and oe = '0') then
			mem(conv_integer(address)) := data_in;
			ready <= '1' after 5 ns;
		elsif (we = '0' and oe = '1')  then
			data_out <= mem(conv_integer(address));
			ready <= '1' after 5 ns;
		elsif (we = '0' and oe = '0') then
			ready <= '0' after 5 ns;
		end if;
	end process;

end architecture;