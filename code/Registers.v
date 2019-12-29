module Registers (
  input                      clk_i,
  input  [`REG_NUM_BITS-1:0] RS1addr_i,
  input  [`REG_NUM_BITS-1:0] RS2addr_i,
  input  [`REG_NUM_BITS-1:0] RDaddr_i,
  input  [`REG_LEN-1:0]      RDdata_i,
  input                      RegWrite_i,
  output [`REG_LEN-1:0]      RS1data_o,
  output [`REG_LEN-1:0]      RS2data_o
);

  // Register File
  reg [`REG_LEN-1:0] register[0:`REG_NUM_MASK];

  // Read Data
  // assign RS1data_o = RS1addr_i == 5'b0 ? 32'b0 : register[RS1addr_i];
  // assign RS2data_o = RS2addr_i == 5'b0 ? 32'b0 : register[RS2addr_i];
  assign RS1data_o = RS1addr_i == 5'b0 ? 32'b0 : (RS1addr_i == RDaddr_i ? RDdata_i : register[RS1addr_i]);
  assign RS2data_o = RS2addr_i == 5'b0 ? 32'b0 : (RS2addr_i == RDaddr_i ? RDdata_i : register[RS2addr_i]);

  initial begin // for debugging convenience only
    register[0] = 32'b0; // x0 register
  end
  // Write Data
  always @(posedge clk_i) begin
    if (RegWrite_i && RDaddr_i != 5'b0) // not write to x0
      register[RDaddr_i] <= RDdata_i;
  end

endmodule
