----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2019 08:48:14 PM
-- Design Name: 
-- Module Name: dmem - Behavioral
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dmem is
  Port (   clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           wrt_en : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (31 downto 0);
           d_read : out STD_LOGIC_VECTOR (15 downto 0);
           d_write : in STD_LOGIC_VECTOR (15 downto 0)
  );
end dmem;

architecture Behavioral of dmem is
--Define RAM as 128x16bits
TYPE ram is ARRAY (127 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
SIGNAL dmem : ram := (  0 => x"9bbb",
                        1 => x"d8c8",
                        2 => x"1a37",
                        3 => x"f7fb",
                        4 => x"46f8",
                        5 => x"E8C5", 
                        6 => x"460C", 
                        7 => x"6085",
                        8 => x"70F8", 
                        9 => x"3B8A", 
                        10 => x"284B", 
                        11 => x"8303", 
                        12 => x"513E", 
                        13 => x"1454", 
                        14 => x"F621", 
                        15 => x"ED22",
                        16 => x"3125", 
                        17 => x"065D", 
                        18 => x"11A8", 
                        19 => x"3A5D", 
                        20 => x"D427", 
                        21 => x"686B", 
                        22 => x"713A", 
                        23 => x"D82D",
                        24 => x"4B79", 
                        25 => x"2F99", 
                        26 => x"2799", 
                        27 => x"A4DD", 
                        28 => x"A790", 
                        29 => x"1C49", 
                        30 => x"DEDE", 
                        31 => x"871A",
                        32 => x"36C0", 
                        33 => x"3196", 
                        34 => x"A7EF", 
                        35 => x"C249", 
                        36 => x"61A7", 
                        37 => x"8BB8", 
                        38 => x"3B0A", 
                        39 => x"1D2B",
                        40 => x"4DBF", 
                        41 => x"CA76", 
                        42 => x"AE16", 
                        43 => x"2167", 
                        44 => x"30D7", 
                        45 => x"6B0A", 
                        46 => x"4319", 
                        47 => x"2304",
                        48 => x"F6CC", 
                        49 => x"1431", 
                        50 => x"6504", 
                        51 => x"6380",
                        52 => x"fedc",
                        53 => x"ba98",
                        54 => x"7654",
                        55 => x"3210",
                        others => (others => '0'));

begin

    PROCESS(clk,wrt_en,addr,d_write,rst)                            
        begin
        if ((addr <= x"7F") ) then
        --    When Write is Disabled
            if (wrt_en='0')then
                --    Read From address in bits Addr[10:4]
                d_read(15 downto 0) <= dmem(CONV_INTEGER(unsigned(addr(31 downto 0))));        --Upper 16 Bits (Big Endian)
            --    When Write is ENabled
            elsif (wrt_en='1')then
                dmem(CONV_INTEGER(unsigned(addr(31 downto 0))))<=d_write(15 downto 0);         --Upper 16 bits (Big Endian)
            end if;
    end if;    
end process;

end Behavioral;
