`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire sign_extD,  //是否做有符号拓展
	input wire pcsrcD,branchD,
	input wire jumpD,jrD,linkD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire[4:0] rtD,
	//execute stage
	input wire[1:0] memtoregE,regdstE,
	input wire alusrcE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	input wire linkE,
	output wire flushE,stallE,
	//mem stage
	input wire[1:0] memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	input wire hilowriteM,
	input wire[2:0] memread_conM,
	//writeback stage
	input wire[1:0] memtoregW,
	input wire regwriteW,
	//sram debug
	output wire[31:0] pcW,
	output wire[4:0] writeregW,
	output wire[31:0] resultW
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD;
	//decode stage
	wire [31:0] pcplus4D,instrD,pcplus8D;
	wire [1:0] forwardaD,forwardbD;
	wire [4:0] rsD,rdD,saD;    //在译码阶段从指令中直接获取
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire [31:0] pcplus8E;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE,saE;
	wire [4:0] writeregE;  //写入哪个寄存器
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE,aluout2E;  //aluout2E表明了最终输出为alu结果还是pc+8
	wire [31:0] hiE,loE;
	wire [31:0] hi_inE,lo_inE;
	wire [31:0] resultM;
	wire [63:0] hilooutE;
	//mem stage
	wire [4:0] writeregM;
	wire [31:0] hiM,loM;
	wire [31:0] hi_inM,lo_inM;
	wire [31:0] True_readdataM;
	//writeback stage
	wire [31:0] aluoutW,readdataW;
	wire [31:0] hiW,loW;
	
    //for sram debug
    wire [31:0] pcD,pcE,pcM;
    
	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		branchD,
		forwardaD,forwardbD,
		stallD,
		//execute stage
		stall_divE,   //由于除法而进行的阻塞
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		forwardaE,forwardbE,
		flushE,stallE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		//write back stage
		writeregW,
		regwriteW
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);  //判断下一条指令是否来自branch
	mux4 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],instrD[25:0],2'b00},32'b0,srca2D,{jrD,jumpD},pcnextFD);  //判断下一条指令是否来自jump

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	//hilo reg(在MEM上升沿写，EXE读)
	hilo HL(clk,rst,hilowriteM,hi_inM,lo_inM,hiE,loE);
	
	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);    //PC+4
	
	//decode stage
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	
	signext se(instrD[15:0], sign_extD, signimmD); //立即数拓展模块
	sl2 immsh(signimmD,signimmshD);                //左移两位模块
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	adder pcadd3(pcplus4D,32'b100,pcplus8D);//PC+8
	
	mux4 #(32) forwardamux(srcaD,aluout2E,resultM,resultW,forwardaD,srca2D);
	mux4 #(32) forwardbmux(srcbD,aluout2E,resultM,resultW,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);  //equalD为是否满足条件

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];

	//execute stage
	//ID_EX寄存器
	flopenrc #(32) r1E(clk,rst,~stallE, flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE, flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE, flushE,signimmD,signimmE);
	
	flopenrc #(5) r4E(clk,rst,~stallE, flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE, flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE, flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE, flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE, flushE,pcD,pcE);
	flopenrc #(32) r9E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	
	
    //ALU数据来源的数据冒险处理
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);    //判断源操作数b输入
	ALU_v1 alu(clk,rst,srca2E,srcb3E,alucontrolE,saE, aluoutE, hilooutE, stall_divE);    //ALU模块
	mux3 #(5) waddrmux(rtE,rdE,5'b11111,regdstE,writeregE);    //判断目的寄存器位置
	mux2 #(32) PC8_mux(aluoutE, pcplus8E, linkE, aluout2E);
    assign hi_inE = ((alucontrolE==5'b11111) || (alucontrolE==5'b01111) || (alucontrolE==5'b01110) || (alucontrolE==5'b11110))? 
                    hilooutE[63:32] : aluoutE;  //决定hi的输入来自乘除法还是数据移动
    assign lo_inE = ((alucontrolE==5'b11111) || (alucontrolE==5'b01111) || (alucontrolE==5'b01110) || (alucontrolE==5'b11110))? 
                    hilooutE[31:0] : aluoutE;  //决定lo的输入来自乘除法还是数据移动
	
	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluout2E,aluoutM);
	flopr #(32) r3M(clk,rst,hiE,hiM);
	flopr #(32) r4M(clk,rst,loE,loM);
	flopr #(32) r5M(clk,rst,hi_inE,hi_inM);
	flopr #(32) r6M(clk,rst,lo_inE,lo_inM);
	flopr #(5) r7M(clk,rst,writeregE,writeregM);
	flopr #(32) r8M(clk,rst,pcE,pcM);
	
	data_mux Rdata_mux(readdataM, memread_conM, aluoutM, True_readdataM);
	mux4 #(32) ResultMuxM(aluoutM,True_readdataM,hiM,loM, memtoregM,resultM);//在生成一遍

	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,True_readdataM,readdataW);
	flopr #(32) r3W(clk,rst,hiM,hiW);
	flopr #(32) r4W(clk,rst,loM,loW);
	flopr #(5) r5W(clk,rst,writeregM,writeregW);
	flopr #(32) r6W(clk,rst,pcM,pcW);
	
	mux4 #(32) ResultMuxW(aluoutW,readdataW,hiW,loW, memtoregW,resultW);
endmodule
