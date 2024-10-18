library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity biestableT is
  Port ( clk : in std_logic;
         enable : in std_logic;
         reset : in std_logic;
         data : in std_logic;
         output_data : out std_logic );
end biestableT;

architecture Behavioral of biestableT is
signal q : std_logic := '0';

begin

process (clk, reset)
begin
    if reset = '1' then
        q <= '0';
    elsif rising_edge(clk) then
        if enable = '1' then
            if data = '1' then
                q <= not q;
            end if;
        end if;
    end if;
end process;

output_data <= q;

end Behavioral;
