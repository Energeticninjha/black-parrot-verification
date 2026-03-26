module test_before;
  // Parameters
  localparam els_p = 4;
  
  // Signals
  logic clk_i = 0;
  logic reset_i;
  logic enq_i, deq_i;
  logic full_o, empty_o;
  
  // Clock generation (10ns period)
  always #5 clk_i = ~clk_i;

 // Instantiate the Tracker (The "Device Under Test")
  bsg_fifo_tracker #(.els_p(els_p)) dut (
    .clk_i(clk_i), 
    .reset_i(reset_i),
    .enq_i(enq_i), 
    .deq_i(deq_i),
    .wptr_r_o(),   // Connected to "nothing" to stop the warning
    .rptr_r_o(),   // Connected to "nothing"
    .rptr_n_o(),   // Connected to "nothing"
    .full_o(full_o), 
    .empty_o(empty_o)
  );

  initial begin
    $display("--- STARTING 'BEFORE' TEST (Passive Verification) ---");
    reset_i = 1; enq_i = 0; deq_i = 0;
    repeat (2) @(posedge clk_i);
    reset_i = 0;

    // 1. Fill the FIFO to its limit
    $display("Action: Filling FIFO with %0d items...", els_p);
    repeat (els_p) begin
      @(posedge clk_i);
      enq_i = 1;
    end
    @(posedge clk_i) enq_i = 0;

    // 2. The Illegal Move: Force an Enqueue when the tracker says it's FULL
    #1; // Small delay to let signals settle
    if (full_o) begin
      $display("STATUS: full_o is %b. Forcing ILLEGAL Enqueue now...", full_o);
      @(posedge clk_i);
      enq_i = 1; 
    end
    
    @(posedge clk_i);
    enq_i = 0;

    // 3. The Result
    $display("STATUS: Simulation finished at %t.", $time);
    $display("RESULT: Check the log above. Did the hardware stop you or print an error?");
    $display("-----------------------------------------------------");
    $finish;
  end
endmodule