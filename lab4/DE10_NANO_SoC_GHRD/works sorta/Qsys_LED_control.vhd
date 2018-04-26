library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity Qsys_LED_control is
	port	(
		clk		: in  std_logic;
		reset_n		: in  std_logic;
		avs_s1_address	: in  std_logic_vector(1 downto 0);
		avs_s1_write	: in  std_logic;
		avs_s1_writedata: in  std_logic_vector(31 downto 0);
		avs_s1_read	: in  std_logic;
		avs_s1_readdata	: out std_logic_vector(31 downto 0);
		switches	: in  std_logic_vector(3 downto 0);
		pushbutton	: in  std_logic;
		LEDs		: out std_logic_vector(7 downto 0)
	);
end entity;

architecture Qsys_LED_control_arch of Qsys_LED_control is

	signal reg0	: std_logic_vector(31 downto 0);
	signal reg1	: std_logic_vector(31 downto 0);

	component LED_control is 
		port(
			clk	: in std_logic;
			reset	: in std_logic;
			PB	: in std_logic;
			SW	: in std_logic_vector(3 downto 0);
			LED_reg	: in std_logic_vector(3 downto 0);
			LED	: out std_logic_vector(7 downto 0)
		);
	end component;


	begin

	control: LED_control port map( clk => clk, reset => reset_n, PB => pushbutton, SW => switches, LED_reg => reg1(3 downto 0), LED => LEDs);


		read_register : process(clk) is
				begin
					if rising_edge(clk) and avs_s1_read = '1' then
						case avs_s1_address is
							when "00" => avs_s1_readdata <= reg0;
							when "01" => avs_s1_readdata <= reg1;
							when others => avs_s1_readdata <= (others => '0');
						end case;
					end if;
				end process;

		write_register : process(clk) is
				begin
					if rising_edge(clk) and avs_s1_write = '1' then
						case avs_s1_address is
							when "00" => reg0 <= avs_s1_writedata;
							when "01" => reg1 <= avs_s1_writedata;
							when others => reg0 <= avs_s1_writedata;
						end case;
					end if;
				end process;

		read_switches : process(clk) is
				begin
					if rising_edge(clk) then
						reg0(3 downto 0) <= switches;
					end if;
				end process;


end architecture;