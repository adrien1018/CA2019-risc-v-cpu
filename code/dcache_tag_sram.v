module dcache_tag_sram (
  input                         clk_i,
  input [`L1_INDEX_SIZE-1:0]    addr_i,
  input [`L1_TAG_MEM_SIZE-1:0]  data_i,
  input                         enable_i,
  input                         write_i,
  output [`L1_TAG_MEM_SIZE-1:0] data_o
);
  reg [`L1_TAG_MEM_SIZE-1:0] memory[0:`L1_INDEX_MASK];

  assign data_o = (enable_i) ? memory[addr_i] : 24'b0;

  always @(posedge clk_i) begin
    if (enable_i && write_i) begin
      memory[addr_i] <= data_i;
    end
  end
endmodule
