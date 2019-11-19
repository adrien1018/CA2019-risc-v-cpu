module Control (
  opcode,
  alu_control,
  alu_2_src,
);

  input  [6:0] opcode; // instruction[6:0]
  output       alu_control;
  output       alu_2_src; // 1 if immediate, 0 if register

  assign alu_control = opcode != 7'b0010011;
  assign alu_2_src = opcode != 7'b0110011; // register arithmetic

endmodule
