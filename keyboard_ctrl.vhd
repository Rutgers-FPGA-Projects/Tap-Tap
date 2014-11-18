-- Keyboard controller
-- Created through the assistance of the tutorial found at the following link
-- https://www.youtube.com/watch?v=EtJBqvk1ZZw

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY keyboard_ctrl IS
	PORT(
			CLOCK_50: IN STD_LOGIC;
			CLR 	: IN STD_LOGIC;
			PS2_CLK : IN STD_LOGIC;
			PS2_DAT : IN STD_LOGIC;
			KEYVAL1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			KEYVAL2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			KEYVAL3 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
END ENTITY;

ARCHITECTURE rtl OF keyboard_ctrl IS

	TYPE state_type IS (start, wtclklo1, wtclkhi1, getkey1, wtclklo2, wtclkhi2, getkey2, breakkey, wtclklo3, wtclkhi3, getkey3);
	SIGNAL state: state_type;
	
	SIGNAL ps2cf, ps2df : STD_LOGIC;
	SIGNAL ps2c_filter, ps2d_filter : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL shift1, shift2, shift3 : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL keyval1s, keyval2s, keyval3s : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL bit_count : STD_LOGIC_VECTOR(3 DOWNTO 0);
	CONSTANT bit_count_max : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011"; -- Max number of bits will be 11
	
	BEGIN
	
	FILTER : PROCESS(CLOCK_50, CLR)
	BEGIN
		IF clr = '1' THEN
			ps2c_filter <= (others => '0');
			ps2d_filter <= (others => '0');
			ps2cf <= '1';
			ps2df <= '1';
		ELSIF CLOCK_50'EVENT AND CLOCK_50 = '1' THEN
			-- clock and data filters to remove noise, cleans the values	
			ps2c_filter(7) <= PS2_CLK;
			ps2c_filter(6 DOWNTO 0) <= ps2c_filter(7 DOWNTO 1);
			ps2d_filter(7) <= PS2_DAT;
			ps2d_filter(6 DOWNTO 0) <= ps2d_filter(7 DOWNTO 1);
			
			IF ps2c_filter = X"FF" THEN
				ps2cf <= '1';
			ELSIF ps2c_filter = X"00" then
				ps2cf <= '0';
			END IF;
			
			IF ps2d_filter = X"FF" THEN
				ps2df <= '1';
			ELSIF ps2d_filter = X"00" then
				ps2df <= '0';
			END IF;	
		
		END IF;
				
	END PROCESS;
	
	state_machine_keyboard: PROCESS (CLOCK_50, CLR)
	BEGIN
		IF (clr = '1') THEN
			--initialize the clear state
			state <= start;
			bit_count <= (others => '0');
			shift1 <= (others => '0');
			shift2 <= (others => '0');
			shift3 <= (others => '0');
			keyval1s <= (others => '0');
			keyval2s <= (others => '0');
			keyval3s <= (others => '0');
		ELSIF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
			CASE STATE IS
				WHEN start =>
					IF ps2df = '1' THEN
						state <= start;
					ELSE
						state <= wtclklo1;
					END IF;
					
			END CASE;
		END IF;
	
END rtl;
