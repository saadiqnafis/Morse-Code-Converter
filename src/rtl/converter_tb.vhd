--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   converter_tb.vhd
-- Description: A testbench for testing our converter component
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
ENTITY converter_tb IS
END converter_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF converter_tb IS 

component converter is
	generic(
		TCountMax 		: integer);
	PORT ( 	clk_port		: 	in 	STD_LOGIC;
		Data_port		: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        	New_data_port		:	in	STD_LOGIC;
        	morseOut		:	out STD_LOGIC;
        	Queue_full_port		:	out STD_Logic);
end component; 

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_port         : std_logic := '0';
signal Data_port        : std_logic_vector(7 downto 0) := (others => '0');
signal New_data_port    : std_logic := '0';
signal morseOut         : std_logic;
signal Queue_full_port  : std_logic;

-- Clock period definitions
constant clk_period     : time := 10ns;		-- simulating a 100 MHz clock

BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: converter
generic map(
	TCountMax => 20)
port map(
	clk_port	=> clk_port,
	Data_port 	=> Data_port,
	New_data_port	=> New_data_port,
	morseOut	=> morseOut,
	Queue_full_port	=> Queue_full_port);	

--=============================================================
--Timing:
--=============================================================		      
-- Clock process definitions
clk_process: process
begin
    clk_port <= '0';
    wait for clk_period/2;
    clk_port <= '1';
    wait for clk_period/2;
end process;

--=============================================================
--Stimulus Process:
--=============================================================		
stim_proc : process
begin
	wait for CLK_PERIOD*0.25;
	-- Initialize Inputs
        New_data_port <= '0';
        Data_port <= (others => '0');

        wait for clk_period * 10;


        Data_port <= "01010000"; --P
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;

        Data_port <= "01000001"; --A
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;
        
        Data_port <= "01010010"; --R
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;
        
        Data_port <= "01001001"; --I
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;

        Data_port <= "01010011"; --S
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;

	Data_port <= "00100000"; --space
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;
          
        wait for clk_period * 1100; --wait for at least one transmission to be done. 50 periods * 20 clk/period = 1000 clk cycles
        
       	Data_port <= "01100010"; --b
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;
		
	Data_port <= "00110101"; --5
        New_data_port <= '1';  -- Signal that new data is being written
        wait for clk_period;
        New_data_port <= '0';  -- Reset the new data signal
        wait for clk_period * 5;

	--21 periods * 20 clk cycles/period=420 clk cycles
	wait for clk_period * 420;

	wait;
end process stim_proc;

END;
