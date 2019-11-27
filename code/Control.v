module Control (
  opcode,
  funct3,
  funct7,
  alu_1_src,
  alu_2_src,
  reg_write,
  is_branch,
  is_jalr,
  is_jal,
  mem_write,
  mem_width,
  mem_sign_extend,
  reg_src,
  alu_op,
  alu_flag
);

  input  [6:0] opcode; // instruction[6:0]
  input  [2:0] funct3; // instruction[14:12]
  input  [6:0] funct7; // instruction[31:25]
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
  output [3:0] alu_op;
  output       alu_flag;

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

  wire [1:0] control = opcode == 7'b0010011 ? 2'b10 : // imm arithmetic
                       opcode == 7'b0110011 ? 2'b11 : // reg arithmetic
                       2'b00;
  assign alu_op = control == 2'b11 ? {funct7[0], funct3} :
                  control == 2'b10 ? {1'b0, funct3} : 4'b0;
  assign alu_flag = (control[1] == 1'b1 && funct3 == 3'b101 && funct7[5]) || // SRA/SRAI
                (control == 2'b11 && funct3 == 3'b000 && funct7[5]); // SUB

endmodule
