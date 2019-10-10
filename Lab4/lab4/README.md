# Description

This Vivado Project implements RC5 Encryption/Decryption. RC5 input: 2 32-bit data; output: 2 32-bit data. The Vivado version is 2017.3. It should work on any version above that. If not, create a new project and copy every file in the new project.

The left roate and right rotate function can be instantiated in file rc5_top.v to integrate with system.
Right now, the roate_FPGA module is declared for basys3 board with its constraints.
For nexsys4, change the ports of rotate_fpga.v and activate nexsys4.xdc file which is part fo the project.

Use tcl script for simulation.

------ Board file for Digilent Boards-----

* Github repo for Digilent boards: https://github.com/Digilent/vivado-boards

* Instructions for doanloading and configuring the board files in vivado: https://reference.digilentinc.com/vivado/installing-vivado/start

------------------------------------------

For UART connection, I use moserial software in linux. It is easy to transmit and receive hex vlaues in this software. One can use any softwar to transmit hex values.
UART configuration for software:
* Baud Rate --> 115200
* Data bits --> 8
* Stop bits --> 1
* Parity    --> none

**Hint**: check the functional simulation for different testcases.

**Example**: In the software transmit , "FFFFFFF FFFFFFFF" in hex, you should receive --> "D32B105B 8D38A6E3".
