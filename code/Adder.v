module Adder (
  input  [`REG_LEN-1:0] opr_1,
  input  [`REG_LEN-1:0] opr_2,
  output [`REG_LEN-1:0] result
);
  assign result = opr_1 + opr_2;
endmodule
