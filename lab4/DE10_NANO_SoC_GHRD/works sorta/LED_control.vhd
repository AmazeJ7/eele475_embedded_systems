library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_textio.all;

entity LED_control is 
	port(
		clk	: in std_logic;
		reset	: in std_logic;
		PB	: in std_logic;
		SW	: in std_logic_vector(3 downto 0);
		LED_reg	: in std_logic_vector(3 downto 0);
		LED	: out std_logic_vector(7 downto 0)
	);
end entity LED_control;

architecture LED_control_arch of LED_control is

	type State_Type is (C0, C1);
	signal next_state : State_Type;
	signal current_state : State_Type := C0;
	signal temp	: std_logic := '0';
	signal PB_sync : std_logic;
	signal PB_ignore_time	: std_logic_vector(24 downto 0);

	component PB_transform is 
		port(
			clk	: in std_logic;
			reset	: in std_logic;
			PB	: in std_logic;
			PB_sync : out std_logic;
			PB_ignore_time : in std_logic_vector(24 downto 0)
		);
	end component;

	begin

		transform : PB_transform port map(clk => clk, reset => reset, PB => PB, PB_sync => PB_sync, PB_ignore_time => PB_ignore_time);

		State_Memory : process(clk, reset)
			begin
				if (reset = '0') then
					current_state <= C0;
				elsif (rising_edge(clk)) then
					current_state <= next_state;
				end if;
			end process;

		Next_State_Logic : process(current_state, PB_sync)
			begin
				if (PB_sync = '1') then
					if(current_state = C0) then
							next_state <= C1;
					else 
							next_state <= C0;
					end if;
				else
					next_state <= current_state;
				end if;
			end process;

		Output_Logic : process (current_state)
			begin
				case (current_state) is
					when C0	=> LED(3 downto 0) <= SW;
							LED(7 downto 6) <= "10";
					when C1	=> LED(3 downto 0) <= LED_reg;
							LED(7 downto 6) <= "01";
				end case;
			end process;
			

end architecture;