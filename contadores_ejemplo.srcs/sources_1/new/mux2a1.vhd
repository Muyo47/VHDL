library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux2a1 is
    Generic( bits_en : integer); --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);
           sel_mux : in STD_LOGIC;
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));
end mux2a1;

architecture Behavioral of mux2a1 is
begin
         sal_mux <= ent_mux_0 when sel_mux = '0'  
         else ent_mux_1 when sel_mux = '1';     --concurrente, entrada 0 cuando sel=0, entrada 1 en el otro caso

end Behavioral;
