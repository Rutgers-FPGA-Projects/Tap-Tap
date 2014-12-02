----------------------------------------------------------------------------------------------------------------------
-- keyboard_top
----------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use work.vga_components.all;
ENTITY keyboard_top IS
	PORT(
		MCLK : IN STD_LOGIC;
		PS2C : IN STD_LOGIC;		-- PS2 CLOCK
		PS2D : IN STD_LOGIC;		-- PS2 DATA
		BTN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		LD : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		A_to_G : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		DP : OUT STD_LOGIC;
		AN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END keyboard_top;

ARCHITECTURE keyboard_top OF keyboard_top IS
	SIGNAL pclk, clock_50, clr : STD_LOGIC;
	SIGNAL xkey : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL keyval1, keyval2, keyval3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	BEGIN
		xkey <= keyval1 & keyval2;
		LD <= keyval3;
		clr <= BTN(3);
		
		U1 : clkdiv
			PORT MAP(
					mclk => mclk,
					clr => clr,
					clock_190 => clock_190,
					clock_48 => clock_48
				);
				
		U2 : keyboard_ctrl
			PORT MAP(
					clock_50 => clock_50,
					clr => clr,
					PS2C => PS2C, PS2D => PS2D,
					keyval1 => keyval1, keyval2 => keyval2,
					keyval3 => keyval3
				);
				
		U3 : x7segbc
			PORT MAP(
					x => xkey,
					cclk => clock_190,		-- what is cclk???
					clr => clr,
					A_to_Q => A_to_Q,
					AN => AN,
					DP => DP
				);
END keyboard_top;

----------------------------------------------------------------------------------------------------------------------
-- clkdiv
----------------------------------------------------------------------------------------------------------------------
--Example 52: clock divider
library ieee;
use ieee.std_logic_1164.all
use ieee.std_logic_unsigned.all;
entity clkdiv is
	port(
			mclk : in std_logic;
			clr : in std_logic;
			clk190 : out std_logic;
			clk48 : out std_logic
	);
end clkdiv;

architecture clkdiv of clkdiv is
signal q : std_logic_vector (23 downto 0);
begin
	--clock divider\
	process(mclk, clr)
	begin
		if clr = '1' then
			q <= X"000000";
		elsif mclk'event and mclk = '1' then
			q <= q + 1;
		end if;
	end process;
	clk48 <= q(19);
	clk190 <= q(17);
end clkdiv;


----------------------------------------------------------------------------------------------------------------------
-- x7segbc
----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all
use ieee.std_logic_unsigned.all;
entity x7segbc is
	port(
			x : in std_logic_vector(15 downto 0);
			cclk : in std_logic;
			clr : in std_logic;
			a_to_g : out std_logic_vector(6 downto 0);
			an : out std_logic_vector(3 downto 0);
			dp : out std_logic
	);
end x7segbc;

architecture x7segbc of x7segbc is
signal s : std_logic_vector(1 downto 0);
signal digit : std_logic_vector(3 downto 0);
signal aen : std_logic_vector(3 downto 0);

begin
	dp <= '1';
	-- set aen(3 downto 0) for leading blanks
	aen(3) <= x(15) or x(14) or x(13) or x(12);
	aen(2) <= x(15) or x(14) or x(13) or x(12) or x(11) or x(10) or x(9) or x(8);
	aen(1) <= x(15) or x(14) or x(13) or x(12) or x(11) or x(10) or x(9) or x(8)or x(7) or x(6) or x(5) or x(4);
	aen(0) <= '1';	-- digit 0 always on

	-- Quad 4-to-1 MUX : mux4
	process (s,x)
		begin
			case s is
				when "00" => digit <= x(3 downto 0);
				when "01" => digit <= x(7 downto 4);
				when "10" => digit <= x(11 downto 8);
				when others => digit <= x(15 downto 12);
			end case;
		end process;
	
	-- 7 seg decoder : hex7seg
	process(digit)
		begin
			case digit is
				when X"0" => a_to_g <= "0000001";	--0
				when X"1" => a_to_g <= "1001111";	--1
				when X"2" => a_to_g <= "0010010";	--2
				when X"3" => a_to_g <= "0000110";	--3
				when X"4" => a_to_g <= "1001100";	--4
				when X"5" => a_to_g <= "0100100";	--5
				when X"6" => a_to_g <= "0100000";	--6
				when X"7" => a_to_g <= "0001101";	--7
				when X"8" => a_to_g <= "0000000";	--8
				when X"9" => a_to_g <= "0000100";	--9
				when X"A" => a_to_g <= "0001000";	--A
				when X"B" => a_to_g <= "1100000";	--b
				when X"C" => a_to_g <= "0110001";	--C
				when X"D" => a_to_g <= "1000010";	--d
				when X"E" => a_to_g <= "0110000";	--E
				when others => a_to_g <= "0111000";	--F
			end case;
		end process;
		
	-- Digit select : ancode
	process(s, aen)
	begin
		an <= "1111";
		if aen(conv_integer(s)) = '1' then
			an(conv_integer(s)) <= '0';
		end if;
	end process;
	
	-- 2-bit counter
	process(cclk, clr)
	begin
		if clr = '1' then
			s <= "00";
		elsif cclk'event and cclk = '1' then
			s <= s + 1;
		end if;
	end process;
end x7segbc;
		





----------------------------------------------------------------------------------------------------------------------
-- keyboard_ctrl
----------------------------------------------------------------------------------------------------------------------
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
	SIGNAL shift1, shift2, shift3 : STD_LOGIC_VECTOR(10 DOWNTO 0);
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
			ps2c_filter(6 DOWNTO 0) <= ps2c_filter(7 DOWNTO 1);	-- shift from most significant bit
			ps2d_filter(7) <= PS2_DAT;
			ps2d_filter(6 DOWNTO 0) <= ps2d_filter(7 DOWNTO 1);	-- shift from most significant bit
			
			-- cleaning noise
			IF ps2c_filter = X"FF" THEN
				ps2cf <= '1';
			ELSIF ps2c_filter = X"00" then
				ps2cf <= '0';
			END IF;
			
			-- cleaning noise
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
				WHEN wtclklo1 =>	-- wait for clock low
					IF bit_count < bit_count_max THEN
						IF ps2cf = '1' THEN
							state <= wtclklo1;
						ELSE
							state <= wtclkhi1;
							shift1 <= ps2df & shift1(10 DOWNTO 1);
						END IF;
					ELSE
						state <= getkey1;
					END IF;
				WHEN wtclkhi1 =>	-- wait for clock high
					IF ps2cf = '0' THEN
						state <= wtclkhi1;
					ELSE
						state <= wtclklo1;
						bit_count <= std_logic_vector( unsigned(bit_count) + 1 );
					END IF;
				WHEN getkey1 =>
					keyval1s <= shift1(8 DOWNTO 1);
					bit_count <= (others => '0');
					state <= wtclklo2;
				WHEN wtclklo1 =>
					IF bit_count < bit_count_max THEN
						IF ps2cf = '1' THEN
							state <= wtclklo2;
						ELSE
							state <= wtclkhi2;
							shift2 <= ps2df & shift2(10 DOWNTO 1);
						END IF;
					ELSE
						state <= getkey2;
					END IF;
				WHEN wtclkhi2 =>
					IF ps2cf = '0' THEN
						state <= wtclkhi2;
					ELSE
						state <= wtclklo2;
						bit_count <= std_logic_vector( unsigned(bit_count) + 1 );
					END IF;
				WHEN getkey2 =>
					keyval2s <= shift2(8 DOWNTO 1);
					bit_count <= (others => '0');
					state <= breakkey;
				WHEN breakkey =>
					IF keyval2s = X"f0" THEN
						state <= wtclklo3;
					ELSE
						IF keyval1s = X"E0" THEN
							state <= wtclklo1;
						ELSE
							state <= wtclklo1;
						END IF;
					END IF;
				WHEN wtclklo3 => 
					IF bit_count < bit_count_max THEN
						IF ps2cf = '1' THEN
							state <= wtclklo3;
						ELSE
							state <= wtclkhi3;
							shift3 <= ps2df & shift3(10 DOWNTO 1);
						END IF;
					ELSE
						state <= getkey3;
					END IF;
				WHEN wtclkhi3 =>
					IF ps2cf = '0' THEN
						state <= wtclkhi3;
					ELSE
						state <= wtclklo3;
						bit_count <= std_logic_vector( unsigned(bit_count) + 1 );
					END IF;
				WHEN getkey3 =>
					keyval3s <= shift3(8 DOWNTO 1);
					bit_count <= (others => '0');
					state <= wtclklo1;
			END CASE;
		END IF;
	END PROCESS state_machine_keyboard;
		
	KEYVAL1 <= keyval1s;
	KEYVAL2 <= keyval2s;
	KEYVAL3 <= keyval3s;
	
END rtl;

