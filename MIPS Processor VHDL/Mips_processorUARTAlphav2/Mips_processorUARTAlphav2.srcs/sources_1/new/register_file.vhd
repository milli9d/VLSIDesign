----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2019 05:33:40 PM
-- Design Name: 
-- Module Name: imem - Behavioral
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
USE IEEE.numeric_std.all;  
use work.header_pk.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
  Port ( 
         clk,rst: in std_logic;
         reg_write_en: in std_logic;
         reg_write_addr: in std_logic_vector(4 downto 0);
         reg_write_data: in std_logic_vector(31 downto 0);
         reg_read_addr_1: in std_logic_vector(4 downto 0);
         reg_read_data_1: out std_logic_vector(31 downto 0);
         reg_read_addr_2: in std_logic_vector(4 downto 0);
         reg_read_data_2: out std_logic_vector(31 downto 0);
         rf_out : out registers
  );
end register_file;

architecture Behavioral of register_file is

-- 32 Register Array(32-bits each) 

signal reg_arr_signal:
registers:=registers'(x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000",
x"00000000", x"00000000", x"00000000", x"00000000");

begin

    rf_out <= reg_arr_signal;

    process(clk,rst) 
    begin
    if(rst='1') then
        reg_arr_signal(0) <= x"00000000";
        reg_arr_signal(1) <= x"4dcc5c5b";
        reg_arr_signal(2) <= x"b78427c0";
        reg_arr_signal(3) <= x"00000000";
        reg_arr_signal(4) <= x"00000000";
        reg_arr_signal(5) <= x"00000000";
        reg_arr_signal(6) <= x"00000000";
        reg_arr_signal(7) <= x"00000000";
        reg_arr_signal(8) <= x"00000000";
        reg_arr_signal(9) <= x"00000000";
        reg_arr_signal(10) <= x"00000000";
        reg_arr_signal(11) <= x"00000000";
        reg_arr_signal(12) <= x"00000000";
        reg_arr_signal(13) <= x"00000000";
        reg_arr_signal(14) <= x"00000000";
        reg_arr_signal(15) <= x"00000000";
        reg_arr_signal(16) <= x"00000000";
        reg_arr_signal(17) <= x"00000000";
        reg_arr_signal(18) <= x"00000000";
        reg_arr_signal(19) <= x"00000000";
        reg_arr_signal(20) <= x"00000000";
        reg_arr_signal(21) <= x"00000000";
        reg_arr_signal(22) <= x"00000000";
        reg_arr_signal(23) <= x"00000000";
        reg_arr_signal(24) <= x"00000000";
        reg_arr_signal(25) <= x"00000000";
        reg_arr_signal(26) <= x"00000000";
        reg_arr_signal(27) <= x"00000000";
        reg_arr_signal(28) <= x"00000000";
        reg_arr_signal(29) <= x"00000000";
        reg_arr_signal(30) <= x"00000000";
        reg_arr_signal(31) <= x"00000000";
    elsif(rising_edge(clk)) then
--        R0 is read-only
        if(reg_write_en='1' and reg_write_addr /= "00000") then
            reg_arr_signal(to_integer(unsigned(reg_write_addr))) <= reg_write_data;
        end if;
    end if;
    end process;

          
--Transfer data to Output ports
    reg_read_data_1 <= reg_arr_signal(to_integer(unsigned(reg_read_addr_1)));
    reg_read_data_2 <= reg_arr_signal(to_integer(unsigned(reg_read_addr_2)));

end Behavioral;
