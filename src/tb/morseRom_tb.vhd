--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   MorseRom_tb.vhd
-- Description: A testbench for testing our MorseRom component
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

--empty entity for testbench
entity tb_MorseRom is
end tb_MorseRom;

architecture Behavioral of tb_MorseRom is

COMPONENT MorseRom
    PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(18 DOWNTO 0)  );
END COMPONENT;

--port signals for connecting with the bram
signal clka : std_logic := '0';
signal addra : std_logic_vector(7 downto 0) := (others => '0');
signal douta : std_logic_vector(18 downto 0) := (others => '0');

constant clk_period : time := 10 ns; --clock period.

begin

--component instantiation using named association.
MorseRom1 : MorseRom port map(
    clka => clka,
    addra => addra,
    douta => douta);

--generate the clock
clk_generation: process
begin
    wait for clk_period/2;
    clka <= not clka;
end process;

--this is where we generate the inputs to apply to the bram
stimulus: process
begin
    wait for clk_period;

    addra <= x"30"; wait for clk_period*100; --0 should output 1110111011101110111
    addra <= x"41"; wait for clk_period*100; --A should output 1011100000000000000
    addra <= x"6b"; wait for clk_period*100; --k should output 1110101110000000000
    --addra <= x"03"; wait for clk_period;
    --addra <= x"04"; wait for clk_period;
    --addra <= x"05"; wait for clk_period;
    --addra <= x"06"; wait for clk_period;
    wait;
end process;

end Behavioral;
