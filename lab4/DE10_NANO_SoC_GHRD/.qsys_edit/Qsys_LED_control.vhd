library IEEE;
use IEEE.std_logic_1164.all;

entity Qsys_LED_control is
  port (clk             : in  std_logic;
        reset_n         : in  std_logic;--reset asserted low
		avs_s1_address  : in  std_logic_vector(1downto 0);
		avs_s1_write    : in  std_logic;
		avs_s1_writedata: in  std_logic_vector(31 downto 0);
		avs_s1_read     : in  std_logic;
		avs_s1_readdata : out std_logic_vector(31 downto 0);
		switches        : in  std_logic_vector(3downto 0);
		pushbutton      : in  std_logic;
		LEDs            : out std_logic_vector(7 downto 0));
end Qsys_LED_control;

architecture Qsys_LED_control_arch of Qsys_LED_control is

  component LED_control
	port(clk, reset, PB : in  std_logic;
         SW, LED_reg	: in  std_logic_vector(3 downto 0);
		 LED			: out std_logic_vector(7 downto 0));
  end component;
	
  signal LED_reg : std_logic_vector(3 downto 0);
  signal reg0, reg1: std_logic_vector(31 downto 0);
  signal reset_int : std_logic;
  signal avs_s1_readdata_int : std_logic_vector(31 downto 0);
	
	begin
	
	LED : LED_control port map(clk => clk, reset => reset_int, PB => pushbutton, SW => switches, LED_reg => LED_reg, LED => LEDs);
								
	AVS_READ : process (clk) is
	  begin
		if(rising_edge(clk) and avs_s1_read = '1') then
		  case avs_s1_address is
			when "00" => avs_s1_readdata_int <= reg0;
			when "01" => avs_s1_readdata_int <= reg1;
			when others => avs_s1_readdata_int <= (others => '0'); -- return zeros for undefined registers
		  end case;
		end if;
	end process;
	
	AVS_WRITE : process (clk) is
	  begin
		if(rising_edge(clk) and avs_s1_write = '1') then
		  case avs_s1_address is
			when "00" => reg0 <= avs_s1_writedata;
			when "01" => reg1 <= avs_s1_writedata;
			when others =>  reg0 <= (others => '0'); reg1 <= (others => '0');
		  end case;
		end if;
	end process;
	
	avs_s1_readdata <= avs_s1_readdata_int;	
	reset_int <= not reset_n;
	LED_reg <= avs_s1_readdata_int(3 downto 0);	
	
end process; 

