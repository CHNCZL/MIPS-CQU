`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire[5:0] opD,functD,
	input wire[4:0] rtD,
	output wire pcsrcD,branchD,equalD,jumpD,jrD,linkD,
	output wire sign_extD,
	
	//execute stage
	input wire flushE,stallE,
	output wire[1:0] memtoregE,regdstE,
	output wire alusrcE,regwriteE,	
	output wire[4:0] alucontrolE,
    output wire linkE,
	//mem stage
	output wire[1:0] memtoregM,
	output wire memwriteM, regwriteM, hilowriteM,
	output wire[1:0] memwrite_conM,
	output wire[2:0] memread_conM, 
	//write back stage
	output wire[1:0] memtoregW,
	output wire regwriteW

    );
	
	//decode stage
	wire[4:0] aluopD;
	wire[1:0] memtoregD; 
	wire memwriteD, alusrcD, regwriteD, hilowriteD;
	wire[1:0] regdstD;
	wire[4:0] alucontrolD;
	wire[1:0] memwrite_conD;
	wire[2:0] memread_conD;
	
	//execute stage
	wire memwriteE,hilowriteE;
	wire[1:0] memwrite_conE;
	wire[2:0] memread_conE;

	maindec md(
		opD,functD,
		rtD,
		//output
		sign_extD,
		memtoregD,
		memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		hilowriteD,
		jumpD,jrD,linkD,
		aluopD,
		memwrite_conD,
		memread_conD
		);
		
	aludec ad(functD,aluopD,alucontrolD);

	assign pcsrcD = branchD & equalD;  //是分支且相等才跳转

	//pipeline registers,当拓宽ALUcontrol信号的时候也要拓宽
	flopenrc #(19) regE(
		clk,
		rst,
		~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,hilowriteD,alucontrolD,memwrite_conD,memread_conD,linkD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,hilowriteE,alucontrolE,memwrite_conE,memread_conE,linkE}
		);
	flopr #(10) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE,hilowriteE,memwrite_conE,memread_conE},
		{memtoregM,memwriteM,regwriteM,hilowriteM,memwrite_conM,memread_conM}
		);
	flopr #(8) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
