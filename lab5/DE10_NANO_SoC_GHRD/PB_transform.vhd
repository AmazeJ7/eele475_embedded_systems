library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity PB_transform is
  port (
        delay  : in std_logic_vector (24 downto 0);
        button : in std_logic;
        clk    : in std_logic;
        reset  : in std_logic;
        result : out std_logic
  );
end entity;



architecture PB_transform_arch of PB_transform is

  type State_Type is (S0, S1, S2, S3);
  signal button_inv : std_logic;
  signal current_state, next_state : State_Type;
  signal DFF, PB_sync : std_logic;
  signal counter : std_logic_vector (24 downto 0);
  signal enable, switch : std_logic;
  signal counter_int : integer;

  begin

  counter <= std_logic_vector(to_unsigned(counter_int, 25));
  button_inv <= not button;

------------SYNCHRONIZE PB TO THE CLOCK--------------------
  SYNCHRONIZE : process (clk)
    begin
      DFF <= button_inv;
      PB_sync <= DFF;
  end process; 

-----------------------DELAY COUNTER-----------------------
  COUNTER_PROC : process (clk, reset)
    begin
      if (reset = '0') then
        counter_int <= 0;
        switch <= '0';
      elsif (rising_edge(clk) and enable = '1') then
        if (counter_int > to_integer(unsigned(delay))) then
          counter_int <= 0;
          switch <= '1';
        else
          counter_int <= counter_int + 1;
          switch <= '0';
        end if;
      end if;
  end process;     

-----------------STATE MACHINE PROCESSES--------------------
  STATE_MEMORY : process (clk, reset)
    begin
      if (reset = '0') then
        current_state <= S0;
      elsif (rising_edge(clk)) then
        current_state <= next_state;
      end if;
  end process;

  NEXT_STATE_LOGIC : process (PB_sync, current_state, switch)
    begin
      case (current_state) is
        when S0 => if (PB_sync = '0') then
                     next_state <= S0;
                   else
                     next_state <= S1;
                   end if;
        when S1 => next_state <= S2;
        when S2 => if (switch = '0') then
                     next_state <= S2;
                   else
                     next_state <= S3;
                   end if;
        when S3 => if (PB_sync = '1') then
                     next_state <= S3;
                   else
                     next_state <= S0;
                   end if;
        when others => next_state <= S0;
      end case;
  end process;

  OUTPUT_LOGIC : process (current_state)
    begin
      case (current_state) is
        when S0 =>     result <= '0';
                       enable <= '0';
        when S1 =>     result <= '1';
                       enable <= '0';
        when S2 =>     result <= '0';
                       enable <= '1';
        when S3 =>     result <= '0';
                       enable <= '0';
        when others => result <= '0';
                       enable <= '0';
      end case;
  end process;     
end architecture;
