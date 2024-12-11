----------------------------------------------------------------------------------------------------------------
-- Circuito diseñado para gestionar los movimientos de un sprite de forma automatica. Es necesario incluir la retroalimentacion de la posicion actual.
-- Devuelve el dato al contador para gestionar el sprite. Es necesario crear 2 contadores en la entidad inmediatamente
-- superior, uno para filas y otro para columnas. Tambien se debe incluir una señal de muestreo para determinar la velocidad del bot.
-- Para ello se añade un contador de tiempo variable de muestreo.
-- El circuito se implementa con 4 estados relacionados con los movimientos posibles.
-- Se analizan los movimientos siguiendo una lista de prioridad.
-- La actualizacion de estado solo se realiza una vez se alcanza la señal de muestreo,
-- que indica que el movimiento se ha completado y podemos cambiar de estado.
----------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.RACETRACK_PKG.ALL;

entity FSM_sprite_automatico is
  Port ( 
         --PUERTOS DE ENTRADA--
         clk : in std_logic;
         reset : in std_logic;
         feedback_cuad_col : in std_logic_vector (5 downto 0);
         feedback_cuad_fil : in std_logic_vector (5 downto 0);
         muestreo_auto : in std_logic;
         
         --PUERTOS DE SALIDA--
         cont_col : out std_logic;
         cont_fil : out std_logic;
         sig_col : out std_logic;
         sig_fil : out std_logic );
         
end FSM_sprite_automatico;

architecture Behavioral of FSM_sprite_automatico is

    type MOVIMIENTO_SPRITE is (arriba, abajo, izquierda, derecha);      --4 estados en total
    signal e_actual, e_siguiente : MOVIMIENTO_SPRITE;

constant max_col_cuad : natural := 31;    --Maximo de cuadriculas en columnas
constant max_fil_cuad : natural := 29;    --Maximo de cuadriculas en filas

signal movimientos : std_logic_vector(3 downto 0);

begin

movimientos <= pista(to_integer(unsigned(feedback_cuad_fil)-1))(to_integer(unsigned(feedback_cuad_col))) & pista(to_integer(unsigned(feedback_cuad_fil)+1))(to_integer(unsigned(feedback_cuad_col))) & pista(to_integer(unsigned(feedback_cuad_fil)))(to_integer(unsigned(feedback_cuad_col)-1)) & pista(to_integer(unsigned(feedback_cuad_fil)))(to_integer(unsigned(feedback_cuad_col)+1));

---------PROCESO SECUENCIAL PARA LA TRANSICION DE ESTADOS Y REINICIO DE PROGRAMA--------------------------------------------------------
------ En este proceso se reinicia al estado inicial en caso de reset, y se actualiza el estado actual de la maquina de acuerdo con la logica implementada
seq_P : process(reset,clk)
    begin
        if reset = '1' then
            e_actual <= derecha;       --Condicion de reset, reinicio el estado al estado 0
        elsif rising_edge (clk) then
            if muestreo_auto = '1' then
                e_actual <= e_siguiente;
            else
                e_actual <= e_actual;
            end if;
        end if;
end process;
---------------------------------------------------------------------------------------------------------------------------------------------

--------PROCESO COMBINACIONAL PARA TRANSICIONAR ENTRE ESTADOS---------------------------------------------------------------------------------
------ En este proceso, se actualiza el estado de acuerdo al diagrama de estados que hemos implementado.

comb_P : process(e_actual, feedback_cuad_fil, feedback_cuad_col)
    begin
        e_siguiente <= e_actual;        --En caso de que no se cumpla ninguna condicion dentro de los casos
        case e_actual is
            when derecha =>
                if movimientos(2) = '0' then
                    if movimientos (0) = '0' then
                        e_siguiente <= arriba;
                    else
                        e_siguiente <= derecha;
                    end if;
                else
                    e_siguiente <= abajo;
                end if;
            when izquierda =>
                if movimientos(3) = '0' then
                    if movimientos (1) = '0' then
                        e_siguiente <= abajo;
                    else
                        e_siguiente <= izquierda;
                    end if;
                else
                    e_siguiente <= arriba;
                end if;
            when abajo =>
                if movimientos(1) = '0' then
                    if movimientos (2) = '0' then
                        e_siguiente <= derecha;
                    else
                        e_siguiente <= abajo;
                    end if;
                else
                    e_siguiente <= izquierda;
                end if;
            when arriba =>
                if movimientos(0) = '0' then
                    if movimientos (3) = '0' then
                        e_siguiente <= izquierda;
                    else
                        e_siguiente <= arriba;
                    end if;
                else
                    e_siguiente <= derecha;
                end if;
       end case;
end process; 
--------------------------------------------------------------------------------------------------------------------------

---------PROCESO COMBINACIONAL PARA ASIGNAR SALIDAS DE NUESTRO CIRCUITO----------------------------------------------------
------- En este proceso, simplemente se decide que contador se debe accionar, y si debe contar hacia arriba o abajo (recordar que para nuestros contadores 
------- el sentido de la cuenta hacia arriba se hace con un '0' y hacia abajo con un '1'). El conteo dependera del estado en el que este la maquina
comb_salidas : process(muestreo_auto, e_actual)
    begin
    sig_col <= '0';
    cont_col <= '0';
    sig_fil <= '0';
    cont_fil <= '0';
        case e_siguiente is
            when derecha => 
                if muestreo_auto = '1' then
                    sig_col <= '0';
                    cont_col <= '1';
                    sig_fil <= '0';
                    cont_fil <= '0';
                end if;
            when izquierda =>
                if muestreo_auto = '1' then
                    sig_col <= '1';
                    cont_col <= '1';
                    sig_fil <= '0';
                    cont_fil <= '0';
                end if;
            when arriba =>
                if muestreo_auto = '1' then
                    sig_col <= '0';
                    cont_col <= '0';
                    sig_fil <= '1';
                    cont_fil <= '1';
                end if;
            when abajo => 
                if muestreo_auto = '1' then
                    sig_col <= '0';
                    cont_col <= '0';
                    sig_fil <= '0';
                    cont_fil <= '1';
                end if;
         end case;
end process;

end Behavioral;
