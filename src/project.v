/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ricardohuizar (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [63:0] product;
wire done;

pm32 pm32_inst (
    .clk(clk),
    .rst(!rst_n),
    .start(ui_in[7]),
    .mc({25'b0, ui_in[6:0]}),
    .mp({24'b0, uio_in}),
    .p(product),
    .done(done)
);

assign uo_out = {done, product[6:0]};
assign uio_out = 0;
assign uio_oe  = 0;

wire _unused = &{ena, 1'b0};

endmodule
