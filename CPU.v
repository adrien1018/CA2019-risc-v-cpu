module CPU (
  clk_i,
  rst_i,
  start_i
);

  // Ports
  input clk_i;
  input rst_i;
  input start_i;

  // ----- Instruction fetch stage -----
  wire [31:0] instruction_1;

  wire [31:0] now_pc;
  wire [31:0] advance_pc;
  PC PC(
    .clk_i   (clk_i),
    .rst_i   (rst_i),
    .start_i (start_i),
    .pc_i    (advance_pc),
    .pc_o    (now_pc)
  );

  Adder pc_advance (
    .opr_1  (now_pc),
    .opr_2  (32'd4),
    .result (advance_pc)
  );

  Instruction_Memory Instruction_Memory(
    .addr_i  (now_pc),
    .instr_o (instruction_1)
  );

  // ----- Register read stage -----
  // . <-
  wire [31:0] reg_write_data_back2; // from stage 5
  // -> .
  wire [31:0] instruction_2 = instruction_1;
  // . ->
  wire [31:0] alu_1_opr_2;
  wire [31:0] alu_2_opr_2;
  wire [3:0]  alu_op_2;
  wire        flag_2;

  wire [31:0] reg_1_data;
  wire [31:0] reg_2_data;
  wire [31:0] imm;
  wire        alu_1_src;
  wire        alu_2_src;
  wire        alu_control;

  Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i  (instruction_2[19:15]),
    .RS2addr_i  (instruction_2[24:20]),
    .RDaddr_i   (instruction_2[11:7]),
    .RDdata_i   (reg_write_data_back2),
    .RegWrite_i (1'b1),
    .RS1data_o  (reg_1_data),
    .RS2data_o  (reg_2_data)
  );

  Control control(
    .opcode          (instruction_2[6:0]),
    .alu_control     (alu_control),
    .alu_2_src       (alu_2_src)
  );

  ALU_Control alu_ctrl_unit(
    .ins     ({instruction_2[30], instruction_2[25], instruction_2[14:12]}),
    .control (alu_control),
    .alu_op  (alu_op_2),
    .flag    (flag_2)
  );

  Immediate_Gen imm_gen(
    .insr   (instruction_2),
    .result (imm)
  );

  assign alu_1_opr_2 = reg_1_data;

  MUX32_2 mux_alu_2_opr (
    .in0     (reg_2_data),
    .in1     (imm),
    .control (alu_2_src),
    .result  (alu_2_opr_2)
  );

  // ----- ALU stage -----
  // -> .
  wire [31:0] alu_1_opr_3 = alu_1_opr_2;
  wire [31:0] alu_2_opr_3 = alu_2_opr_2;
  wire [3:0]  alu_op_3 = alu_op_2;
  wire        flag_3 = flag_2;
  // . ->
  wire [31:0] alu_result_3;

  ALU alu(
    .opr_1   (alu_1_opr_3),
    .opr_2   (alu_2_opr_3),
    .alu_op  (alu_op_3),
    .flag    (flag_3),
    .result  (alu_result_3)
  );

  // ----- Register write stage -----
  // -> . (<-)
  wire [31:0] reg_write_data_5 = alu_result_3;

  assign reg_write_data_back2 = reg_write_data_5;

endmodule

