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
			done:        out std_logic := '0';
			idleOut:     out std_logic);
	end component md5;
	
	signal s_ready    	: std_logic; -- master -> slave
    signal s_validOut 	: std_logic; -- data valid: slave->master
    signal s_dataOut  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0); 
    signal s_md5Result	  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_done     	: std_logic;
	signal s_start		: std_logic;
	signal s_reset		: std_logic;
	signal s_dataIn  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_idleOut	: std_logic;

	type state_t is (	init,
						proc0,
						last,
						busyReady,
						busyIdle);

signal state, state_n : state_t;

    begin
    
    md5_comp: md5
        port map (  data_in => s_dataIn,
                    start => s_start,
                    clk => S_AXIS_ACLK,
                    reset => s_reset,      
                    data_out =>  s_md5Result,
					done => s_done,
					idleOut => s_idleOut); -- verificar
					
	s_ready <= (not s_validOut) or readEnabled;


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
			when init =>
				s_start <= '0';
				s_validOut <= '0';
				s_dataOut  <= (others => '0');

				if(S_AXIS_TVALID = '1') then
					if (S_AXIS_TLAST = '1') then
						state_n <= last;
					elsif ((s_idleOut <= '0' and s_ready = '0') or (s_idleOut <= '0' or s_ready = '1')) then
						state_n <= busyIdle;
					elsif (s_idleOut = '1' and s_ready = '0') then
						state_n <= busyReady;
					else
						state_n <= proc0;
					end if;
				else
					state_n <= init;
				end if;
			
			when proc0 =>
				s_start <= '1';
				s_validOut <= '1';
				s_dataOut  <= s_md5result;

				if(S_AXIS_TVALID = '1') then
					state_n <= init;
				else
					state_n <= proc0;
				end if;

			when last =>
				s_start <= '0';
				s_validOut <= '0';
				s_dataOut  <= (others => '0');

				if(S_AXIS_TVALID = '1') then
					state_n <= init;
				else
					state_n <= last;
                end if;
			when busyReady =>
				s_start <= '0';
				s_validOut <= '0';
				s_dataOut  <= (others => '0');

				if(S_AXIS_TVALID = '1') then
					if (s_idleOut = '1' and s_ready = '1') then
						state_n <= proc0;
					else
						state_n <= busyReady;
					end if;
				else
					state_n <= busyReady;
				end if;

			when busyIdle =>
				s_start <= '0';
				s_validOut <= '0';
				s_dataOut  <= (others => '0');

				if(S_AXIS_TVALID = '1') then
					if (s_idleOut = '1' and s_ready = '1') then
						state_n <= proc0;
					elsif (s_idleOut = '1' and s_ready = '0') then
						state_n <= busyReady;
					else
						state_n <= busyIdle;
					end if;
				else
					state_n <= busyIdle;
				end if;

		end case;

	end process;
	

    validData <= s_validOut;
    md5Data <= s_dataOut;
    S_AXIS_TREADY <= s_ready;
    
end arch_imp;
