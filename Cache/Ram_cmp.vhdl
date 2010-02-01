library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.CacheLibrary.all;
use work.Global.all;

entity Ram_cmp is
    port (
        address : in std_logic_vector (PARALLELISM - 1 downto OFFSET_BIT); 	-- address Input
        bdata_in : in data_line;				  												-- data bi-directional
        bdata_out : out data_line;
		  write_enable : in std_logic;                               
        read_enable : in std_logic;
		  ram_ready : out std_logic;
		  ram_debug : out RamType (0 to RAM_DEPTH)
    );
end entity;

architecture Behavioral of ram_cmp is

	 signal address_buffer: std_logic_vector (PARALLELISM - 1 downto OFFSET_BIT);
    signal mem : RamType (0 to RAM_DEPTH);
	 
begin
    ram_access: process (write_enable,read_enable) 
	 begin
       if (write_enable = '1' and write_enable'event) or (read_enable = '1' and read_enable'event) then
			address_buffer <= address;
		 end if;
	end process;
	
	async: process(address_buffer) 
	begin
			
			if(write_enable = '1')then
				 mem(conv_integer(address_buffer)) <= bdata_in;
			else
             bdata_out <= mem(conv_integer(address_buffer));
			end if;
			
			ram_debug <= mem;
    end process;
	 
	 ready_p: process
	 begin
			wait until (write_enable = '1' and write_enable'event) or (read_enable = '1' and read_enable'event);
			ram_ready <= '1';
			ram_ready <= '0' after TIME_UNIT/3;
	end process;

end architecture;
