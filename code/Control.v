`include "Opcode.v"

module Control (
  input  [6:0] opcode, // instruction[6:0]
  input  [2:0] funct3, // instruction[14:12]
  input  [6:0] funct7, // instruction[31:25]
  output [1:0] alu_1_src, // 10 if PC, 01 if zero, 00 if register
  output       alu_2_src, // 1 if immediate, 0 if register
  output       reg_write,
  output       is_branch,
  output       is_jalr,
  output       is_jal,
  output       mem_read,
  output       mem_write,
  output [1:0] mem_width,
  output       mem_sign_extend,
  output [1:0] reg_src, // 10 if next PC, 01 if memory, 00 if ALU result
  output [3:0] alu_op,
  output       alu_flag
);

  assign alu_1_src = opcode == `OP_LUI   ? 2'b01 :
                     opcode == `OP_AUIPC ? 2'b10 : 2'b00;
  assign is_branch = opcode == `OP_BRANCH;
  assign alu_2_src = opcode != `OP_REGARI && opcode != `OP_BRANCH;
  assign reg_write = opcode != `OP_STORE && opcode != `OP_BRANCH;
  assign is_jalr = opcode == `OP_JALR;
  assign is_jal = opcode == `OP_JAL;
  assign mem_read = opcode == `OP_LOAD;
  assign mem_write = opcode == `OP_STORE;
  assign mem_width = funct3[1:0];
  assign mem_sign_extend = ~funct3[2];
  assign reg_src = (is_jal | is_jalr) ? 2'b10 :
                   opcode == `OP_LOAD ? 2'b01 : 2'b00;

  wire [1:0] control = opcode == `OP_IMMARI ? 2'b10 :
                       opcode == `OP_REGARI ? 2'b11 : 2'b00;
  assign alu_op = control == 2'b11 ? {funct7[0], funct3} :
                  control == 2'b10 ? {1'b0, funct3} : 4'b0;
  assign alu_flag = (control[1] == 1'b1 && funct3 == 3'b101 && funct7[5]) || // SRA/SRAI
                (control == 2'b11 && funct3 == 3'b000 && funct7[5]); // SUB

endmodule
