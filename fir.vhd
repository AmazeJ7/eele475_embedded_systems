library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir is
  port (
    clk  : in std_logic;
    x    : in std_logic_vector(15 downto 0);
    y    : out std_logic_vector(33 downto 0)
  );
end entity;


architecture fir_arch of fir is

  constant b0 : std_logic_vector(15 downto 0) := "0010000000000000"; --b0 = 0.5 
  constant b1 : std_logic_vector(15 downto 0) := "1101100110011010"; --b1 = -0.6 
  constant b2 : std_logic_vector(15 downto 0) := "0011111101011100"; --b2 = 0.99
  constant b3 : std_logic_vector(15 downto 0) := "1111100110011010"; --b3 = -0.1

  signal x1, x2, x3 : std_logic_vector(15 downto 0);
  signal s0, s1, s2, s3 : signed(31 downto 0);
  signal s0e, s1e, s2e, s3e : signed(32 downto 0);
  signal s01, s23 : signed(32 downto 0);
  signal s01e, s23e : signed(33 downto 0);

  begin

    SHIFT : process(clk)
      begin
        if(rising_edge(clk)) then
          x1 <= x;
          x2 <= x1;
          x3 <= x2;
        end if;
    end process;

    MULTIPLY : process(clk)
      begin
        if(rising_edge(clk)) then
          s0 <= signed(b0) * signed(x);
          s1 <= signed(b1) * signed(x1);
          s2 <= signed(b2) * signed(x2);
          s3 <= signed(b3) * signed(x3);
        end if;
    end process;

    FIRST_ADD : process(clk)
      begin
        if(rising_edge(clk)) then
          if(s0(31) = '0') then
            s0e <= '0' & s0;
          else
            s0e <= '1' & s0;
          end if;

          if(s1(31) = '0') then
            s1e <= '0' & s1;
          else
            s1e <= '1' & s1;
          end if;

          if(s2(31) = '0') then
            s2e <= '0' & s2;
          else
            s2e <= '1' & s2;
          end if;

          if(s3(31) = '0') then
            s3e <= '0' & s3;
          else
            s3e <= '1' & s3;
          end if;

          s01 <= s0e + s1e;
          s23 <= s2e + s3e;
        end if;
    end process;
                  
    FINAL_ADD : process(clk)
      begin
        if(rising_edge(clk)) then
          if(s01(32) = '0') then
            s01e <= '0' & s01;
          else
            s01e <= '1' & s01;
          end if;

          if(s23(32) = '0') then
            s23e <= '0' & s23;
          else
            s23e <= '1' & s23;
          end if;
          
          y <= std_logic_vector(s01e + s23e);
        end if;
    end process;
end architecture;
