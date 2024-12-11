library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.RACETRACK_PKG.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity juego_tb is
--  Port ( );
end juego_tb;

architecture Behavioral of juego_tb is

component top_vga is
  Port ( clk : in std_logic;
         reset : in std_logic;
         btn_dificultad_bot : in std_logic;
         btn_crono : in std_logic;
         data_SNES : in std_logic;
         
         clkP : out std_logic;
         clkN : out std_logic;
         dataP : out std_logic_vector (2 downto 0);
         dataN : out std_logic_vector ( 2 downto 0);
         latch_SNES : out std_logic;
         clk_SNES : out std_logic );
end component;


signal clock : std_logic;
signal reset_s : std_logic;
signal btn_dificultad_bot_s : std_logic;
signal btn_crono_s : std_logic;
signal data_SNES_s : std_logic;

signal clkP_s : std_logic;
signal clkN_s : std_logic;
signal dataP_s : std_logic_vector (2 downto 0);
signal dataN_S : std_logic_vector ( 2 downto 0);
signal latch_SNES_S : std_logic;
signal clk_SNES_s : std_logic;

begin

topvga : top_vga
    Port map( clk => clock,
              reset => reset_s,
              btn_dificultad_bot => btn_dificultad_bot_s,
              btn_crono => btn_crono_s,
              data_SNES => data_SNES_s,
              clkP => clkP_s,                     
              clkN => clkN_s,                      
              dataP => dataP_s,
              dataN => dataN_s,
              latch_SNES => latch_SNES_s,               
              clk_SNES => clk_SNES_s );      
              
                        
clksim : process
   begin
        clock <= '0';
        wait for 4ns;  --4 ns para 125MHz aumentamos frecuencia para verlo mejor
        clock <= '1';
        wait for 4ns;  --4 ns original
   end process;

reset_s <= '1', '0' after 120ns;
btn_dificultad_bot_s <= '0', '1' after 20us, '0' after 21us;
btn_crono_s <= '0';
data_SNES_s <= '1' , '0' after 78us, '1' after 1228us, '0' after 1400us;


end Behavioral;
