`timescale 1ns / 1ps

module sram_buffer #(
    parameter DATA_WIDTH = 32, 
    parameter ADDR_WIDTH = 8,  
    parameter DEPTH = 256
)(
    input wire clk,
    input wire we,                     
    input wire [ADDR_WIDTH-1:0] addr,  
    input wire [DATA_WIDTH-1:0] din,   
    input wire bank_sel,               
    output reg [DATA_WIDTH-1:0] dout   
);

    reg [DATA_WIDTH-1:0] ram_bank_A [0:DEPTH-1];
    reg [DATA_WIDTH-1:0] ram_bank_B [0:DEPTH-1];

    always @(posedge clk) begin
        if (we) begin
            if (bank_sel == 1'b1) 
                ram_bank_A[addr] <= din;
            else                  
                ram_bank_B[addr] <= din;
        end
    end

    always @(posedge clk) begin
        if (bank_sel == 1'b0)
            dout <= ram_bank_A[addr];
        else
            dout <= ram_bank_B[addr];
    end
endmodule