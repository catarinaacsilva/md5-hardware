library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity md5Demo is
    Port (  clk       : in std_logic;
            led : out STD_LOGIC_VECTOR(7 downto 0);
            sw  : in STD_LOGIC_VECTOR(7 downto 0)
    );
end md5Demo;

architecture Behavioral of md5Demo is
begin
md5:    entity work.md5(Behavioral)
        port map(   data_in => "00000011100011100000000000011110",
                    data_out =>
                    done => led(0),
                    err => led(1),
                    start => led(2),
                    clk => clk,
                    reset => sw(0)
        );
    
end Behavioral;
