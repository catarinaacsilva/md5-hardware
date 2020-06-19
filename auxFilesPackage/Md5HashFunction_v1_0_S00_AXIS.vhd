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
    signal s_md5Result	  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
	signal s_done     	: std_logic;
	signal s_start		: std_logic;
	signal s_reset		: std_logic;
	signal s_dataIn  	: std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);

	-- signal s_wrAddr : unsigned(MEM_ADDR_WIDTH-1 downto 0);

	-- type TMemory is array (0 to (2**MEM_ADDR_WIDTH)-1) of std_logic_vector(S_AXIS_TDATA'range);
    -- signal s_arrayBuffer : TMemory;

    begin
    
    md5_comp: md5
        port map (  data_in => s_dataIn,
                    start => s_start,
                    clk => S_AXIS_ACLK,
                    reset => s_reset,      
                    data_out =>  s_md5Result,
					done => s_done);
					
	s_ready <= (not s_validOut) or readEnabled;

	process(S_AXIS_ACLK)
    begin
        if (rising_edge(S_AXIS_ACLK)) then
            if (S_AXIS_TVALID = '1') then
				
				-- start to read the word
				if (S_AXIS_TSTRB(0) = '1' and S_AXIS_TSTRB(1) = '1' and S_AXIS_TSTRB(2) = '1' andS_AXIS_TSTRB(3) = '1') then
					s_start = '1';
            		s_dataIn <= S_AXIS_TDATA;
                end if;
                          
			end if;  
		end if;
	end process;

    process(S_AXIS_ACLK)
	begin
        if (rising_edge (S_AXIS_ACLK)) then
			if (S_AXIS_ARESETN = '0') then
				s_reset <= '1';
				s_validOut <= '0';
				s_dataOut  <= (others => '0');    

			elsif (S_AXIS_TVALID = '1') then
				if (S_AXIS_TLAST = '1') then
                    s_validOut <= '0';
                else
					if (s_ready = '1') then
						s_validOut <= '1';
						s_dataOut  <= s_md5Result;
					end if;
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
