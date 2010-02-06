----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:27:43 02/02/2010 
-- Design Name: 
-- Module Name:    BlockRam_cmp - Behavioral 
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

use work.BlockRamLibrary.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity BlockRam_cmp is
port(
	reset: in std_logic;
   addr:in std_logic_vector (ADDR_BIT-1 downto 0);  -- address Input
	clk:in 	std_logic;
	br_clk:in std_logic;
   bdata_in: in mem_line;
	memrd:in std_logic;                                 
   memwr:in std_logic; 
	en:in std_logic;         -- Ram Enable
	bdata_out: out mem_line;
	addr_m:out std_logic_vector (ADDR_BIT-1 downto 0); --segnale di debug per indirizzi inviati alla BlockRam
   ready:out	std_logic

);
end BlockRam_cmp;

architecture Behavioral of BlockRam_cmp is

-- Dichiarazione del componente Block Ram RAMB16_S9 (ram depth: 2048 data width: 8 bit + parity bit)

component RAMB16_S9 --DATA_WIDTH=8 RAM_DEPTH=2048

--configurazione attributi della Block Ram
generic (
	
	WRITE_MODE : string := "READ_FIRST" ; -- WRITE_FIRST(default)/ READ_FIRST/NO_CHANGE
	
	-- valore in output dopo inizializzazione
	INIT : bit_vector(35 downto 0) := X"000000000";
	
	-- valore letto in caso di asserimento del segnale SSR
	SRVAL : bit_vector(35 downto 0) := X"000000000";
	
	-- Inizializzazione del contenuto della Block Ram
	 INIT_00 : bit_vector := X"F0000000000000000000000000000000000000000000000000000000000000FF";
    INIT_01 : bit_vector := X"100000000000000000000000000000000000000000000000000000000000000F";
    INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000012";
    INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000100";
    INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000101";
    INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3F : bit_vector := X"000000000000000000000000000000000000000000000000000000000000000F"
	);
	
	port(
		DI: in std_logic_vector (DATA_WIDTH-1 downto 0);
		DIP: in std_logic_vector (0 downto 0);
		DO: out std_logic_vector (DATA_WIDTH-1 downto 0);
		DOP: out std_logic_vector (0 downto 0);
		ADDR: in std_logic_vector (ADDR_BIT-1 downto 0);
		WE: in std_logic;
		EN: in std_logic;
		CLK: in std_logic;
		SSR: in std_logic
	);
end component;

	--Segnali per l'interfacciamento interno con la Block Ram
	signal br_data_in: std_logic_vector (DATA_WIDTH-1 downto 0):=conv_std_logic_vector(0,DATA_WIDTH);
	signal br_data_out: std_logic_vector (DATA_WIDTH-1 downto 0):=conv_std_logic_vector(0,DATA_WIDTH);
	signal br_parity_in: std_logic_vector (0 downto 0):="0";
	signal br_parity_out: std_logic_vector (0 downto 0):="0";
	signal br_addr: std_logic_vector (ADDR_BIT-1 downto 0):=conv_std_logic_vector(0,ADDR_BIT);
	signal br_en: std_logic:='0';
	signal br_we: std_logic:='0';
	signal br_ssr: std_logic:='0';
	
	--Variabili condivise tra i processi
	shared variable counter : natural := 0; --contatore per gli accessi in block ram per letture e scritture di linee
	shared variable line: mem_line;
	shared variable written_line: mem_line;
	shared variable stato_ready: std_logic := '0';
	shared variable temp_byte: std_logic_vector(7 downto 0);
	shared variable line_r: mem_line;
	
	--Segnali di sincronizzazione tra processi
	signal line_ready: std_logic :='0';
	signal blockRam_read: std_logic := '0';
	signal blockRam_write: std_logic := '0';
	
	
	begin
	
	RAMB16_S9_inst : RAMB16_S9
	port map
	(
		DI => br_data_in (DATA_WIDTH-1 downto 0),
		DIP => br_parity_in,
		DO => br_data_out (DATA_WIDTH-1 downto 0),
		DOP => br_parity_out,
		ADDR => br_addr (ADDR_BIT-1 downto 0),
		WE => br_we,
		EN => br_en,
		CLK => br_clk,
		SSR => br_ssr
		);
	
	--processo che gestisce i segnali che arrivano al componente BlockRam_cmp e comanda l'avvio 
	--delle operazioni corrispondenti con accessi in sequenza alla Block Ram BRAM16_S9 interna.
	main : process(clk)
	begin
	if(clk'event and clk='1') then
		if(en='1') then
			if(memwr='1' and memrd='0') then --scrittura su block ram di una linea
				line := bdata_in;
				blockRam_write <= '1';
			elsif(memwr='0' and memrd='1') then -- lettura da block ram di una linea
				blockRam_read <= '1';
			else -- attivi o disattivi entrambi i segnali di lettura e scrittura
				blockRam_write <= '0';
				blockRam_read <= '0';
			end if;
		else --en=0
			blockRam_write <= '0';
			blockRam_read <= '0';
		end if;
	end if;
	
	end process main;
	
	--Processo che gestisce gli accessi sequenziali alla Block Ram in sincronia col clock br_clk.
	blockram_access_seq : process(br_clk)
	begin
		if(br_clk'event and br_clk='1') then
			if(line_ready='0' and (blockRam_read='1' xor blockRam_write='1')) then --accedo alla Block Ram
				
				if (counter=0) then
					br_addr <= addr;
					addr_m <= addr;
				else
					br_addr <= br_addr + 1;
					addr_m <= br_addr + 1;
				end if;
			
				if(blockRam_write='1') then --scrittura su block ram
					br_en <= '1';
					br_we <= '1';
					br_ssr <= '0';
					temp_byte := line(counter);
					written_line(counter) := br_data_out; -- per debug del dato scritto in BlockRam [WRITE_MODE = WRITE_FIRST]
					br_data_in<=temp_byte;
				elsif(blockRam_read='1') then --lettura da block ram
					br_en <= '1';
					br_we <= '0';
					br_ssr <= '0';
					line_r(counter) := br_data_out;
				else
					br_en <= '0';
					br_we <= '0';
					br_ssr <= '0';
				end if;
				
				counter := counter + 1;
				
				if(counter = nbyte_line) then
					line_ready <= '1';
				--else
					--line_ready <= '0';
				end if;
			else
				br_en <= '0';
				br_we <= '0';
				br_ssr <= '0';
				if(stato_ready = '1') then--prova
					line_ready<='0';
					stato_ready := '0';
				end if;
			end if;
		end if;
	end process blockram_access_seq;
	
	--Processo che gestisce la terminazione di un ciclo d'accesso sequenziale alla Block Ram.
	--Il processo asserisce il segnale di ready per indicare il termine di un'operazione e in
   --caso di lettura trasmette la linea appena letta sul bus dati di output (bdata_out).
	end_blockram_access : process(clk)
	begin
	if(clk'event and clk='1') then
		if(line_ready='1') then
		
			counter := 0; --azzero contatore degli accessi alla block ram

			if(blockRam_read='1') then --lettura su block ram
				bdata_out <= line_r; --devo fornire linea letta a cache
			
			elsif(blockRam_write='1') then --scrittura su block ram
				bdata_out <= written_line; --[per debug] utilizzando la WRITE_MODE = WRITE_FIRST ad ogni scrittura in Block Ram si ha il dato scritto in memoria in output su DO (bus dati di output)
			end if;
			
			--line_ready <= '0';
			stato_ready := '1';
			ready <= '1';--operazione completata	
			ready <= '0' after 100ns;
			
		--else
			--ready <= '0';
		end if;
	end if;
	end process end_blockram_access;

	
end Behavioral;

