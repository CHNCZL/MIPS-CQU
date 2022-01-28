`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/04 16:34:32
// Design Name: 
// Module Name: hilo
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

module hilo(
	input wire clk,rst,we,
	input wire[31:0] hi,lo,
	output reg[31:0] hi_o,lo_o	//从寄存器中取出的值
    );
	
	always @(negedge clk) begin
		if(rst) begin
			hi_o <= 0;
			lo_o <= 0;
		end else if (we) begin
			hi_o <= hi;
			lo_o <= lo;
		end
		else begin
            hi_o <=hi_o;
            lo_o <=lo_o;
        end
	end
	
endmodule
