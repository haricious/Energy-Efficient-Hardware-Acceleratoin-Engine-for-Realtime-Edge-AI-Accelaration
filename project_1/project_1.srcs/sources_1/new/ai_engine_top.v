`timescale 1ns / 1ps

module ai_engine_top #(
    parameter ARRAY_SIZE = 4,
    parameter ACT_W = 8,
    parameter PSUM_W = 32
)(
    input wire clk, rst_n, start_inference,
    input wire host_we_weight, host_we_act,
    input wire [7:0] host_addr,
    input wire [(ARRAY_SIZE*ACT_W)-1:0] host_din,
    output wire [(ARRAY_SIZE*ACT_W)-1:0] final_psum_bus, 
    output wire engine_done
);

    wire load_weight_sig, enable_array_sig, current_bank_sig;
    wire [(ARRAY_SIZE*ACT_W)-1:0] sram_weight_out, sram_act_out;
    wire [(ARRAY_SIZE*PSUM_W)-1:0] raw_psum_bus; 
    reg [7:0] fetch_addr_w, fetch_addr_a;

    accelerator_fsm fsm_inst (
        .clk(clk), .rst_n(rst_n), .start_inference(start_inference),
        .load_weight(load_weight_sig), .enable_array(enable_array_sig),
        .active_bank(current_bank_sig), .array_done(engine_done)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fetch_addr_w <= 0; fetch_addr_a <= 0;
        end else begin
            if (load_weight_sig) fetch_addr_w <= fetch_addr_w + 1;
            else if (engine_done) fetch_addr_w <= 0;
            if (enable_array_sig && !load_weight_sig) fetch_addr_a <= fetch_addr_a + 1;
            else if (engine_done) fetch_addr_a <= 0;
        end
    end

    sram_buffer #(.DATA_WIDTH(ARRAY_SIZE*ACT_W)) weight_memory (
        .clk(clk), .we(host_we_weight), .addr(host_we_weight ? host_addr : fetch_addr_w),
        .din(host_din), .bank_sel(current_bank_sig), .dout(sram_weight_out)
    );

    sram_buffer #(.DATA_WIDTH(ARRAY_SIZE*ACT_W)) act_memory (
        .clk(clk), .we(host_we_act), .addr(host_we_act ? host_addr : fetch_addr_a),
        .din(host_din), .bank_sel(current_bank_sig), .dout(sram_act_out)
    );

    systolic_array #(.ARRAY_SIZE(ARRAY_SIZE)) core_array (
        .clk(clk), .rst_n(rst_n), .enable(enable_array_sig), .load_weight(load_weight_sig),
        .act_in_bus(sram_act_out), .weight_in_bus(sram_weight_out), .psum_out_bus(raw_psum_bus)
    );

    relu_array #(.ARRAY_SIZE(ARRAY_SIZE)) activation_layer (
        .psum_bus_in(raw_psum_bus), .act_bus_out(final_psum_bus)
    );
endmodule