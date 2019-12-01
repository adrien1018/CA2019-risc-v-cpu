module Adder (
  input  [31:0] opr_1,
  input  [31:0] opr_2,
  output [31:0] result
);
  assign result = opr_1 + opr_2;
endmodule
