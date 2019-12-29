module DCache_SRAM (
  input                         clk_i,
  input [`L1_INDEX_SIZE-1:0]    addr_i,
  input [`DM_UNIT_MASK:0]       data_i,
  input [`L1_TAG_MEM_SIZE-1:0]  tag_i,
  input                         enable_i,
  input                         write_i,
  output [`DM_UNIT_MASK:0]      data_o,
  output [`L1_TAG_MEM_SIZE-1:0] tag_o
);
  reg [`DM_UNIT_MASK:0]      data_memory[0:`L1_INDEX_MASK];
  reg [`L1_TAG_MEM_SIZE-1:0] tag_memory[0:`L1_INDEX_MASK];

  assign data_o = enable_i ? data_memory[addr_i] : 256'b0;
  assign tag_o  = enable_i ? tag_memory[addr_i] : 24'b0;

  always @(posedge clk_i) begin
    if (enable_i && write_i) begin
      data_memory[addr_i] <= data_i;
      tag_memory[addr_i] <= tag_i;
    end
  end
endmodule
