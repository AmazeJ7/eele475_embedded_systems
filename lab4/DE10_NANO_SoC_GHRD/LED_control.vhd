library ieee;
use ieee.std_logic_1164.all;

entity LED_control is
  port(
    clk     :  in std_logic;                         -- system clock
    reset   :  in std_logic;                         -- system reset
    PB      :  in std_logic;                         -- pushbutton to change state (hardware vs software control)
    SW      :  in std_logic_vector(3 downto 0);      -- slide switched on the DE10
    LED_reg :  in std_logic_vector(3 downto 0);      -- LED register
    LED     :  out std_logic_vector(7 downto 0)      -- LEDs on DE10
  );
end entity;


architecture LED_control_arch of LED_control is

  type State_Type is (State_1, State_2);  
  signal current_state, next_state : State_Type;
  signal push : std_logic;

  component PB_transform is
    port (
          delay  : in std_logic_vector (24 downto 0);
          button : in std_logic;
          clk    : in std_logic;
          reset  : in std_logic;
          result : out std_logic
    );
  end component;

  begin

    DEBOUNCE : PB_transform port map (clk => clk, reset => reset, button => PB, result => push, delay => "0001001100010010110100000");

    LED (5 downto 4) <= "00";

    STATE_MEMORY : process (clk, reset)
      begin
        if(reset = '0') then
          current_state <= State_1;
        elsif (rising_edge(clk)) then
          current_state <= next_state;
        end if;
    end process;

    NEXT_STATE_LOGIC : process (push, current_state)
      begin
        if (push = '1') then
          if (current_state = State_1) then
            next_state <= State_2;
          else
            next_state <= State_1;
          end if;
        else
          next_state <= current_state;
        end if;
    end process;



    OUTPUT_LOGIC : process (current_state)
      begin
        case (current_state) is
          when State_1 => LED (3 downto 0) <= SW;
                          LED (7) <= '1';
                          LED (6) <= '0';
          when State_2 => LED (3 downto 0) <= LED_reg;
                          LED (7) <= '0';
                          LED (6) <= '1';
          when others =>  LED     <= "00000000";
        end case;
    end process;
end architecture;
