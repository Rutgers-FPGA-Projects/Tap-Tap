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
	
	type thegame is array(0 to 15) of STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	SIGNAL gamesequence1 : thegame;	
	SIGNAL U, D, L, R : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
BEGIN
	U <= "00";
	D <= "01";
	L <= "10";
	R <= "11";
	
	gamesequence1 <= (L,R,D,R,U,L,U,D,R,L,R,D,U,L,D,U);
	
	GAME3 <= gamesequence1(COUNTER);
	GAME2 <= gamesequence1(COUNTER + 1);
	GAME1 <= gamesequence1(COUNTER + 2);
	GAME0 <= gamesequence1(COUNTER + 3);
	
	PROCESS (RESET, CLOCK)
	BEGIN
		IF (RESET = '1') THEN
			COUNTER <= 0;
		ELSIF (falling_edge(CLOCK)) THEN
			COUNTER <= COUNTER + 1;
		ELSE
			COUNTER <= COUNTER;
		END IF;		
	END PROCESS;

END Behavior;
