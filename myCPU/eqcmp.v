`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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

module eqcmp(
	input wire [31:0] a,b, //a=rs,b=rt
	input wire [5:0] op,
	input wire [4:0] rt,   //需要借助rt判断指令类型
	output wire y
    );

	assign y = (op == 6'b000100) ? (a == b):      //BEQ
	           (op == 6'b000101) ? (a != b):      //BNE
	           (op == 6'b000111) ? ((a[31] == 1'b0) && (a != 32'b0)):     //BGTZ,a>0
	           (op == 6'b000110) ? ((a[31] == 1'b1) || (a == 32'b0)):     //BLEZ,a<=0
	           ((op == 6'b000001) && ((rt == 5'b00001) || (rt == 5'b10001))) ? (a[31] == 1'b0):    //BGEZ,a>=0
	           ((op == 6'b000001) && ((rt == 5'b00000) || (rt == 5'b10000))) ? (a[31] == 1'b1):    //BLTZ,a<0
	           1'b0;
endmodule
