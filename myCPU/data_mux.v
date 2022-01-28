`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/05 15:29:31
// Design Name: 
// Module Name: data_mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 从数据cache中读到的数据要根据类型（读字节，半字，字），有无符号拓展，偏移量来共同决定最终要获得的数据
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_mux(
    input wire [31:0] readdata,
    input wire [2:0] memread,   //memread控制信号
    input wire [31:0] addr,     //地址信号，由低两位决定偏移量
    
    output reg [31:0] truedata,
    output reg exp              //地址异常
    );
    
    always @(*) begin
        case (memread)
			3'b000: truedata <= readdata;    //LW
			
			3'b001: case(addr[1:0])          //LH
                2'b00: truedata <= {{16{readdata[15]}},readdata[15:0]};
                2'b10: truedata <= {{16{readdata[31]}},readdata[31:16]};
                default: truedata <= 32'b0;
            endcase
            
            3'b101: case(addr[1:0])          //LHU
                2'b00: truedata <= {{16{1'b0}},readdata[15:0]};
                2'b10: truedata <= {{16{1'b0}},readdata[31:16]};
                default: truedata <= 32'b0;
            endcase

			3'b010: case(addr[1:0])          //LB
                2'b00: truedata <= {{24{readdata[7]}},readdata[7:0]};
                2'b01: truedata <= {{24{readdata[15]}},readdata[15:8]};
                2'b10: truedata <= {{24{readdata[23]}},readdata[23:16]};
                2'b11: truedata <= {{24{readdata[31]}},readdata[31:24]};
                default: truedata <= 32'b0;
            endcase
            
            3'b110: case(addr[1:0])          //LBU
                2'b00: truedata <= {{24{1'b0}},readdata[7:0]};
                2'b01: truedata <= {{24{1'b0}},readdata[15:8]};
                2'b10: truedata <= {{24{1'b0}},readdata[23:16]};
                2'b11: truedata <= {{24{1'b0}},readdata[31:24]};
                default: truedata <= 32'b0;
            endcase
            
			default:  truedata <= 32'b0; //illegal 
		endcase
	end
endmodule
