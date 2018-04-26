library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    port(Opcode 	: in std_logic_vector(2 downto 0);
         A    		: in std_logic_vector(31 downto 0);
         B       	: in std_logic_vector(31 downto 0);
         ALU_Result 	: out std_logic_vector(31 downto 0);
         Status    	: out std_logic_vector(3 downto 0));  
end entity;

architecture ALU_arch of ALU is

  begin

    ALU : process(Opcode)

	 variable sum			: unsigned (32 downto 0);
	 variable twoB			: unsigned (63 downto 0);
	 variable sum_signed 	: signed (32 downto 0);
	 variable multiply 		: signed (63 downto 0);
		 
		begin
		
			if(Opcode = "000") then -- Nop
				Status(1) <= '0';
				Status(1) <= '0';
				Status(2) <= '0';
				Status(3) <= '0';
					
			
			elsif(Opcode = "001") then -- Add
				sum := unsigned('0' & A) + unsigned('0' & B);
				ALU_Result(31 downto 0)  <= std_logic_vector(signed(sum(31 downto 0)));
				Status(2) <= sum(31); 
				if(sum(31 downto 0) = x"00000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				if((A(31)='0' and B(31)='0' and sum(31)='1') or (A(31)='1' and B(31)='1' and sum(31)='0')) then
					Status(3) <= '1';
				else
					Status(3)  <='0';
				end if;
				Status(1) <= sum(32);

			elsif(Opcode = "010") then -- Subtract
				sum_signed := signed('0' & A)-signed('0' & B);
				ALU_Result(31 downto 0)  <= std_logic_vector(sum_signed(31 downto 0));
				Status(2) <= sum_signed(31);
				if(sum_signed(31 downto 0) = x"00000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				if((A(31)='0' and B(31)='0' and sum_signed(31)='1') or (A(31)='1' and B(31)='1' and sum_signed(31)='0')) then
					Status(3) <= '1';
				else
					Status(3)  <='0';
				end if;
				Status(1) <= sum_signed(32);

			elsif(Opcode = "011") then -- Multiply	
				multiply := signed(A) * signed(B);
				ALU_Result <= std_logic_vector(multiply(31 downto 0));
				if(multiply = x"0000000000000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				if((A(31)='0' and B(31)='0' and multiply(63)='1') or (A(31)='1' and B(31)='1' and multiply(63)='0') or (multiply < x"ffffffff80000000") or (multiply > x"7ffffffff")) then
					Status(3) <= '1';
				else
					Status(3)  <='0';
				end if;
				Status(1) <= '0';
				Status(2) <= multiply(63);
			
			elsif(Opcode = "100") then -- Increment 
				sum := unsigned('0' & A);
				sum := sum + 1;
				ALU_Result(31 downto 0)  <= std_logic_vector(sum(31 downto 0));
				if(sum(31 downto 0) = x"00000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				Status(1) <= sum(32);
			
			elsif(Opcode = "101") then -- Move A
				ALU_Result(31 downto 0) <= A;
				if(A = x"00000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				Status(1) <= '0';
				Status(2) <= A(31);
				Status(3) <= '0';
					
			elsif(Opcode = "110") then -- Move B
				ALU_Result(31 downto 0) <= B;
				if(B = x"00000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				Status(1) <= '0';
				Status(2) <= B(31);
				Status(3) <= '0';
			
			elsif(Opcode = "111") then -- Add A + 2B
				twoB := 2 * unsigned(B);
				sum := unsigned('0' & A) + ('0' & twoB(31 downto 0));
				ALU_Result(31 downto 0)  <= std_logic_vector(signed(sum(31 downto 0)));
				Status(2) <= sum(31);
				if(sum(31 downto 0) = x"00000000") then
					Status(0) <='1';
				else
					Status(0) <='0';
				end if;
				if((A(31)='0' and twoB(31)='0' and sum(31)='1') or (A(31)='1' and twoB(31)='1' and sum(31)='0')) then
					Status(3) <= '1';
				else
					Status(3)  <='0';
				end if;
				Status(1) <= sum(32);
			end if;			
	end process;	
end architecture;