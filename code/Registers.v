module Registers (
  input         clk_i,
  input  [4:0]  RS1addr_i,
  input  [4:0]  RS2addr_i,
  input  [4:0]  RDaddr_i,
  input  [31:0] RDdata_i,
  input         RegWrite_i,
  output [31:0] RS1data_o,
  output [31:0] RS2data_o
);

  // Register File
  reg [31:0] register[0:31];

  // Read Data
  assign RS1data_o = RS1addr_i == 5'b0 ? 32'b0 : register[RS1addr_i];
  assign RS2data_o = RS2addr_i == 5'b0 ? 32'b0 : register[RS2addr_i];

  initial begin // for debugging convenience only
    register[0] = 32'b0; // x0 register
  end
  // Write Data
  always @(posedge clk_i) begin
    if (RegWrite_i && RDaddr_i != 5'b0) // not write to x0
      register[RDaddr_i] <= RDdata_i;
  end

endmodule
