----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:04:08 03/03/2014 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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

entity mux is
    Port ( data : in  STD_LOGIC_VECTOR (7 downto 0);
           sel : in  STD_LOGIC_VECTOR (2 downto 0);
           output : out  STD_LOGIC
			  );
end mux; 

architecture Behavioral of mux is

begin

	process(sel, data) is
	
	begin
		if( sel = "000") then
			output <= data(7);
		elsif(sel = "001") then
			output <= data(6);
		elsif(sel = "010") then
			output <= data(5);
		elsif(sel <="011") then
			output <= data(4);
		elsif(sel <="100") then
			output <= data(3);
		elsif(sel <="101") then
			output <= data(2);
		elsif(sel <= "110") then
			output <= data(1);
		else
			output <= data(0);
		end if;

	end process;

end Behavioral;


