----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2019 05:50:24 PM
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- ALU Control signals
--000 -> AND
--001 -> OR
--010 -> NOR
--011 -> XRLR
--100 -> RRXR
--101 -> LRAD
--110 -> SBRR
--111 -> ADD

--Control signals for branch
--000 -> BLT
--001 -> BEQ
--010 -> BNE
--011 -> JMP

entity control_unit is
Port (
    op: in std_logic_vector(5 downto 0);
    func: in std_logic_vector(5 downto 0);
    MemToReg: out std_logic; -- mem data write to register 1-> from data mem 0 -> from alu
    MemWrite: out std_logic; -- 1-> write to mem 0-> don't write
    Branch: out std_logic; -- 1-> check if branch 0-> no branch
    ALUControl: out std_logic_vector(2 downto 0); -- ALU operation
    ALUsrc: out std_logic; -- 1 -> sign extended b_reg 0-> normal b_reg
    RegDst: out std_logic; -- 0 -> I type instruction dest reg 1-> R type instruction dest reg
    RegWrite: out std_logic; -- reg write enable
    stop: out std_logic;
    jump: out std_logic
  );
end control_unit;

architecture Behavioral of control_unit is

begin

process(op, func)
begin
stop <= '0';
jump <= '0';
case op is
    when "000011" => --ANDI
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '0';
        ALUControl <= "000";
        ALUsrc <= '1';
        RegDst <= '0';
        RegWrite <= '1';
        
    when "000100" => --ORI
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '0';
        ALUControl <= "001";
        ALUsrc <= '1';
        RegDst <= '0';
        RegWrite <= '1';
    when "000111" => --LW
        MemToReg <= '1';
        MemWrite <= '0';
        Branch <= '0';
        ALUControl <= "111";
        ALUsrc <= '1';
        RegDst <= '0';
        RegWrite <= '1'; 
        
    when "001000" => --SW
        MemToReg <= '0';
        MemWrite <= '1';
        Branch <= '0';
        ALUControl <= "111";
        ALUsrc <= '1';
        RegDst <= '0';
        RegWrite <= '0';
        
    when "001001" => --BLT
        MemToReg <= '0';
        MemWrite <='0';
        Branch <='1';
        ALUControl <="000";
        ALUsrc <='0';
        RegDst <='0';
        RegWrite <= '0';
    
    when "001010" => --BEQ
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '1';
        ALUControl <="001";
        ALUsrc <='0';
        RegDst <='0';
        RegWrite <= '0';
        
    when "001011" => --BNE
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '1';
        ALUControl <="010";
        ALUsrc <='0';
        RegDst <='0';
        RegWrite <= '0';

    when "001100" => --JMP
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '1';
        ALUControl <="011";
        ALUsrc <='1';
        RegDst <='0';
        RegWrite <= '0'; 
        jump <= '1';
    
    when "111111" => --halt
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '1';
        ALUControl <="011";
        ALUsrc <='1';
        RegDst <='0';
        RegWrite <= '0';   
        stop <= '1';
    
    when "000000" => -- R Type Instructions
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '0';
        ALUsrc <='0';
        RegDst <='1';
        RegWrite <= '1';
     case func is 
        when "010010" => --AND
            ALUControl <= "000"; 
        when "010011" => --OR
            ALUControl <= "001";
        when "010100" => --NOR
            ALUControl <= "010";
        when "010000" => --XRLR
            ALUControl <= "011";
        when "010001" => --RRLR
            ALUControl <= "100";
        when "010101" => --LRAD
            ALUControl <= "101";
        when "010110" => --SBRR
            ALUControl <= "110";
        when others=> -- ADD
            ALUControl <= "111";
        end case;  
        
    when others=> --default
        MemToReg <= '0';
        MemWrite <= '0';
        Branch <= '1';
        ALUControl <="011";
        ALUsrc <='1';
        RegDst <='0';
        RegWrite <= '0';                                      
end case;
end process;



end Behavioral;
