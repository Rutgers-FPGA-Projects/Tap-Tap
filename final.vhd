LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL; 
ENTITY final IS
	PORT(
		CLOCK_50 	: IN STD_LOGIC; -- 50MHz
		KEY			: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- LCD controller stuff
      LCD_RS, LCD_EN         : OUT STD_LOGIC;
      LCD_RW                 : OUT STD_LOGIC;
      LCD_ON                 : OUT STD_LOGIC;
      LCD_DATA               : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		HEX0, HEX1				  : OUT STD_LOGIC_VECTOR(0 TO 6);
		LEDG							:OUT STD_LOGIC_VECTOR(7 DOWNTO 7);
		LEDR							:OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		IRDA_RXD: in std_logic
	);
END final;

ARCHITECTURE arch OF final IS
		
	-- LCD display controller
	COMPONENT LCD_Display IS
		PORT( 
		 RESET         : IN STD_LOGIC;
       CLOCK_50       : IN  STD_LOGIC;
       LCD_RS, LCD_EN         : OUT STD_LOGIC;
       LCD_RW                 : OUT   STD_LOGIC;
       LCD_ON                 : OUT STD_LOGIC;
       LCD_DATA               : INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		 GAME0 						: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		 GAME1 						: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		 GAME2 						: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		 GAME3 						: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		 OFFSET						: IN INTEGER RANGE 0 TO 3);
	END COMPONENT;
	
	COMPONENT ARROW_GENERATOR IS

	PORT(
		CLOCK		: IN  STD_LOGIC;
		RESET 	: IN 	STD_LOGIC;
	 	GAME0 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		GAME1 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		GAME2 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		GAME3 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0));

	END COMPONENT;
	
	COMPONENT bcd7seg -- 7 segment hex display
		PORT (C : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				H : OUT STD_LOGIC_VECTOR(0 TO 6);
				DASH : IN STD_LOGIC; -- dash flag
				BLANK : IN STD_LOGIC); --blank flag
	END COMPONENT;
	
	COMPONENT finalir 
	port (
     CLOCK_50: in std_logic;
	  reset: in std_logic;
	  IRDA_RXD: in std_logic;
	  input_data: out std_logic_vector(7 DOWNTO 0));
	end component;
	
	SIGNAL COUNTER : INTEGER RANGE 0 TO 40000000:= 0;
	SIGNAL COUNTER2 : INTEGER RANGE 0 TO 10000000:= 0;
	SIGNAL COUNTER3 : INTEGER RANGE 0 TO 10000000:= 0;
	
	SIGNAL SCORE : INTEGER RANGE 0 TO 31 := 15;
	SIGNAL ASYNCSCORE : INTEGER RANGE 0 TO 31 := 0;
	SIGNAL SCORE_VECTOR : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
	
	SIGNAL reset: STD_LOGIC; 
	SIGNAL A0 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL A1 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL A2 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL A3 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL current_input : STD_LOGIC_VECTOR (2 DOWNTO 0) := "100";
	SIGNAL CLOCK, CLOCK2 :STD_LOGIC;

	SIGNAL IRRESETER : STD_LOGIC := '0';

	SIGNAL old_counter, change_counter : INTEGER RANGE 0 TO 10 := 0;
	
	SIGNAL G0,G1,G2,G3 : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	SIGNAL input_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	
	SIGNAL OFFSET : INTEGER RANGE 0 TO 3:= 0;
	
	SIGNAL WIN, LOSE, GAMEOVER: STD_LOGIC:= '0';
	
BEGIN
	reset <= KEY(1);
	GAMEOVER <= WIN OR LOSE;
	
	LEDG(7) <= WIN;
	LEDR(0) <= LOSE;
	
	PROCESS (SCORE)
	BEGIN
		CASE (SCORE MOD 10) IS
			WHEN 0 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0000";
			WHEN 1 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0001";
			WHEN 2 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0010";
			WHEN 3 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0011";
			WHEN 4 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0100";
			WHEN 5 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0101";
			WHEN 6 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0110";
			WHEN 7 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "0111";
			WHEN 8 =>
				SCORE_VECTOR(3 DOWNTO 0) <= "1000";
			WHEN OTHERS =>
				SCORE_VECTOR(3 DOWNTO 0) <= "1001";
		END CASE;
		
		CASE (SCORE / 10) IS
			WHEN 0 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0000";
			WHEN 1 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0001";
			WHEN 2 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0010";
			WHEN 3 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0011";
			WHEN 4 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0100";
			WHEN 5 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0101";
			WHEN 6 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0110";
			WHEN 7 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "0111";
			WHEN 8 =>
				SCORE_VECTOR(7 DOWNTO 4) <= "1000";
			WHEN OTHERS =>
				SCORE_VECTOR(7 DOWNTO 4) <= "1001";
		END CASE;
	END PROCESS;
	
	PROCESS (CLOCK_50,GAMEOVER) -- 1.25 Hz clock
	BEGIN
		IF (GAMEOVER = '1') THEN
			COUNTER <= 0;
		ELSIF (rising_edge(CLOCK_50)) THEN
			COUNTER <= COUNTER + 1;
			IF (COUNTER <= 20000000) THEN
				CLOCK <= '1';
			ELSE
				CLOCK <= '0';
			END IF;
		END IF;		
	END PROCESS;
	
	PROCESS (CLOCK_50,GAMEOVER) -- 5 Hz clock
	BEGIN
		IF (GAMEOVER = '1') THEN
			COUNTER2 <= 0;
		ELSIF (rising_edge(CLOCK_50)) THEN
			COUNTER2 <= COUNTER2 + 1;
			IF (COUNTER2 <= 5000000) THEN
				CLOCK2 <= '1';
			ELSE
				CLOCK2 <= '0';
			END IF;
		END IF;		
	END PROCESS;
	
	PROCESS (CLOCK_50,GAMEOVER) -- 5 Hz clock
	BEGIN
		IF (GAMEOVER = '1') THEN
			COUNTER3 <= 0;
		ELSIF (rising_edge(CLOCK_50)) THEN
			COUNTER3 <= COUNTER3 + 1;
			IF (COUNTER3 <= 625000) THEN
				IRRESETER <= '0';
			ELSE
				IRRESETER <= '1';
			END IF;
		END IF;		
	END PROCESS;
	
	PROCESS (CLOCK2,RESET)
	BEGIN	
	
		IF(RESET = '0' AND GAMEOVER = '1') THEN
			WIN <= '0';
			LOSE <= '0';
			OFFSET <= 0;
			SCORE <= 15;
		ELSIF (GAMEOVER = '1') THEN
			-- RESET ALL SIGNALS HERE
			OFFSET <= 0;
			SCORE <= 15;
			WIN <= WIN;
			LOSE <= LOSE;
		ELSIF (rising_edge(CLOCK2)) THEN
			OFFSET <= OFFSET + 1;
			SCORE <= ASYNCSCORE;
			IF (SCORE = 0) THEN
				LOSE <= '1';
				WIN <= '0';
			ELSIF (SCORE = 31) THEN
				WIN <= '1';
				LOSE <= '0';
			ELSE
				WIN <= '0';
				LOSE <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (input_data)
	BEGIN
		CASE (input_data) IS
			WHEN X"05" =>
				current_input <= "000";
			WHEN X"07" =>
				current_input <= "010";
			WHEN X"08" =>
				current_input <= "001";
			WHEN X"09" =>
				current_input <= "011";
			WHEN OTHERS =>
				current_input <= "100";
		END CASE;
	END PROCESS;
	
	PROCESS (IRRESETER, SCORE, current_input, OFFSET, G3)
	BEGIN
		IF(IRRESETER = '1' AND GAMEOVER ='0') THEN
			IF(OFFSET = 3) THEN
				IF(current_input(2) = '0' AND current_input(1 DOWNTO 0) = G3) THEN
					ASYNCSCORE <= SCORE + 1;
				ELSE
					ASYNCSCORE <= SCORE - 1;
				END IF;
			ELSE
				ASYNCSCORE <= SCORE;
			END IF;
		ELSE
			ASYNCSCORE <= ASYNCSCORE;
		END IF;
	END PROCESS;
	
	PROCESS (OFFSET)
	BEGIN
		IF(OFFSET = 0)	THEN
			G0 <= A0;
			G1 <= A1;
			G2 <= A2;
			G3 <= A3;
		ELSE
			G0 <= G0;
			G1 <= G1;
			G2 <= G2;
			G3 <= G3;
		END IF;
	END PROCESS;
		
	DISP0 : bcd7seg PORT MAP (SCORE_VECTOR(3 DOWNTO 0), HEX0, '0', GAMEOVER);
	DISP1 : bcd7seg PORT MAP (SCORE_VECTOR(7 DOWNTO 4), HEX1, '0', GAMEOVER);	

	
	FINAILIRR : finalir PORT MAP (CLOCK_50, IRRESETER, IRDA_RXD, input_data);
	
	-- instantiate LCD controller
	lcd : LCD_Display PORT MAP(RESET,CLOCK_50,LCD_RS, LCD_EN,LCD_RW ,LCD_ON,LCD_DATA, A0, A1, A2, A3,OFFSET);
	
	AG : ARROW_GENERATOR PORT MAP(CLOCK, GAMEOVER, A0, A1, A2, A3);
END arch;