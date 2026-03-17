`timescale 1ns / 1ps

module accelerator_fsm (
    input wire clk,
    input wire rst_n,
    input wire start_inference,
    output reg load_weight,
    output reg enable_array,
    output reg active_bank, 
    output reg array_done
);

    localparam IDLE=2'b00, LOAD_W=2'b01, COMPUTE=2'b10, DONE=2'b11;
    reg [1:0] current_state, next_state;
    reg [4:0] cycle_counter; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            cycle_counter <= 0;
            active_bank   <= 1'b0;
        end else begin
            current_state <= next_state;
            if (current_state == DONE) active_bank <= ~active_bank;
            if (current_state == LOAD_W || current_state == COMPUTE)
                cycle_counter <= cycle_counter + 1;
            else
                cycle_counter <= 0;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE:    if (start_inference) next_state = LOAD_W;
            LOAD_W:  if (cycle_counter == 5'd4) next_state = COMPUTE; 
            COMPUTE: if (cycle_counter == 5'd16) next_state = DONE; 
            DONE:    next_state = IDLE;
        endcase
    end

    always @(*) begin
        load_weight = (current_state == LOAD_W);
        enable_array = (current_state == LOAD_W || current_state == COMPUTE);
        array_done = (current_state == DONE);
    end
endmodule