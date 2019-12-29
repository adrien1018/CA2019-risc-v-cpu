module Instruction_Memory (
  input  [`REG_LEN-1:0]  addr_i,
  output [`INSR_LEN-1:0] instr_o
);
  reg  [`INSR_LEN-1:0] memory[0:`IM_MASK];
  wire [`IM_BITS-1:0]  entry = addr_i[`REG_LEN-1:2] & `IM_MASK;
  assign instr_o = memory[entry];
endmodule
