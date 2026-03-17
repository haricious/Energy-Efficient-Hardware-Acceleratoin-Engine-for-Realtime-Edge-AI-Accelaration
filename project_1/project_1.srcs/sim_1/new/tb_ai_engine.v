`timescale 1ns / 1ps

module tb_ai_engine();

    // ---------------------------------------------------------
    // 1. SIGNAL DEFINITIONS
    // ---------------------------------------------------------
    reg clk;
    reg rst_n;
    reg start_inference;
    
    // Host Interface
    reg host_we_weight;
    reg host_we_act;
    reg [7:0] host_addr;
    reg [31:0] host_din; // 4 parallel 8-bit values
    
    // Output Bus (Now 32 bits total: 4 columns * 8 bits)
    wire [31:0] final_psum_bus; 
    wire engine_done;

    // ---------------------------------------------------------
    // 2. OUTPUT DATA CATCHERS
    // ---------------------------------------------------------
    // These registers latch the result when engine_done pulses
    reg [7:0] catch_col_0;
    reg [7:0] catch_col_1;
    reg [7:0] catch_col_2;
    reg [7:0] catch_col_3;

    always @(posedge clk) begin
        if (!rst_n) begin
            catch_col_0 <= 0; catch_col_1 <= 0; 
            catch_col_2 <= 0; catch_col_3 <= 0;
        end else if (engine_done) begin
            catch_col_0 <= final_psum_bus[7:0];
            catch_col_1 <= final_psum_bus[15:8];
            catch_col_2 <= final_psum_bus[23:16];
            catch_col_3 <= final_psum_bus[31:24];
        end
    end

    // ---------------------------------------------------------
    // 3. UNIT UNDER TEST (UUT) INSTANTIATION
    // ---------------------------------------------------------
    ai_engine_top #(
        .ARRAY_SIZE(4),
        .ACT_W(8),
        .PSUM_W(32)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start_inference(start_inference),
        .host_we_weight(host_we_weight),
        .host_we_act(host_we_act),
        .host_addr(host_addr),
        .host_din(host_din),
        .final_psum_bus(final_psum_bus),
        .engine_done(engine_done)
    );

    // ---------------------------------------------------------
    // 4. CLOCK GENERATION (100 MHz)
    // ---------------------------------------------------------
    always #5 clk = ~clk;

    // ---------------------------------------------------------
    // 5. TEST SEQUENCE
    // ---------------------------------------------------------
    initial begin
        // Initialize Signals
        clk = 0;
        rst_n = 0;
        start_inference = 0;
        host_we_weight = 0;
        host_we_act = 0;
        host_addr = 0;
        host_din = 0;

        $display("--- Starting Edge AI Accelerator Final Verification ---");

        // 1. Load data using RELATIVE PATHS
        // Vivado will find these because they are added as Simulation Sources
        // 1. Load data using ABSOLUTE PATHS to bypass Vivado's temporary folders
        #1; 
        $readmemh("D:/Projects/SIXXIS/Energy Efficient Hardware Acceleratoin Engine for Realtime Edge AI Accelaration/project_1/py/real_weights.hex", uut.weight_memory.ram_bank_A);
        $readmemh("D:/Projects/SIXXIS/Energy Efficient Hardware Acceleratoin Engine for Realtime Edge AI Accelaration/project_1/py/real_image.hex", uut.act_memory.ram_bank_A);
        
        $display("[TIME: %0t] Memory files loaded from project database.", $time);

        // 2. Reset and Run
        #20 rst_n = 1;
        #20;

        $display("[TIME: %0t] Triggering Autonomous Inference...", $time);
        start_inference = 1;
        #10 start_inference = 0; 

        wait(engine_done == 1'b1);
        #10; 
        
        $display("\n==================================================");
        $display("   AI ACCELERATOR INFERENCE COMPLETE");
        $display("==================================================");
        $display("Resulting Feature Map (ReLU Activated):");
        $display(" -> Col 0: %d", catch_col_0);
        $display(" -> Col 1: %d", catch_col_1);
        $display(" -> Col 2: %d", catch_col_2);
        $display(" -> Col 3: %d", catch_col_3);
        $display("==================================================\n");

        #50 $finish;
    end

endmodule