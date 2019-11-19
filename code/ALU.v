module ALU (
  opr_1,
  opr_2,
  alu_op,
  flag,
  result,
);

  input  [31:0] opr_1;
  input  [31:0] opr_2;
  input  [3:0]  alu_op; // {1'b0, ins[14:12]}    if opcode == b0010011
                        // {ins[25], ins[14:12]} if opcode == b0110011
  input         flag;   // 1 if SUB else 0
  output [31:0] result;

  reg    [31:0] result; // use reg for simpler code

  always @* begin // a combo logic (no clock)
    case (alu_op)
      4'b0000: // ADD, SUB
        result = flag ? opr_1 - opr_2 : opr_1 + opr_2;
      4'b0110: // OR
        result = opr_1 | opr_2;
      4'b0111: // AND
        result = opr_1 & opr_2;
      4'b1000: // MUL
        result = opr_1 * opr_2;
    endcase
  end

endmodule
