--------------------------------------------
-- Module Name: MD5 testbench
-- Description: Testbench to MD5 module
--
-- Authors: Catarina Silva
-- Email: c.alexandracorreia@ua.pt
--------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM; -- check if it is necessary
use UNISIM.VComponents.all; -- check if it is necessary
 

entity MD5_tb IS
end MD5_tb;
 
architecture Behavioral OF MD5_tb IS 
    component MD5
    port(
        data_in:     in  std_logic_vector (31 downto 0);
        start:       in  std_logic;
        clk:         in  std_logic;
        reset:       in  std_logic;
        data_out:    out std_logic_vector (31 downto 0) := (others => '0');
        done:        out std_logic := '0';
        err:         out std_logic := '0');
    end component;
    
   signal s_data_in : std_logic_vector(31 downto 0) := (others => '0');
   signal s_start : std_logic := '0';
   signal s_clk : std_logic := '0';
   signal s_reset : std_logic := '0';
   signal s_data_out : std_logic_vector(31 downto 0);
   signal s_done : std_logic;
   signal s_err : std_logic;

   constant clkPeriod : time := 10 ns;

   type msg_t is array(0 to 15) of std_logic_vector(31 downto 0);


   signal message : msg_t := (X"24cda8da", X"aed64a2e", X"312f765a", X"b90c9791",
                              X"fd32d9d0", X"615206cb", X"5b0e5045", X"dbb5f6af",
                              X"f4310a8e", X"58468968", X"c3b8c9aa", X"24db1a8d",
                              X"aec70000", X"00000000", X"00000000", X"00000000");

 
    signal message_length : std_logic_vector(31 downto 0) := (others => '0');
    signal hash : std_logic_vector(0 to 127) := (others => '0');

begin
 
    uut: MD5 PORT MAP (
          data_in => s_data_in,
          data_out => s_data_out,
          done => s_done,
          err => s_err,
          start => s_start,
          clk => s_clk,
          reset => s_reset);

   clkProc : process
   begin
        -- duty cycle = 50%
		s_clk <= '0';
		wait for clkPeriod/2;
		s_clk <= '1';
		wait for clkPeriod/2;
   end process;


   behavProc: process
   begin
       reset <= '1';
       
       wait for clkPeriod; -- 10 ns
       reset <= '0';
       start <= '1';
       
       wait for 2 ns;
       data_in <= message_length; -- load message length
      
       wait for clkPeriod; -- 10 ns
       start <= '0';
       for i in 0 to 15 loop -- array size = 16
           data_in <= message(i); -- input message
           wait for clkPeriod; -- 10 ns
       end loop;

       -- hash
       wait for 500 ns;
       start <= '1';
       
       wait for clkPeriod;
       start <= '0';
       
       wait for clkPeriod;
       for i in 0 to 3 loop
           hash(32*i to 32*i+31) <= data_out; -- store hash
           wait for clkPeriod;
       end loop;
       
       wait for 50 ns; -- wait for done
   end process;

end;
