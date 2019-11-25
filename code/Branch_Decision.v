module BranchDecision (
  opr_1,
  opr_2,
  op,
  taken
);

  input  [31:0] opr_1;
  input  [31:0] opr_2;
  input  [2:0]  op;      // ins[14:12]
  output        taken;

  assign taken = op[0] ^ (
      op[2:1] == 2'b00 ? opr_1 == opr_2 :
      op[2:1] == 2'b10 ? $signed(opr_1) < $signed(opr_2) :
                         opr_1 < opr_2);

endmodule
