library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity mux4a1 is
    Generic( bits_en : integer);   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
           ent_mux_2 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 2
           ent_mux_3 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 3
           sel_mux : in STD_LOGIC_VECTOR (1 downto 0);     --Selector del multiplexor
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end mux4a1; 

architecture Behavioral of mux4a1 is
begin
         sal_mux <= ent_mux_0 when sel_mux = "00"  
         else ent_mux_1 when sel_mux = "01"
         else ent_mux_2 when sel_mux = "10"
         else ent_mux_3 when sel_mux = "11";
         --Concurrente

end Behavioral;
