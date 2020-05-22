----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2019 05:52:20 PM
-- Design Name: 
-- Module Name: mips_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use work.header_pk.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mips_top is
  Port ( 
      CLK50M,BTNC,BTNU,BTNR: in std_logic;
      UART_TXD_IN : in STD_LOGIC;
      UART_RXD_OUT : out STD_LOGIC;
      SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0); -- Connect to Cathode signal in XDC File for 7 SEG
      SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0); -- Connnect to Anode signal in XDC File for 7 SEG
--      dout, pc_out, instr : out std_logic_vector(31 downto 0);jmki
      SW : in STD_LOGIC_VECTOR(15 DOWNTO 0) -- Switch arrray for later use

  );
end mips_top;

architecture Behavioral of mips_top is

-- SIGNALS SORTED BY ORIGIN--

SIGNAL clk : STD_LOGIC; 
SIGNAL rst : STD_LOGIC;
--SIGNAL BTNC : STD_LOGIC;
--Program COunter
SIGNAL pc_curr: STD_LOGIC_VECTOR(31 downto 0);               --  PC Address to Instruction Memory
SIGNAL pc_next: STD_LOGIC_VECTOR(31 downto 0);               --  PC Address to Instruction Memory

--Instruction Memory
SIGNAL inst: STD_LOGIC_VECTOR(31 downto 0);             --  Instruction Memory to Register File Signal
SIGNAL add_temp: STD_LOGIC_VECTOR(31 downto 0);        --  Temp Address Signal to feed UART Values
SIGNAL add_UART: STD_LOGIC_VECTOR(31 downto 0);        --  Temp Address Signal to feed UART Values
SIGNAL add_UART_out: STD_LOGIC_VECTOR(31 downto 0);        --  Temp Instruction Signal to feed UART Values
SIGNAL rf_val :STD_LOGIC_VECTOR(31 DOWNTO 0);               -- Temp place to store value from Rf File for transfer to UART

--Control Unit
SIGNAL funct :STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL wrt_en_rf : STD_LOGIC;                           --  Write Enable from Control Unit
SIGNAL op_code :STD_LOGIC_VECTOR(5 DOWNTO 0);           -- Control Signals 
SIGNAL memtoreg : STD_LOGIC;
SIGNAL wrt_en_mem : STD_LOGIC;
SIGNAL rd_en_mem : STD_LOGIC;
SIGNAL branch : STD_LOGIC; 
SIGNAL branch_cond :STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL alu_control :STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL alu_src : STD_LOGIC;
SIGNAL reg_dst: STD_LOGIC;
SIGNAL reg_wrt : STD_LOGIC;
SIGNAL stop : STD_LOGIC;
SIGNAL jump : STD_LOGIC;

--ALU
SIGNAL in_a:STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL in_b:STD_LOGIC_VECTOR(31 DOWNTO 0);
--SIGNAL Alu_control:STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL equ: STD_LOGIC;
SIGNAL not_equal: STD_LOGIC;
SIGNAL less_than: STD_LOGIC;
SIGNAL alu_op:STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL zero: STD_LOGIC;

--DMEM
SIGNAL d_read:STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL d_write:STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL mem_address:STD_LOGIC_VECTOR(31 DOWNTO 0);

--Register File
SIGNAL wrt_add_rf :STD_LOGIC_VECTOR(4 DOWNTO 0);        --  RF Write Address
SIGNAL wrt_data_rf :STD_LOGIC_VECTOR(31 DOWNTO 0);      --  RF Write Data
SIGNAL read_add_rf_1 :STD_LOGIC_VECTOR(4 DOWNTO 0);     --  RF Read Add 1
SIGNAL read_data_rf_1:STD_LOGIC_VECTOR(31 DOWNTO 0);    --  RF Read Data 1
SIGNAL read_add_rf_2 :STD_LOGIC_VECTOR(4 DOWNTO 0);     --  RF Read Add 2
SIGNAL read_data_rf_2:STD_LOGIC_VECTOR(31 DOWNTO 0);    --  RF Read Data 2
SIGNAL rf_rom : registers;

--sign extension
SIGNAL sign_ext_imm:STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL tmp:STD_LOGIC_VECTOR(15 DOWNTO 0);

--UART Wrapper
SIGNAL  CPU_RESET:  std_logic;
SIGNAL  USB_UART_TX:  std_logic;
SIGNAL  USB_UART_RX2:  std_logic;
SIGNAL  O_RX_OUT2:  std_logic_vector(7 downto 0);
--SIGNAL  O_RX_VLD2:  std_logic;
SIGNAL  O_FRAME_ERROR2:  std_logic;
 -- RST: in std_logic;
SIGNAL  tx_data:  std_logic_vector(7 downto 0);
 --(* mark_debug = "true" *)     input  [07:0] I_TX_DATA,  // ///
 --(* mark_debug = "true" *)     input         I_TX_START, // ///
SIGNAL I_TX_START:  std_logic;
SIGNAL O_BUSY2:  std_logic ;

signal rx_counter: std_logic_vector(1 downto 0):= "00";
signal tx_counter: std_logic_vector(1 downto 0):= "00";
signal tx_start: std_logic;
signal delay_counter: std_logic_vector(15 downto 0);
signal vld: std_logic;
signal uart_busy_d: std_logic;
signal tx_vld: std_logic;




--SEven Seg
SIGNAL add_SS_out :STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
SIGNAL rf_val_SS :STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL BTNU_sig : STD_LOGIC;
SIGNAL BTNR_sig : STD_LOGIC;
SIGNAL BTNC_sig : STD_LOGIC;
begin

clk <= CLK50M;
rst <= BTNU_sig;

process(clk, rst)
begin

    if(rst = '1') then
        pc_curr <= x"00000000";
    elsif(rising_edge(clk)) then
        pc_curr <= pc_next;
    end if;    

end process;

imem_block: imem PORT MAP(
                            pc=>pc_curr,
                            instruction => inst
                            );
                            
control_unit_block: control_unit PORT MAP(
                        op=>inst(31 downto 26),
                        func=> inst(5 downto 0),
                        MemToReg=>memtoreg,
                        MemWrite=>wrt_en_mem,
                        Branch=>branch,
                        ALUControl=>alu_control,
                        ALUsrc=>alu_src,
                        RegDst=>reg_dst,
                        RegWrite=> reg_wrt,
                        stop => stop,
                        jump => jump
                        );                        

with reg_dst select
wrt_add_rf <= inst(15 downto 11) when '1',
              inst(20 downto 16) when others;
              
read_add_rf_1 <= inst(25 downto 21);
read_add_rf_2 <= inst(20 downto 16);
              
rf_block: register_file PORT MAP(
                            clk => clk ,
                            rst => RST,
                            reg_write_en=> reg_wrt,
                            reg_write_addr=>wrt_add_rf,
                            reg_write_data=>wrt_data_rf,
                            reg_read_addr_1=>read_add_rf_1,
                            reg_read_data_1=>read_data_rf_1,
                            reg_read_addr_2=>read_add_rf_2,
                            reg_read_data_2=>read_data_rf_2,
                            rf_out => rf_rom
);

--SIGN EXTENSION
with inst(15) select
tmp<="1111111111111111" when '1',
     "0000000000000000" when others;
sign_ext_imm<=tmp & inst(15 downto 0);

in_a <= read_data_rf_1;

with alu_src select
in_b <= read_data_rf_2 when '0',
        sign_ext_imm when others; 

alu_block: alu PORT MAP(
                   InA =>in_a,
                   InB =>in_b,
                   alu_control => alu_control,
                   rot_amt => inst(10 downto 7), 
                   zero => zero,
                   alu_result => alu_op
                );



dmem_block: dmem PORT MAP(
                    clk => clk,
                    rst => rst,
                    wrt_en => wrt_en_mem,
--                    mem_en => rd_en_mem,
                    addr => alu_op,
                    d_read => d_read,
                    d_write => read_data_rf_2(15 downto 0)
); 


BTNU_sig<=BTNU;

--BTNU_deb : debounce PORT MAP(
--                    clk => clk,
--                    reset_n => rst,
--                    button => BTNU,
--                    result => BTNU_sig );
                    
BTNR_deb : debounce PORT MAP(
                    clk => clk,
                    reset_n => rst,
                    button => BTNR,
                    result => BTNR_sig );
                    
BTNC_deb : debounce PORT MAP(
                    clk => clk,
                    reset_n => rst,
                    button => BTNC,
                    result => BTNC_sig );


--UART SECTION

--Port Map
uart_wrapper : uart_wrapper2 PORT MAP(
     CLK => clk,
     CPU_RESET=> BTNC_sig,
     USB_UART_TX=>UART_TXD_IN  ,
     USB_UART_RX2=> UART_RXD_OUT ,
     O_RX_OUT2=>O_RX_OUT2 ,
     O_RX_VLD2=> vld, 
     O_FRAME_ERROR2=> O_FRAME_ERROR2,
     -- RST: in std_logic;
     I_TX_DATA=> tx_data,
     --(* mark_debug = "true" *)     input  [07:0] I_TX_DATA,  // ///
     --(* mark_debug = "true" *)     input         I_TX_START, // ///
     I_TX_START=> tx_vld,
     O_BUSY2=> O_BUSY2
      );

--Recieve 32 bit Instruction from UART 
with rx_counter select
add_UART <= O_RX_OUT2 & add_UART(23 downto 0) when "00",
  add_UART(31 downto 24) & O_RX_OUT2 & add_UART(15 downto 0) when "01",
  add_UART(31 downto 16) & O_RX_OUT2 & add_UART(07 downto 0) when "10",
  add_UART(31 downto 08) & O_RX_OUT2  when "11",
  add_UART when others;

-- RX Counter
PROCESS(CLK50M, BTNC_sig) begin
if(rising_edge(CLK50M)) then
   if(BTNC_sig = '1') then
        add_UART_out <= x"00000000";
--        b_d <= x"00000000";
        rx_counter <= "00";
   elsif(vld = '1') then
        add_UART_out <= add_UART;
        rx_counter <= rx_counter + '1';
   end if;
   end if;
end process;

rf_val <= rf_rom(CONV_INTEGER(add_UART_out));

--With SW(0) select
--    inst <= add_UART_OUT when '1',
--            inst_temp when others;
            
--TX Counter (Needed if using to Output values to UART)
PROCESS(CLK50M,BTNC_sig) begin
if(rising_edge(CLK50M)) then
   if(BTNC_sig = '1') then 
        tx_counter <= "00";
   elsif(tx_vld = '1') then
        tx_counter <= tx_counter + '1';
   end if;
   end if;
end process;

--Controls Proper Delay between Data Pulses
PROCESS(CLK50M, BTNC_sig) begin
if(rising_edge(CLK50M)) then
   if(BTNC_sig = '1') then
        delay_counter <= x"FFFF";
   elsif(vld = '1') then
        delay_counter <= x"0000";
   elsif(delay_counter < x"FFFF") then
        delay_counter <= delay_counter + '1';
   end if;
   end if;
end process;

--Controls Transmit delay
process(delay_counter) begin
if(delay_counter = x"FFFE") then
    tx_start <= '1';
else 
    tx_start <= '0';
end if;
end process;

--Report if TX was successful
process(tx_start, uart_busy_d, tx_counter) begin
if((tx_start = '1') or ((uart_busy_d = '0') and (tx_counter /= "00"))) then
    tx_vld <= '1';
else 
    tx_vld <= '0';
end if;
end process;

--Reset UART
PROCESS(CLK50M, BTNC_sig) begin
if(rising_edge(CLK50M)) then
   if(BTNC_sig = '1') then
    uart_busy_d <= '1';
   else
    uart_busy_d <= O_BUSY2;
   end if;
   end if;
end process;

with tx_counter select
tx_data <= rf_val(31 downto 24) when "00",
  rf_val(23 downto 16) when "01",
  rf_val(15 downto 08) when "10",
  rf_val(07 downto 00) when "11",
  rf_val(31 downto 24) when others;

--UART SECTION END


--7 Segment
seven_seg: SevenSeg_Top PORT MAP(
                CLK => CLK,
                data_in => rf_val_ss,
                SSEG_CA => SSEG_CA,
                SSEG_AN => SSEG_AN 
                );
                
                
with SW(15 downto 11) select 
    rf_val_ss <= rf_rom(0) when "00000",
                 rf_rom(1) when "00001",
                 rf_rom(2) when "00010",
                 rf_rom(3) when "00011",
                 rf_rom(4) when "00100",
                 rf_rom(5) when "00101",
                 rf_rom(6) when "00110",
                 rf_rom(7) when "00111",
                 rf_rom(8) when "01000",
                 rf_rom(9) when "01001",
                 rf_rom(10) when "01010",
                 rf_rom(11) when "01011",
                 rf_rom(12) when "01100",
                 rf_rom(13) when "01101",
                 rf_rom(14) when "01110",
                 rf_rom(15) when "01111",
                 rf_rom(16) when "10000",
                 rf_rom(17) when "10001",
                 rf_rom(18) when "10010",
                 rf_rom(19) when "10011",
                 rf_rom(20) when "10100",
                 rf_rom(21) when "10101",
                 rf_rom(22) when "10110",
                 rf_rom(23) when "10111",
                 rf_rom(24) when "11000",
                 rf_rom(25) when "11001",
                 rf_rom(26) when "11010",
                 rf_rom(27) when "11011",
                 rf_rom(28) when "11100",
                 rf_rom(29) when "11101",
                 rf_rom(30) when "11110",
                 rf_rom(31) when "11111",
                 rf_rom(0) when OTHERS;
                 
                         

PROCESS(BTNR_sig,BTNU_sig) BEGIN
    IF (BTNR_sig'event AND BTNR_sig = '1') THEN add_SS_out <= add_SS_out + '1';
        if (add_SS_out=x"0000001f") then
            add_SS_out <= x"00000000";  
            end if;
    END IF;
    IF (BTNU_sig'event AND BTNU_sig = '0') THEN add_SS_out <= x"00000000"; END IF;
END PROCESS;

with memtoreg select
    wrt_data_rf <= alu_op when '0',
    x"0000" & d_read  when others;

process(branch, jump, clk, rst, stop)
begin
    if (stop = '1') then
        pc_next <= pc_curr;
    elsif (jump = '1') then
        pc_next <= pc_curr + x"00000004" + (inst(25) & inst(25) & inst(25) & inst(25) & inst(25 downto 0) & "00");
    elsif (branch = '1' and zero='1') then
        pc_next <= pc_curr + x"00000004" + ("00000000000000" & inst(15 downto 0) & "00");
    else
        pc_next <= pc_curr + x"00000004";
    end if;
end process;

--instr <= inst;
--pc_out <= pc_curr;
--dout <= alu_op;

end Behavioral;
