`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2025 10:42:05 AM
// Design Name: 
// Module Name: TopLevelModule
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


module TopLevelModule(
    output [7:0] HDIO_OUT
    );
    
    wire [7:0] EMIO_IN;
    
    kria_starter_kit starter_kit (
        .EMIO_OUT(EMIO_IN)
    );
    
    assign HDIO_OUT[3:0] = EMIO_IN[3:0];
    assign HDIO_OUT[7:4] = 4'b0101;
    
endmodule
