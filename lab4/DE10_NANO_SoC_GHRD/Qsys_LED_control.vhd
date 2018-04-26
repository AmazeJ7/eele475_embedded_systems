library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Qsys_LED_control is
  port (
        clk               : in std_logic;
        reset_n           : in std_logic;  --reset asserted low
        avs_s1_address    : in std_logic_vector(1 downto 0);
        avs_s1_write      : in std_logic;
        avs_s1_writedata  : in std_logic_vector(31 downto 0);
        avs_s1_read       : in std_logic;
        avs_s1_readdata   : out std_logic_vector(31 downto 0);
        switches          : in std_logic_vector(3 downto 0);
        pushbutton        : in std_logic;
        LEDs              : out std_logic_vector(7 downto 0)
  );
end entity;

architecture Qsys_LED_control_arch of Qsys_LED_control is

  component LED_control is
    port(
      clk     :  in std_logic;                         -- system clock
      reset   :  in std_logic;                         -- system reset
      PB      :  in std_logic;                         -- pushbutton to change state (hardware vs software control)
      SW      :  in std_logic_vector(3 downto 0);      -- slide switched on the DE10
      LED_reg :  in std_logic_vector(3 downto 0);      -- LED register
      LED     :  out std_logic_vector(7 downto 0)      -- LEDs on DE10
    );
  end component;

  signal reg0, reg1 : std_logic_vector(31 downto 0) := x"00000000";

  begin

  led0 : LED_control port map (clk => clk, reset => reset_n, PB => pushbutton, SW => switches, 
                               LED_reg => reg1, LED => LEDs);

  
										 
  REGISTER_READ : process(clk)
    begin
      if(rising_edge(clk) and avs_s1_read = '1') then
        case avs_s1_address is
          when "00" =>   avs_s1_readdata <= reg0;
          when "01" =>   avs_s1_readdata <= reg1;
          when others => avs_s1_readdata <= (others => '0'); --return zeros for undefined registers
        end case;
      end if;
  end process;

  REGISTER_WRITE : process(clk)
    begin
      if(rising_edge(clk) and avs_s1_write = '1') then
        case avs_s1_address is
          --when "00" =>   reg0 <= avs_s1_writedata;
          when "01" =>   reg1 <= avs_s1_writedata;
          when others => reg1 <= reg1;
        end case;
      end if;
  end process;
  
  REG0_UPDATE : process (clk)
    begin
	   if(rising_edge(clk)) then
		  reg0 <= switches;
		end if;
  end process;
  
  
  

end architecture;