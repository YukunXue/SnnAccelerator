module sorter_tb ();

  localparam IMAGE_SIZE      = 7;
  localparam IMAGE_SIZE_BITS = $clog2(IMAGE_SIZE);
  localparam PIXEL_MAX_VALUE = 255;
	localparam PIXEL_BITS      = $clog2(PIXEL_MAX_VALUE);

  // ------------------------------
  // -- Logic
  // ------------------------------
  logic         sorter_ready;
  
  logic         CLK;
  logic         RST;

  // Input image
  logic [PIXEL_BITS:0] IMAGE [0:IMAGE_SIZE-1];
  logic NEW_IMAGE;

  // From AER
  logic AEROUT_CTRL_BUSY;
  
  // Next index sorted
  logic [PIXEL_BITS:0] NEXT_INDEX;
  logic FOUND_NEXT_INDEX;
  
  // Image sorted
  logic IMAGE_ENCODED;

  // ------------------------------
  // -- Init
  // ------------------------------

  initial begin
    sorter_ready      = 1'b0;
    NEW_IMAGE         = 1'b0;
    AEROUT_CTRL_BUSY  = 1'b0;

    // Initialize image to 0
    for (int i = 0; i < IMAGE_SIZE; i++) begin
      IMAGE[i] = 0;
    end

  end

  // ------------------------------
  // -- Clock and Reset
  // ------------------------------

  initial begin
    CLK = 1'b1; 
    forever begin
      wait_ns(2);
        CLK = ~CLK;
      end
  end

  initial begin
    wait_ns(0.1);
    RST = 1'b0;
    wait_ns(100);
    RST = 1'b1;
    wait_ns(100);
    RST = 1'b0;
    wait_ns(100);
    sorter_ready = 1'b1;
  end
  
  // ------------------------------
  // -- DUT and assignments
  // ------------------------------
  sorter3 u_sorter (
    // Global input
    .CLK              ( CLK               ),
    .RST              ( RST               ),

    // Input image 
    .IMAGE            ( IMAGE             ),
    .NEW_IMAGE        ( NEW_IMAGE         ),

    // From AER
    .AEROUT_CTRL_BUSY ( AEROUT_CTRL_BUSY  ),

    // Next index sorted
    .NEXT_INDEX       ( NEXT_INDEX        ),
    .FOUND_NEXT_INDEX ( FOUND_NEXT_INDEX  ),

    // Image sorted
    .IMAGE_ENCODED    ( IMAGE_ENCODED     )
  );

  // ------------------------------
  // -- Test program
  // ------------------------------

  initial begin
    while (~sorter_ready) wait_ns(1);

    wait_ns(2);

    // Generate an image
    for (int i = 0; i < IMAGE_SIZE; i++) begin
      IMAGE[i] = $urandom_range(0, PIXEL_MAX_VALUE);
    end
    $display("Image sent:");
    for (int i = 0; i < IMAGE_SIZE; i++) begin
      $write("%d: ", i);
      $display("%h", IMAGE[i]);
    end

    // Signal that there is a new image
    NEW_IMAGE = 1'b1;
    wait_ns(4);
    NEW_IMAGE = 1'b0;

    // Output each value until the whole image has been sorted
    while (!IMAGE_ENCODED) begin
      while(!FOUND_NEXT_INDEX) wait_ns(1);
      AEROUT_CTRL_BUSY = 1'b1;
      wait_ns(4);
      $display("Next index: %d", NEXT_INDEX);
      wait_ns(6);
      AEROUT_CTRL_BUSY = 1'b0;

    end

    wait_ns(500);
    $finish;

  end

  // SIMPLE TIME-HANDLING TASKS
  task wait_ns;
    input   tics_ns;
    integer tics_ns;
    #tics_ns;
  endtask

endmodule