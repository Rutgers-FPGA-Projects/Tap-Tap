LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd7seg IS
PORT (C : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		H : OUT STD_LOGIC_VECTOR(0 TO 6);
		DASH : IN STD_LOGIC;
		BLANK : IN STD_LOGIC);
END bcd7seg;

ARCHITECTURE RTL OF bcd7seg IS
BEGIN

	PROCESS(C,DASH,BLANK)
	BEGIN
	
		IF (DASH = '1') THEN
			H <= "1111110"; -- display a dash if dash flag is set to 1
			
		ELSIF (BLANK = '1') THEN
			H <= "1111111"; -- blank the display if the blank flag is set to 1
			
		ELSE		
			CASE C IS -- Switch between the 16 different cases to display a 
			-- character between 0-f
			
				WHEN "0000" => H <= "0000001";
				-- For example, here to display a zero all of the LEDs need to 
				-- be lit except LED 6, so the bit 6 has to be 1 as the LEDs use
				-- inverted logic, similarly for the rest of the ones below
				WHEN "0001" => H <= "1001111";
				WHEN "0010" => H <= "0010010";
				WHEN "0011" => H <= "0000110";
				WHEN "0100" => H <= "1001100";
				WHEN "0101" => H <= "0100100";
				WHEN "0110" => H <= "0100000";
				WHEN "0111" => H <= "0001111";
				WHEN "1000" => H <= "0000000";
				WHEN "1001" => H <= "0001100";
				WHEN "1010" => H <= "0001000";
				WHEN "1011" => H <= "1100000";
				WHEN "1100" => H <= "1110010";
				WHEN "1101" => H <= "1000010";
				WHEN "1110" => H <= "0110000";
				WHEN "1111" => H <= "0111000";
				WHEN OTHERS => H <= "ZZZZZZZ"; -- In this switch case there will never be 
				-- an OTHERS case because all of the cases are exhausted, however, if so, 
				-- the LEDs will be set to high Z (impedance)
			END CASE;
			
		END IF;
		
	END PROCESS;

END RTL;
	