----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:06:41 02/25/2014 
-- Design Name: 
-- Module Name:    character_gen - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;


entity character_gen is
    Port ( clk : in  STD_LOGIC;
           blank : in  STD_LOGIC;
           row : in  STD_LOGIC_VECTOR (10 downto 0);
           column : in  STD_LOGIC_VECTOR (10 downto 0);
           ascii_to_write : in  STD_LOGIC_VECTOR (7 downto 0);
           write_en : in  STD_LOGIC;
           r,g,b : out  STD_LOGIC_VECTOR (7 downto 0));
end character_gen;

architecture Behavioral of character_gen is

signal row_col_multiply : std_logic_vector(13 downto 0);
signal count_reg, count_next: std_logic_vector(11 downto 0);
signal address, addr_sig : std_logic_vector(10 downto 0);
signal rom_data, data_b_sig, font_data_sig : std_logic_vector(7 downto 0);
signal row_reg, row_next : std_logic_vector(3 downto 0);
signal col_reg, col_next_1, col_next_2 : std_logic_vector(2 downto 0);
signal mux_out : std_logic;


begin

		Inst_char_screen_buffer: entity work.char_screen_buffer(Behavioral) PORT MAP(
			clk => clk,
			we => write_en,
			address_a => count_reg ,
			address_b => row_col_multiply(11 downto 0),
			data_in => ascii_to_write,
			data_out_a => open,
			data_out_b => data_b_sig
		);


		Inst_font_rom: entity work.font_rom(arch) PORT MAP(
			clk => clk ,
			addr => addr_sig,
			data =>  font_data_sig
		);


		Inst_mux: entity work.mux(Behavioral) PORT MAP(
			data => font_data_sig,
			sel => col_reg,
			output => mux_out
		);

		--delay column 1
		process(clk) is 
		begin
			if(rising_edge(clk)) then
				col_next_1 <= column(2 downto 0);
			end if;
		end process;

		--delay column 2
		process(clk) is
		begin
			if(rising_edge(clk)) then
				col_reg <= col_next_1;
			end if;
		end process;

		--delay row 1
		process(clk) is 
		begin
			if(rising_edge(clk)) then
				row_reg <= row(3 downto 0);
			end if;
		end process;

		addr_sig <= data_b_sig(6 downto 0) & row_reg ;

		count_reg <= std_logic_vector(unsigned(count_next) + 1) when rising_edge(write_en) else
			count_next;

		count_next <= (others => '0') when unsigned(count_reg) = to_unsigned(2400, 12)  else
					count_reg;

		row_col_multiply <= std_logic_vector((unsigned(row(10 downto 4)) * 80) + unsigned(column(10 downto 3)));

		process(mux_out, blank) is
		begin
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
			if(blank = '0') then
				if(mux_out = '1') then
					r <= (others => '1');
				end if;
			end if;	
		end process;

end Behavioral;
