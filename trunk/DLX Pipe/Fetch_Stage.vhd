library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.Global.all;

entity Fetch_Stage is
	port (
		-- uscite standard
		clk: in std_logic;
		reset: in std_logic;
		force_jump: in std_logic;
		pc_for_jump: in std_logic_vector(PC_BITS-1 downto 0);
		instruction: out std_logic_vector(PARALLELISM-1 downto 0);
		pc: out std_logic_vector(PC_BITS-1 downto 0)
	);
end Fetch_Stage;

architecture Arch1_Fetch_Stage of Fetch_Stage is

-- segnale utilizzato internamente all'architecture per il program counter
signal pc_reg: std_logic_vector(PC_BITS-1 downto 0) := (others => '0');	

-- valore di inizializzazione del program counter (30 bit a 0)
constant PC_INIT: std_logic_vector(PC_BITS-1 downto 0) := (others => '0');

-- La memoria con il codice macchina del DLX
constant EPROM_inst: eprom_type(0 to 11) := (
X"20010000",	--l1: addi r1,r0,0 ; azzera r1
X"20020001",	--l2: addi r2,r0,1 ; imposta a 1 r2
X"AC220000",	--l3: sw 0(r1),r2 ; memorizzza il valore 1 all'indirizzo 0(via 1 dell index0)
X"20420001",	--l4: addi r2,r2,1 ; incrementa r2
X"AC220100",	--l5: sw 16#100(r1),r2 ; memorizzza il valore di r2 all'indirizzo 16#100(via 0 dell index0)
X"20420001",	--l6: addi r2,r2,1 ; incrementa r2
X"AC220080",	--l7: sw 16#80(r1),r2 ; memorizzza il valore di r2 all'indirizzo 16#80(replacement via 1 dell index0) 
X"8C220000",	--l8: lw r2,0(r1) ; ripristina valore iniziale di r2 (1)
X"20210004",	--l9: addi r1,r1,4 ; incremento di 4 indirizzo di base in r1
X"0BFFFFE0",	--l10: j l3 ;
X"FFFFFFFF",	--NOP 
X"FFFFFFFF"		--NOP
											);


begin
		
		sync: process(clk, reset) begin

			if reset = '1' then
				pc_reg <= PC_INIT;	
			else
			
			-- se il reset non è asserito verifica se si è 
			-- verificato un fronte di salita del clock	
				
				if clk'event and clk = '1' then
					if force_jump = '1' then
						pc_reg <= pc_for_jump + 1;
					else
						pc_reg <= pc_reg + 1;
					end if;
				end if;
			end if;
			
		end process sync;
		

		async: process (pc_reg, reset, force_jump, pc_for_jump) 
		begin
			-- verifica se è asserito il reset e in caso affermativo prepara una NOP per lo stadio successivo (ID)
			-- e invia ID PC_INIT come indirizzo 
			if reset = '1' then
				instruction <= (others => '1');
				pc <= PC_INIT;
			else
				if force_jump = '1' then
					-- Se force_jump (da J&B EX) è asserito esegue il fetch della istruzione all'indirizzo di destinazione 
					-- del salto (ovvero a all'indirizzo pc_for_jump (opportunamente esteso) fornito da J&B di EX)
					instruction <= EPROM_inst(conv_integer(PC_EXT & pc_for_jump));
					
					-- Invia il program counter, con la destinazione del salto, all'uscita per essere 
					-- campionato dallo stadio successivo (ID)
					pc <= pc_for_jump;					
				else
					-- Altrimenti esegue un fetch tradizionale della istruzione successiva (il valore del 
					-- program counter è stato incrementato di +4 (, ovvero +1 con 30 bit), dal processo
					-- sync sul fronte di salita del clock)
					instruction <= EPROM_inst(conv_integer(PC_EXT & pc_reg)); 
					-- trasforma l'indice a 32 bit aggungendo i due bit più significativi a 00 per poter fare la 
					-- conversione a intero ma l'indirizzo deve ancora essere "interpretato" a 30 bit perchè la 
					-- EPROM contiene WORD a 32 bit e non byte
					
					
					-- Invia il program counter all'uscita per essere campionato dallo stadio successivo (ID)
					pc <= pc_reg;
				end if;
			end if;
		end process async;		
		
end Arch1_Fetch_Stage;

