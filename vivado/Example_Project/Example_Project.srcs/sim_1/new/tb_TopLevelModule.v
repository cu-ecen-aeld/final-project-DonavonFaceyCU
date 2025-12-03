`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 12:05:09 PM
// Design Name: 
// Module Name: tb_TopLevelModule
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


`timescale 1ns/1ps

module tb_TopLevelModule;

    // Testbench signals to *force* into DUT
    reg tb_clk = 0;
    reg [7:0] tb_emio = 8'd1;

    // Output wire from DUT
    wire [7:0] HDIO_OUT;

    // Instantiate DUT
    TopLevelModule dut (
        .HDIO_OUT(HDIO_OUT)
    );

    // ============================================================
    // 100 MHz Clock Generator
    // 10 ns period → toggle every 5 ns
    // ============================================================
    always #5 tb_clk = ~tb_clk;

    // ============================================================
    // Drive EMIO_IN: Count from 1 → 255 → wrap → repeat
    // ============================================================
    always begin
        #20;                       // change value every 20 ns
        tb_emio = tb_emio + 1;
        //if (tb_emio == 8'd255)
            //$finish;
    end

    // ============================================================
    // FORCE Internal Signals of the DUT
    // (Because PL_CLK and EMIO_IN are *internal wires* in DUT)
    // ============================================================
    initial begin
        force dut.PL_CLK  = tb_clk;
        force dut.EMIO_IN = tb_emio;
    end

    // ============================================================
    // Simulation Control & Waveform Dump
    // ============================================================
    initial begin
        $dumpfile("TopLevelModule_tb.vcd");
        $dumpvars(0, tb_TopLevelModule);

        // Run the simulation long enough to observe behavior
        //#5000;
       //$finish;
    end

endmodule
