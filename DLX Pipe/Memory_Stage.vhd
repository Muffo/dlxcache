library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Global.all;

library UNISIM;
use UNISIM.VComponents.all;

entity Memory_Stage is
	port (
		clk: in std_logic;
		ready: in std_logic;
		memrd: out std_logic;
		memwr: out std_logic;
		pc_in: in std_logic_vector(PC_BITS-1 downto 0);
		pc_out: out std_logic_vector(PC_BITS-1 downto 0);
		instruction_format_in: in std_logic_vector(2 downto 0);
		instruction_format_out: out std_logic_vector(2 downto 0);
		instruction_in: in std_logic_vector(PARALLELISM-1 downto 0);
		instruction_out: out std_logic_vector(PARALLELISM-1 downto 0);		
		memory_data_register: in std_logic_vector(PARALLELISM-1 downto 0);
		store_memory_data_register: out std_logic_vector(PARALLELISM-1 downto 0);
		load_memory_data_register: in std_logic_vector(PARALLELISM-1 downto 0);
		memory_address_register: out std_logic_vector(PARALLELISM-1 downto 0);
		alu_exit_in: in std_logic_vector(PARALLELISM-1 downto 0);
		data_out: out std_logic_vector(PARALLELISM-1 downto 0);
		
		-- forwarding unit
		dest_register: out std_logic_vector(4 downto 0);
		dest_register_data: out std_logic_vector(PARALLELISM-1 downto 0)
	);
end Memory_Stage;

architecture Arch1_Memory_Stage of Memory_Stage is
	
	signal pc_buffer: std_logic_vector(PC_BITS-1 downto 0);
	signal instruction_buffer: std_logic_vector(PARALLELISM-1 downto 0) := (others => '1');
	signal instruction_format_buffer: std_logic_vector(2 downto 0) := IF_NOP;
	
	signal memory_data_register_buffer: std_logic_vector(PARALLELISM-1 downto 0);
	signal alu_exit_buffer: std_logic_vector(PARALLELISM-1 downto 0);
	
	alias a_opcode_high is instruction_buffer(31 downto 26); -- codice operativo istruzioni tipo I e J
	alias a_opcode_low is instruction_buffer(5 downto 0); -- codice operativo istruzioni tipo R
	alias a_rd_r is instruction_buffer(15 downto 11); -- registro destinatione instruzioni di tipo R
	alias a_rd_i is instruction_buffer(20 downto 16); -- registro destinazione istruzioni di tipo I
	
	begin
		
		async: process
		begin			
				wait on a_opcode_high, alu_exit_buffer, memory_data_register_buffer, instruction_format_buffer, instruction_buffer;
				memrd <= '0';
				memwr <= '0';
				-- esecuzione istruzioni di load e store + forwarding unit
				if instruction_format_buffer = IF_R or instruction_format_buffer = IF_F then -- nessuna operazione di memoria
					dest_register <= a_rd_r;
					dest_register_data <= alu_exit_buffer;
					data_out <= alu_exit_buffer;
				elsif instruction_format_buffer = IF_I or instruction_format_buffer = IF_J or instruction_format_buffer = IF_IF then -- istruzioni I, IF e J
					case a_opcode_high is
						when I_LW | IF_LF =>  -- Load Word e Load Float. Forwarding del dato appena letto
							memory_address_register <= alu_exit_buffer;
							memrd <= '1';	
							wait until ready = '1' and ready'event;
							memrd <= '0' after TIME_UNIT/3;
							dest_register <= a_rd_i;
							dest_register_data <= load_memory_data_register;
							data_out <= load_memory_data_register;	
						when I_SW | IF_SF => -- Store Word e Store Float. il register file resta inalterato, non � necessario il forwarding
							dest_register <= (others => '0');
							dest_register_data <= (others => '0');
							data_out <= alu_exit_buffer;
							store_memory_data_register <= memory_data_register_buffer; 
							memory_address_register <= alu_exit_buffer;
							memwr <= '1';
							wait until ready = '1' and ready'event;
							memwr <= '0' after TIME_UNIT/3;
						when I_JALR | J_JAL => -- il registro di destinazione � sicuramente R31. Il dato �
												-- l'uscita della alu
							dest_register <= conv_std_logic_vector(31, REGISTER_ADDR_LEN);
							dest_register_data <= alu_exit_buffer;
							data_out <= alu_exit_buffer; 
						when J_J | I_JR | I_BNEZ | I_BEQZ => -- il register file resta inalterato, forwarding non necessario
							dest_register <= (others => '0');
							dest_register_data <= (others => '0');
							data_out <= alu_exit_buffer;
						when others => -- istruzioni di tipo I diverse da quelle sopra
							dest_register <= a_rd_i;
							dest_register_data <= alu_exit_buffer;
							data_out <= alu_exit_buffer;
					end case;
				else -- nop						
					dest_register <= (others => '0');
					dest_register_data <= (others => '0');
					data_out <= (others => '0');
				end if;
					
		end process;
		
		-- campionamento degli ingressi
		sync: process 
		begin
			wait until clk'event and clk = '1';
			pc_buffer <= pc_in;
			instruction_buffer <= instruction_in;
			instruction_format_buffer <= instruction_format_in;
			alu_exit_buffer <= alu_exit_in;
			memory_data_register_buffer <= memory_data_register;
		end process;
	
	
		-- aggiornamento segnali di uscita per stadio successivo
		pc_out <= pc_buffer;
		instruction_out <= instruction_buffer;
		instruction_format_out <= instruction_format_buffer;
		
	end Arch1_Memory_Stage;

