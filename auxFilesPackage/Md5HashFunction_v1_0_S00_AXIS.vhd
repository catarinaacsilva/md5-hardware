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

        -- validData    	: out std_logic;
        -- md5Data 		: out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		--readEnabled  : in  std_logic;
		--readyM 			: in std_logic; -- vem do master quando pode aceitar mais palavras

		reset : in std_logic;
		start : out std_logic;
		enable: out std_logic;
		dataOutSlave : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		lastInfo : out std_logic;
        
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

	-- last process
	signal s_tlastdelayed : std_logic;

	-- dataIn process
	signal s_dataOutSlave : std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);

	-- md5 core signals (control)
	signal s_start, s_enable : std_logic;
	signal s_reset : std_logic;

	signal s_readyS : in std_logic;


	type state_t is ( 	IN_IDLE, 
						IN_START, 
						IN_ENABLE, 
						NO_START);

	-- FSM
	signal state, state_n : state_t;

	begin
		
	s_reset <= reset;

	register_last: Register
		generic map(k 	=> 1)
		port map (  reset	=> s_reset,
					clk 	=> S_AXIS_ACLK,
					enable	=> '1',
					dataIn	=> S_AXIS_TLAST,
					dataOut => s_tlastdelayed);
					
	register_dataIn: Register
		generic map(k 	=> C_S_AXIS_TDATA_WIDTH)
		port map (  reset	=> s_reset,
					clk 	=> S_AXIS_ACLK,
					enable	=> s_enable and s_start,
					dataIn	=> S_AXIS_TDATA,
					dataOut => s_dataOutSlave); -- input data on MD5 core
					

	process(S_AXIS_ARESETN, S_AXIS_ACLK)
    begin
        if (S_AXIS_ARESETN = '1') then
            state <= IN_IDLE;
        elsif (rising_edge(S_AXIS_ACLK)) then
            state <= state_n;
        end if;
    end process;


	process(state)
	begin

		state_n <= state;

		s_readyS <= '0';

		case state is
			when IN_IDLE =>
				s_start = '0';
				s_enable = '0';

				s_readyS <= '1';

				if(S_AXIS_TVALID = '1') then
					state_n <= IN_START;
				elsif (s_reset = '1') then
					state_n <= IN_IDLE;
				else
					state_n <= IN_IDLE;
				end if;
			
				

			when IN_START =>
				s_start = '1';
				enable = '1';
				

				if (S_AXIS_TVALID = '1' and s_idle = '1') then
					state_n <= IN_ENABLE;
				elsif (s_idle = '0' or S_AXIS_TVALID = '0') then
					state_n <= NO_START;
				elsif (s_reset = '1') then
					state_n <= IN_IDLE;
				else
					state_n <= IN_START;
				end if;


			when IN_ENABLE =>
				s_start = '0';
				s_enable = '1';
			
				
				if(s_idle = '0') then
					state_n <= NO_START;
				elsif (s_tlastdelayed = '1') then
					state_n <= IN_IDLE;
				elsif (s_reset = '1') then
					state_n <= IN_IDLE;
				else
					state_n <= IN_ENABLE;
				end if;


			when NO_START =>
				s_start = '0';
				s_enable = '0';
				
				if(S_AXIS_TVALID = '0') then
					state_n <= NO_START;
				elsif (s_idle = '1' or S_AXIS_TVALID = '1') then
					state_n <= IN_ENABLE;
				elsif (s_reset = '1') then
					state_n <= IN_IDLE;
				else
					state_n <= NO_START;
				end if;

		end case;

	end process;

	start <= s_start;
	enable <= s_enable;
	
	dataOutSlave <= s_dataOutSlave;

	lastInfo <= s_tlastdelayed;
	S_AXIS_TREADY <= s_readyS;
    
end arch_imp;
