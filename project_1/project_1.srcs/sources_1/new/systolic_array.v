`timescale 1ns / 1ps

module systolic_array #(
    parameter ARRAY_SIZE = 4,
    parameter ACT_W = 8,
    parameter PSUM_W = 32
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire load_weight,
    input wire [(ARRAY_SIZE*ACT_W)-1:0] act_in_bus,
    input wire [(ARRAY_SIZE*ACT_W)-1:0] weight_in_bus,
    output wire [(ARRAY_SIZE*PSUM_W)-1:0] psum_out_bus
);

    wire signed [ACT_W-1:0] horizontal_wires [0:ARRAY_SIZE-1][0:ARRAY_SIZE];
    wire signed [PSUM_W-1:0] vertical_wires [0:ARRAY_SIZE][0:ARRAY_SIZE-1];

    genvar r, c;
    generate
        for (r = 0; r < ARRAY_SIZE; r = r + 1) begin : rows
            assign horizontal_wires[r][0] = act_in_bus[(r*ACT_W) +: ACT_W];
            for (c = 0; c < ARRAY_SIZE; c = c + 1) begin : cols
                if (r == 0) assign vertical_wires[0][c] = 0;
                
                processing_element #(ACT_W, PSUM_W) pe_inst (
                    .clk(clk), .rst_n(rst_n), .enable(enable),
                    .load_weight(load_weight),
                    .act_in(horizontal_wires[r][c]),
                    .weight_in(weight_in_bus[(c*ACT_W) +: ACT_W]),
                    .psum_in(vertical_wires[r][c]),
                    .act_out(horizontal_wires[r][c+1]),
                    .psum_out(vertical_wires[r+1][c])
                );
            end
            assign psum_out_bus[(r*PSUM_W) +: PSUM_W] = vertical_wires[ARRAY_SIZE][r];
        end
    endgenerate
endmodule