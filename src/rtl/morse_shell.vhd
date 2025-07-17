--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   Morse_shell.vhd
-- Description: The top level shell for our Morse Code Converter
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing
library UNISIM;					-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

--=============================================================
--Shell Entitity Declarations
--=============================================================
entity Morse_shell is
port (  
	Clk_ext_port     	  : in  std_logic;						--ext 100 MHz clock
	
	RsRx		  : in  std_logic;	
	RsTx		: out std_logic;				
	MorseOut	      : out std_logic;		--LED1
	Queue_full_port			  : out std_logic;    
	soundOut	: out std_logic);					--LED2
end Morse_shell; 

--=============================================================
--Architecture + Component Declarations
--=============================================================
architecture Behavioral of Morse_shell is


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
component SerialRX 
generic(
		BAUD_PERIOD : integer := 10417);
	PORT(
		Clk : IN std_logic;
		RsRx : IN std_logic;   
		rx_data :  out std_logic_vector(7 downto 0);
		rx_done_tick : out std_logic  );
	END COMPONENT;

component SCI_Tx
generic(
		BAUD_PERIOD 	: integer := 10417);
PORT ( 	clk			: 	in 	STD_LOGIC;
	Parallel_in		: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        New_data		:	in	STD_LOGIC;
        Tx			:	out STD_LOGIC);
end COMPONENT;

component converter IS
generic(
		TCountMax 				: integer := 13200000);
PORT ( 	clk_port		: 	in 	STD_LOGIC;
	Data_port		: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        New_data_port		:	in	STD_LOGIC;
        morseOut		:	out STD_LOGIC;
        Queue_full_port		:	out STD_Logic);
        --queue_empty_port: out std_logic);
end COMPONENT;

component sound is
    generic (FREQUENCY_DIVIDER_RATIO : integer := 100000);
	port (
        input_clk_port		: in std_logic;
        MorseOut            	: in std_logic;
        soundOut	    	: out std_logic);
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
signal New_data_port      : std_logic := '0';                   
signal Data_port         : std_logic_vector(7 downto 0) := (others => '0');	

signal MorseOut_sig		: std_logic := '0';

--=============================================================
--Port Mapping + Processes:
--=============================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SerialRX1: SerialRX 
generic map(
		BAUD_PERIOD => 10417)
port map(
	Clk		=> Clk_ext_port,
	RsRx	=> RsRx,
	rx_data	=> Data_port,
	rx_done_tick	=> New_data_port	);

Transmitter: SCI_Tx 
generic map(
		BAUD_PERIOD => 10417)
PORT MAP(
	CLK => Clk_ext_port,
	Parallel_in => Data_port,
	New_data => New_data_port,
	Tx => RsTx);
	
converter1: converter 
generic map(
	TCountMax => 13200000)
port map( 
    clk_port 		=> Clk_ext_port,	       -- runs on the 1 MHz clock
    Data_port 		=> Data_port, 		        
    New_data_port 		=> New_data_port, 	
    morseOut 		=> MorseOut_sig, 		
    Queue_full_port 		=> Queue_full_port	);	

sound1: sound
generic map(FREQUENCY_DIVIDER_RATIO => 100000)
port map(
	input_clk_port	    => Clk_ext_port,
	MorseOut            => MorseOut_sig,
	soundOut	    => soundOut	);

MorseOut <= MorseOut_sig;

end Behavioral; 
