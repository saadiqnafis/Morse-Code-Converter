--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   SerialTx.vhd
-- Description: Our Component Serial Trasmitter
-- Code Adopted from Professor Luke's solution code of Homework 5
--------------------------------------------------------------------------------
-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY SCI_Tx IS
generic(
		BAUD_PERIOD 				: integer := 10417);
PORT ( 	clk			: 	in 	STD_LOGIC;
		Parallel_in	: 	in 	STD_LOGIC_VECTOR(7 downto 0);
        New_data	:	in	STD_LOGIC;
        Tx			:	out STD_LOGIC);
end SCI_Tx;


ARCHITECTURE behavior of SCI_Tx is


--Datapath elements

signal Shift_Reg : std_logic_vector(9 downto 0) := (others => '1');
signal Baud_Counter : unsigned(13 downto 0) := (others => '0'); -- 14 bits are needed to represent 10417 (9600 baud rate).

signal tc : std_logic := '0';

BEGIN

--Datapath
datapath : process(clk, Baud_Counter)
begin
	if rising_edge(clk) then
    	
        --Baud Counter
        Baud_Counter <= Baud_Counter + 1;
        if tc = '1' then
            Baud_Counter <= (others => '0');
        end if;
        if New_data = '1' then
        	Baud_Counter <= (others => '0');
        end if;
    end if;
    
    --asynchronous TC
    tc <= '0';
    if Baud_Counter = BAUD_PERIOD-1 then
        tc <= '1';
    end if;
        
        --Shift Register
	if rising_edge(clk) then        
        if (New_data = '1') then
        	Shift_Reg <= '1' & Parallel_in & '0'; -- Concatenate the start and stop bits
        
        elsif (tc = '1') then
        	Shift_Reg <= '1' & Shift_Reg(9 downto 1); --shift the bits and add an idle bit to the MSB 
        end if;
    end if;
end process datapath;

Tx <= Shift_Reg(0);


end behavior;
        
        
