`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 17:46:32
// Design Name: 
// Module Name: writeData_mux
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


module writeData_mux(
    input wire[31:0] writeData,
    input wire[1:0] memwrite_con,
    
    output reg[31:0] true_writeData
    );
    
    always @(*) begin 
        case (memwrite_con) 
            2'b01: true_writeData <= writeData;   //SW
            2'b10: true_writeData <= {writeData[15:0], writeData[15:0]};   //SH
            2'b11: true_writeData <= {writeData[7:0], writeData[7:0], writeData[7:0], writeData[7:0]};   //SB
            default: true_writeData <= writeData;
        endcase   
    end
endmodule
