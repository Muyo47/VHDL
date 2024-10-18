library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador is
  Generic ( n_bits : integer;     --Bits necesarios para realizar la cuenta deseada
            max_count : integer);     --Generico para asignar la cuenta total a realizar
            
            --En el caso de requerir cuentas mayores, cambiar el numero de bits total!
  Port ( enable : in std_logic;                             --Habilitacion
         clk : in std_logic;                                --Reloj
         count : out std_logic_vector (n_bits-1 downto 0);  --Conteo total
         reset : in std_logic;          --Reset
         fin_cuenta : out std_logic;    --Fin de cuenta
         sentido_c : in std_logic); --0 para ascendente, 1 para descendente
        
end contador;
    
architecture Behavioral of contador is                  
signal counter_temp : unsigned (n_bits-1 downto 0);     --Señal para operaciones aritmeticas
begin                                                   
process (enable, clk, reset)        --Lista de sensibilidad del proceso
begin
    if reset = '1' then
        counter_temp <= (others => '0');      --Reiniciamos la cuenta en caso de que se active reset
     elsif rising_edge (clk) then          
        if enable = '1' then        --Solo cuando esta habilitado
            if counter_temp = to_unsigned(max_count-1, n_bits) then  --Condicion de fin de cuenta
                counter_temp <= (others => '0');  --Al alcanzar el conteo total, se reinicia la cuenta
                                                 
            else
                counter_temp <= counter_temp + 1; --Aumentamos el conteo en una unidad
            end if;
        end if;
     end if;
    end process;
    count <= std_logic_vector(counter_temp) when sentido_c = '0' else std_logic_vector((to_unsigned(max_count - 1, n_bits)) - counter_temp); --En el caso de conteo ascendente, simplemente pasamos el valor de counter_temp a la cuenta. Si el sentido es descendente, pasamos el valor maximo - el conteo realizado
    fin_cuenta <= '1' when counter_temp = max_count - 1 else '0';   --Bit de fin de cuenta. Solo cuando la cuenta ha acabado
end Behavioral;

