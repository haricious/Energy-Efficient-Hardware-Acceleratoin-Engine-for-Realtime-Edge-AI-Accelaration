`timescale 1ns / 1ps

module processing_element #(
    parameter ACT_W = 8,
    parameter PSUM_W = 32
)(
    input wire clk,
    input wire rst_n,
    input wire enable,
    input wire load_weight,
    input wire signed [ACT_W-1:0] act_in,
    input wire signed [ACT_W-1:0] weight_in,
    input wire signed [PSUM_W-1:0] psum_in,
    output reg signed [ACT_W-1:0] act_out,
    output reg signed [PSUM_W-1:0] psum_out
);

    reg signed [ACT_W-1:0] weight_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_reg <= 0;
            act_out <= 0;
            psum_out <= 0;
        end else if (enable) begin
            if (load_weight) begin
                weight_reg <= weight_in;
            end else begin
                act_out <= act_in;
                // Zero-skipping optimization: only multiply if activation is non-zero
                if (act_in == 0)
                    psum_out <= psum_in;
                else
                    psum_out <= psum_in + (act_in * weight_reg);
            end
        end
    end
endmodule