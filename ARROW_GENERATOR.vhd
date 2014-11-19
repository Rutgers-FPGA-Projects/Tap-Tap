--http://www.uio.no/studier/emner/matnat/ifi/INF5430/v11/undervisningsmateriale/lecture_slides_roarsk/INF5430_VHDL_array_type.pdf

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
 
ENTITY ARROW_GENERATOR IS

PORT(
		CLOCK		: IN  STD_LOGIC;
		RESET 	: IN 	STD_LOGIC;
	 	GAME0 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		GAME1 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		GAME2 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		GAME3 	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
);

END ENTITY;

ARCHITECTURE Behavior OF ARROW_GENERATOR IS

	SIGNAL COUNTER : INTEGER := 0;
	
	TYPE arrows IS (U, D, L, R);
	ATTRIBUTE syn_encoding : STD_LOGIC_VECTOR(1 DOWNTO 0);
	ATTRIBUTE syn_encoding of arrows : TYPE IS "00 01 10 11"; -- Ordered by Konami Code
	
	type thegame is array(15 downto 0) of arrows;
	
	signal gamesequence1 : thegame;
	
	
BEGIN
	
	gamesequence1 <= (L,R,D,D,D,L,U,D,U,U,R,D,R,L,D,U);
	
	PROCESS (RISING_EDGE(CLOCK))
	BEGIN
		COUNTER <= COUNTER + 1;
		GAME0 <= gamesequence1(COUNTER);
		GAME1 <= gamesequence1(COUNTER + 1);
		GAME2 <= gamesequence1(COUNTER + 2);
		GAME3 <= gamesequence1(COUNTER + 3);
		
	END PROCESS;

END Behavior;
