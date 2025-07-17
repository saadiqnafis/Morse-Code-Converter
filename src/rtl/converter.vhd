--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   converter.vhd
-- Description: The converter component for our Morse Code Converter
--------------------------------------------------------------------------------
-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY converter IS
generic(
	TCountMax 		: integer := 13200000);
PORT ( 	clk_port		: 	in 	STD_LOGIC;
	Data_port		: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        New_data_port		:	in	STD_LOGIC;
        morseOut		:	out STD_LOGIC;
        Queue_full_port		:	out STD_Logic);

end converter;

ARCHITECTURE behavior of converter is

--FSM states
type state_type is (idle, ASCIIload, compare, spaceCounterClr, MorseSpace, morseLoad, morseTransmit, inWordCounterClr, MorseInWord);
signal CS, NS : state_type := idle;

--control signals for the FSM
signal Queue_read : std_logic := '0';  --control sign
signal Queue_empty : std_logic := '0'; -- status signal for fsm
signal asciiReg_load, Morse_load, transmit, btwCounterClr : std_logic := '0'; --control sign
signal charValid, isSpace, morseOut_done, MorseInWord_TC, MorseSpace_TC : std_logic := '0'; -- status signal for fsm

--brom components
COMPONENT MorseRom
    PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(18 DOWNTO 0)  );
END COMPONENT;
COMPONENT LengthRom
    PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)  );
END COMPONENT;

--Queue and convert components
Component Queue
PORT ( 	clk		:	in	STD_LOGIC; 
		Write	: 	in 	STD_LOGIC;
		read	: 	in 	STD_LOGIC;
        	Data_in	:	in	STD_LOGIC_VECTOR(7 downto 0);
		Data_out:	out	STD_LOGIC_VECTOR(7 downto 0);
        	Empty	:	out	STD_LOGIC;
        	Full	:	out	STD_LOGIC);
end component;

Component convert
generic (
	   TCountMax : integer);
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
		MorseInWord_TC	:	out STD_LOGIC;
		MorseSpace_TC	:	out STD_Logic;
		morseOut_done	:	out std_logic;
		morseOut	:	out std_logic);
end component;

signal Queue_data_out : std_logic_vector(7 downto 0); -- internal signal to go directly from queue to convert
signal Morse_data : std_logic_vector(18 downto 0); --MorseRom to convert 
signal Length_data : std_logic_vector(4 downto 0);

begin

state_update: process(clk_port)
begin
	if rising_edge(clk_port) then
    	CS <= NS;
    end if;
end process state_update;

next_state_logic : process (cs, queue_empty, charValid, isSpace, MorseSpace_TC, morseOut_done, MorseInWord_TC)
begin
	ns <= cs;
	queue_read <= '0';
    asciiReg_load <= '0'; Morse_load <= '0'; transmit <= '0'; btwCounterClr <= '0';

    case (cs) is
    	when idle =>
        	if queue_empty = '0' then
            ns <= ASCIIload;
            end if;

        when ASCIIload => queue_read <= '1'; 
            asciiReg_load <= '1';
            ns <= compare;

		when compare =>
			if isSpace = '1' then ns <= spaceCounterClr;
			elsif isSpace = '0' and charValid = '1' then ns <= morseLoad;
			elsif charValid = '0' and queue_empty = '1' then
				ns <= idle;
			elsif charValid = '0' and queue_empty = '0' then ns <= ASCIIload;
			end if;

		when morseLoad => Morse_load <= '1';
			transmit <= '1';
			ns <= morseTransmit;

        when morseTransmit => transmit <= '1';
        	if morseOut_done = '1' and queue_empty = '1' then
            	ns <= idle;
            elsif morseOut_done = '1' and queue_empty = '0' then
            	ns <= inWordCounterClr;
            end if;

		when inWordCounterClr => btwCounterClr <= '1';
			ns <= MorseInWord;
		when MorseInWord =>
			if  MorseInWord_TC = '1' then
				ns <= ASCIIload;
				end if;

		when spaceCounterClr => btwCounterClr <= '1';
			ns <= MorseSpace;

		when MorseSpace =>
			if MorseSpace_TC = '1' and queue_empty = '1' then
				ns <= idle;
			elsif MorseSpace_TC = '1' and queue_empty = '0' then
				ns <= ASCIIload;
				end if;

        when others => ns <= idle;
     end case;

end process;

MorseRom1: MorseRom
 PORT MAP (
    clka                => clk_port,
    addra               => Queue_data_out,
    douta               => Morse_data);

LengthRom1: LengthRom
 PORT MAP (
    clka                => clk_port,
    addra               => Queue_data_out,
    douta               => Length_data);

queue1: Queue 
PORT MAP(
	clk => clk_port,
    write => New_data_port,
    read => Queue_read,
    data_in => Data_port,
    data_out => Queue_data_out,
    empty => Queue_empty,
    full => Queue_full_port);

convert1: convert 
generic map(
	TCountMax => TCountMax)
PORT MAP(
	Morse_data => Morse_data,
	Length_data => Length_data,
	clk => clk_port,
  	data_in => Queue_data_out,
    load => morse_load, --control signals
	AR_load => asciiReg_load,
	transmit => transmit,
	btwCounterClr => btwCounterClr, --control signals
	charValid => charValid, --status signals
	isSpace => isSpace,
	MorseInWord_TC => MorseInWord_TC,
	MorseSpace_TC => MorseSpace_TC,
	morseOut_done => morseOut_done, --status signals
    morseOut => morseOut);

end behavior;
