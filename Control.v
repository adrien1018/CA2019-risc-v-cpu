module Control (
  opcode,
  alu_control,
  alu_2_src,
  reg_write,
  is_branch
);

  input  [6:0] opcode; // instruction[6:0]
  output [1:0] alu_control;
  output       alu_2_src; // 1 if immediate, 0 if register
  output       reg_write;
  output       is_branch;

  assign alu_control = opcode == 7'b0010011 ? 2'b10 :
                       opcode == 7'b0110011 ? 2'b11 :
                       opcode == 7'b1100011 ? 2'b01 : 2'b00;
  assign alu_2_src = opcode != 7'b0110011 && opcode != 7'b1100011;
  assign reg_write = opcode[5:2] != 4'b1000; // store/branch
  assign is_branch = opcode == 7'b1100011;

endmodule
