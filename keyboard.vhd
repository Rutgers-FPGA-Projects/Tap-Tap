-- Keyboard controller
-- Created through the assistance of the tutorial found at the following link
-- https://www.youtube.com/watch?v=EtJBqvk1ZZw

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY lab5 IS
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

