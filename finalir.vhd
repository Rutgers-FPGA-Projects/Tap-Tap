library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ;

entity finalir is
port (
     CLOCK_50: in std_logic;
	  reset: in std_logic;
	  IRDA_RXD: in std_logic;
	  input_data: out std_logic_vector(7 DOWNTO 0)
);
 end finalir;
 
 architecture rtl of finalir is
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
	input_data <= odata(23 DOWNTO 16);
	--	//idle counter works on clk50 under idle state only		    
   process (reset,CLOCK_50)
      begin
		 if(rising_edge(CLOCK_50))then
		   if(reset = '0')then 
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
		 	 process (reset, CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (reset = '0')then
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
   process (reset,CLOCK_50)
      begin
		 if(rising_edge(CLOCK_50))then
		   if(reset = '0')then 
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
		 	 process (reset, CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (reset = '0')then
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
   process (reset,CLOCK_50)
      begin
		 if(rising_edge(CLOCK_50))then
		   if(reset = '0')then 
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
		 	 process (reset, CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (reset = '0')then
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
		 	 process (reset, CLOCK_50)
            begin
       		    if (rising_edge(CLOCK_50))then
					   if (reset = '0')then
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
				

process(reset, CLOCK_50)
begin
	if (rising_edge(CLOCK_50)) then
		if (reset = '0') then
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

process(reset, CLOCK_50)
begin
	if (rising_edge(CLOCK_50)) then
		if (reset = '0') then
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
						  
process(reset, CLOCK_50)
begin
	if (rising_edge(CLOCK_50)) then
		if (reset = '0') then
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

process(reset, CLOCK_50)
begin
	if rising_edge(CLOCK_50) then
		if reset = '0' then
			odata <= (others => '0') ;
		elsif(ready = '1') then
			odata <= data_buf ;
		end if ;
	end if ;
	end process ;				


end rtl ;						  
