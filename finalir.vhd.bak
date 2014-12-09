library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ;

entity finalir is
port (
     CLOCK_50: in std_logic;
	  key: in std_logic_vector(0 downto 0);
	  IRDA_RXD: in std_logic;
--	  data_ready: out std_logic;
	  hex0,hex1,hex2,hex3,hex4,hex5,hex6,hex7: out std_logic_vector (6 downto 0)
);
 end finalir;
 
 architecture rtl of finalir is
 
component bcd7seg is
PORT ( C: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		H: OUT STD_LOGIC_VECTOR(0 TO 6));
end component;

   type count_state is (idle, guidance, dataread);
	signal state : count_state;
	attribute syn_encoding:    string;
	attribute syn_encoding of count_state: type is "00 01 10";
	signal idle_count: integer range 0 to 263000;
	signal state_count: integer range 0 to 263000; 
	signal data_count: integer range 0 to 263000;
	
	signal idle_count_flag, state_count_flag, data_count_flag: std_logic;
   signal bitcount: integer range 0 to 33;
	
	signal odata: std_logic_vector(31 downto 0);
	signal data_buf: std_logic_vector(31 downto 0);
	signal data:  std_logic_vector(31 downto 0);
	signal ready: std_logic;
	
	begin
	--	//idle counter works on clk50 under idle state only		    
   process (key(0),CLOCK_50)
      begin
		 if(rising_edge(CLOCK_50))then
		   if(key(0) = '0')then 
			  idle_count <= 0;
			  else
			    if (idle_count_flag = '1')then 
				   idle_count <= idle_count + 1;
					 else 
					    idle_count <= 0;
				  end if;
			 end if;
		  end if;		
	end process;
--//idle counter switch when IRDA_RXD is low under IDLE state		 
		 	 process (key(0), CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (key(0) = '0')then
                    idle_count_flag <= '0';
						  else 
						    if ((state = idle) and (IRDA_RXD = '0'))then
						      idle_count_flag <= '1';
							   else 
							     idle_count_flag <= '0';
							  end if;
						  end if;
						end if;
		 end process;
	--	//state counter works on clk50 under state state only		    
   process (key(0),CLOCK_50)
      begin
		 if(rising_edge(CLOCK_50))then
		   if(key(0) = '0')then 
			  state_count <= 0;
			  else
			    if (state_count_flag = '1')then 
				   state_count <= state_count + 1;
					 else 
					    state_count <= 0;
				  end if;
			 end if;
		  end if;		
	end process;
--//state counter switch when IRDA_RXD is high under GUIdance state		 
		 	 process (key(0), CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (key(0) = '0')then
                    state_count_flag <= '0';
						  else 
						    if ((state = guidance) and (IRDA_RXD = '1'))then
						      state_count_flag <= '1';
							   else 
							     state_count_flag <= '0';
							  end if;
						  end if;
						end if;
		 end process;
	--	//data counter works on clk50 under data state only		    
   process (key(0),CLOCK_50)
      begin
		 if(rising_edge(CLOCK_50))then
		   if(key(0) = '0')then 
			  data_count <= 0;
			  else
			    if (data_count_flag = '1')then 
				   data_count <= data_count + 1;
					 else 
					    data_count <= 0;
				  end if;
			 end if;
		  end if;		
	end process;
--//data counter switch when IRDA_RXD is high under DATAREAD state		 
		 	 process (key(0), CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (key(0) = '0')then
                    data_count_flag <= '0';
						  else 
						    if ((state = dataread) and (IRDA_RXD = '1'))then
						      data_count_flag <= '1';
							   else 
							     data_count_flag <= '0';
							  end if;
						  end if;
						end if;
		 end process;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
		 	 process (key(0), CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (key(0) = '0')then
                    bitcount <= 0;		
							else
							if(state = dataread)then 
								if(data_count = 20000)then
									bitcount <= bitcount + 1;
								end if;
								else 
											bitcount <= 0;
							
							end if;
						end if;
					end if;
				end process;
				

process(key(0), CLOCK_50)
begin
	if (rising_edge(CLOCK_50)) then
		if (key(0) = '0') then
			state <= idle ;
		else 
			case state is
				when idle => 
					if idle_count > 230000 then
						state <= guidance ;
					end if ;
				when guidance =>
					if state_count > 210000 then
						state <= dataread ;
					end if ;
				when dataread =>
					if data_count > 262143 or bitcount >= 33 then
						state <= idle ;
					end if ;
				when others =>	
						state <= idle ;
			end case ;
		end if ;
	end if ;
end process ;

process(key(0), CLOCK_50)
begin
	if (rising_edge(CLOCK_50)) then
		if (key(0) = '0') then
			data <= (others => '0') ;
		elsif (state = dataread)then
				if data_count >= 41500 then
					data(bitcount - 1) <= '1' ;
					end if;
		else
				data <= (others => '0') ;
		end if ;
	end if ;
end process ;						
						  
process(key(0), CLOCK_50)
begin
	if (rising_edge(CLOCK_50)) then
		if (key(0) = '0') then
			ready <= '0' ;
		else 
			if bitcount = 32 then
				if (data(31 downto 24) = (not data(23 downto 16))) then
					data_buf <= data ;
					ready <= '1' ;
				else
					ready <= '0' ;
				end if ;
			else
				ready <= '0' ;
			end if ;
		end if ;
	end if ;
end process ;

process(key(0), CLOCK_50)
begin
	if rising_edge(CLOCK_50) then
		if key(0) = '0' then
			odata <= (others => '0') ;
		elsif(ready = '1') then
			odata <= data_buf ;
		end if ;
	end if ;
	end process ;
	
               digit7: bcd7seg port map( odata(31 downto 28),hex7);
               digit6: bcd7seg port map( odata(27 downto 24),hex6);
               digit5: bcd7seg port map( odata(23 downto 20),hex5);	
	            digit4: bcd7seg port map( odata(19 downto 16),hex4);
               digit3: bcd7seg port map( odata(15 downto 12),hex3);              
					digit2: bcd7seg port map( odata(11 downto 8 ),hex2);
               digit1: bcd7seg port map( odata(7  downto 4 ),hex1);
					digit0: bcd7seg port map( odata(3  downto 0 ),hex0);
					


end rtl ;						  
						  
LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY bcd7seg IS
PORT ( C: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		H: OUT STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE Behavior OF bcd7seg IS
BEGIN
PROCESS (C)
BEGIN
CASE C IS
when "0000"=> H <="1000000";  -- '0'
when "0001"=> H <="1111001";  -- '1'
when "0010"=> H <="0100100";  -- '2'
when "0011"=> H <="0110000";  -- '3'
when "0100"=> H <="0011001";  -- '4' 
when "0101"=> H <="0010010";  -- '5'
when "0110"=> H <="0000010";  -- '6'
when "0111"=> H <="1111000";  -- '7'
when "1000"=> H <="0000000";  -- '8'
when "1001"=> H <="0011000";  -- '9'
when "1010"=> H <="0001000";  -- 'A'
when "1011"=> H <="0000011";  -- 'b'
when "1100"=> H <="1000110";  -- 'C'
when "1101"=> H <="0100001";  -- 'd'
when "1110"=> H <="0000110";  -- 'E'
when "1111"=> H <="0001110";  -- 'F'
	END CASE;
	END PROCESS;
END Behavior;
		 
