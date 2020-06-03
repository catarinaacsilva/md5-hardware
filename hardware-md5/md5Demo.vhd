library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity md5Demo is
    Port (  clk : in  STD_LOGIC;
            led : out STD_LOGIC_VECTOR(1 downto 0);
            sw  : in  STD_LOGIC_VECTOR(1 downto 0);
            an  : out std_logic_vector(7 downto 0);
            seg : out std_logic_vector(6 downto 0);
            dp  : out std_logic
    );
end md5Demo;

architecture Behavioral of md5Demo is
    signal data_out : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
    signal s_dispRefEn : STD_LOGIC;
begin

md5:    entity work.md5(Behavioral)
        port map(   data_in => "00000011100011100000000000011110",
                    data_out => data_out,
                    done => led(0),
                    err => led(1),
                    start => sw(1),
                    clk => clk,
                    reset => sw(0)
        );
        
p_gen: entity work.PulseGenerator(Behavioral)
                    port map(clk100MHz  => clk,
                             dispRefEn  => s_dispRefEn
                    );
        
disp:   entity work.Nexys4DispDriver(Behavioral)
        port map(   clk       => clk,   
                    enable    => s_dispRefEn,
                    digitEn   => "11111111",
                    digVal0   => data_out(3 downto 0),
                    digVal1   => data_out(7 downto 4),
                    digVal2   => data_out(11 downto 8),
                    digVal3   => data_out(15 downto 12),
                    digVal4   => data_out(19 downto 16),
                    digVal5   => data_out(23 downto 20),
                    digVal6   => data_out(27 downto 24),
                    digVal7   => data_out(31 downto 28),
                    decPtEn   => "00000000",
                    dispEn_n  => an(7 downto 0),
                    dispSeg_n => seg(6 downto 0),
                    dispPt_n  => dp
         );
    
end Behavioral;
