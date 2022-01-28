`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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

module aludec(
	input wire[5:0] funct,
	input wire[4:0] aluop,
	output reg[4:0] alucontrol
    );
	always @(*) begin
		case (aluop)
			5'b00000: alucontrol <= 5'b00010;//add (for lw/sw/addi)
			5'b00101: alucontrol <= 5'b10010;//addu (for addiu)
			5'b00110: alucontrol <= 5'b00111;//slt (for slti)
			5'b00111: alucontrol <= 5'b10111;//sltu (for sltiu)
			
			5'b01000: alucontrol <= 5'b00110;//sub (for beq)
			5'b00001: alucontrol <= 5'b00000;//and (for andi)
			5'b00010: alucontrol <= 5'b00011;//xor (for xori)
			5'b00011: alucontrol <= 5'b00001;//or (for ori)
			5'b00100: alucontrol <= 5'b00101;//LUI (for lui)
			
			//Ò»¶¨ÎªRÐÍÖ¸Áî£¬´ËÊ±¿´funct
			default : case (funct)
				6'b100000:alucontrol <= 5'b00010; //add£¨ÓÐ·ûºÅ£©
				6'b100001:alucontrol <= 5'b10010; //addu(ÎÞ·ûºÅ)
				6'b100010:alucontrol <= 5'b00110; //sub
				6'b100011:alucontrol <= 5'b10110; //subu
				6'b101010:alucontrol <= 5'b00111; //slt
				6'b101011:alucontrol <= 5'b10111; //sltu
				
				6'b100100:alucontrol <= 5'b00000; //and
				6'b100101:alucontrol <= 5'b00001; //or
				6'b100110:alucontrol <= 5'b00011; //xor
				6'b100111:alucontrol <= 5'b00100; //nor
				
				6'b000000:alucontrol <= 5'b01000; //sll(Âß¼­×óÒÆ,sa)
				6'b000010:alucontrol <= 5'b01001; //srl(Âß¼­ÓÒÒÆ,sa)
				6'b000011:alucontrol <= 5'b01010; //sra(ËãÊõÓÒÒÆ,sa)
				6'b000100:alucontrol <= 5'b11000; //sll(Âß¼­×óÒÆ,rs)
				6'b000110:alucontrol <= 5'b11001; //srl(Âß¼­ÓÒÒÆ,rs)
				6'b000111:alucontrol <= 5'b11010; //sra(ËãÊõÓÒÒÆ,rs)
				
				6'b010001:alucontrol <= 5'b10000; //rs¸³ÖµÔËËã
				6'b010011:alucontrol <= 5'b10000; //rs¸³ÖµÔËËã
				
				6'b011000: alucontrol <= 5'b01111;//MULT
                6'b011001: alucontrol <= 5'b11111;//MULTU
                6'b011010: alucontrol <= 5'b01110;//DIV
                6'b011011: alucontrol <= 5'b11110;//DIVU
				
				default:  alucontrol <= 5'b00000;
			endcase
		endcase
	
	end
endmodule
