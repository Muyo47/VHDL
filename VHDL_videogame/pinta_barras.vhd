---------------------------------------------------------------------------------------------------------------------
-- Codigo modificado para incluir una figura en el diseño de la pantalla, asi como division de cuadriculas
-- y la creacion de la malla separadora.
-- cuad_col_sprite y cuad_fil_sprite son las salidas de conteo de los contadores asociados al circuito que gestiona
-- el movimiento de los sprites.
---------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pinta_barras is
  Port (
    -- In ports
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    
    cuad_col_sprite   : in unsigned (5 downto 0);
    cuad_fil_sprite   : in unsigned (5 downto 0);
    
    cuad_col_sprite_auto   : in unsigned (5 downto 0);
    cuad_fil_sprite_auto   : in unsigned (5 downto 0);
    
    data_memo         : in unsigned (15 downto 0);
    data_memo_rojo         : in unsigned (15 downto 0);
    data_memo_verde         : in unsigned (15 downto 0);
    data_memo_azul         : in unsigned (15 downto 0);
    
    
    data_memo_pista   : in unsigned (31 downto 0);
    data_memo_pista_verde   : in unsigned (31 downto 0);
    data_memo_pista_azul   : in unsigned (31 downto 0);
    
    data_snes_pb : in std_logic_vector (15 downto 0);              --UP4, DOWN5, DERECHA7, IZQUIERDA6 -> MAS A MENOS SIGNIFICATIVO ESTO ES PARA LA SNES
    
    data_memo_crono_rojo    : in unsigned (15 downto 0);
    data_memo_crono_verde    : in unsigned (15 downto 0);
    data_memo_crono_azul    : in unsigned (15 downto 0);
    
    cuenta_segundos : in std_logic_vector (4 downto 0);
    cuenta_decenas : in std_logic_vector (4 downto 0);
    cuenta_minutos : in std_logic_vector (4 downto 0);

    -- Out ports
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0);
    adress_memo_mono  : out std_logic_vector (7 downto 0);
    adress_memo_rgb  : out std_logic_vector (8 downto 0); 
        
    adress_memo_pista : out std_logic_vector (4 downto 0);
    adress_memo_pista_rgb : out std_logic_vector (9 downto 0);      --Esto se puede reducir a 10 bits
    
    adress_crono : out std_logic_vector (8 downto 0)
  );
end pinta_barras;

architecture behavioral of pinta_barras is

constant max_col_cuad : natural := 32;    --Maximo de cuadriculas en columnas
constant max_fil_cuad : natural := 30;    --Maximo de cuadriculas en filas
constant fantasma_memo_mono : std_logic_vector := "0100";
constant fantasma_memo : std_logic_vector := "11010";
constant fernandoalonso_memo : std_logic_vector := "11110";
constant fernandoalonso_memo_mono : std_logic_vector := "1110";
constant giro_memo : std_logic_vector := "11111";
constant giro_memo_mono : std_logic_vector := "1111";

signal last_adress : std_logic_vector (2 downto 0);

begin

  P_pinta: Process (visible, col, fila)
    --variable last_adress : std_logic_vector (2 downto 0);
  begin
  ----LOGICA DE BUSQUEDA EN MEMORIAS-------------------------------------------------------------------------------------------------------------
  ----LOGICA DE CAMBIO DE SPRITE DE ACUERDO A DIRECCION-----------------------------------------------------------------
  

    if data_snes_pb(7) = '0' and data_snes_pb(4) = '0' then     --
       adress_memo_rgb <= giro_memo & not(std_logic_vector(col(3 downto 0)));
       adress_memo_mono <= giro_memo_mono & not(std_logic_vector(col(3 downto 0)));
        last_adress <= "100";
    elsif data_snes_pb(4) = '0' and data_snes_pb(6) = '0' then      --
        adress_memo_rgb <= giro_memo & std_logic_vector(fila(3 downto 0));
        adress_memo_mono <= giro_memo_mono & std_logic_vector(fila(3 downto 0));
        last_adress <= "101";
    elsif data_snes_pb(7) = '0' and data_snes_pb(5) = '0' then      --
        adress_memo_rgb <= giro_memo & not(std_logic_vector(col(3 downto 0)));
        adress_memo_mono <= giro_memo_mono & not(std_logic_vector(col(3 downto 0)));
        last_adress <= "110";
    elsif data_snes_pb(5) = '0' and data_snes_pb(6) = '0' then      --
        adress_memo_rgb <= giro_memo & not(std_logic_vector(fila(3 downto 0)));
        adress_memo_mono <= giro_memo_mono & not(std_logic_vector(fila(3 downto 0)));
        last_adress <= "111";
    elsif data_snes_pb(4) = '0' then      --
        adress_memo_rgb <= fernandoalonso_memo & std_logic_vector(fila(3 downto 0));
        adress_memo_mono <= fernandoalonso_memo_mono & std_logic_vector(fila(3 downto 0));
        last_adress <= "000";
    elsif data_snes_pb(5) = '0' then      --
        adress_memo_rgb <= fernandoalonso_memo & not(std_logic_vector(fila(3 downto 0)));
        adress_memo_mono <= fernandoalonso_memo_mono & not(std_logic_vector(fila(3 downto 0)));
        last_adress <= "001";
    elsif data_snes_pb(7) = '0' then      --
        adress_memo_rgb <= fernandoalonso_memo & not(std_logic_vector(col(3 downto 0)));
        adress_memo_mono <= fernandoalonso_memo_mono & not(std_logic_vector(col(3 downto 0)));
        last_adress <= "010";
    elsif data_snes_pb(6) = '0' then      --
        adress_memo_rgb <= fernandoalonso_memo & std_logic_vector(col(3 downto 0));
        adress_memo_mono <= fernandoalonso_memo_mono & std_logic_vector(col(3 downto 0));
        last_adress <= "011";
    else            --Para intentar mantener la ultima orientacion del sprite
       case last_adress is 
        when "000" =>
            adress_memo_rgb <= fernandoalonso_memo & std_logic_vector(fila(3 downto 0));
            adress_memo_mono <= fernandoalonso_memo_mono & std_logic_vector(fila(3 downto 0));
        when "001" =>
            adress_memo_rgb <= fernandoalonso_memo & not(std_logic_vector(fila(3 downto 0)));
            adress_memo_mono <= fernandoalonso_memo_mono & not(std_logic_vector(fila(3 downto 0)));
        when "010" => 
            adress_memo_rgb <= fernandoalonso_memo & not(std_logic_vector(col(3 downto 0)));
            adress_memo_mono <= fernandoalonso_memo_mono & not(std_logic_vector(col(3 downto 0)));
        when "011" =>
            adress_memo_rgb <= fernandoalonso_memo & std_logic_vector(col(3 downto 0));
            adress_memo_mono <= fernandoalonso_memo_mono & std_logic_vector(col(3 downto 0));
        when "100" =>
            adress_memo_rgb <= giro_memo & std_logic_vector(col(3 downto 0));
            adress_memo_mono <= giro_memo_mono & std_logic_vector(col(3 downto 0));
        when "101" =>
            adress_memo_rgb <= giro_memo & not(std_logic_vector(fila(3 downto 0)));
            adress_memo_mono <= giro_memo_mono & not(std_logic_vector(fila(3 downto 0)));
        when others =>
            last_adress <= last_adress;
       end case;
    end if;
    -----------------------------------------------------------------------------------------------------------------------------------------------
  
    
    adress_memo_pista <= std_logic_vector(fila (8 downto 4));
    adress_memo_pista_rgb(9 downto 5) <= std_logic_vector(fila (8 downto 4));       --Direccion memoria datos verdes
    adress_memo_pista_rgb(4 downto 0) <= std_logic_vector(fila (8 downto 4));       --Direccion memoria datos azuels
    
    
 -----------------------------------------------------------------------------------------------------------------------------------------------
    -- Para tener una base en negro (zona no permitida de juego)
    rojo   <= (others=>'0');
    verde  <= (others=>'0');
    azul   <= (others=>'0');
    
-------LOGICA PARA PINTAR PISTA Y SPRITES---------------------------------------------------------------------------------
    if visible = '1' then
      --Una linea blanca en los bordes
      if col = 0 OR col = 640 - 1 OR fila = 0 OR fila = 480 - 1 then
        rojo   <= (others=>'1');
        verde  <= (others=>'1');
        azul   <= (others=>'1');
        
      --Cuando pasamos de la cuadricula 32, todo el resto de la pantalla se pinta de negro
      elsif col >= 512 then     
        rojo   <= (others=>'0');
        verde  <= (others=>'0');
        azul   <= (others=>'0');
        
------PINTAMOS LA PISTA SEGUN CUADRICULA--------------------------------------------------------------------------------------
      else
        if data_memo_pista_verde (to_integer(col (9 downto 4))) = '1' then
            if data_memo_pista (to_integer(col (9 downto 4))) = '1' then
                rojo   <= (others=>'1');
                verde  <= (others=>'1');
                azul   <= (others=>'1');
            else
                rojo   <= (others=>'0');
                verde  <= (others=>'1');
                azul   <= (others=>'0');
            end if;
        elsif data_memo_pista_azul (to_integer(col (9 downto 4))) = '1' then
            rojo   <= (others=>'0');
            verde  <= (others=>'0');
            azul   <= (others=>'1');
        else
            rojo   <= (others=>'1');
            verde  <= (others=>'0');
            azul   <= (others=>'0');
        end if;
-------------------------------------------------------------------------------------------------------------------------------
        
----CREAMOS LA MALLA DE LA PISTA-----------------------------------------------------------------------------------------------
        if (col(3 downto 0) = 0) or (fila(3 downto 0) = 0) then     --Cuando los 4 bits menos significativos son 0, hemos llegado a 16 o algun multiplo suyo
                                                                    --Dibujamos un pixel negro para crear la malla
          rojo   <= (others=>'0');
          verde  <= (others=>'0');
          azul   <= (others=>'0');
------------------------------------------------------------------------------------------------------------------------------

          
------SPRITE DEL USUARIO------------------------------------------------------------------------------------------------------
          elsif (col(9 downto 4) < max_col_cuad) and (fila(9 downto 4) < max_fil_cuad) then   --Si estamos dentro del espacio permitido
            if (col (9 downto 4) = cuad_col_sprite) and (fila (9 downto 4) = cuad_fil_sprite) then  --En el caso de que la cuadricula correspondan con la posicion del sprite, dibujamos sprite
                if last_adress = "011" or last_adress = "010" or last_adress = "100" then   --Comprobamos la posicion del sprite
                    if data_memo(to_integer(fila (3 downto 0))) = '0' then                  --Comprobamos que solo dibujamos el coche, no el fondo
                        if data_memo_rojo(to_integer(fila (3 downto 0))) = '1' then         --Parte roja del coche
                            rojo   <= (others=>'1');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        elsif data_memo_verde(to_integer(fila (3 downto 0))) = '1' then     --Parte verde del coche
                            rojo   <= (others=>'0');
                            verde  <= (others=>'1');
                            azul   <= (others=>'0');
                        elsif data_memo_azul(to_integer(fila (3 downto 0))) = '1' then      --Parte azul del coche
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'1');
                        else                                                                --El resto en negro
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        end if;
                    else                                     --Todo lo que no corresponda al coche lo pintamos del color de la pista
                        if data_memo_rojo(to_integer(fila (3 downto 0))) = '0' or data_memo_verde(to_integer(fila (3 downto 0))) = '0' or data_memo_azul(to_integer(fila (3 downto 0))) = '0' then
                            if data_memo_pista_verde (to_integer(col (3 downto 0))) = '1' then
                                if data_memo_pista (to_integer(col (3 downto 0))) = '1' then
                                    rojo   <= (others=>'1');
                                    verde  <= (others=>'1');
                                    azul   <= (others=>'1');
                                else
                                    rojo   <= (others=>'0');
                                    verde  <= (others=>'1');
                                    azul   <= (others=>'0');
                                end if;
                            elsif data_memo_pista_azul (to_integer(col (3 downto 0))) = '1' then
                                rojo   <= (others=>'0');
                                verde  <= (others=>'0');
                                azul   <= (others=>'1');
                            else
                                rojo   <= (others=>'1');
                                verde  <= (others=>'0');
                                azul   <= (others=>'0');
                            end if;
                        end if;
                    end if;
                    
                    
                    elsif last_adress = "110" then   --Comprobamos la posicion del sprite
                    if data_memo(to_integer(not(fila (3 downto 0)))) = '0' then                  --Comprobamos que solo dibujamos el coche, no el fondo
                        if data_memo_rojo(to_integer(not(fila (3 downto 0)))) = '1' then         --Parte roja del coche
                            rojo   <= (others=>'1');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        elsif data_memo_verde(to_integer(not(fila (3 downto 0)))) = '1' then     --Parte verde del coche
                            rojo   <= (others=>'0');
                            verde  <= (others=>'1');
                            azul   <= (others=>'0');
                        elsif data_memo_azul(to_integer(not(fila (3 downto 0)))) = '1' then      --Parte azul del coche
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'1');
                        else                                                                --El resto en negro
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        end if;
                    else                                     --Todo lo que no corresponda al coche lo pintamos del color de la pista
                        if data_memo_rojo(to_integer(not(fila (3 downto 0)))) = '0' or data_memo_verde(to_integer(not(fila (3 downto 0)))) = '0' or data_memo_azul(to_integer(not(fila (3 downto 0)))) = '0' then
                            if data_memo_pista_verde (to_integer(col (3 downto 0))) = '1' then
                                if data_memo_pista (to_integer(col (3 downto 0))) = '1' then
                                    rojo   <= (others=>'1');
                                    verde  <= (others=>'1');
                                    azul   <= (others=>'1');
                                else
                                    rojo   <= (others=>'0');
                                    verde  <= (others=>'1');
                                    azul   <= (others=>'0');
                                end if;
                            elsif data_memo_pista_azul (to_integer(col (3 downto 0))) = '1' then
                                rojo   <= (others=>'0');
                                verde  <= (others=>'0');
                                azul   <= (others=>'1');
                            else
                                rojo   <= (others=>'1');
                                verde  <= (others=>'0');
                                azul   <= (others=>'0');
                            end if;
                        end if;
                    end if;
                    
                    
                elsif last_adress = "000"  or last_adress = "001" or last_adress = "101" or last_adress = "111" then
                    if data_memo(to_integer(col (3 downto 0))) = '0' then
                        if data_memo_rojo(to_integer(col (3 downto 0))) = '1' then
                            rojo   <= (others=>'1');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        elsif data_memo_verde(to_integer(col (3 downto 0))) = '1' then
                            rojo   <= (others=>'0');
                            verde  <= (others=>'1');
                            azul   <= (others=>'0');
                        elsif data_memo_azul(to_integer(col (3 downto 0))) = '1' then
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'1');
                        else
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        end if;
                    else
                        if data_memo_rojo(to_integer(col (3 downto 0))) = '0' or data_memo_verde(to_integer(col (3 downto 0))) = '0' or data_memo_azul(to_integer(col (3 downto 0))) = '0' then
                            if data_memo_pista_verde (to_integer(col (3 downto 0))) = '1' then
                                if data_memo_pista (to_integer(col (3 downto 0))) = '1' then
                                    rojo   <= (others=>'1');
                                    verde  <= (others=>'1');
                                    azul   <= (others=>'1');
                                else
                                    rojo   <= (others=>'0');
                                    verde  <= (others=>'1');
                                    azul   <= (others=>'0');
                                end if;
                            elsif data_memo_pista_azul (to_integer(col (3 downto 0))) = '1' then
                                rojo   <= (others=>'0');
                                verde  <= (others=>'0');
                                azul   <= (others=>'1');
                            else
                                rojo   <= (others=>'1');
                                verde  <= (others=>'0');
                                azul   <= (others=>'0');
                            end if;
                        end if;
                    end if;
                end if;        
                      
--------SPRITE AUTOMATICO------------------------------------------------------------------------------------------------------
            elsif (col (9 downto 4) = cuad_col_sprite_auto) and (fila (9 downto 4) = cuad_fil_sprite_auto) then  --En el caso de que la cuadricula correspondan con la posicion del sprite, dibujamos sprite
            adress_memo_mono <= fantasma_memo_mono & std_logic_vector(fila(3 downto 0));     --Direccion de memoria completa MONOCROMATICO
            adress_memo_rgb <= fantasma_memo & std_logic_vector(fila(3 downto 0));     --Direccion de memoria completa
                if data_memo(to_integer(col (3 downto 0))) = '0' then
                    if data_memo_rojo(to_integer(col (3 downto 0))) = '1' then         --Parte roja del bot
                            rojo   <= (others=>'1');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                        elsif data_memo_verde(to_integer(col (3 downto 0))) = '1' then     --Parte verde del bot
                            rojo   <= (others=>'0');
                            verde  <= (others=>'1');
                            azul   <= (others=>'0');
                        elsif data_memo_azul(to_integer(col (3 downto 0))) = '1' then      --Parte azul del bot
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'1');
                        else                                                                --El resto en negro
                            rojo   <= (others=>'0');
                            verde  <= (others=>'0');
                            azul   <= (others=>'0');
                    end if;
                end if;
                
---------CRONOMETRO NUMEROS---------------------------------------------------------
            elsif (col (9 downto 4) = "000000") and (fila (9 downto 4) = "000000") then
            adress_crono <= cuenta_minutos & std_logic_vector(fila(3 downto 0));
                if data_memo_crono_rojo(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_verde(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_azul(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'1');
                else
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'0');
                end if;  
            elsif (col (9 downto 4) = "000001") and (fila (9 downto 4) = "000000") then
            adress_crono <= "10101" & std_logic_vector(fila(3 downto 0));
                if data_memo_crono_rojo(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_verde(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_azul(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'1');
                else
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'0');
                end if;
            elsif (col (9 downto 4) = "000010") and (fila (9 downto 4) = "000000") then
            adress_crono <= cuenta_decenas & std_logic_vector(fila(3 downto 0)); 
                if data_memo_crono_rojo(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_verde(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_azul(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'1');
                else
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'0');
                end if;
            elsif (col (9 downto 4) = "000011") and (fila (9 downto 4) = "000000") then
            adress_crono <= cuenta_segundos & std_logic_vector(fila(3 downto 0));
                if data_memo_crono_rojo(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_verde(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'1');
                    azul   <= (others=>'0');
                elsif data_memo_crono_azul(to_integer(not(col (3 downto 0)))) = '1' then
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'1');
                else
                    rojo   <= (others=>'0');
                    verde  <= (others=>'0');
                    azul   <= (others=>'0');
                end if; 
            end if;     --ENDIF SPRITES
--------------------------------------------------------------------------------------------------------------------------------
        end if;     --ENDIF DE PINTAR EN EL MAXIMO ESPACIO PERMITIDO
      end if;   --ENDIF PARA LA CUADRICULA EN NEGRO
    end if;  --ENDIF DE VISIBLE = '1'
  end process;
  
end Behavioral;