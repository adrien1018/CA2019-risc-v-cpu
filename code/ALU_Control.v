module ALU_Control (
  ins,
  control,
  alu_op,
  flag,
);

  input  [4:0] ins;     // instruction[30|25|14:12]
  input        control; // 1'b1 if opcode = b0110011 (reg arithmetic)
                        // 1'b0 if opcode = b0010011 (imm arithmetic)
  output [3:0] alu_op;
  output       flag;

  assign alu_op = control ? ins[3:0] : {1'b0, ins[2:0]};
  assign flag = control && ins[2:0] == 3'b000 && ins[4]; // SUB

endmodule
