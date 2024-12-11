--------------------------------------------------------------------------------------------------------------------
-- Entidad superior que contiene todos los circuitos digitales y logica implementada.
--------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

------PAQUETE MATRIZ PISTA DE CARRERAS-------------------
use WORK.RACETRACK_PKG.ALL;

entity top_vga is
  Port ( clk : in std_logic;
         reset : in std_logic;
         btn_dificultad_bot : in std_logic;
         btn_crono : in std_logic;
         data_SNES : in std_logic;
         
         clk_SNES : out std_logic;
         latch_SNES : out std_logic;
         clkP : out std_logic;
         clkN : out std_logic;
         dataP : out std_logic_vector (2 downto 0);
         dataN : out std_logic_vector ( 2 downto 0));
end top_vga;

architecture Behavioral of top_vga is

component mux2a1 is
    Generic( bits_en : integer);   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
           sel_mux : in STD_LOGIC;                                  --Selector del multiplexor
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end component; 

component mux4a1 is
    Generic( bits_en : integer);   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 1
           ent_mux_2 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 2
           ent_mux_3 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);  --Entrada 3
           sel_mux : in STD_LOGIC_VECTOR (1 downto 0);     --Selector del multiplexor
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));  --Salida del multiplexor
end component;

component contador is
  Generic ( n_bits : integer := 24;     --Bits necesarios para realizar la cuenta deseada
            max_count : integer := 12500000;   --Generico para asignar la cuenta total a realizar
            cont_inicial : integer := 0);     
            
            --En el caso de requerir cuentas mayores, cambiar el numero de bits total!
  Port ( enable : in std_logic;                             --Habilitacion
         clk : in std_logic;                                --Reloj
         count : out std_logic_vector (n_bits-1 downto 0);  --Conteo total
         reset : in std_logic;          --Reset
         fin_cuenta : out std_logic;    --Fin de cuenta
         sentido_c : in std_logic); --0 para ascendente, 1 para descendente
end component;


----MEMORIAS ROM--------------------------------------------------------------------------------
component ROM1b_1f_imagenes16_16x16_bn is       --SPRITES GENERICOS EN BLANCO Y NEGRO
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(8-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component ROM1b_1f_racetrack_1 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM1b_1f_green_racetrack_1 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM1b_1f_blue_racetrack_1 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM1b_1f_red_num32_play_sprite16x16 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component ROM1b_1f_green_num32_play_sprite16x16 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component ROM1b_1f_blue_num32_play_sprite16x16 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(9-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

-----------------------------------------------------------------------------------


component Syncro_VGA is
  Port ( clkPLL : in std_logic;
         reset : in std_logic;
         
         hsinc : out std_logic;
         vsinc : out std_logic;
         visible : out std_logic;
         filas : out std_logic_vector (9 downto 0);
         columnas : out std_logic_vector (9 downto 0));
end component;

component mov_sprite is
  Port ( clk : in std_logic;
         reset : in std_logic;
         feedback_cuad_fil : in std_logic_vector (5 downto 0);
         feedback_cuad_col : in std_logic_vector (5 downto 0);
         control_SNES : in std_logic_vector(15 downto 0);
         muestreo : in std_logic;
         
         cont_col : out std_logic;
         cont_fil : out std_logic;
         sig_col : out std_logic;
         sig_fil : out std_logic );
end component;

component hdmi_rgb2tmds is
    generic (
        SERIES6 : boolean := false
    );
    port(
        -- reset and clocks
        rst : in std_logic;
        pixelclock : in std_logic;  -- slow pixel clock 1x
        serialclock : in std_logic; -- fast serial clock 5x

        -- video signals
        video_data : in std_logic_vector(23 downto 0);
        video_active  : in std_logic;
        hsync : in std_logic;
        vsync : in std_logic;

        -- tmds output ports
        clk_p : out std_logic;
        clk_n : out std_logic;
        data_p : out std_logic_vector(2 downto 0);
        data_n : out std_logic_vector(2 downto 0)
    );
end component;

----PINTA BARRAS "TARJETA GRAFICA"-----------------------------------------------------------------------
component pinta_barras is
  Port (
    -- In ports
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    
    data_snes_pb : in std_logic_vector (15 downto 0);
    
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
    adress_memo_pista_rgb : out std_logic_vector (9 downto 0);
    
    adress_crono : out std_logic_vector (8 downto 0)
  );
end component;

-----------------------------------------------------------------------------------------------------


component clock_gen is
        generic ( CLKOUT1_DIV : integer := 40; -- pixel clock divider
                  CLKIN_PERIOD : real := 8.000; -- input clock period (8ns)
                  CLK_MULTIPLY : integer := 8; -- multiplier
                  CLK_DIVIDE : integer := 1; -- divider
                  CLKOUT0_DIV : integer := 8 ); -- serial clock divider
         
        port ( clk_i : in std_logic; -- input clock
               clk0_o : out std_logic; -- serial clock
               clk1_o : out std_logic ); -- pixel clock
end component;


-----MAQUINAS DE ESTADO PARA EL BOT---------------------------------------------------------------------------------
component FSM_sprite_automatico is
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
end component;

component FSM_velocidad is
  Port ( clk : in std_logic;
         rst : in std_logic;
         boton : in std_logic;
         seleccion : out std_logic_vector (1 downto 0));
end component;
---------------------------------------------------------------------------------------------------------------------

component Detector_flanco is
  Port ( flanco_in : in std_logic;
         flanco_out : out std_logic;
         clk : in std_logic;
         reset : in std_logic );
end component;

component biestableT is
  Port ( clk : in std_logic;    --Reloj
         enable : in std_logic; --Habilitacion
         reset : in std_logic;  --Reset
         data : in std_logic;   --Entrada del codigo de operacion al biestable
         output_data : out std_logic );     --Salida conmutada de datos del biestable
end component;

component FSM_mando_SNES is
  Port ( clk : in std_logic;
         reset : in std_logic;
         fin_6us : in std_logic;
         fin_12us : in std_logic;
         data_count : in unsigned (4 downto 0);
         
         data_end : out std_logic;
         latch_out : out std_logic;
         clk_SNES_out : out std_logic);
end component;


--SEÑALES PARA RELOG PRINCIPAL Y RELOJ DE 25MHZ (CLK1) DEL PLL----------
signal clk0_s : std_logic;
signal clk1_s : std_logic;


--SEÑALES DE PROPOSITO GENERAL PARA VGA---------------------------------
signal columnas_s : std_logic_vector (9 downto 0);
signal filas_s : std_logic_vector (9 downto 0);
signal rojo_s : std_logic_vector (7 downto 0);
signal verde_s : std_logic_vector (7 downto 0);
signal azul_s : std_logic_vector (7 downto 0);
signal rgb : std_logic_vector (23 downto 0);

--SEÑALES DE INTERCONEXION----------------------------------------------
signal visible_2_tmds : std_logic;
signal hsinc_2_tmds : std_logic;
signal vsinc_2_tmds : std_logic;

--SEÑALES PARA LA GESTION DE LOS SPRITES--------------------------------
signal muestreo100ms : std_logic;
signal muestreo75ms : std_logic;
signal muestreo60ms : std_logic;
signal muestreo50ms : std_logic;
signal muestreo500ms : std_logic;
signal muestreo : std_logic;    --Esta señal es para el muestreo del personaje del jugador, no para el bot
signal jug_en_pista : std_logic;
signal spritecuadcol : std_logic_vector (5 downto 0);
signal spritecuadfil : std_logic_vector (5 downto 0);
signal spritecuadcol_auto : std_logic_vector (5 downto 0);
signal spritecuadfil_auto : std_logic_vector (5 downto 0);
signal contcol_s : std_logic;
signal contfil_s : std_logic;
signal sigcol_s : std_logic;
signal sigfil_s : std_logic;
signal contcol_auto_s : std_logic;
signal contfil_auto_s : std_logic;
signal sigcol_auto_s : std_logic;
signal sigfil_auto_s : std_logic;


--SEÑALES PARA LA FSM DE LA VELOCIDAD DEL BOT----------------------------
signal boton_velocidad_s : std_logic;
signal seleccion_velocidad_bot : std_logic_vector (1 downto 0);     --Selector del multiplexor
signal velocidad_bot_s : std_logic_vector(0 downto 0);      --Esta señal gestiona el muestreo del bot (su velocidad en pista)


--SEÑALES PARA LA MEJORA DEL CRONOMETRO----------------------------------
signal btn_crono_s : std_logic;
signal btn_crono_conmutado_s : std_logic;
signal segundero_s : std_logic;
signal segundos_crono_s : std_logic_vector (4 downto 0);
signal fin_10s_s : std_logic;
signal en60s_s : std_logic;
signal decenas_segundos_crono_s : std_logic_vector (4 downto 0);
signal fin_60s_s : std_logic;
signal en_minutos_s : std_logic;
signal minutos_s : std_logic_vector (4 downto 0);
signal adress_crono_s : std_logic_vector (8 downto 0);



--SEÑALES PARA MEMORIAS ROM--------------------------------------------
signal adress_memo_mono_s : std_logic_vector (7 downto 0);      --8 bits para la direccion de memoria -> 256 posibles direcciones
signal adress_memo_rgb_s : std_logic_vector (8 downto 0);

signal adress_pista : std_logic_vector (4 downto 0);        --Direccion para memoria de pista monocromatica
signal adress_pista_rgb : std_logic_vector (9 downto 0);   --Contiene todas las direcciones G(5 primeros bits), B(5 ultimos)

signal rom_data_s : std_logic_vector (15 downto 0);
signal rom_data_rojo_s : std_logic_vector (15 downto 0);
signal rom_data_verde_s : std_logic_vector (15 downto 0);
signal rom_data_azul_s : std_logic_vector (15 downto 0);


signal rom_data_pista : std_logic_vector (31 downto 0);
signal rom_data_pista_verde : std_logic_vector (31 downto 0);
signal rom_data_pista_azul : std_logic_vector (31 downto 0);


signal data_memo_crono_rojo_s     : std_logic_vector (15 downto 0);
signal data_memo_crono_verde_s    : std_logic_vector (15 downto 0);
signal data_memo_crono_azul_s     : std_logic_vector (15 downto 0);


--SEÑALES PARA FSM DE LA SNES--------------------------------------------------------------------------------------
signal latch_out_s : std_logic;
signal buttons_snes_fin_s : std_logic_vector (15 downto 0);  --Señal final de los botones
signal buttons_snes_s : std_logic_vector (15 downto 0);     --Señal variable de los botones
signal fin_cuenta_6us : std_logic;
signal fin_cuenta_12us_aux : std_logic;
signal fin_cuenta_12us : std_logic;
signal data_count_s : std_logic_vector(4 downto 0);
signal clk_SNES_s : std_logic;
signal data_end_s : std_logic;

signal enable_contador_especial : std_logic;
signal reset_contador_especial : std_logic;

begin

-----PARA EL MOVIMIENTO DE LOS SPRITES------------------------------------------------------------------------------------------------------
maquina_movimiento_automatico : FSM_sprite_automatico
    Port map( clk => clk,
              muestreo_auto => velocidad_bot_s(0),
              reset => reset,
              feedback_cuad_col => spritecuadcol_auto,
              feedback_cuad_fil => spritecuadfil_auto,
              cont_col => contcol_auto_s,
              cont_fil => contfil_auto_s,
              sig_col => sigcol_auto_s,
              sig_fil => sigfil_auto_s);
              
maquina_velocidad_bot : FSM_velocidad
  Port map( clk => clk,
         rst => reset,
         boton => boton_velocidad_s,
         seleccion => seleccion_velocidad_bot);

              
contador_filas_sprite_auto : contador
    Generic map( n_bits => 6,
                 max_count => 30,
                 cont_inicial => 27 )
    Port map( enable => contfil_auto_s,
              clk => clk,
              sentido_c => sigfil_auto_s,
              reset => reset,
              count => spritecuadfil_auto );
         
contador_columnas_sprite_auto : contador
    Generic map( n_bits => 6,
                 max_count => 32,
                 cont_inicial => 13 )        
    Port map( enable => contcol_auto_s,
              clk => clk,
              sentido_c => sigcol_auto_s,
              reset => reset,
              count => spritecuadcol_auto );
              
muestreador100ms : contador
    Generic map( n_bits => 24,
                 max_count => 12500000,         --12500000 100ms
                 cont_inicial => 0 )        
    Port map( enable => '1',
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => muestreo100ms );
              
muestreador75ms : contador
    Generic map( n_bits => 25,
                 max_count => 9375000,         --9375000 75ms
                 cont_inicial => 0 )        
    Port map( enable => '1',
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => muestreo75ms );
              
muestreador60ms : contador
    Generic map( n_bits => 26,
                 max_count => 7500000,         --7500000 60ms
                 cont_inicial => 0 )        
    Port map( enable => '1',
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => muestreo60ms );
              
muestreador50ms : contador
    Generic map( n_bits => 26,
                 max_count => 6250000,         --6250000 50ms
                 cont_inicial => 0 )        
    Port map( enable => '1',
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => muestreo50ms );
              
muestreador500ms : contador
    Generic map( n_bits => 26,
                 max_count => 62500000,         --62500000 500ms
                 cont_inicial => 0 )        
    Port map( enable => '1',
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => muestreo500ms );
              
multiplexor_muestreo : mux2a1
    Generic map( bits_en => 1)   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port map ( ent_mux_0(0) => muestreo500ms,  --Entrada 0
               ent_mux_1(0) => muestreo100ms,  --Entrada 1
               sel_mux => jug_en_pista,  --Selector del multiplexor
               sal_mux(0) => muestreo);  --Salida del multiplexor
               
multiplexor_velocidad_bot : mux4a1
    Generic map( bits_en => 1)   --Generico para poder modificar los bits de los buses de las entradas del multiplexor
    Port map ( ent_mux_0(0) => muestreo100ms,
               ent_mux_1(0) => muestreo75ms,
               ent_mux_2(0) => muestreo60ms,
               ent_mux_3(0) => muestreo50ms,
               sel_mux => seleccion_velocidad_bot,
               sal_mux => velocidad_bot_s);  --Salida del multiplexor
              
maquina_sprite : mov_sprite
    Port map ( clk => clk,
               reset => reset,
               feedback_cuad_fil => spritecuadfil,
               feedback_cuad_col => spritecuadcol,
               --control_SNES => bttnn,
               control_SNES => buttons_snes_fin_s,
               muestreo => muestreo,
               cont_col => contcol_s,
               cont_fil => contfil_s,
               sig_col => sigcol_s,
               sig_fil => sigfil_s );
              
contador_filas_sprite : contador
    Generic map( n_bits => 6,
                 max_count => 30,
                 cont_inicial => 26 )
    Port map( enable => contfil_s,
              clk => clk,
              sentido_c => sigfil_s,
              reset => reset,
              count => spritecuadfil );
         
contador_columnas_sprite : contador
    Generic map( n_bits => 6,
                 max_count => 32,
                 cont_inicial => 13 )        
    Port map( enable => contcol_s,
              clk => clk,
              sentido_c => sigcol_s,
              reset => reset,
              count => spritecuadcol );



----------OBTENCION DE DATOS VGA Y CONVERSION A HDMI--------------------------------------------------------------------------------------------------------------------
PLL : clock_gen
    Port map( clk_i => clk,
              clk0_o => clk0_s,
              clk1_o => clk1_s);

sincrovga : Syncro_vga
    Port map( clkPLL => clk1_s,
              reset => reset,
              columnas => columnas_s,
              filas => filas_s,
              visible => visible_2_tmds,
              hsinc => hsinc_2_tmds,
              vsinc => vsinc_2_tmds);
              
TMDS : hdmi_rgb2tmds
    Port map ( video_data => rgb,
               rst => reset,
               pixelclock => clk1_s,        --25 MHz
               serialclock => clk0_s,       --125 MHz
               video_active => visible_2_tmds,
               hsync => hsinc_2_tmds,
               vsync => vsinc_2_tmds,
               clk_p => clkP,
               clk_n => clkN,
               data_p => dataP,
               data_n => dataN);
               
               
               
---------PARA PINTAR LOS DATOS EN PANTALLA--------------------------------------------------------------------------------------------------------
pinta : pinta_barras
    Port map( visible => visible_2_tmds, 
              col => unsigned(columnas_s),
              fila => unsigned(filas_s),
              rojo => rojo_s,
              verde => verde_s,
              azul => azul_s,
              
              cuad_col_sprite => unsigned(spritecuadcol),
              cuad_fil_sprite => unsigned(spritecuadfil),
              cuad_col_sprite_auto => unsigned(spritecuadcol_auto),
              cuad_fil_sprite_auto => unsigned(spritecuadfil_auto),
              data_memo => unsigned(rom_data_s),
              
              data_snes_pb => buttons_SNES_fin_s,     --Para orientar el sprite
              --data_stream => bttnn,
              
              data_memo_rojo => unsigned(rom_data_rojo_s),      --Para dibujar el personaje principal y bot
              data_memo_verde=> unsigned(rom_data_verde_s),
              data_memo_azul => unsigned(rom_data_azul_s),
              
              data_memo_pista => unsigned(rom_data_pista),      --Para dibujar la pista
              data_memo_pista_verde => unsigned(rom_data_pista_verde),
              data_memo_pista_azul => unsigned(rom_data_pista_azul),
              
              adress_memo_mono => adress_memo_mono_s,       --Para el personaje principal y el bot
              adress_memo_rgb => adress_memo_rgb_s,
              
              adress_memo_pista => adress_pista,            --Para la pista
              adress_memo_pista_rgb => adress_pista_rgb,
              
              adress_crono => adress_crono_s,               --Para la parte del cronometro
              
              data_memo_crono_rojo => unsigned (data_memo_crono_rojo_s),        --Para dibujar el cronometro
              data_memo_crono_verde => unsigned (data_memo_crono_verde_s),
              data_memo_crono_azul => unsigned (data_memo_crono_azul_s),

              cuenta_segundos => segundos_crono_s,      --Para reasignar la direccion del cronometro en funcion del tiempo
              cuenta_decenas => decenas_segundos_crono_s,
              cuenta_minutos => minutos_s);


      
------MEMORIAS ROM-------------------------------------------------------------------------------------------------------- 
ROM_memo : ROM1b_1f_imagenes16_16x16_bn
    Port map( clk => clk,
              addr => adress_memo_mono_s,
              dout => rom_data_s );
              
ROM_memo_rojo : ROM1b_1f_red_num32_play_sprite16x16
    Port map(clk => clk,
             addr => adress_memo_rgb_s,
             dout => rom_data_rojo_s);
             
ROM_memo_verde : ROM1b_1f_green_num32_play_sprite16x16
    Port map(clk => clk,
             addr => adress_memo_rgb_s,
             dout => rom_data_verde_s);
             
ROM_memo_azul : ROM1b_1f_blue_num32_play_sprite16x16
    Port map(clk => clk,
             addr => adress_memo_rgb_s,
             dout => rom_data_azul_s);
              
memo_pista_grises : ROM1b_1f_racetrack_1
    Port map ( clk => clk,   -- reloj
               addr => adress_pista,
               dout => rom_data_pista );
               
memo_pista_verde : ROM1b_1f_green_racetrack_1
    Port map ( clk => clk,   -- reloj
               addr => adress_pista_rgb (9 downto 5),
               dout => rom_data_pista_verde );
               
memo_pista_azul : ROM1b_1f_blue_racetrack_1
    Port map ( clk => clk,   -- reloj
               addr => adress_pista_rgb (4 downto 0),
               dout => rom_data_pista_azul );
               
ROM_memo_crono_rojo : ROM1b_1f_red_num32_play_sprite16x16
    Port map(clk => clk,
             addr => adress_crono_s,
             dout => data_memo_crono_rojo_s);
             
ROM_memo_crono_verde : ROM1b_1f_green_num32_play_sprite16x16
    Port map(clk => clk,
             addr => adress_crono_s,
             dout => data_memo_crono_verde_s);
             
ROM_memo_crono_azul : ROM1b_1f_blue_num32_play_sprite16x16
    Port map(clk => clk,
             addr => adress_crono_s,
             dout => data_memo_crono_azul_s);
             
             

----PROPOSITO GENERAL Y CRONOMETRO----------------------------------------------------------------------------------------------------------------------------
               
flanco_boton_velocidad : Detector_flanco
  Port map ( flanco_in => btn_dificultad_bot,
         flanco_out => boton_velocidad_s,
         clk => clk,
         reset => reset );
         
flanco_cronometro : Detector_flanco
  Port map ( flanco_in => btn_crono,
         flanco_out => btn_crono_s,
         clk => clk,
         reset => reset );
         
conmutar_crono_flanco : biestableT
  Port map ( clk => clk,    --Reloj
         enable => '1', --Habilitacion
         reset => reset,
         data => btn_crono_s,   --Entrada del codigo de operacion al biestable
         output_data => btn_crono_conmutado_s );     --Salida conmutada de datos del biestable
         
segundero : contador
    Generic map( n_bits => 27,
                 max_count => 125000000,        --125000000 1s
                 cont_inicial => 0 )        
    Port map( enable => btn_crono_conmutado_s,
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => segundero_s );
              
segundos_crono : contador
    Generic map( n_bits => 5,       --Con motivo de compatibilidad con la memoria ROM se usan 5 bits
                 max_count => 10,        --10 segundos em total
                 cont_inicial => 0 )
    Port map( enable => segundero_s,
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => fin_10s_s,
              count => segundos_crono_s );
              
decenas_de_segundos_crono : contador
    Generic map( n_bits => 5,       --Con motivo de compatibilidad con la memoria ROM se usan 5 bits
                 max_count => 6,        --60 segundos en total
                 cont_inicial => 0 )
    Port map( enable => en60s_s,
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => fin_60s_s,
              count => decenas_segundos_crono_s );
              
minutos_crono : contador
    Generic map( n_bits => 5,       --Con motivo de compatibilidad con la memoria ROM se usan 5 bits
                 max_count => 9,        --9 minutos en total
                 cont_inicial => 0 )
    Port map( enable => en_minutos_s,
              clk => clk,
              sentido_c => '0',
              reset => reset,
              count => minutos_s );
               
               
               
-----MANDO SNES INSTANCIAS----------------------------------------------------------------------------------------------------------------

fsm_mandoSNES : FSM_mando_SNES
  Port map ( clk => clk,
             reset => reset,
             fin_6us => fin_cuenta_6us,    
             fin_12us => fin_cuenta_12us, 
             data_count => unsigned(data_count_s),        
             --Puertos de salida
             latch_out => latch_out_s,
             clk_SNES_out => clk_SNES_s,
             data_end => data_end_s);
             
             
vector_datos : process(clk_SNES_s)
begin
    if clk_SNES_s'event and clk_SNES_s = '0' then 
        buttons_SNES_s <= data_SNES & buttons_SNES_s(15 downto 1);
    end if;
end process;

process(data_end_s)
begin
    if data_end_s'event and data_end_s = '1' then 
        buttons_SNES_fin_s <= buttons_SNES_s;
    end if;
end process;


contador6us : contador
    Generic map( n_bits => 10,
                 max_count => 750,
                 cont_inicial => 0 )        
    Port map( enable => '1',
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => fin_cuenta_6us );
              
contador12us : contador
    Generic map( n_bits => 2,       --2
                 max_count => 2,        --2
                 cont_inicial => 0 )        
    Port map( enable => fin_cuenta_6us,
              clk => clk,
              sentido_c => '0',
              reset => reset,
              fin_cuenta => fin_cuenta_12us_aux );
    
              
              
contador_especial_SNES : contador
    Generic map( n_bits => 5,
                 max_count => 20,
                 cont_inicial => 0 )        
    Port map( enable => enable_contador_especial,
              clk => clk,
              sentido_c => '0',
              reset => reset_contador_especial,
              count => data_count_s );

              

----LOGICA ADICIONAL--------------------------------------------------------------------------------------------------------------
        
fin_cuenta_12us <= fin_cuenta_6us and fin_cuenta_12us_aux;       
rgb <= rojo_s & verde_s & azul_s;
jug_en_pista <= pista(to_integer(unsigned(spritecuadfil)))(to_integer(unsigned(spritecuadcol)));
en60s_s <= segundero_s and fin_10s_s;
en_minutos_s <= fin_60s_s and fin_10s_s and segundero_s;

latch_SNES <= latch_out_s;
clk_SNES <= clk_SNES_s;

enable_contador_especial <= fin_cuenta_6us and not clk_SNES_s;
reset_contador_especial <= reset or data_end_s;


end Behavioral;