library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

------ENTIDAD MAQUINA DE ESTADOS--------------------------------------------------------------------
entity FSM_velocidad is
  Port ( clk : in std_logic;
         rst : in std_logic;
         boton : in std_logic;
         seleccion : out std_logic_vector (1 downto 0));
end FSM_velocidad;
--------------------------------------------------------------------------------------------------------

architecture Behavioral of FSM_velocidad is

---------DECLARACION ESTADOS-------------------------------------------------------------------------------------------------------
signal fincuenta_s : std_logic;
signal cuenta_s : std_logic_vector (1 downto 0);

    type VELOCIDAD is (ms100, ms75, ms60, ms50);      --4 estados en total
    signal e_actual, e_siguiente : VELOCIDAD;    
--signal btn : std_logic;
signal seleccion_s : std_logic_vector (1 downto 0);
------------------------------------------------------------------------------------------------------------------------------------

begin

-------PROCESO SECUENCIAL PARA LA TRANSICION DE ESTADOS Y REINICIO DE PROGRAMA--------------------------------------------------------
seq_P : process(rst,clk)
    begin
        if rst = '1' then
            e_actual <= ms100;       --Condicion de reset, reinicio el estado al estado 0
        elsif rising_edge (clk) then
            e_actual <= e_siguiente;
        end if;
    end process;
-------------------------------------------------------------------------------------------------------------------------------------------

------PROCESO COMBINACIONAL PARA TRANSICIONAR ENTRE ESTADOS---------------------------------------------------------------------------------
comb_P : process(e_actual, boton)
    begin
    e_siguiente <= e_actual;
        case e_actual is
            when ms100 =>
                if boton = '1' then
                    e_siguiente <= ms75;
                end if;
            when ms75 =>
                if boton = '1' then
                    e_siguiente <= ms60;
                end if;
            when ms60 =>
                if boton = '1' then
                    e_siguiente <= ms50;
                end if;
            when ms50 =>
                if boton = '1' then
                    e_siguiente <= ms100;
                end if;
       end case;
end process; 
------------------------------------------------------------------------------------------------------------------------

-------PROCESO COMBINACIONAL PARA ASIGNAR SALIDAS DE NUESTRO CIRCUITO----------------------------------------------------
comb_salidas : process(e_actual)
    begin
        case e_actual is
            when ms100 => 
                    seleccion_s <= "00";
            when ms75 =>
                    seleccion_s <= "01";
            when ms60 => 
                    seleccion_s <= "10";
            when ms50 => 
                    seleccion_s <= "11";
         end case;
end process;
----------------------------------------------------------------------------------------------------------------------------

--Aqui pasamos de unsigned a std_logic_vector con motivos de compatibilidad
seleccion <= std_logic_vector(seleccion_s);

end Behavioral;
