`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/03 18:13:21
// Design Name: 
// Module Name: ALU_v1
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

module ALU_v1(
    input wire clk, rst,
	input wire[31:0] a,b,  //a=rs, b=rt
	input wire[4:0] op,    //其实是ALUcontrol 
	input wire[4:0] sa,    //五位的shamt
	
	output reg[31:0] y,
	output reg[63:0] hilo_out, //专门用于接收乘除法结果
	output wire stall_div,     //对除法进行暂停
	output reg overflow,
	output wire zero
    );
    
    //除法
    wire [63:0] result_div;
    wire start_div, signed_div, div_ready;
    assign start_div = (op==5'b01110 | op==5'b11110) ? 1'b1 : 1'b0;
    assign signed_div = (op==5'b01110) ? 1'b1 : 1'b0;   //DIV
    assign div_ready=~stall_div;
    divide_v1 div(~clk, rst, a, b, start_div, signed_div, stall_div, result_div); 
    
	always @(*) begin
		case (op[4:0])
			5'b00000: y <= a & b;
			5'b00001: y <= a | b;
			5'b00011: y <= a ^ b;
			5'b00100: y <= ~(a | b);
			5'b00101: y <= { b[15:0], {16{1'b0}} };
			
			5'b10000: y <= a;
			
			//在无溢出时，add与addu两条指令等价
			5'b00010: y <= a + b;    //add
			5'b10010: y <= a + b;    //addu
			5'b00110: y <= a + (~b) + 1'b1;  //sub
			5'b10110: y <= a + (~b) + 1'b1;  //subu
			5'b00111: y <= ($signed(a)) < ($signed(b));  //slt
			5'b10111: y <= (a < b);  //sltu
			
			//$signed()可过vivado仿真
			5'b01000: y <= b << sa;
			5'b01001: y <= b >> sa;
			//5'b01010: y <= ({32{b[31]}} << (6'h20 - {1'b0,sa}))| b >> sa;
			5'b01010: y <= ($signed(b)) >>> sa;
			5'b11000: y <= b << a[4:0];      //注意指令a[4:0]
			5'b11001: y <= b >> a[4:0];
			//5'b11010: y <= ({32{b[31]}} << (33'h1_0000_0000 - {1'b0,a}))| b >> a;//有问题
			5'b11010: y <= ($signed(b)) >>> a[4:0];
			
			5'b11111: hilo_out <= {32'b0, a} * {32'b0, b};
            5'b01111: hilo_out <= $signed(a) * $signed(b);
            //当除法模块结束计算后直接传入结果，再输出
            5'b01110: hilo_out <= result_div;
            5'b11110: hilo_out <= result_div;
			
			default : y <= 32'b0;
		endcase	
	end
	
	assign zero = (y == 32'b0);

    //处理溢出
	always @(*) begin
		case (op)
		
			default : overflow <= 1'b0;
		endcase	
	end
endmodule
