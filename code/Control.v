module Control (
  opcode,
  funct3,
  alu_control,
  alu_1_src,
  alu_2_src,
  reg_write,
  is_branch,
  is_jalr,
  is_jal,
  mem_write,
  mem_width,
  mem_sign_extend,
  reg_src
);

  input  [6:0] opcode; // instruction[6:0]
  input  [2:0] funct3; // instruction[14:12]
  output [1:0] alu_control;
  output [1:0] alu_1_src; // 10 if PC, 01 if zero, 00 if register
  output       alu_2_src; // 1 if immediate, 0 if register
  output       reg_write;
  output       is_branch;
  output       is_jalr;
  output       is_jal;
  output       mem_write;
  output [1:0] mem_width;
  output       mem_sign_extend;
  output [1:0] reg_src; // 10 if next PC, 01 if memory, 00 if ALU result

  assign alu_control = opcode == 7'b0010011 ? 2'b10 :
                       opcode == 7'b0110011 ? 2'b11 : 2'b00;
  assign alu_1_src = opcode == 7'b0110111 ? 2'b01 : // LUI
                     opcode == 7'b0010111 ? 2'b10 /* AUIPC */ : 2'b00;
  assign alu_2_src = opcode != 7'b0110011 && // register arithmetic
                     opcode != 7'b1100011;   // branch
  assign reg_write = opcode[5:2] != 4'b1000; // store/branch does not write registers
  assign is_branch = opcode == 7'b1100011;
  assign is_jalr = opcode == 7'b1100111;
  assign is_jal = opcode == 7'b1101111;
  assign mem_write = opcode == 7'b0100011;
  assign mem_width = funct3[1:0];
  assign mem_sign_extend = ~funct3[2];
  assign reg_src = (is_jal | is_jalr) ? 2'b10 :
                   opcode == 7'b0000011 ? 2'b01 /* load */ : 2'b00;

endmodule
