----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Deepraj
-- 
-- Create Date: 10/10/2018 01:05:02 AM
-- Design Name: 
-- Module Name: RC5_TOP - Behavioral
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity rc5_top is
    Port ( 
           CLK100MHZ : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           UART_TXD_IN : in STD_LOGIC;
           UART_RXD_OUT : out STD_LOGIC);
end rc5_top;

architecture Behavioral of rc5_top is
signal CLK50MHZ: std_logic;
signal tx_vld: std_logic;
signal a: std_logic_vector(31 downto 0);
signal b: std_logic_vector(31 downto 0);
signal c: std_logic_vector(63 downto 0);
signal  o_rx_out: std_logic_vector(7 downto 0);
signal   tx_data: std_logic_vector(7 downto 0);
signal   tx_data2: std_logic_vector(7 downto 0);
signal o_frame_error: std_logic;
signal uart_busy: std_logic;
signal uart_busy_d: std_logic;
signal vld: std_logic;
signal vld1: std_logic;
signal k1:std_logic;
signal k1_d:std_logic;
signal rx_counter: std_logic_vector(2 downto 0);
signal tx_counter: std_logic_vector(2 downto 0);
signal tx_start: std_logic;
signal delay_counter: std_logic_vector(15 downto 0);

signal i_counter: std_logic_vector (3 downto 0);
signal a_d: std_logic_vector(31 downto 0);
signal b_d: std_logic_vector(31 downto 0);

component rc5 port(
    clr1: in std_logic;
    clk1: in std_logic;
    di_vld: in std_logic;
    din1: in std_logic_vector(31 downto 0);
    din2: in std_logic_vector(31 downto 0);
    do_vld: out std_logic;
    dout: out std_logic_vector(63 downto 0)
    );
end component;

component clk_wiz_0 port(
  clk_out1 : out std_logic;
  clk_in1: in std_logic
 );
end component;

--component SevenSeg_Top is
--    Port ( 
--           CLK 			: in  STD_LOGIC;
--           data_in      : in   STD_LOGIC_VECTOR (31 downto 0);
--           alphabet     : in  STD_LOGIC;
--           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0);
--           SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0)
--			);
--end component;
component debounce port(
    clk     : IN  STD_LOGIC;  --input clock
    reset_n : IN  STD_LOGIC;  --asynchronous active low reset
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal

end component;
component uart_wrapper2 port(
 CLK: in std_logic;
CPU_RESET: in std_logic;
USB_UART_TX: in std_logic;
USB_UART_RX2: out std_logic;
O_RX_OUT2: out std_logic_vector(7 downto 0);
O_RX_VLD2: out std_logic;
O_FRAME_ERROR2: out std_logic;
I_TX_DATA: in std_logic_vector(7 downto 0);
I_TX_START: in std_logic;
O_BUSY2: out std_logic
 );
    end component;

begin
vld <= '1' when (vld1 = '1') else '0';


clk_divider_inst: clk_wiz_0 port map(
  clk_out1 => CLK50MHZ,
  clk_in1 => CLK100MHZ
 );

u_uart_wrapper: uart_wrapper2 port map(
    CLK           => CLK50MHZ       ,
    CPU_RESET     => BTNC   ,
    USB_UART_TX   => UART_TXD_IN   ,
    USB_UART_RX2   => UART_RXD_OUT  ,
    O_RX_OUT2      => o_rx_out      , 
    O_RX_VLD2      => vld1      ,
    O_FRAME_ERROR2 => o_frame_error ,
    I_TX_DATA     => tx_data ,
    I_TX_START    => tx_vld,
    O_BUSY2        => uart_busy     
    );

PROCESS(CLK50MHZ) 
BEGIN
IF(CLK50MHZ'EVENT AND CLK50MHZ='1') THEN
 IF(BTNC='1') THEN 
   i_counter<="0000";
 ELSIF(i_counter="1101") THEN
   i_counter<="1101";
 ELSE
   i_counter<=i_counter+'1';
 END IF;
END IF;
END PROCESS;

with rx_counter select
a <= o_rx_out & a(23 downto 0) when "000",
  a(31 downto 24) & o_rx_out & a(15 downto 0) when "001",
  a(31 downto 16) & o_rx_out & a(07 downto 0) when "010",
  a(31 downto 08) & o_rx_out  when "011",
  a when others;

with rx_counter select
  b <= o_rx_out & b(23 downto 0) when "100",
    b(31 downto 24) & o_rx_out & b(15 downto 0) when "101",
    b(31 downto 16) & o_rx_out & b(07 downto 0) when "110",
    b(31 downto 08) & o_rx_out  when "111",
    b when others;


PROCESS(CLK50MHZ, BTNC) begin
if(rising_edge(CLK50MHZ)) then
   if(BTNC = '1') then
        a_d <= x"00000000";
        b_d <= x"00000000";
        rx_counter <= "000";
   elsif(vld1 = '1') then
        a_d <= a;
        b_d <= b;
        rx_counter <= rx_counter + '1';
   end if;
   end if;
end process;

PROCESS(CLK50MHZ, BTNC) begin
if(rising_edge(CLK50MHZ)) then
   if(BTNC = '1') then
        k1_d <= '0';
   else
        k1_d<= k1;
   end if;
   end if;
end process;


PROCESS(CLK50MHZ, BTNC) begin
if(rising_edge(CLK50MHZ)) then
   if(BTNC = '1') then
        delay_counter <= x"FFFF";
   elsif(vld = '1') then
        delay_counter <= x"0000";
   elsif(delay_counter < x"FFFF") then
        delay_counter <= delay_counter + '1';
   end if;
   end if;
end process;


process(delay_counter) begin
if(delay_counter = x"FFFE") then
    tx_start <= '1';
else 
    tx_start <= '0';
end if;
end process;

process(tx_start, uart_busy_d, tx_counter) begin
--if((tx_start = '1') or ((uart_busy_d = '0') and (tx_counter /= "000")) )  then
if((k1_d = '1') or ((uart_busy_d = '0') and (tx_counter /= "000")) )  then
    tx_vld <= '1';
else 
    tx_vld <= '0';
end if;
end process;

PROCESS(CLK50MHZ, BTNC) begin
if(rising_edge(CLK50MHZ)) then
   if(BTNC = '1') then
    uart_busy_d <= '1';
   else
    uart_busy_d <= uart_busy;
   end if;
   end if;
end process;

with tx_counter select
tx_data <= c(63 downto 56) when "000",
  c(55 downto 48) when "001",
  c(47 downto 40) when "010",
  c(39 downto 32) when "011",
  c(31 downto 24) when "100",
  c(23 downto 16) when "101",
  c(15 downto 08) when "110",
  c(07 downto 00) when "111",
  c(63 downto 56) when others;

PROCESS(CLK50MHZ,BTNC) begin
if(rising_edge(CLK50MHZ)) then
   if(BTNC = '1') then 
        tx_counter <= "000";
   elsif(tx_vld = '1') then
        tx_counter <= tx_counter + '1';
   end if;
   end if;
end process;

rc5_inst: rc5 port map(
    clr1 => BTNC,
    clk1 => CLK50MHZ,
    di_vld => tx_start,
    din1    =>  b_d,
    din2 => a_d ,
    do_vld => k1,
    dout =>  c
);

end Behavioral;
