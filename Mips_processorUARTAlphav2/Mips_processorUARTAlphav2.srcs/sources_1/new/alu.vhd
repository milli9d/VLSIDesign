----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2019 07:53:26 PM
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is  
    Port ( InA: in STD_LOGIC_VECTOR (31 downto 0);
           InB : in STD_LOGIC_VECTOR (31 downto 0);
           alu_control : in STD_LOGIC_VECTOR (2 downto 0);
           rot_amt: in STD_LOGIC_VECTOR (3 downto 0);
           zero: out STD_LOGIC;
           alu_result: out STD_LOGIC_VECTOR(31 DOWNTO 0));--The result of the ALU operation);
end alu;

architecture Behavioral of alu is
signal leftRotate: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal rightRotate: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal srcA: STD_LOGIC_VECTOR(31 downto 0);
signal srcB: STD_LOGIC_VECTOR(31 downto 0);
begin


with alu_control select
srcA <= (InA xor InB) when "011",
        (InA - InB) when "110",
         InA when others;

srcB <= InB;


--- Left Rotate ---
WITH rot_amt SELECT
leftRotate<= srcA(30 DOWNTO 0) & srcA(31) WHEN x"1",
srcA(29 DOWNTO 0) & srcA(31 DOWNTO 30) WHEN x"2",
srcA(28 DOWNTO 0) & srcA(31 DOWNTO 29) WHEN x"3",
srcA(27 DOWNTO 0) & srcA(31 DOWNTO 28) WHEN x"4",
srcA(26 DOWNTO 0) & srcA(31 DOWNTO 27) WHEN x"5",
srcA(25 DOWNTO 0) & srcA(31 DOWNTO 26) WHEN x"6",
srcA(24 DOWNTO 0) & srcA(31 DOWNTO 25) WHEN x"7",
srcA(23 DOWNTO 0) & srcA(31 DOWNTO 24) WHEN x"8",
srcA(22 DOWNTO 0) & srcA(31 DOWNTO 23) WHEN x"9",
srcA(21 DOWNTO 0) & srcA(31 DOWNTO 22) WHEN x"A",
srcA(20 DOWNTO 0) & srcA(31 DOWNTO 21) WHEN x"B",
srcA(19 DOWNTO 0) & srcA(31 DOWNTO 20) WHEN x"C",
srcA(18 DOWNTO 0) & srcA(31 DOWNTO 19) WHEN x"D",
srcA(17 DOWNTO 0) & srcA(31 DOWNTO 18) WHEN x"E",
srcA(16 DOWNTO 0) & srcA(31 DOWNTO 17) WHEN x"F",
srcA WHEN OTHERS;

----Right rotate-----
WITH rot_amt SELECT
rightRotate<= srcA(0) & srcA(31 DOWNTO 1) WHEN x"1",     
srcA(1 DOWNTO 0) & srcA(31 DOWNTO 2) WHEN x"2",      
srcA(2 DOWNTO 0) & srcA(31 DOWNTO 3) WHEN x"3",      
srcA(3 DOWNTO 0) & srcA(31 DOWNTO 4) WHEN x"4",      
srcA(4 DOWNTO 0) & srcA(31 DOWNTO 5) WHEN x"5",      
srcA(5 DOWNTO 0) & srcA(31 DOWNTO 6) WHEN x"6",      
srcA(6 DOWNTO 0) & srcA(31 DOWNTO 7) WHEN x"7",      
srcA(7 DOWNTO 0) & srcA(31 DOWNTO 8) WHEN x"8",      
srcA(8 DOWNTO 0) & srcA(31 DOWNTO 9) WHEN x"9",      
srcA(9 DOWNTO 0) & srcA(31 DOWNTO 10) WHEN x"A",     
srcA(10 DOWNTO 0) & srcA(31 DOWNTO 11) WHEN x"B",      
srcA(11 DOWNTO 0) & srcA(31 DOWNTO 12) WHEN x"C",      
srcA(12 DOWNTO 0) & srcA(31 DOWNTO 13) WHEN x"D",      
srcA(13 DOWNTO 0) & srcA(31 DOWNTO 14) WHEN x"E",      
srcA(14 DOWNTO 0) & srcA(31 DOWNTO 15) WHEN x"F",       
srcA WHEN OTHERS;


with ALU_Control select 
alu_result<=     srcA and srcB when "000",
                 srcA or srcB when "001",
                 srcA nor srcB when "010",
                 leftRotate when "011",
                 (rightRotate xor srcB) when "100",
                 (leftRotate + srcB) when "101",
                 rightRotate when "110",
                 srcA + srcB when "111",
                 srcA + srcB when others;



zero <= '1' when (ALU_Control = "000" AND (srcA < srcB)) else
        '1' when (ALU_Control = "001" AND (srcA = srcB)) else
        '1' when (ALU_Control = "010" AND (srcA /= srcB)) else
        '0';
                    
end Behavioral;
