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
		--readEnabled  : in  std_logic;
		readyM : in std_logic; -- vem do master quando pode aceitar mais palavras
        
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
			done:        out std_logic := '0';
			idleOut:     out std_logic);
	end component md5;
	
	-- signal s_ready    	: std_logic;
	signal s_readyS		: std_logic;
    signal s_validOut 	: std_logic; 
	
	signal s_dataOut  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0); 
    signal s_md5Result	  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_done     	: std_logic;
	signal s_start		: std_logic;
	signal s_reset		: std_logic;
	signal s_dataIn  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_idle	: std_logic;
	signal s_enable		: std_logic;

	-- last process
	signal s_tlastdelayed : std_logic;


	type state_t is ( 	IN_IDLE, 
						IN_START, 
						IN_ENABLE, 
						NO_START);

signal state, state_n : state_t;

    begin
    
    md5_comp: md5
		port map (  data_in		=>	s_dataIn,
					enable		=> 	s_enable,
                    start 		=> 	s_start,
                    clk 		=> 	S_AXIS_ACLK,
                    reset 		=> 	s_reset,      
                    data_out 	=>  s_md5Result,
					done 		=> 	s_done,
					idleOut 	=> 	s_idle);

	register_last: Register
		generic map(k 	=> 1)
		port map (  reset	=> s_reset,
					clk 	=> S_AXIS_ACLK,
					enable	=> '1', -- sempre que o last esteja a 1 então passa para a saida
					dataIn	=> S_AXIS_TLAST,
					dataOut => s_tlastdelayed);
					
	register_dataIn: Register
		generic map(k 	=> C_S_AXIS_TDATA_WIDTH)
		port map (  reset	=> s_reset,
					clk 	=> S_AXIS_ACLK,
					enable	=> s_enable and s_start,
					dataIn	=> s_dataIn,
					dataOut => s_dataIn); --dados de entrada no md5 core
					

	process(S_AXIS_ARESETN, S_AXIS_ACLK)
    begin
        if (S_AXIS_ARESETN = '1') then
            state <= init;
        elsif (rising_edge(S_AXIS_ACLK)) then
            state <= state_n;
        end if;
    end process;


	process(state)
	begin

		state_n <= state;

		case state is
			when IN_IDLE =>
				s_start = '0';
				s_enable = '0';
				-- s_validOut = '0';
				-- s_dataOut  <= (others => '0');
				-- s_readyS = '1';

				if(S_AXIS_TVALID = '1') then
					state_n <= IN_START;
				else
					state_n <= IN_IDLE;
			
				

			when IN_START =>
				s_start = '1';
				enable = '1';
				-- s_validOut = '0';
				-- s_dataOut  <= (others => '0');
				-- s_readyS = 0;
				
				if (S_AXIS_TVALID = '1' and s_idle = '1') then
					state_n <= IN_ENABLE;
				elsif (s_idle = '0' or S_AXIS_TVALID = '0') then
					state_n <= NO_START;
				else
					state_n <= IN_START;


			when IN_ENABLE =>
				s_start = '0';
				s_enable = '1';
				-- s_validOut = '0';
				-- s_dataOut  <= (others => '0');
				-- s_readyS = '0';
				 
				if(s_idle = '0') then
					state_n <= NO_START;
				elsif (s_tlastdelayed = '1') then
					state_n <= IN_IDLE;
				else
					state_n <= IN_ENABLE;


			when NO_START =>
				s_start = 1;
				s_validOut = 0;
				-- s_dataOut  <= (others => '0');
				-- s_readyS = 0;
				
				if(S_AXIS_TVALID = '0') then
					state_n <= NO_START;
				elsif (s_idle = '1' or S_AXIS_TVALID = '1') then
					state_n <= IN_ENABLE;
				else
					state_n <= NO_START;

		end case;

	end process;


    validData <= s_validOut;
	md5Data <= s_dataOut;
    S_AXIS_TREADY <= s_ready;
    
end arch_imp;
