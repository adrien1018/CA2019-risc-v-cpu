module Control (
  opcode,
  alu_control,
  alu_src_2,
  reg_write
);

  input  [6:0] opcode; // instruction[6:0]
  output [1:0] alu_control;
  output       alu_src_2; // 1 if immediate, 0 if register
  output       reg_write;

  assign alu_control = {opcode[6], opcode[4:0]} == 6'b010011 ? 2'b01;
                       opcode == 7'b1100011 ? 2'b10 : 2'b00;
  assign alu_src_2 = opcode[6:4] != 3'b011;
  assign reg_write = opcode[5:2] != 4'b1000; // store/branch

endmodule
