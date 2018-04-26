library ieee;
use ieee.std_logic_1164.all;

entity LED_control_TB is
end entity;

architecture LED_control_TB_arch of LED_control_TB is

  component LED_control is
    port (clk, reset, PB : in  std_logic;
          SW             : in  std_logic_vector(3 downto 0);
	  LED_reg        : in  std_logic_vector(3 downto 0);
          LED            : out std_logic_vector(7 downto 0));
  end component;

  signal clk_TB, reset_TB : std_logic;
  signal PB_TB : std_logic;
  signal SW_TB : std_logic_vector (3 downto 0);
  signal LED_reg_TB : std_logic_vector (3 downto 0);
  signal LED_TB :std_logic_vector(7 downto 0);

  begin

  SW_TB <= "1010";
  LED_reg_TB <= "0101";

  DUT : LED_control port map (clk => clk_TB, reset => reset_TB, PB => PB_TB, SW => SW_TB, LED_reg => LED_reg_TB, LED => LED_TB);

  CLOCK_STIM : process
    begin
      clk_TB <= '0'; wait for 20 ns;
      clk_TB <= '1'; wait for 20 ns;
  end process;

  RESET_STIM : process
    begin
      reset_TB <= '0'; wait for 60 ns;
      reset_TB <= '1'; wait;
  end process;

  PB_STIM : process
    begin
      PB_TB <= '0'; wait for 5 ms;
      PB_TB <= '1'; wait for 15 ms;
      PB_TB <= '0'; wait;
  end process;
end architecture;