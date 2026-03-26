module test_after;
  localparam els_p = 4;
  logic clk_i = 0;
  logic reset_i, enq_i, deq_i, full_o, empty_o;
  
  logic [31:0] test_data;
  int shadow_queue[$]; 

  always #5 clk_i = ~clk_i;

  bsg_fifo_tracker #(.els_p(els_p)) dut (
    .clk_i(clk_i), .reset_i(reset_i),
    .enq_i(enq_i), .deq_i(deq_i),
    .wptr_r_o(), .rptr_r_o(), .rptr_n_o(),
    .full_o(full_o), .empty_o(empty_o)
  );

  // --- THE UVM SCOREBOARD & MONITOR ---
  always @(posedge clk_i) begin
    if (reset_i) begin
      shadow_queue.delete();
    end else begin
      // Logic for Data Integrity
      if (enq_i && !full_o) begin
        shadow_queue.push_back(test_data);
      end
      
      if (deq_i && !empty_o) begin
        // Standard way to remove first element
        if (shadow_queue.size() > 0) begin
           shadow_queue.pop_front();
        end
      end
      
      // Illegal Push Detection
      if (enq_i && full_o && !deq_i) begin
        $display("[DHARSHINI_UVM] ERROR: Illegal Push caught at %0t!", $time);
      end
    end
  end

  initial begin
    $display("--- STARTING CONSOLIDATED UVM TEST SUITE ---");
    reset_i = 1; enq_i = 0; deq_i = 0; test_data = 0;
    repeat (5) @(posedge clk_i);

    // --- SCENARIO 1: Reset Timing ---
    $display("Scenario 1: Testing Enqueue AFTER Reset ends...");
    reset_i = 0; 
    @(posedge clk_i); 
    enq_i = 1; 
    test_data = 32'hA5A5_B6B6;
    @(posedge clk_i);
    enq_i = 0;

    // --- SCENARIO 2: Random Sequences ---
    $display("Scenario 2: Running 20 Random Operations...");
    repeat (20) begin
      @(posedge clk_i);
      enq_i = 1'($urandom_range(0, 1));
      deq_i = 1'($urandom_range(0, 1));
      test_data = $urandom;
    end

    // --- SCENARIO 3: Error Injection ---
    $display("Scenario 3: Attempting to Overflow...");
    while (!full_o) begin
      @(posedge clk_i);
      enq_i = 1; deq_i = 0;
      test_data = 32'hDEAD_BEEF;
    end
    @(posedge clk_i);
    enq_i = 1; 

    repeat (5) @(posedge clk_i);
    $display("--- ALL SCENARIOS COMPLETE ---");
    $finish;
  end
endmodule