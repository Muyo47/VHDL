----------------------------------------------------------------------------------------------------------------
-- Circuito diseñado para gestionar los movimientos de un sprite. Es necesario incluir los opcommands de los
-- movimientos a realizar (botones). Tambien es necesario retroalimentacion de la posicion actual.
-- Devuelve el dato al contador para gestionar el sprite. Es necesario crear 2 contadores en la entidad inmediatamente
-- superior, uno para filas y otro para columnas. Tambien se debe incluir una señal de muestreo para evitar debounce.
-- Para ello se añade un contador de tiempo variable de muestreo.
-- Es recomendable usar este circuito ya que cumple las recomendaciones de sincronismo con reloj, en vez
-- de emplear registros de desplazamiento directamente.
----------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mov_sprite is
  Port ( clk : in std_logic;
         reset : in std_logic;
         feedback_cuad_fil : in std_logic_vector (5 downto 0);
         feedback_cuad_col : in std_logic_vector (5 downto 0);
         control_SNES : in std_logic_vector (15 downto 0);        --SNES
         muestreo : in std_logic;
         
         cont_col : out std_logic;
         cont_fil : out std_logic;
         sig_col : out std_logic;
         sig_fil : out std_logic );
end mov_sprite;

architecture Behavioral of mov_sprite is

begin
--SNES 4->UP    5->DOWN    6->IZQUIERDA     7->DERECHA
--BOTONES 0UP 1DOWN 2IZQ 3DER
process(clk, reset, muestreo, control_SNES)
begin
    if reset = '1' then
        cont_fil <= '0';
        sig_fil <= '0';
        cont_col <= '0';
        sig_col <= '0';
    elsif rising_edge(clk) then
    cont_fil <= '0';
    sig_fil <= '0';
    cont_col <= '0';
    sig_col <= '0';
        if muestreo = '1' then
        if control_SNES(4) = '0' and control_SNES(7) = '0' then     --SNES
        --if control_SNES(0) = '1' and control_SNES(3) = '1' then       --BOTONES PLACA
            if unsigned(feedback_cuad_fil) > 0 and unsigned(feedback_cuad_col) < 31 then
                cont_fil <= '1';
                sig_fil <= '1';
                cont_col <= '1';
                sig_col <= '0';
            end if;
        elsif control_SNES(4) = '0' and control_SNES(6) = '0' then        --SNES
        --elsif control_SNES(0) = '1' and control_SNES(2) = '1' then
            if unsigned(feedback_cuad_fil) > 0 and unsigned(feedback_cuad_col) > 0 then
                cont_fil <= '1';
                sig_fil <= '1';
                cont_col <= '1';
                sig_col <= '1';
            end if;
        elsif control_SNES(5) = '0' and control_SNES(6) = '0' then        --SNES
        --elsif control_SNES(1) = '1' and control_SNES(2) = '1' then
            if unsigned(feedback_cuad_fil) < 29 and unsigned(feedback_cuad_col) > 0 then
                cont_fil <= '1';
                sig_fil <= '0';
                cont_col <= '1';
                sig_col <= '1';
            end if;       
        elsif control_SNES(5) = '0' and control_SNES(7) = '0' then        --SNES
        --elsif control_SNES(1) = '1' and control_SNES(3) = '1' then
            if unsigned(feedback_cuad_fil) < 29 and unsigned(feedback_cuad_col) < 31 then
                cont_fil <= '1';
                sig_fil <= '0';
                cont_col <= '1';
                sig_col <= '0';
            end if;
        elsif control_SNES(4) = '0' then      --SNES
        --elsif control_SNES(0) = '1' then
            if unsigned(feedback_cuad_fil) > 0 then
                cont_fil <= '1';
                sig_fil <= '1';
            end if;
        elsif control_SNES(5) = '0' then      --SNES
        --elsif control_SNES(1) = '1' then
            if unsigned(feedback_cuad_fil) < 29 then
                cont_fil <= '1';
                sig_fil <= '0';
            end if;
        elsif control_SNES(7) = '0' then      --SNES
        --elsif control_SNES(3) = '1' then
            if unsigned(feedback_cuad_col) < 31  then
                cont_col <= '1';
                sig_col <= '0';
            end if;
        elsif control_SNES(6) = '0' then      --SNES
        --elsif control_SNES(2) = '1' then
            if unsigned(feedback_cuad_col) > 0 then
                cont_col <= '1';
                sig_col <= '1';
            end if;
        end if;
     end if;
  end if;
end process;
end Behavioral;
     



