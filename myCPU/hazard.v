`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,
	output reg[1:0] forwardaD,forwardbD,
	output wire stallD,
	//execute stage
	input wire stall_divE,
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire[1:0] memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,stallE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire[1:0] memtoregM,

	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW
    );

	wire lwstallD,branchstallD;

	//forwarding sources to D stage (branch equality)
	//assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	//assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	always @(*) begin
		forwardaD = 2'b00;
		forwardbD = 2'b00;
		if(rsD != 0) begin
			if(rsD == writeregE & regwriteE) begin
				forwardaD = 2'b01;
			end else if(rsD == writeregM & regwriteM) begin
				forwardaD = 2'b10;
			end else if(rsD == writeregW & regwriteW) begin
			    forwardaD = 2'b11;
			end
		end
		if(rtD != 0) begin
			if(rtD == writeregE & regwriteE) begin
				forwardbD = 2'b01;
			end else if(rtD == writeregM & regwriteM) begin
				forwardbD = 2'b10;
			end else if(rtD == writeregW & regwriteW) begin
			    forwardbD = 2'b11;
			end
		end
	end
	
	//forwarding sources to E stage (ALU)
	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end

	//stalls,由于memreg拓宽，所以做了相应的改动
	assign #1 lwstallD = (~memtoregE[1] & memtoregE[0]) & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD = branchD &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				(~memtoregM[1] & memtoregM[0]) &
				(writeregM == rsD | writeregM == rtD));
	assign #1 stallF = lwstallD | branchstallD | stall_divE;
	assign #1 stallD = lwstallD | branchstallD | stall_divE;
		//stalling D stalls all previous stages
	assign #1 flushE = lwstallD | branchstallD;
	assign #1 stallE = stall_divE;
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule
