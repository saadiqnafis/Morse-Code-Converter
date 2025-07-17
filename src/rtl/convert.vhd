--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   Convert.vhd
-- Description: Our convert sub-component under the converter component
--------------------------------------------------------------------------------
-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY convert IS
generic(
		TCountMax 				: integer := 13200000);
PORT ( 	Morse_data  :   in  std_logic_vector(18 downto 0);
        Length_data :   in std_logic_vector(4 downto 0);
        clk			: 	in 	STD_LOGIC;
		Data_in		: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        Load		:	in	STD_LOGIC;
		AR_load		:	in	STD_LOGIC;
		transmit	:	in	std_logic;
		btwCounterClr	:	in	std_logic;
		charValid	:	out	std_logic;
		isSpace		:	out	std_logic;
        MorseInWord_TC			:	out STD_LOGIC;
        MorseSpace_TC		:	out STD_Logic;
		morseOut_done	:	out std_logic;
		morseOut	:	out std_logic);
end convert;


ARCHITECTURE behavior of convert is

constant num_space : integer := 4;
constant num_inWord : integer := 3;

signal Morse_Reg : std_logic_vector(18 downto 0) := (others => '0');

signal length_Reg : unsigned(4 downto 0) := (others => '0');
signal asciiReg : unsigned(7 downto 0) := (others => '0');


signal T_Counter : unsigned(24 downto 0) := (others => '0'); -- 25 bits are needed to represent max value: 33554431, typical val: 13200000
signal morseCodeBit_Counter : unsigned (4 downto 0) := (others => '0');
signal space_counter, inWord_Counter : unsigned(1 downto 0) := (others => '0');

signal T_TC : std_logic := '0';
signal MorseOut_done_sig, MorseSpace_TC_sig, MorseInWord_TC_sig : std_logic := '0'; --internal sign



BEGIN
datapath : process(clk, T_Counter, space_counter, inWord_Counter, T_tc, Morse_Reg, morseCodeBit_Counter, Length_Reg, transmit, asciiReg)
begin
    --T Counter
	if rising_edge(clk) then
        T_Counter <= T_Counter + 1;
        if T_tc = '1' then
            T_Counter <= (others => '0');
        end if;
        if load = '1' then
        	T_Counter <= (others => '0');
        end if;
    end if;

	    --asynchronous TC
    T_tc <= '0';
    if T_Counter = TCountMax-1 then
        T_tc <= '1';
    end if;
    
    --space Counter
    if rising_edge(clk) then
    	if T_tc = '1' then
        	space_Counter <= space_Counter + 1;
        	if MorseSpace_TC_sig = '1' then
            	space_Counter <= (others => '0');
	        end if;
        end if;
        if btwCounterClr = '1' then
        	space_Counter <= (others => '0');
        end if;
    end if;
    
    --asynchronous TC
    MorseSpace_TC_sig <= '0';
    if (space_Counter = num_space-1) AND (T_tc = '1') then
        MorseSpace_TC_sig <= '1';
    end if;

	--in word Counter
    if rising_edge(clk) then
    	if T_tc = '1' then
        	inWord_Counter <= inWord_Counter + 1;
        	if MorseInWord_TC_sig = '1' then
            	inWord_Counter <= (others => '0');
	        end if;
        end if;
        if btwCounterClr = '1' then
        	inWord_Counter <= (others => '0');
        end if;
    end if;
    
    --asynchronous TC
    MorseInWord_TC_sig <= '0';
    if (inWord_Counter = num_inWord-1) AND (T_tc = '1') then
        MorseInWord_TC_sig <= '1';
    end if;
    
        --Morse Register and Length_Reg ----------------
	if rising_edge(clk) then        
        if (load = '1') then
        	Morse_Reg <= Morse_data; -- Concatenate the start and stop bits
            Length_Reg <= unsigned(Length_data);
        
        elsif (T_tc = '1') then
        	Morse_Reg <= Morse_Reg(17 downto 0) & '0'; --shift the bits and add an idle bit to the MSB 
        end if;
    end if;

    --morseCodeBit_Counter
    if rising_edge(clk) then
    	if T_tc = '1' then
        	morseCodeBit_Counter <= morseCodeBit_Counter + 1;
        	if MorseOut_done_sig = '1' then
            	morseCodeBit_Counter <= (others => '0');
	        end if;
        end if;
        if load = '1' then
        	morseCodeBit_Counter <= (others => '0');
        end if;
    end if;
    --asynchronous TC
    MorseOut_done_sig <= '0';
    if (morseCodeBit_Counter = length_Reg-1) AND (T_tc = '1') then
        MorseOut_done_sig <= '1';
    end if;


	-- ascii Register
	if rising_edge(clk) then        
        if (AR_load = '1') then
        	asciiReg <= unsigned(Data_in); -- Concatenate the start and stop bits
        	end if;
    end if;

	-- determine isSpace,charValid
	isSpace <= '0';
	if asciiReg = "00100000" then
		isSpace <= '1';
		end if;
	charValid <= '0';
	if (asciiReg = "00100000") or ((asciiReg > "01100000") and (asciiReg < "01111011")) or ((asciiReg > "01000000") and (asciiReg < "01011011")) or ((asciiReg > "00101111") and (asciiReg < "00111010")) then
		charValid <= '1';
		end if;


	morseOut <= Morse_Reg(18);
	if transmit = '0' then	
		morseOut <= '0';
		end if;

    end process datapath;
    
    
--Tx <= Shift_Reg(0);
morseOut_done <= MorseOut_done_sig;

MorseSpace_TC <= MorseSpace_TC_sig;
MorseInWord_TC <= MorseInWord_TC_sig;

End Behavior;        
