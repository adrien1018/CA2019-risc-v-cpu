module ALU_Control (
  ins,
  control,
  alu_op,
  flag,
  eq
);

  input  [4:0] ins;     // instruction[30|25|14:12]
  input  [1:0] control; // 2'b11 if opcode = b0110011 (reg arithmetic)
                        // 2'b10 if opcode = b0010011 (imm arithmetic)
                        // 2'b01 if opcode = b1100011 (branch)
                        // 2'b00 otherwise
  output [3:0] alu_op;
  output       flag;
  output       eq;

  assign alu_op = control == 2'b11 ? ins[3:0] :
                  control == 2'b10 ? {1'b0, ins[2:0]} :
                  control == 2'b01 ? {2'b0, ins[2:1]} : 4'b0;
  assign flag = (control[1] == 1'b1 && ins[2:0] == 3'b101 && ins[4]) || // SRA/SRAI
                (control == 2'b11 && ins[2:0] == 3'b000 && ins[4]) || // SUB
                (control == 2'b01 && !ins[2]); // BEQ/BNE
  assign eq = ~ins[2] ^ ins[0];

endmodule
