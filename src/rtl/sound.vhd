--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   sound.vhd
-- Description: The sound component for our Morse Code Converter
--------------------------------------------------------------------------------
--=============================================================================
--Library Declarations:
--=============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
library UNISIM;
use UNISIM.VComponents.all;

--=============================================================================
--Entity Declaration:
--=============================================================================
entity sound is
    generic (FREQUENCY_DIVIDER_RATIO : integer := 100000);
	port (
        input_clk_port		: in std_logic;
        MorseOut            : in std_logic;
        soundOut	    : out std_logic);
end sound;

--=============================================================================
--Architecture Type:
--=============================================================================
architecture behavioral_architecture of sound is
--=============================================================================
--Signal Declarations:
--=============================================================================
--CONSTANT FOR SYNTHESIS:
constant DIVIDER_TC: integer := FREQUENCY_DIVIDER_RATIO/2;
--CONSTANT FOR SIMULATION:
--constant DIVIDER_TC: integer := 5;

--Automatic register sizing:
constant COUNT_LEN					: integer := integer(ceil( log2( real(DIVIDER_TC) ) ));
signal divider_counter	: unsigned(COUNT_LEN-1 downto 0) := (others => '0');
signal tog				: std_logic := '0';

--=============================================================================
--Processes:
--=============================================================================
begin
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- (frequency) Divider):
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
freq_divider: process(input_clk_port)
begin
	if rising_edge(input_clk_port) then
	   	if divider_counter = DIVIDER_TC-1 then 	  -- Counts to 1/2 clk period
	   		tog <= NOT(tog);        		      -- T flip flop
			divider_counter <= (others => '0');			  -- Reset
		else
			divider_counter <= divider_counter + 1; -- Count up
		end if;
	end if;
end process freq_divider;

soundOut <= (tog and MorseOut); 


end behavioral_architecture;
