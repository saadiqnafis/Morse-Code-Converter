--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   Convert_tb.vhd
-- Description: A testbench for testing our convert sub-component
--------------------------------------------------------------------------------
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY convert_tb IS
END convert_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF convert_tb IS 

component convert is
	generic(
		TCountMax 	:   integer);
	PORT ( 	Morse_data  	:   in  std_logic_vector(18 downto 0);
        	Length_data 	:   in std_logic_vector(4 downto 0);
        	clk		: 	in 	STD_LOGIC;
		Data_in		: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        	Load		:	in	STD_LOGIC;
		AR_load		:	in	STD_LOGIC;
		transmit	:	in	std_logic;
		btwCounterClr	:	in	std_logic;
		charValid	:	out	std_logic;
		isSpace		:	out	std_logic;
		MorseInWord_TC	:	out STD_LOGIC;
		MorseSpace_TC	:	out STD_Logic;
		morseOut_done	:	out std_logic;
		morseOut	:	out std_logic);
end component; 

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk          : std_logic := '0';

signal Load       : std_logic := '0';
signal AR_load      : std_logic := '0';
signal transmit         : std_logic := '0' ;
signal btwCounterClr	: std_logic := '0';

signal Morse_data         : std_logic_vector(18 downto 0) := (others => '0');
signal Length_data         : std_logic_vector(4 downto 0) := (others => '0');
signal Data_in         : std_logic_vector(7 downto 0) := (others => '0');

--signal for output
signal charValid, isSpace, MorseInWord_TC, MorseSpace_TC, morseOut_done, morseOut	:	std_logic;

-- Clock period definitions
constant clk_period     : time := 10ns;		-- 100 MHz clock
	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: convert
generic map(
	TCountMax => 4)
port map(
		Morse_data	=> Morse_data,
        	Length_data	=> Length_data,
        	clk		=> clk,
		Data_in		=> Data_in,
        	Load		=> Load,
		AR_load		=> AR_load,
		transmit	=> transmit,
		btwCounterClr	=> btwCounterClr,
		charValid	=> charValid,
		isSpace		=> isSpace,
		MorseInWord_TC	=> MorseInWord_TC,
		MorseSpace_TC	=> MorseSpace_TC,
		morseOut_done	=> morseOut_done,
		morseOut	=> morseOut);	

--=============================================================
--Timing:
--=============================================================		      
-- Clock process definitions
clk_process : process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

stim_proc : process
begin
	wait for CLK_PERIOD*0.25;
	-- simulating the processing of uppercase I, T set to be 4 clock cycles
	Load <= '0';
	AR_load <= '1';

	Morse_data <= "1111111111111111111"; 
	Length_data <= "00000";
	Data_in <= "01001001";
	transmit <= '0'; --despite LMB of Morse_data = 1, since transmit = 0 morseOut = 0
	btwCounterClr <= '0';
    

        wait for CLK_PERIOD*2;
	Load <= '1';
	AR_load <= '0';

	Morse_data <= "1010000000000000000"; --uppercase I (. .)
	Length_data <= "00011";
	transmit <= '1';

	wait for CLK_PERIOD;
	Load <= '0';

	wait for CLK_PERIOD*14; --mmorsecode representation of I should be transmitted
	
	AR_load <= '1';
	Data_in <= "00100000"; --space, isSpace and charValid should assert

	wait for clk_period*2;
	Data_in <= "00110000"; -- ascii representation of 0
	wait for clk_period *2;
	Data_in <= "01000001"; -- ascii A
	wait for clk_period * 2;
	Data_in <= "01100001"; --ascii a. In all these cases charValid should assert, isSpace should be 0
	
	wait for clk_period * 2;
	data_in <= "01000000"; --ascii . charValid should be 0
    wait for CLK_PERIOD*2;

    
    wait;
end process stim_proc;

END;
