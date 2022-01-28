`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module maindec(
	input wire[5:0] op, funct,
    input wire[4:0] rt,
     
    output wire sign_ext,   //是否为有符号拓展（1为是）
	output wire[1:0] memtoreg,
	output wire memwrite,
	output wire branch,alusrc,
	output wire[1:0] regdst,
	output wire regwrite,
	output wire hilowrite,
	output wire jump,jr,link,   //jump是否为无条件跳转指令，jr是否为jumpR指令，link是否跳转指令要连接寄存器
	output wire[4:0] aluop,
	output wire[1:0] memwrite_con, //写指令类型
	output wire[2:0] memread_con  //读指令类型
    );
    
	reg[22:0] controls;
	assign {sign_ext,regwrite,regdst,alusrc,branch,memwrite, memtoreg, jump,jr,link, hilowrite, aluop, memwrite_con, memread_con} = controls;
	always @(*) begin
		case (op)
			6'b000000: case(funct)
			    //虽然4条数据移位指令与4条乘除指令属于R型，但由于其与标准R型指令不同，所以要特判
                6'b010000: controls <= 23'b01_01_000_10_000_0_10000_00_000;//hi->rd
                6'b010010: controls <= 23'b01_01_000_11_000_0_10000_00_000;//lo->rd
                6'b010001: controls <= 23'b00_00_000_00_000_1_10000_00_000;//rs->hi
                6'b010011: controls <= 23'b00_00_000_00_000_1_10000_00_000;//rs->lo
                
                6'b011000: controls <= 23'b00_00_000_00_000_1_10000_00_000;//MULT
                6'b011001: controls <= 23'b00_00_000_00_000_1_10000_00_000;//MULTU
                6'b011010: controls <= 23'b00_00_000_00_000_1_10000_00_000;//DIV
                6'b011011: controls <= 23'b00_00_000_00_000_1_10000_00_000;//DIVU
                
                //此时PC＋８被并到Aluout中
                6'b001000: controls <= 23'b00_00_000_00_110_0_00000_00_000;//JR
                6'b001001: controls <= 23'b01_01_000_00_111_0_00000_00_000;//JalR
                
                default: controls <= 23'b01_01_000_00_000_0_10000_00_000;//标准R-TYRE，因为R型没有imm，所以是否为有符号拓展没影响
			endcase
			
			6'b000001: case(rt)
			    //因为4条分支指令在除了计算方面有不同，所以要特判
                5'b00000: controls <= 23'b10_00_010_00_000_0_01000_00_000;//Bltz
                5'b00001: controls <= 23'b10_00_010_00_000_0_01000_00_000;//Bgez
                5'b10000: controls <= 23'b11_10_010_00_001_0_01000_00_000;//Bltzal
                5'b10001: controls <= 23'b11_10_010_00_001_0_01000_00_000;//Bgezal
                
                default: controls <= 23'b00_00_000_00_000_0_00000_00_000;//illegal
			endcase
			6'b001100:controls <= 23'b01_00_100_00_000_0_00001_00_000;//ANDI
			6'b001110:controls <= 23'b01_00_100_00_000_0_00010_00_000;//XORI
			6'b001101:controls <= 23'b01_00_100_00_000_0_00011_00_000;//ORI
			6'b001111:controls <= 23'b01_00_100_00_000_0_00100_00_000;//LUI
			
			6'b100011:controls <= 23'b11_00_100_01_000_0_00000_00_000;//LW
			6'b100001:controls <= 23'b11_00_100_01_000_0_00000_00_001;//LH
			6'b100101:controls <= 23'b11_00_100_01_000_0_00000_00_101;//LHU
			6'b100000:controls <= 23'b11_00_100_01_000_0_00000_00_010;//LB
			6'b100100:controls <= 23'b11_00_100_01_000_0_00000_00_110;//LBU
			
			6'b101011:controls <= 23'b10_00_101_00_000_0_00000_01_000;//SW
			6'b101001:controls <= 23'b10_00_101_00_000_0_00000_10_000;//SH
			6'b101000:controls <= 23'b10_00_101_00_000_0_00000_11_000;//SB
			
			//{sign_ext,regwrite,regdst,alusrc,branch,memwrite, memtoreg, jump,jr,link, hilowrite, aluop, memwrite_con, memread_con}
			6'b000100:controls <= 23'b10_00_010_00_000_0_01000_00_000;//BEQ
			6'b000111:controls <= 23'b10_00_010_00_000_0_01000_00_000;//Bgtz
			6'b000110:controls <= 23'b10_00_010_00_000_0_01000_00_000;//Blez
			6'b000101:controls <= 23'b10_00_010_00_000_0_01000_00_000;//BNE
			
			6'b001000:controls <= 23'b11_00_100_00_000_0_00000_00_000;//ADDI
			6'b001001:controls <= 23'b11_00_100_00_000_0_00101_00_000;//ADDIU
			6'b001010:controls <= 23'b11_00_100_00_000_0_00110_00_000;//SLTI
			6'b001011:controls <= 23'b11_00_100_00_000_0_00111_00_000;//SLTIU
			
			6'b000010:controls <= 23'b10_00_000_00_100_0_00000_00_000;//J
			6'b000011:controls <= 23'b11_10_000_00_101_0_00000_00_000;//Jal
			
			default:  controls <= 23'b00_00_000_00_000_0_00000_00_000;//illegal op
		endcase
	end
endmodule
