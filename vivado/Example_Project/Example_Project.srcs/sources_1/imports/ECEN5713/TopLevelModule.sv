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
    wire PL_CLK;
    
    /*
    wire PWM_CLK;
    wire [3:0] SELECTED_DIGIT;
    
    clk_div_pow2 clk_div (
        .clk_in         (PL_CLK),
        .reset          (1'b0),
        .clk_out        (PWM_CLK)
    );
    
    Digit_Mux Digit (
        .dataIn0        (EMIO_IN[3:0]),
        .dataIn1        (EMIO_IN[7:4]),
        .dataSelect     (PWM_CLK),
        .dataOut        (SELECTED_DIGIT)
    );
    
    seven_seg_decoder (
        .hex            (SELECTED_DIGIT),
        .seg            (HDIO_OUT[6:0])
    );
    */
    
    kria_starter_kit starter_kit (
        .EMIO_OUT       (EMIO_IN),
        .PS_RESET       (1'b1),
        .PL_CLK         (PL_CLK)
    );
    
    //assign HDIO_OUT[7] = PWM_CLK;
    assign HDIO_OUT = EMIO_IN;
    
endmodule

//NOTE: This module was generated using ChatGPT
module clk_div_pow2 (
    input  wire clk_in,
    input  wire reset,
    output wire clk_out
);

    reg [18:0] counter = 19'd0;  // 19-bit counter → divides by 2^19

    always @(posedge clk_in or posedge reset) begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    assign clk_out = counter[18];  // MSB = divided clock

endmodule

//NOTE: This module was generated using ChatGPT
module Digit_Mux (
    input  wire [3:0] dataIn0,
    input  wire [3:0] dataIn1,
    input  wire       dataSelect,
    output wire [3:0] dataOut
);

    assign dataOut = dataSelect ? dataIn1 : dataIn0;

endmodule

module seven_seg_decoder (
    input  wire [3:0] hex,       // 4-bit input (0-F)
    output reg  [6:0] seg        // {a, b, c, d, e, f, g}
);

    always @(*) begin
        case (hex)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // b
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // d
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // all off
        endcase
    end

endmodule

