library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.CacheLibrary.all;

entity ram_cmp is
    generic (
        ADDR_WIDTH :integer := 8
    );
    port (
        address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);  -- address Input
        data    :inout data_line;				  -- data bi-directional
        we      :in    std_logic;                                 -- Write Enable/Read Enable
        oe      :in    std_logic;                                 -- Output Enable
		  ready	 :out	  std_logic
    );
end entity;

architecture Behavioral of ram_cmp is
    ----------------Internal variables----------------
    constant RAM_DEPTH :integer := 2**ADDR_WIDTH;

    signal data_out : data_line;

    type RAM is array (integer range <>)of data_line;
    signal mem : RAM (0 to RAM_DEPTH-1);
begin

    ----------------Code Starts Here------------------
    -- Tri-State Buffer control
    data <= data_out when (oe = '1' and we = '0');

    -- Memory Write Block
    MEM_WRITE:
    process (address, data, we) begin
       if (we = '1') then
           mem(conv_integer(address)) <= data;
			  ready <= '1';
		 else
			  ready <= '0';
       end if;
    end process;

    -- Memory Read Block
    MEM_READ:
    process (address, we, oe, mem) begin
        if (we = '0' and oe = '1')  then
             data_out <= mem(conv_integer(address));
				 ready <= '1';
		  else
			    ready <= '0';
        end if;
    end process;

end architecture;
