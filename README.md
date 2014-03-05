Lab_3 - Font Controller
=====


### Introduction

The purpose of this laboratory exercise was to create a font controller to be used with the VGA controller that we had already created in Lab 1. Basic functionality consisted of writing all A's to the screen.

### Implementation

The implementation of this lab consisted of having to write code for five separate VHDL modules. Once again, I used my `vga_sync` module written for Lab 1 with instantiations for `h_sync` and `v_sync`. A block diagram/RTL schematic of my design can be seen in the image below:

![alt text](http://i.imgur.com/Fq27U9o.png "RTL Schematic")


The modules that I wrote for this lab are listed below complete with examples and explanations:

 * `atlys_lab_font_controller` - This file is the top level VHDL file that includes the instantiations of the `vga_sync`, `character_gen`, and `input_to_pulse` modules. The instantiations for each of these components can be seen below:

```vhdl
	Inst_vga_sync: entity work.vga_sync(Behavioral) PORT MAP(
		clk => pixel_clk,
		reset => reset,
		h_sync => h_sync,
		v_sync => v_sync,
		v_completed => v_completed,
		blank => blank,
		row => row,
		column => column
	);

	Inst_character_gen: entity work.character_gen(Behavioral) PORT MAP(
		clk => pixel_clk,
		blank => blank_reg ,
		row => std_logic_vector(row),
		column => std_logic_vector(column),
		ascii_to_write => "00000011", -- this is the A ascii
		write_en => WE,
		r => red,
		g => green,
		b => blue 
	);

	Inst_input_to_pulse: entity work.input_to_pulse(Behavioral) PORT MAP(
		clk => pixel_clk,
		reset => reset,
		button => start,
		button_pulse => WE
	);
```
 * In addition, in order for the characters to properly display on the monitor, I needed to implement multiple delays in the top shell. These delays can be seen below:

```vhdl
		process(pixel_clk) is 
		begin
			if(rising_edge(pixel_clk)) then
				delay1 <= blank;
			end if;
		end process;

		process(pixel_clk) is
		begin
			if(rising_edge(pixel_clk)) then
				blank_reg <= delay1;
			end if;
		end process;

		process(pixel_clk) is 
		begin
			if(rising_edge(pixel_clk)) then
				h_sync_delay1 <= h_sync;
				h_sync_delay2 <= h_sync_delay1;
			end if;
		end process;

		process(pixel_clk) is 
		begin
			if(rising_edge(pixel_clk)) then
				v_sync_delay1 <= v_sync;
				v_sync_delay2 <= v_sync_delay1;
			end if;
		end process;
```

 * `character_gen` - This VHDL module actually generates the display of characters on the actual monitor. This also contained three instantiations for entities utilized to generate the signal. The instantiations can be seen below:

```vhdl
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
```
 * In addition, the below picture depicts the block diagram for `character_gen`.

![alt text](http://i.imgur.com/HRA0zA8.png "Character Gen")

 * Also, my `character_gen` module contained a process that actually displayed the characters/colors on the monitor, which took the place of a separate `pixel_gen` module. This process can be seen below:

```vhdl
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
```

 * `mux` - This VHDL module is the multiplexer that is utilized with my `character_gen` module to generate the characters on the monitor dsiplay. I decided to create this mux in a separate module and then instantiate it in the `character_gen` module. The mux code can be seen below:

```vhdl
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
```
 * `mux` - This VHDL module is the multiplexer that is utilized with my `character_gen` module to generate the characters on the monitor dsiplay. I decided to create this mux in a separate module and then instantiate it in the `character_gen` module. The mux code can be seen below:

```vhdl
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
```

### Test/Debug

While working on this lab, I experienced issue with many of my VHDL modules. The problems I experienced can be seen below.
 * The first of my issues was with the hierarchichal design of the lab. I had initial issues determining which module were to be instantiated where, specifially with the `font_rom` and `char_screen_buffer` modules. Initially i had placed both of them in the top shell - `atlys_lab_font_controller` and I was experiencing many issues with my code. Ultimately though, I figured out to instantiate them both in the `character_gen` module, which solved this particular issue.
 * Another issue I experienced was with trying to generate the characters to be drawn to the screen in a separate `pixel_gen` module. In theory, this should have worked, but I was experiencing difficulties interfacing the `pixel_gen` module with the font ROM library, since I was no longer just drawing things on the screen. I eventually just scrapped my `pixel_gen` module altogether and created the apropriate code in the `character_gen` module using already existing inputs.
 * The final issue I experienced in this lab occured after I got the characters to display on the screen. The issue was that the very first and very last columns of pixels were being cut off. I had already implemented appropriate delays for blank in the top shell, but I couldn't figure out why this was happenening. After consulting with Captain Branchflower, he noted that my issue was most likely with the delay for `h_sync` and `v_sync`. After writing delays for these signals, the pixels were no longer being cut off, and I achieved basic functionality.


### Conclusion

Overall, though very challenging, I thought that this was a valuable lab. It was extremely frustrating, but it definitely succeeded in teaching me a lot about how to write better VHDL code. One of the biggest challenges was trying to write code that the machine could synthesize. A lot of what I knew about writing in java and C does not apply in VHDL, and vice versa. In addition, I would not personally change very much about this lab besides maybe adding a little bit more direction in terms of choosing which state machines to use for which applications.

 
