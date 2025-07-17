--------------------------------------------------------------------------------
-- Authors: Nafis Saadiq Bhuiyan, Zihao Yuan, Remington Gall
-- Course:	 		Engs 31 25S 
-- Final Project (Morse Code Converter)
-- Module Name:   Morse_Shell_tb.vhd
-- VHDL Test Bench for module: Morse_Shell
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_shell_tb is
    --  Port ( );
end top_shell_tb;

architecture Behavioral of top_shell_tb is

    component lab5_shell is
        Generic (
            CLK_DIVIDER_RATIO : integer;
            STABLE_TIME : integer
        );
        Port (
            clk_ext_port	        : in std_logic;						-- mapped to external IO device (100 MHz Clock)				
            term_input_ext_port		: in std_logic_vector(3 downto 0);	-- slide switches SW15 (MSB) down to SW12 (LSB)
            op_ext_port		        : in std_logic;						-- button center
            clear_ext_port		    : in std_logic;						-- button down
            seg_ext_port		    : out std_logic_vector(0 to 6);
            dp_ext_port				: out std_logic;
            an_ext_port				: out std_logic_vector(3 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal term : std_logic_vector( 3 downto 0 ) := "0000";
    signal clear, op : std_logic := '0';
    
    constant tcycle : time := 10ns;   -- 100MHz
    constant cdiv : integer := 10;    -- 10MHz for sim
    constant stableCycles : integer := 10;  -- inputs must be stable for 10 cycles.
    constant mpTime : time := (stableCycles + 5) * cdiv * tcycle;
begin

    dut: lab5_shell
        generic map (
            CLK_DIVIDER_RATIO => cdiv,
            STABLE_TIME => stableCycles
        )
        port map (
            clk_ext_port => clk,
            term_input_ext_port => term,
            op_ext_port => op,
            clear_ext_port => clear,
            seg_ext_port => open,
            dp_ext_port => open,
            an_ext_port => open );



    process begin
        clk <= not clk;
        wait for tcycle/2;
    end process;

    process
        -- this is a feature which can be used in test benches to "probe" internal signals.
        alias a   is << signal dut.datapath.term1_display_port  : std_logic_vector(3 downto 0) >>;
        alias b   is << signal dut.datapath.term2_display_port  : std_logic_vector(3 downto 0) >>;
        alias sum is << signal dut.datapath.answer_display_port : std_logic_vector(3 downto 0) >>;
        alias overflow is << signal dut.datapath.overflow_port : std_logic >>;

    -- these procedure can only be used in this process.
    
    -- monopulse the clear signal.
    procedure pulse_clear is
    begin
        clear <= '1';
        wait for mpTime;
        clear <= '0';
        wait for 3 * mpTime;

        -- Make sure it worked.
        assert a = "0000" and b = "0000" and sum = "0000" report "Incorrect Clear" severity FAILURE;
        assert overflow = '0' report "Incorrect Overflow" severity FAILURE;
    end procedure;
     
    -- monopulse the pulse signal.
    procedure pulse_op is
    begin
        op <= '1';
        wait for mpTime;
        op <= '0';
        wait for 3 * mpTime;
    end procedure;
     
    -- load a_op into term1 and b_op into term2 and perform the sum
    --  check the terms load correctly and that they produce the correct 
    --  result
    procedure add_two (a_op,b_op : in std_logic_vector( 3 downto 0 ) ) is 
        variable c : std_logic_vector ( 4 downto 0 );
    begin
        c := std_logic_vector(unsigned( '0' & a_op ) + unsigned( '0' & b_op ));
        term <= a_op;
        pulse_op;
        assert a = a_op report "Term 1 incorrect update" severity FAILURE;
        term <= b_op;
        pulse_op;
        assert a = a_op report "Term 2 incorrect update" severity FAILURE;
        pulse_op;
        assert sum = c(3 downto 0) report "Incorrect Sum" severity FAILURE;
        assert overflow = c(4) report "Incorrect Overflow" severity FAILURE;
    end procedure;
     
    -- finally - use the procedures above to write some stimuls
    begin

        -- Test a few additions        
        pulse_clear;
        add_two( "0001", "0001" );       
    
        
        pulse_clear;
        add_two( "0010", "0001" );

        pulse_clear;
        add_two( "1010", "0101" );

        -- check that overflow works.
        pulse_clear;
        add_two( "1100", "0100" );

        -- finally - check that clear works in the middle.
        term <= "0100";

        pulse_clear;
        pulse_op;
        
        assert a = "0100" report "Bad Term 1" severity FAILURE;
        
        pulse_clear;
        
        pulse_op;
        pulse_op;
        
        assert a = "0100" and b = "0100" report "Bad load" severity FAILURE;
        pulse_clear;
        
        wait for 10 * mpTime;
        
        report "----*****------ Test Passed! -------*******-----";

        stop;
    end process;

end Behavioral;
