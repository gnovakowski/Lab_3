Lab_3 - Font Controller
=====


### Introduction

The purpose of this laboratory exercise was to create a font controller to be used with the VGA controller that we had already created in Lab 1. Basic functionality consisted of writing all A's to the screen.

### Implementation

The implementation of this lab consisted of having to write code for five separate VHDL modules. Once again, I used my `vga_sync` module written for Lab 1 with instantiations for `h_sync` and `v_sync`. A block diagram/RTL schematic of my design can be seen in the image below:

![alt text](http://i.imgur.com/Fq27U9o.png "RTL Schematic")


The modules that I wrote for this lab are listed below complete with examples and explanations:

 * `atlys_lab_font_controller` - This file is the top level VHDL file that includes the instantiations of both the `vga_sync` and `pixel_gen` modules. The instantiations for each of these components can be seen below:

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

 * `character_gen` - This VHDL module is the pixel generator, which is the file that actually writes pixels to the monitor display, using signals and generics initialized in the earlier VHDL modules. The process for drawing the logo, paddle, and ball on the display (with user input from buttons on the FPGA) can be seen below:

```vhdl
		blue_logo <=
			  "00000000" when (blank = '1') else
			  "10101010" when (column_new > 200 and column_new < 280 and row_new > 200 and row_new < 220) else
			  "10101010" when (column_new > 200 and column_new < 220 and row_new > 200 and row_new < 280) else
			  "10101010" when (column_new > 260 and column_new < 280 and row_new > 200 and row_new < 280) else
			  "10101010" when (column_new > 220 and column_new < 260 and row_new > 240 and row_new < 260) else
			  "10101010" when (column_new > 320 and column_new < 400 and row_new > 200 and row_new < 220) else
			  "10101010" when (column_new > 320 and column_new < 340 and row_new > 200 and row_new < 280) else
			  "10101010" when (column_new > 320 and column_new < 400 and row_new > 240 and row_new < 260) else
			  "00000000";

		g <= "00000000" when (blank = '1') else
			  "11111111" when (column_new > 9 and column_new < 21 and (row_new > (paddle_y_new - 30) or 
									 row_new < corr) and row_new < (paddle_y_new + 30) ) else
			  "00000000"; 
 
		r <= "00000000" when (blank = '1') else
			  "00000000" when (blue_logo /= "00000000") else
			  "11111111" when (column_new > (ball_x_new - 5) and column_new < (ball_x_new + 5) and 
									 row_new > (ball_y_new - 5) and row_new < (ball_y_new + 5) ) else
			  "00000000";

		b <= blue_logo;

```


 * `pong_control` - This VHDL module includes all of the functinality required to move the paddle up and down and to move the ball accordingly. The process depicting this functionality can be seen in the code below:

```vhdl
	process(reset, clk, paddle_y_reg, ball_x_reg, ball_y_reg, v_completed, running, delay_reg) is
	begin
		if(reset = '1') then
			ball_x_dir <= '1';
			ball_y_dir <= '1';
			running <= '1';
		elsif(rising_edge(clk) and running = '1') then
			if(hit_paddle = '1') then
				ball_x_dir <= '1';
			else 
				if(ball_x_reg > 635) then
					ball_x_dir <= '0';
				elsif(ball_x_reg <= 7) then
					running <= '0';
				else
					ball_x_dir <= ball_x_dir;
				end if;
				if(ball_y_reg < 5) then
					ball_y_dir <= '1';
				elsif(ball_y_reg > 475) then
					ball_y_dir <= '0';
				else
					ball_y_dir <= ball_y_dir;
				end if;
			end if;
		else
			ball_y_dir <= ball_y_dir;
			ball_x_dir <= ball_x_dir;
			running <= running;
		end if;
	end process;	
```

### Test/Debug

Throughout the course of this lab, I experienced issues with each of my VHDL modules. However, through the careful application of testbenches (and some consulatation with experts such as Captain Branchflower), I was able to properly diagnose and fix the different errors. The problems I experienced can be seen below.
 * In `h_sync_gen`, my first issue came with differences in type. I had initialized various signals to be used with my code, but I had written them with incorrect types. This gave me numerous problems while writing the code for this file, especially when trying to assign a value to my `column` that was dependent on count. I then realized that the value I needed to generate an unsigned value for `column`. After fixing this mistake, my code for `h_sync_gen` worked appropriately. 
 * In `vga_sync`, I was also experiencing issues, which once again seemed to be a result of a conflict in types. After failing to see what was wrong, a careful analysis of the error messages showed that one of my declared signals was not being appropriately used. The signal was being declared but not being used in the highest level file of `v_sync_gen`. After commenting out this input declaration, my code for `vga_sync` worked appropriately.
 * My final issue was one that should not have particularly beeen an issue. After not being able to get my completed code working on my FPGA, I realized that I had not created a constraints file that specified which parts of my FPGA to use. After the creation of this file, my code properly displayed the desired pattern on the monitor display.




### Conclusion

Overall, though very challenging, I thought that this was a valuable lab. It was extremely frustrating, but it definitely succeeded in teaching me a lot about how to write better VHDL code. One of the biggest challenges was trying to write code that the machine could synthesize. A lot of what I knew about writing in java and C does not apply in VHDL, and vice versa. In addition, I would not personally change very much about this lab besides maybe adding a little bit more direction in terms of choosing which state machines to use for which applications.

 
