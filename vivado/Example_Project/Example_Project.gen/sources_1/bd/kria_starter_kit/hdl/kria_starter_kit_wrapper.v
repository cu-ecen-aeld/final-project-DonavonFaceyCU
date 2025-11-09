//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.1 (lin64) Build 6140274 Wed May 21 22:58:25 MDT 2025
//Date        : Sat Nov  8 14:54:37 2025
//Host        : Ubuntu running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target kria_starter_kit_wrapper.bd
//Design      : kria_starter_kit_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module kria_starter_kit_wrapper
   (EMIO_OUT);
  output [7:0]EMIO_OUT;

  wire [7:0]EMIO_OUT;

  kria_starter_kit kria_starter_kit_i
       (.EMIO_OUT(EMIO_OUT));
endmodule
