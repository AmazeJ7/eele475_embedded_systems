library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity PB_transform is 
	port(
		clk		: in std_logic;
		reset		: in std_logic;
		PB		: in std_logic;
		PB_sync 	: out std_logic;
		PB_ignore_time	: in std_logic_vector(24 downto 0) := "1001100010010110100000000"
	);
end entity;

architecture PB_transform_arch of PB_transform is

	signal PB1	: std_logic;
	signal PB2	: std_logic;
	signal counter_reset : std_logic;
	signal flag_ignore : std_logic;

	type state_type is (state_wait, state_pulse, state_ignore, state_deassert);
	signal current_state 	: state_type := state_wait;
	signal next_state 	: state_type;
	signal counter_ignore	: integer;

	begin

		sync : process (clk)
		begin
			PB1 <= NOT PB;
			PB2 <= PB1;
		end process;

		counter : process(clk, reset)
			begin
				if reset = '0' then
					counter_ignore <= 0;
					flag_ignore <= '0';
				elsif (rising_edge(clk) and counter_reset = '1') then
				if(counter_ignore > to_integer(unsigned(PB_ignore_time))) then
					counter_ignore <= 0;
					flag_ignore <= '1';
				else
						counter_ignore <= counter_ignore + 1;
						flag_ignore <= '0';
					end if;
				end if;
		end process;

		next_logic : process(PB2, current_state, flag_ignore)
			begin
					case (current_state) is
						when state_wait 	=>	if PB2 = '0' then
											next_state <= state_wait;
										else
											next_state <= state_pulse;
										end if;
						when state_pulse	=>	
											next_state <= state_ignore;

						when state_ignore	=>	
											if flag_ignore = '0' then
												next_state <= state_ignore;
											else
												next_state <= state_deassert;
											end if;
		
						when state_deassert	=>	
										if PB2 = '1' then
											next_state <= state_deassert;
										else
											next_state <= state_wait;
										end if;

						when others		=>	
											next_state <= state_wait;
					end case;
			end process;
			
		output : process(current_state)
			begin
					case (current_state) is
						when state_wait =>	
											PB_sync <= '0';
											counter_reset <= '0';
						
						when state_pulse	=>	
											PB_sync <= '1';
											counter_reset <= '0';

						when state_ignore	=>	
											PB_sync <= '0';
											counter_reset <= '1';
		
						when state_deassert	=>	
											PB_sync <= '0';
											counter_reset <= '0';

						when others		=>	
											current_state <= state_wait;
					end case;
			end process;

			state_update : process(clk, reset)
			begin
				if (reset = '0') then
					current_state <= state_wait;
				elsif (rising_edge(clk)) then
					current_state <= next_state;
				end if;
			end process;
			
end architecture;