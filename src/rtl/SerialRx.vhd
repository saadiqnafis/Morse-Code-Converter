--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   SerialRx.vhd
-- Description: Module for SCI receiver
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SerialRx is
generic(
		BAUD_PERIOD 				: integer := 10417);
	PORT(
		Clk : IN std_logic;
		RsRx : IN std_logic;   
		rx_data :  out std_logic_vector(7 downto 0);
		rx_done_tick : out std_logic  );
	END SerialRX;

architecture Behavioral of SerialRx is


signal TC2 : STD_LOGIC := '0';
signal shift_en : STD_LOGIC := '0'; 
signal clr_baud : STD_LOGIC := '0';
signal TC : STD_LOGIC := '0';
signal tc_bit : STD_LOGIC := '0';
signal rx_done : STD_LOGIC := '0';
signal clr_bit : STD_LOGIC := '0';
signal in_wait_TC2 : STD_LOGIC := '0';

--Datapath elements

constant BIT_NUMBER : integer := 10; --Number of bits in each SCI transmission (including start/stop bits)

signal shift_reg	    : std_logic_vector(9 downto 0) := (others => '0');
signal data_reg			: std_logic_vector(7 downto 0) := (others => '0');
signal Baud_cnt : unsigned(13 downto 0) := (others => '0'); -- 6 bits are needed to represent 39. 14 bits to represent 10417
signal Bit_cnt : unsigned(4 downto 0) := (others => '0');

--fsm states
type state_type is (Idle, wait_TC2, Shift, wait_TC, Data_Ready, Data_Send);
signal current_state, next_state : state_type := Idle;

begin

--=============================================================
--Controller:
--=============================================================
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--State Update:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
state_update : process(Clk)
begin	
	if rising_edge(Clk) then
		current_state <= next_state;
	end if;
end process state_update;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Next State Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NextStateLogic: process(current_state,RsRx, tc_bit, TC, TC2)
	begin 
	next_state <= current_state;
	case (current_state) is 
		when Idle => if (RsRx = '0') then
							next_state <= wait_TC2;
						end if;
		when wait_TC2 => if (TC2 = '1') then
							next_state <= Shift;
							end if;
		
		when Shift 	=> if (tc_bit = '0') then
							next_state <= wait_TC;
                            else
                            	next_state <= Data_Ready;
							end if;
        when wait_TC	=> if (TC = '1') then
        					next_state <= Shift;
                            end if;
        when Data_Ready => next_state <= Data_Send;
		when Data_Send => next_state <= Idle;
                            
		when others  => next_state <= Idle;
	end case;
end process NextStateLogic;
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--Output Logic:
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
OutputLogic: process(current_state)
begin
    shift_en <= '0';
    clr_baud <= '0';
    rx_done <= '0';
    rx_done_tick <= '0';
    clr_bit <= '0';
    in_wait_TC2 <= '0';
	
    case(current_state) is
	when Idle => shift_en <= '0';
              clr_baud <= '0';
              rx_done <= '0';
              clr_bit <= '0';
	
	when wait_TC2 => shift_en <= '0';
                  clr_baud <= '0';
                  rx_done <= '0';
					  clr_bit <= '0';
					  in_wait_TC2 <= '1';
	when Data_Ready => rx_done <= '1';				  
	when Shift => shift_en <= '1';
				clr_baud <= '1';
	when Data_Send => rx_done_tick <= '1';
					clr_bit <= '1';
	when others =>
    end case;
end process OutputLogic;
-----------
-- end Controller  
-----------

--=============================================================
--Datapath:
--=============================================================
--====================================
-- Baud Counter:
--====================================
baud_counter : process(Clk, Baud_cnt, clr_baud, in_wait_TC2)
begin
    --Baud Counter
    if rising_edge(clk) then        
        Baud_cnt <= Baud_cnt + 1;
        if (Baud_Cnt = BAUD_PERIOD-1) OR (in_wait_TC2 = '1' and Baud_Cnt = BAUD_PERIOD/2) then --reset at terminal count 
            Baud_Cnt <= (others => '0');
        end if;
    end if;
    --Asynchronous tc and tc2 signal
    TC <= '0';
    TC2 <= '0';
    if Baud_Cnt = BAUD_PERIOD-1 then
    	TC <= '1';
    elsif Baud_Cnt = BAUD_PERIOD/2 then
    	TC2 <= '1';
    end if;
end process baud_counter;

bit_counter : process(Clk, shift_en, Bit_cnt)
begin
	if rising_edge(Clk) then
		if clr_bit = '1' then
			Bit_cnt <= (others => '0');
		elsif shift_en = '1' then
			if Bit_cnt < BIT_NUMBER-1 then
				Bit_cnt <= Bit_cnt + 1;
			else 
				Bit_cnt <= (others => '0');
			end if;
		end if;
	end if;
	tc_bit <= '0';
	if (Bit_cnt = BIT_NUMBER - 1) and (shift_en = '1') then
		tc_bit <= '1';
	end if;
end process bit_counter;

shift_register: process(Clk) 
begin
    if rising_edge(Clk) then
	if shift_en = '1' then shift_reg <= RsRx & shift_reg(9 downto 1);
	end if;
	if rx_done = '1' then data_reg <= shift_reg(8 downto 1);
	end if;	
    end if;
end process;

rx_data <= data_reg;


end Behavioral;
