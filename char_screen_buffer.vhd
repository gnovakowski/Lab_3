----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:04:30 02/25/2014 
-- Design Name: 
-- Module Name:    char_screen_buffer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity char_screen_buffer is
    Port ( clk : in  STD_LOGIC;
           we : in  STD_LOGIC;
           address_a : in  STD_LOGIC_VECTOR (11 downto 0);
           address_b : in  STD_LOGIC_VECTOR (11 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out_a : out  STD_LOGIC_VECTOR (7 downto 0);
           data_out_b : out  STD_LOGIC_VECTOR (7 downto 0));
end char_screen_buffer;

architecture behavioral of char_screen_buffer is
    signal address_a_reg : std_logic_vector(11 downto 0);
    signal address_b_reg : std_logic_vector(11 downto 0);


    type ram_type is array (4096-1 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type :=
    (
        (others => x"41")
    );

begin

    process (clk) is
    begin
        if rising_edge(clk) then
            if (we = '1') then
                RAM(to_integer(unsigned(address_a))) <= data_in;
            end if;

            address_a_reg <= address_a;
            address_b_reg <= address_b;
        end if;
    end process;

    data_out_a <= RAM(to_integer(unsigned(address_a_reg)));
    data_out_b <= RAM(to_integer(unsigned(address_b_reg)));

end behavioral;

