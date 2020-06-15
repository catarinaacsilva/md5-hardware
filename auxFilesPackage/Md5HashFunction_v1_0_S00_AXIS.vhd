library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Md5HashFunction_v1_0_S00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- AXI4Stream sink: Data Width
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
		-- Users to add ports here
        validData    : out std_logic;
        md5Data : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
        readEnabled  : in  std_logic; --slave -> dmac
        
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- AXI4Stream sink: Clock
		S_AXIS_ACLK	: in std_logic;
		-- AXI4Stream sink: Reset
		S_AXIS_ARESETN	: in std_logic;
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic;
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic
	);
end Md5HashFunction_v1_0_S00_AXIS;

architecture arch_imp of Md5HashFunction_v1_0_S00_AXIS is
	component md5 is 
	   port(data_in:     in  std_logic_vector (C_S_AXIS_TDATA_WIDTH-1 downto 0);
            start:       in  std_logic;
            clk:         in  std_logic;
            reset:       in  std_logic;
            data_out:    out std_logic_vector (C_S_AXIS_TDATA_WIDTH-1 downto 0) := (others => '0');
            done:        out std_logic := '0');
	end component md5;
	
	signal s_ready    	: std_logic; -- master -> slave
    signal s_validOut 	: std_logic; -- data valid: slave->master
    signal s_dataOut  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0); 
    signal dataOut  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_done     	: std_logic;
	signal s_start		: std_logic;

    begin
    
    md5_comp: md5
        port map (  data_in => S_AXIS_TDATA,
                    start => s_start,
                    clk => S_AXIS_ACLK,
                    reset => S_AXIS_ARESETN,      
                    data_out =>  s_dataOut,
					done => s_done);
					
	s_ready <= (not s_validOut) or readEnabled;

    
    process(S_AXIS_ACLK)
	begin
        if (rising_edge (S_AXIS_ACLK)) then
	        if (S_AXIS_ARESETN = '0') then
	           s_validOut <= '0';
	           s_dataOut  <= (others => '0');
       
            elsif (S_AXIS_TVALID = '1') then
	           if (s_ready = '1') then
					s_validOut <= '1';
					s_dataOut  <= dataOut;
	           end if;
	      
	        elsif (readEnabled = '1') then
	           s_validOut <= '0';       
            end if;
        end if;
    end process;

    validData <= s_validOut;
    md5Data <= s_dataOut;
    S_AXIS_TREADY <= s_ready;
    
end arch_imp;
