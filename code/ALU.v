module ALU (
  input [`REG_LEN-1:0] opr_1,
  input [`REG_LEN-1:0] opr_2,
  input [3:0] alu_op, // {ins[25], ins[14:12]} if opcode == b0110011
                      // {1'b0, ins[14:12]}    if opcode == b0010011
                      // 4'b0                  otherwise
  input       flag,   // 1 if SRA/SRAI/SUB else 0
  output reg [`REG_LEN-1:0] result // use reg for simpler code
);

  always @* begin // a combo logic (no clock)
    case (alu_op)
      4'b0000: // ADD, SUB
        result = flag ? opr_1 - opr_2 : opr_1 + opr_2;
      4'b0001: // SLL
        result = opr_1 << opr_2[4:0];
      4'b0010: // SLT
        result = {31'b0, $signed(opr_1) < $signed(opr_2)};
      4'b0011: // SLTU
        result = {31'b0, opr_1 < opr_2};
      4'b0100: // XOR
        result = opr_1 ^ opr_2;
      4'b0101: // SRL, SRA
        // the $signed on the right is necessary, otherwise >>> would be unsigned shift
        result = flag ? $signed(opr_1) >>> opr_2[4:0] : $signed(opr_1 >> opr_2[4:0]);
      4'b0110: // OR
        result = opr_1 | opr_2;
      4'b0111: // AND
        result = opr_1 & opr_2;
      4'b1000: // MUL
        result = opr_1 * opr_2;
      4'b1001: // MULH
        result = {{{32{opr_1[31]}}, opr_1} * {{32{opr_2[31]}}, opr_2}} >> 32;
      4'b1010: // MULHSU
        result = {{{32{opr_1[31]}}, opr_1} * {32'b0, opr_2}} >> 32;
      4'b1011: // MULHU
        result = {{32'b0, opr_1} * {32'b0, opr_2}} >> 32;
      4'b1100: // DIV
        if (opr_2 == 32'b0) // divide by zero
          result = {32{1'b1}};
        else if (opr_1 == {1'b1, 31'b0} && opr_2 == {32{1'b1}}) // overflow
          result = opr_1;
        else
          result = $signed(opr_1) / $signed(opr_2);
      4'b1101: // DIVU
        result = opr_2 == 32'b0 ? {32{1'b1}} : opr_1 / opr_2;
      4'b1110: // REM
        if (opr_2 == 32'b0) // divide by zero
          result = opr_1;
        else if (opr_1 == {1'b1, 31'b0} && opr_2 == {32{1'b1}}) // overflow
          result = 32'b0;
        else
          result = $signed(opr_1) % $signed(opr_2);
      4'b1111: // REMU
        result = opr_2 == 32'b0 ? opr_1 : opr_1 % opr_2;
    endcase
  end

endmodule
