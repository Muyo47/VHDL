library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Contador_tb is
--  Port ( );
end Contador_tb;

architecture Behavioral of Contador_tb is

component Top_ent is
  Generic ( n_bitsTE : integer := 4 );
  Port ( seg7 : out std_logic_vector(6 downto 0);
         AN : out std_logic_vector (1 downto 0);
         enableTE : in std_logic;
         clkTE : in std_logic; 
         resetTE : in std_logic := '0';
         RGB_r : out std_logic;
         RGB_g : out std_logic;
         sentido_cuenta : in std_logic);
end component;

signal seg7_s : std_logic_vector(6 downto 0) := "0000000";
signal enable_s : std_logic := '0';
signal clk_s : std_logic := '0';
signal reset_s : std_logic := '0';
signal RGBr_s : std_logic := '0';
signal RGBg_s : std_logic := '0';
signal sentido_cuenta_s : std_logic := '0';
signal AN_s : std_logic_vector (1 downto 0) := "00"; 
begin

TE_inst : Top_ent       --Uso valor generico especificado en el componente
port map( enableTE => enable_s,
          seg7 => seg7_s,
          clkTE => clk_s,
          resetTE => reset_s,
          AN => AN_s,
          RGB_r => RGBr_s,
          RGB_g => RGBg_s,
          sentido_cuenta => sentido_cuenta_s );


process
begin
    clk_s <= not clk_s;
    wait for 8ns;       --125MHz
end process;


enable_s <= '0', '1' after 200ns, '0' after 250ns;
reset_s <= '0', '1' after 24ns, '0' after 36ns;
sentido_cuenta_s <= '1';


end Behavioral;
