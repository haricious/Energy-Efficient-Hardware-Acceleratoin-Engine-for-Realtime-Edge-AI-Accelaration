`timescale 1ns / 1ps

module relu_array #(
    parameter ARRAY_SIZE = 4,
    parameter PSUM_W = 32,
    parameter OUT_W = 8
)(
    input wire [(ARRAY_SIZE*PSUM_W)-1:0] psum_bus_in,
    output wire [(ARRAY_SIZE*OUT_W)-1:0] act_bus_out
);

    genvar i;
    generate
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin : relu_gen
            wire signed [PSUM_W-1:0] current_psum = psum_bus_in[(i*PSUM_W) +: PSUM_W];
            assign act_bus_out[(i*OUT_W) +: OUT_W] = (current_psum < 0) ? 8'd0 : 
                                                     (current_psum > 255) ? 8'd255 : current_psum[7:0];
        end
    endgenerate
endmodule