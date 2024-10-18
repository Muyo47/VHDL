library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity segundero is
  Generic ( n_bits : integer := 27;
            f_buscada : integer := 125000000);        --Frecuencia buscada (1Hz));       --Uso 27 bits
  Port ( clk : in std_logic;
         enable : in std_logic;
         reset : in std_logic;
         seg : out std_logic );
end segundero;

architecture Behavioral of segundero is
signal c_count : unsigned (n_bits - 1 downto 0);   --27 bits para contar hasta 125 millones
--signal ciclos_usuario : integer := ;                   --Asignacion en ciclos de la fecuencia buscada
begin
 --Proceso que genera la senal periodica de 1 segundo
 Process (reset, clk, enable)
    begin
        if reset = '1' then
            c_count <= (others => '0');
        elsif rising_edge(clk) then
            if c_count = f_buscada - 1 then --Cuando se alcanza el conteo total. Para un conteo
                c_count <= (others => '0'); --diferente a 1Hz, cambiar la constante nstotal
                               --Devolvemos 1, se contó un segundo completo
            else
                c_count <= c_count + 1; --Seguimos avanzando
            end if;
        end if;
 end process;
 
seg <= '1' when c_count = f_buscada - 1 else '0'; 
 
 end Behavioral;