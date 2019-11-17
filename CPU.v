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
  wire [31:0] next_pc_back1; // from stage 3
  wire [31:0] now_pc_1;
  wire [31:0] advance_pc_1;
  wire [31:0] instruction_1;

  PC PC(
    .clk_i   (clk_i),
    .rst_i   (rst_i),
    .start_i (start_i),
    .pc_i    (next_pc_back1),
    .pc_o    (now_pc_1)
  );

  Adder pc_advance (
    .opr_1  (now_pc_1),
    .opr_2  (32'd4),
    .result (advance_pc_1)
  );

  Instruction_Memory Instruction_Memory(
    .addr_i  (now_pc_1),
    .instr_o (instruction_1)
  );

  // ----- Register read stage -----
  wire [31:0] instruction_2 = instruction_1;
  wire [31:0] reg_write_data_back2; // from stage 5
  wire        reg_write_back2; // from stage 5
  wire [31:0] now_pc_2 = now_pc_1;
  wire [31:0] advance_pc_2 = advance_pc_1;
  wire [31:0] alu_1_opr_2;
  wire [31:0] alu_2_opr_2;
  wire [31:0] imm_2;
  wire [3:0]  alu_op_2;
  wire        flag_2;
  wire        eq_2;
  wire        reg_write_2;
  wire        is_branch_2;

  wire [31:0] reg_1_data;
  wire [31:0] reg_2_data;
  wire        alu_2_src;
  wire [1:0]  alu_control;

  Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i  (instruction_2[19:15]),
    .RS2addr_i  (instruction_2[24:20]),
    .RDaddr_i   (instruction_2[11:7]),
    .RDdata_i   (reg_write_data_back2),
    .RegWrite_i (reg_write_back2),
    .RS1data_o  (reg_1_data),
    .RS2data_o  (reg_2_data)
  );

  Control control(
    .opcode      (instruction_2[6:0]),
    .alu_control (alu_control),
    .alu_2_src   (alu_2_src),
    .reg_write   (reg_write_2),
    .is_branch   (is_branch_2)
  );

  ALU_Control alu_ctrl_unit(
    .ins     ({instruction_2[30], instruction_2[25], instruction_2[14:12]}),
    .control (alu_control),
    .alu_op  (alu_op_2),
    .flag    (flag_2),
    .eq      (eq_2)
  );

  Immediate_Gen imm_gen(
    .insr   (instruction_2),
    .result (imm_2)
  );

  assign alu_1_opr_2 = reg_1_data;

  MUX32_2 mux_alu_2_opr (
    .in0     (reg_2_data),
    .in1     (imm_2),
    .control (alu_2_src),
    .result  (alu_2_opr_2)
  );

  // ----- ALU stage -----
  wire [31:0] now_pc_3 = now_pc_2;
  wire [31:0] advance_pc_3 = advance_pc_2;
  wire [31:0] alu_1_opr_3 = alu_1_opr_2;
  wire [31:0] alu_2_opr_3 = alu_2_opr_2;
  wire [31:0] imm_3 = imm_2;
  wire [3:0]  alu_op_3 = alu_op_2;
  wire        flag_3 = flag_2;
  wire        eq_3 = eq_2;
  wire        is_branch_3 = is_branch_2;
  wire        reg_write_3 = reg_write_2;
  // wire[31:0] taken_pc_3;
  wire [31:0] alu_result_3;

  wire        taken;
  wire [31:0] branch_target;

  Adder branch_dest_adder(
    .opr_1  (now_pc_3),
    .opr_2  (imm_3),
    .result (branch_target)
  );

  ALU alu(
    .opr_1   (alu_1_opr_3),
    .opr_2   (alu_2_opr_3),
    .alu_op  (alu_op_3),
    .flag    (flag_3),
    .eq      (eq_3),
    .result  (alu_result_3),
    .taken   (taken)
  );

  MUX32_2 mux_next_pc(
    .in0     (advance_pc_3),
    .in1     (branch_target),
    .control (taken && is_branch_3),
    .result  (next_pc_back1)
  );

  // ----- Data write stage (omitted) -----
  wire [31:0] alu_result_4 = alu_result_3;
  wire        reg_write_4 = reg_write_3;
  wire [31:0] reg_write_data_4;

  assign reg_write_data_4 = alu_result_4;

  // ----- Register write stage -----
  wire [31:0] reg_write_data_5 = reg_write_data_4;
  wire        reg_write_5 = reg_write_4;

  assign reg_write_data_back2 = reg_write_data_5;
  assign reg_write_back2 = reg_write_5;

endmodule

