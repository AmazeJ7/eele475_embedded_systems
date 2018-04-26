library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PB_transform is
  port (PB, clk, reset : in  std_logic;
	delay          : in  std_logic_vector(24 downto 0);
	PB_out         : out std_logic);
end entity;

architecture PB_transform_arch of PB_transform is

  type State_Type is (S0, S1, S2, S3);
  signal current_state, next_state : State_Type;
  signal DFlipFlop, sync, en, go : std_logic;
  signal count : integer;
  
  begin

    SYNCHRONIZE : process (clk)
      begin
        DFlipFlop <= PB;
        sync <= DFlipFlop;
    end process; 

    COUNTER : process (clk, reset)
      begin 
	if (reset = '0') then
	  count <= 0;
	  go <= '0';
	elsif (en = '1' and rising_edge(clk)) then
	  if (count > to_integer(unsigned(delay))) then
	    count <= 0;
	    go <= '1';
	  else 
	    count <= count + 1;
	    go <= '0';
    	  end if;
	end if;
    end process; 

    STATE_MEMORY : process (clk, reset)
      begin
        if (reset = '0') then 
	  current_state <= S0;
	elsif (rising_edge(clk)) then
	  current_state <= next_state;
	end if;
    end process;

    NEXT_STATE_LOGIC : process (sync, current_state, go)
      begin
	case (current_state) is
	  when S0 => if (sync = '1') then next_state <= S1; end if;
	  when S1 => next_state <= S2;
	  when S2 => if (go = '1') then next_state <= S3; else next_state <= S2; end if;
	  when S3 => if (sync = '0') then next_state <= S0; end if;
	  when others => next_state <= S0;
	end case;
    end process;

    OUTPUT_LOGIC : process (current_state)
      begin
	case (current_state) is
	  when S0     => PB_out <= '0'; en <= '0';
	  when S1     => PB_out <= '1'; en <= '0';
	  when S2     => PB_out <= '0'; en <= '1';
	  when S3     => PB_out <= '0'; en <= '0';
	  when others => PB_out <= '0'; en <= '0';
	end case;
    end process;
  


end architecture;