module Control (
  opcode,
  funct3,
  alu_control,
  alu_2_src,
  reg_write,
  is_branch,
  mem_write,
  mem_width,
  mem_sign_extend,
  load_mem
);

  input  [6:0] opcode; // instruction[6:0]
  input  [2:0] funct3; // instruction[14:12]
  output [1:0] alu_control;
  output       alu_2_src; // 1 if immediate, 0 if register
  output       reg_write;
  output       is_branch;
  output       mem_write;
  output [1:0] mem_width;
  output       mem_sign_extend;
  output       load_mem;

  assign alu_control = opcode == 7'b0010011 ? 2'b10 :
                       opcode == 7'b0110011 ? 2'b11 :
                       opcode == 7'b1100011 ? 2'b01 : 2'b00;
  assign alu_2_src = opcode != 7'b0110011 && opcode != 7'b1100011;
  assign reg_write = opcode[5:2] != 4'b1000; // store/branch does not write registers
  assign is_branch = opcode == 7'b1100011;
  assign mem_write = opcode == 7'b0100011;
  assign mem_width = funct3[1:0];
  assign mem_sign_extend = ~funct3[2];
  assign load_mem = opcode == 7'b0000011;

endmodule
