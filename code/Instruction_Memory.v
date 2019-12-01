`define IM_BITS 8 // 1 KiB
`define IM_MASK ((1<<`IM_BITS)-1)

module Instruction_Memory (
  input  [31:0] addr_i,
  output [31:0] instr_o
);
  reg  [31:0] memory[0:`IM_MASK];
  wire [`IM_BITS-1:0] entry = addr_i[31:2] & `IM_MASK;
  assign instr_o = memory[entry];
endmodule
