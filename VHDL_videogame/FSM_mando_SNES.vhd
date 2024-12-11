library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_mando_SNES is
  Port ( clk : in std_logic;
         reset : in std_logic;
         fin_6us : in std_logic;
         fin_12us : in std_logic;
         data_count : in unsigned (4 downto 0);
         
         latch_out : out std_logic;
         clk_SNES_out : out std_logic;
         data_end : out std_logic);
end FSM_mando_SNES;

architecture Behavioral of FSM_mando_SNES is

    type MANDO_SNES is (IDLE, estado1, estado2, estado3, estado4);      --4 estados en total
    signal e_actual, e_siguiente : MANDO_SNES;

begin

-----------PROCESO SECUENCIAL PARA LA TRANSICION DE ESTADOS Y REINICIO DE PROGRAMA--------------------------------------------------------
-------- En este proceso se reinicia al estado inicial en caso de reset, y se actualiza el estado actual de la maquina de acuerdo con la logica implementada
seq_P : process(reset,clk)
    begin
        if reset = '1' then
            e_actual <= IDLE;       --Condicion de reset, reinicio el estado al estado 0
        elsif rising_edge (clk) then
            e_actual <= e_siguiente;
        end if;
end process;
-----------------------------------------------------------------------------------------------------------------------------------------------



----------PROCESO COMBINACIONAL PARA TRANSICIONAR ENTRE ESTADOS---------------------------------------------------------------------------------
-------- En este proceso, se actualiza el estado de acuerdo al diagrama de estados que hemos implementado.

comb_P : process(e_actual,fin_12us,fin_6us)
    begin
        e_siguiente <= e_actual;        --En caso de que no se cumpla ninguna condicion dentro de los casos
        case e_actual is
            when IDLE =>
                if fin_12us = '1' then
                    e_siguiente <= estado1;
                end if;
            when estado1 =>
                if fin_12us = '1' then
                    e_siguiente <= estado2;                 
                end if;
            when estado2 =>
                if fin_6us = '1' then
                    e_siguiente <= estado3;
                end if;
            when estado3 =>
                if fin_6us = '1' then
                    if data_count < 15 then            
                        e_siguiente <= estado2;
                    else
                        e_siguiente <= estado4;
                    end if;
                end if;
            when estado4 =>
                if fin_12us = '1' then
                    e_siguiente <= IDLE;
                end if;
       end case;
end process; 
--------------------------------------------------------------------------------------------------------------------------

---------PROCESO COMBINACIONAL PARA ASIGNAR SALIDAS DE NUESTRO CIRCUITO----------------------------------------------------
------- En este proceso, simplemente se decide que contador se debe accionar, y si debe contar hacia arriba o abajo (recordar que para nuestros contadores 
------- el sentido de la cuenta hacia arriba se hace con un '0' y hacia abajo con un '1'). El conteo dependera del estado en el que este la maquina
comb_salidas : process(e_actual)
    begin
    latch_out <= '0';
    clk_SNES_out <= '1';
    data_end <= '0';
        case e_actual is
            when IDLE => 
                latch_out <= '0';
                clk_SNES_out <= '1';
                data_end <= '0';
            when estado1 =>
                latch_out <= '1';
                clk_SNES_out <= '1';
                data_end <= '0';
            when estado2 =>
                latch_out <= '0';
                clk_SNES_out <= '1';
                data_end <= '0';
            when estado3 => 
                latch_out <= '0';
                clk_SNES_out <= '0';
                data_end <= '0';
            when estado4 => 
                latch_out <= '0';
                clk_SNES_out <= '1';
                data_end <= '1';
         end case;
end process;

end Behavioral;