----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2019 06:20:14 PM
-- Design Name: 
-- Module Name: header_pk - Behavioral
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

package header_pk is

constant InstLength : integer := 219; ----- number of instructions 

type registers is array (0 to 31 ) of std_logic_vector (31 downto 0);

type i_mem IS ARRAY (0 TO InstLength) of std_logic_vector(7 downto 0);

TYPE d_mem is ARRAY (127 downto 0) of STD_LOGIC_VECTOR(15 downto 0);

component imem 
    Port(
        pc: in std_logic_vector(31 downto 0);
        instruction: out std_logic_vector(31 downto 0)
    );
end component;


component debounce 
   PORT(
    clk     : IN  STD_LOGIC;  --input clock
    reset_n : IN  STD_LOGIC;  --asynchronous active low reset
    button  : IN  STD_LOGIC;  --input signal to be debounced
    result  : OUT STD_LOGIC); --debounced signal
END Component;


component SevenSeg_Top PORT(
           CLK 			: in  STD_LOGIC;
           data_in      : in   STD_LOGIC_VECTOR (31 downto 0);
           SSEG_CA 		: out  STD_LOGIC_VECTOR (7 downto 0); 
           SSEG_AN 		: out  STD_LOGIC_VECTOR (7 downto 0) 
);
end component;

component uart_wrapper2
 Port (
 CLK: in std_logic;
 CPU_RESET: in std_logic;
 USB_UART_TX: in std_logic;
 USB_UART_RX2: out std_logic;
 O_RX_OUT2: out std_logic_vector(7 downto 0);
 O_RX_VLD2: out std_logic;
 O_FRAME_ERROR2: out std_logic;
-- RST: in std_logic;
 I_TX_DATA: in std_logic_vector(7 downto 0);
--(* mark_debug = "true" *)     input  [07:0] I_TX_DATA,  // ///
--(* mark_debug = "true" *)     input         I_TX_START, // ///
I_TX_START: in std_logic;
  O_BUSY2: out std_logic );
end component;


component register_file 
  Port ( clk,rst: in std_logic;
         reg_write_en: in std_logic;
         reg_write_addr: in std_logic_vector(4 downto 0);
         reg_write_data: in std_logic_vector(31 downto 0);
         reg_read_addr_1: in std_logic_vector(4 downto 0);
         reg_read_data_1: out std_logic_vector(31 downto 0);
         reg_read_addr_2: in std_logic_vector(4 downto 0);
         reg_read_data_2: out std_logic_vector(31 downto 0);
         rf_out : out registers
        );
end component;

component alu 
    Port ( InA: in STD_LOGIC_VECTOR (31 downto 0);
           InB : in STD_LOGIC_VECTOR (31 downto 0);
           alu_control : in STD_LOGIC_VECTOR (2 downto 0);
           rot_amt: in STD_LOGIC_VECTOR (3 downto 0);
           zero: out STD_LOGIC;
           alu_result: out STD_LOGIC_VECTOR(31 DOWNTO 0));--The result of the ALU operation);
end component ;

component control_unit 
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
  end component;

component dmem 
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           wrt_en : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR (31 downto 0);
           d_read : out STD_LOGIC_VECTOR (15 downto 0);
           d_write : in STD_LOGIC_VECTOR (15 downto 0));
end component ;

end header_pk;

