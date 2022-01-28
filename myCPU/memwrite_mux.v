`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 17:15:38
// Design Name: 
// Module Name: memwrite_mux
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


module memwrite_mux(
    input wire memwrite,
    input wire[1:0] memwrite_con,
    input wire[31:0] addr,
    
    output reg[3:0] true_memwrite
    );
    always @(*) begin
        if (memwrite) begin  
            case (memwrite_con) 
                2'b01: true_memwrite <= 4'b1111;    //SW
                
                2'b10: case(addr[1:0])              //SH
                    2'b00: true_memwrite <= 4'b0011;
                    2'b10: true_memwrite <= 4'b1100;
                    default: true_memwrite <= 4'b0000;
                endcase
                
                2'b11: case(addr[1:0])              //SB
                    2'b00: true_memwrite <= 4'b0001;
                    2'b01: true_memwrite <= 4'b0010;
                    2'b10: true_memwrite <= 4'b0100;
                    2'b11: true_memwrite <= 4'b1000;
                    default: true_memwrite <= 4'b0000;
                endcase
                
                default: true_memwrite <= 4'b0000;
            endcase
        end
        else begin //²»ÔÊÐíÐ´
            true_memwrite <= 4'b0000;
        end
    end
endmodule
