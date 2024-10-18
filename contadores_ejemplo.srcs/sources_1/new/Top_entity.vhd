library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Top_ent is
  Generic ( n_bitsTE : integer := 4 ); --Generico para las señales asignadas a la salida de la cuenta de los contadores, para reducir numero de lineas a cambiar
  Port ( seg7 : out std_logic_vector(6 downto 0);   --Salida del decodificador de 7 segmentos
         AN : out std_logic_vector (1 downto 0);    --Salida del anodo del display
         enableTE : in std_logic;                   --Habilitacion
         clkTE : in std_logic;                      --Reloj
         resetTE : in std_logic := '0';             --Reset
         RGB_g : out std_logic;                     --Entrada canal verde del LED RGB
         RGB_r : out std_logic;                     --Entrada canal rojo del LED RGB
         sentido_cuenta : in std_logic;             --Sentido de la cuenta, 0 para ascendente, 1 para descendente
         LEDS : out std_logic_vector (3 downto 0)); --LEDS para la cuenta binaria de la salida del contador de 10s
end Top_ent;

architecture Behavioral of Top_ent is

--COMPONENTES-------------------------------------------------------------------------------------------------

component contador is
  Generic ( n_bits : integer := 4;     --Genericos por defecto. Cambiar valor en la instancia si es necesario
            max_count : integer := 9);     
  Port ( enable : in std_logic;     --Habilitacion contador
         clk : in std_logic;        --Reloj
         count : out std_logic_vector (n_bits - 1 downto 0);    --Cuenta total contador
         reset : in std_logic;      --Reset
         fin_cuenta : out std_logic;        --Fin de cuenta
         sentido_c : std_logic := '0');     --0 ascendente, 1 descendente
end component;

component mux2a1 is
    Generic( bits_en : integer := 4 );      --Generico para los buses de entrada del multiplexor
    Port ( ent_mux_0 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);      --Entrada 0
           ent_mux_1 : in STD_LOGIC_VECTOR (bits_en - 1 downto 0);      --Entrada 1
           sel_mux : in STD_LOGIC;                                      --Selector
           sal_mux : out STD_LOGIC_VECTOR (bits_en - 1 downto 0));      --Salida
end component;

component deco_7_seg is
    Port ( deco7_ent : in STD_LOGIC_VECTOR (3 downto 0);    --Entrada decodificador
           deco7_sal : out STD_LOGIC_VECTOR (6 downto 0));  --Salida decodificador
end component;

component biestableT is
  Port ( clk : in std_logic;        --Reloj
         enable : in std_logic;     --Habilitacion biestable
         reset : in std_logic;      --Reset biestable
         data : in std_logic;       --Entrada del biestable
         output_data : out std_logic ); --Salida del biestable
end component;


--SEÑALES---------------------------------------------------------------------------------------------------------------

signal fin_cuenta_1s : std_logic;       --Señal fin de cuenta para contador de 1s
signal fin_cuenta_10s : std_logic;      --Señal fin de cuenta para contador de 10s
signal enable60s : std_logic;           --Señal para la habilitacion del contador de 60s
signal fin_cuenta_1ms : std_logic;      --Señal fin de cuenta para contador de 1ms
signal cuenta_10s : std_logic_vector (n_bitsTE - 1 downto 0);   --Señal que contiene los 4 bits de la cuenta del contador de 10s
signal cuenta_60s : std_logic_vector (n_bitsTE - 1 downto 0);   --Señal que contiene los 4 bits de la cuenta del contador de 60s
signal mux2deco : std_logic_vector (n_bitsTE - 1 downto 0);     --Señal de union del multiplexor con el decodificador
signal mux_sel_s : std_logic;       --Señal de selector del multiplexor
signal halfsec : std_logic;         --Señal de final de cuenta del contador de 0.5s
signal RGB_s : std_logic;           --Señal para la salida del biestable T que regula que canal del LED RGB se va a usar
signal enableTE_s : std_logic := '0';   --Señal para el enable del circuito
signal q0toq1 : std_logic;              --Señal que conecta la salida del primer biestable T con la entrada del segundo biestable T en el detector de flancos
signal q1out : std_logic;               --Señal de salida del segundo biestable T del detector de flancos
signal q2in : std_logic;                --Señal de entrada del tercer biestable T del detector de flancos
signal sentido_cuenta_s : std_logic;    --Señal para el sentido de la cuenta



begin

--INSTANCIAS DE LOS CONTADORES----------------------------------------------------------------------------------------------------------

contador1s_inst : contador
    Generic map ( n_bits => 27,
                  max_count => 125000000 )  --Si no se añade generic map se usa generico especificado en el componente
                  
    Port map( clk => clkTE,
              enable => enableTE_s,
              reset => resetTE,
              fin_cuenta => fin_cuenta_1s,
              sentido_c => '0');    --En este mantenemos sentido normal
 
              
contador10s_inst : contador
    Generic map( n_bits => 4,     --Bits necesarios para alcanzar 9 segundos
                 max_count => 10 )  --Cuenta segundos (0 a 9)
    Port map( clk => clkTE,
              enable => fin_cuenta_1s,
              reset => resetTE,
              count => cuenta_10s,
              fin_cuenta => fin_cuenta_10s,
              sentido_c => sentido_cuenta_s);
              
contador60s_inst : contador
    Generic map( n_bits => 4,     --Aunque 3 bits son suficientes para la cuenta hasta 6, se eligen 4 bits para matener la coherencia con las entradas al multiplexor y al decodificador
                 max_count => 6 )   --Cuenta decenas de segundos
    Port map( clk => clkTE,
              enable => enable60s,
              reset => resetTE,
              count => cuenta_60s,
              sentido_c => sentido_cuenta_s);
              
contador1ms_inst : contador
    Generic map( n_bits => 17,     
                 max_count => 125000 )     --1 ms
    Port map( clk => clkTE,
              enable => '1',
              reset => resetTE,
              fin_cuenta => fin_cuenta_1ms,
              sentido_c => '0');
              
contador2ms_inst : contador
    Generic map( n_bits => 2,     
                 max_count => 2 )     --2 ms
    Port map( clk => clkTE,
              enable => fin_cuenta_1ms,
              reset => resetTE,
              fin_cuenta => mux_sel_s,
              count => AN,
              sentido_c => '0');
              
contadorRGB_inst : contador
    Generic map( n_bits => 26,     
                 max_count => 62500000 )     --0.5s
    Port map( clk => clkTE,
              enable => enableTE_s,
              reset => resetTE,
              fin_cuenta => halfsec,
              sentido_c => '0');
              
--------INSTANCIAS DECODIFICADOR Y MULTIPLEXOR----------------------------------------------------------------------------------------
              
deco7 : deco_7_seg
    Port map( deco7_sal => seg7,
              deco7_ent => mux2deco );
              
mux1 : mux2a1
Generic map( bits_en => 4)
Port map( ent_mux_0 => cuenta_10s ,
           ent_mux_1 => cuenta_60s,
           sel_mux => mux_sel_s,
           sal_mux => mux2deco);
           
           
--INSTANCIAS BIESTABLES T----------------------------------------------------------------------------------------------------
           
biesT_RGB : biestableT
Port map( clk => clkTE,
         enable => enableTE_s,
         reset => resetTE,
         data => halfsec,
         output_data => RGB_s);
         
--Los siguientes biestables son para el detector de flancos

biestT1 : biestableT
Port map( clk => clkTE,
         enable => '1',
         reset => resetTE,
         data => enableTE,      --Entrada del boton
         output_data => q0toq1);

biestT2 : biestableT
Port map( clk => clkTE,
         enable => '1',
         reset => resetTE,
         data => q0toq1,
         output_data => q1out);
         
biestT3 : biestableT
Port map( clk => clkTE,
         enable => enableTE,
         reset => resetTE,
         data => q1out,
         output_data => enableTE_s);
           
 enable60s <= fin_cuenta_1s and fin_cuenta_10s;
 RGB_g <= RGB_s and enableTE_s;
 RGB_r <= not enableTE_s;
 q2in <= q0toq1 and q1out;
 sentido_cuenta_s <= sentido_cuenta;
 LEDS <= cuenta_10s;        --Asignacion directa signal 2 puerto de salida
end Behavioral;
