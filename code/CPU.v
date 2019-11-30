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
  wire [31:0] next_pc_back1_2; // from stage 2
  wire [31:0] next_pc_back1_3; // from stage 3 (indir branch)
  wire [31:0] next_pc_jump;
  wire        next_pc_control_back1; // from stage 2
  wire [31:0] now_pc_1;
  wire [31:0] advance_pc_1;
  wire [31:0] instruction_1;

  wire [31:0] next_pc;

  PC PC(
    .clk_i   (clk_i),
    .rst_i   (rst_i),
    .start_i (start_i),
    .pc_i    (next_pc),
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

  MUX32_2 mux_next_pc_jump(
    .in0     (next_pc_back1_2),
    .in1     (next_pc_back1_3),
    .control (next_pc_control_back1),
    .result  (next_pc_jump)
  );

  MUX32_2 mux_next_pc(
    .in0 (advance_pc_1),
    .in1 (next_pc_jump),
    .control (is_jalr | is_jal | (taken & is_branch)),
    .result (next_pc)
  );

  // ----- Register read stage -----
  // . <-
  wire [31:0] reg_write_data_back2; // from stage 5
  wire        reg_write_back2;      // from stage 5
  wire [4:0]  reg_write_addr_back2; // from stage 5
  // -> .
  wire [31:0] now_pc_2;
  // -> . ->
  wire [31:0] instruction_2_a;
  wire [31:0] instruction_2;
  wire [31:0] advance_pc_2;
  // . ->
  wire [31:0] alu_1_opr_2;
  wire [31:0] alu_2_opr_2;
  wire [3:0]  alu_op_2;
  wire        alu_flag_2;
  wire        reg_write_2;
  wire [4:0]  reg_write_data_addr_2 = instruction_2[11:7];
  wire        mem_write_2;
  wire [1:0]  mem_width_2;
  wire        mem_sign_extend_2;
  wire [1:0]  reg_src_2;
  wire [31:0] reg_2_data_2;

  wire [31:0] reg_2_data_2_file;
  wire [31:0] reg_2_data_2_forward = reg_2_data_2_file; //TODO
  wire        reg_2_data_2_src = 0; //TODO
  wire [31:0] branch_target;
  wire [31:0] imm;
  wire [31:0] reg_1_data;
  wire [31:0] reg_1_data_file;
  wire [31:0] reg_1_data_forward = reg_1_data_file; //TODO
  wire        reg_1_data_src = 0; //TODO
  wire [1:0]  alu_1_src;
  wire        alu_2_src_2;
  wire [1:0]  alu_control;
  wire        taken;
  wire        is_branch;
  wire        is_jal;
  wire        is_jalr;
  wire        is_nop = 0;

  MUX32_2 mux_inst_or_nop(
    .in0     (instruction_2_a),
    .in1     (32'b0),
    .control (is_nop),
    .result  (instruction_2)
  );

  Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i  (instruction_2[19:15]),
    .RS2addr_i  (instruction_2[24:20]),
    .RDaddr_i   (reg_write_addr_back2),
    .RDdata_i   (reg_write_data_back2),
    .RegWrite_i (reg_write_back2),
    .RS1data_o  (reg_1_data_file),
    .RS2data_o  (reg_2_data_2_file)
  );

  MUX32_2 mux_reg_2_data_2 (
    .in0     (reg_2_data_2_file),
    .in1     (reg_2_data_2_forward),
    .control (reg_2_data_2_src),
    .result  (reg_2_data_2)
  );

  MUX32_2 mux_reg_1_data (
    .in0     (reg_1_data_file),
    .in1     (reg_1_data_forward),
    .control (reg_1_data_src),
    .result  (reg_1_data)
  );

  BranchDecision branch_dec(
    .opr_1 (reg_1_data),
    .opr_2 (reg_2_data_2),
    .op    (instruction_2[14:12]),
    .taken (taken)
  );

  Control control(
    .opcode          (instruction_2[6:0]),
    .funct3          (instruction_2[14:12]),
    .funct7          (instruction_2[31:25]),
    .alu_1_src       (alu_1_src),
    .alu_2_src       (alu_2_src_2),
    .reg_write       (reg_write_2),
    .is_branch       (is_branch),
    .is_jalr         (is_jalr),
    .is_jal          (is_jal),
    .mem_write       (mem_write_2),
    .mem_width       (mem_width_2),
    .mem_sign_extend (mem_sign_extend_2),
    .reg_src         (reg_src_2),
    .alu_op          (alu_op_2),
    .alu_flag        (alu_flag_2)
  );

  Immediate_Gen imm_gen(
    .insr   (instruction_2),
    .result (imm)
  );

  MUX32_4 mux_alu_1_opr (
    .in0     (reg_1_data),
    .in1     (32'b0),
    .in2     (now_pc_1),
    .in3     (32'hXXXXXXXX),
    .control (alu_1_src),
    .result  (alu_1_opr_2)
  );

  MUX32_2 mux_alu_2_opr (
    .in0     (reg_2_data_2),
    .in1     (imm),
    .control (alu_2_src_2),
    .result  (alu_2_opr_2)
  );

  Adder branch_dest_adder(
    .opr_1  (now_pc_2),
    .opr_2  (imm),
    .result (branch_target)
  );

  assign next_pc_back1_2 = branch_target;
  assign next_pc_control_back1 = is_jalr;

  // ----- ALU stage -----
  // -> .
  wire [31:0] alu_1_opr_3_flow;
  wire [31:0] alu_2_opr_3_flow;
  wire [3:0]  alu_op_3;
  wire        alu_flag_3;
  wire        alu_2_src_3;
  wire        is_reg1;
  // -> . ->
  wire [31:0] advance_pc_3;
  wire [31:0] reg_2_data_3;
  wire [31:0] reg_2_data_3_flow;
  wire [31:0] reg_2_data_3_forward = reg_2_data_3_flow; //TODO
  wire        reg_2_data_3_src = 0; //TODO
  wire        reg_write_3;
  wire [4:0]  reg_write_data_addr_3;
  wire        mem_write_3;
  wire [1:0]  mem_width_3;
  wire        mem_sign_extend_3;
  wire [1:0]  reg_src_3;
  // . ->
  wire [31:0] alu_result_3;

  wire [31:0] alu_1_opr_3;
  wire [31:0] alu_2_opr_3;
  wire        alu_1_opr_3_src = is_reg1 & 0; //TODO: forward
  wire        alu_2_opr_3_src = !(alu_2_src_3) & 0; //TODO: forward
  wire [31:0] alu_1_opr_3_forward = alu_1_opr_3_flow; //TODO
  wire [31:0] alu_2_opr_3_forward = alu_2_opr_3_flow; //TODO

  MUX32_2 mux_alu_1_opr_3 (
    .in0     (alu_1_opr_3_flow),
    .in1     (alu_1_opr_3_forward),
    .control (alu_1_opr_3_src),
    .result  (alu_1_opr_3)
  );

  MUX32_2 mux_alu_2_opr_3 (
    .in0     (alu_2_opr_3_flow),
    .in1     (alu_2_opr_3_forward),
    .control (alu_2_opr_3_src),
    .result  (alu_2_opr_3)
  );

  MUX32_2 mux_reg_2_data_3 (
    .in0     (reg_2_data_3_flow),
    .in1     (reg_2_data_3_forward),
    .control (reg_2_data_3_src),
    .result  (reg_2_data_3)
  );

  ALU alu(
    .opr_1   (alu_1_opr_3),
    .opr_2   (alu_2_opr_3),
    .alu_op  (alu_op_3),
    .flag    (alu_flag_3),
    .result  (alu_result_3)
  );

  assign next_pc_back1_3 = alu_result_3;

  // ----- Data write stage -----
  // -> .
  wire [31:0] advance_pc_4;
  wire [31:0] alu_result_4;
  wire [31:0] reg_2_data_4;
  wire        reg_write_4;
  wire [4:0]  reg_write_data_addr_4;
  wire [1:0]  mem_width_4;
  wire        mem_sign_extend_4;
  wire [1:0]  reg_src_4;
  // -> . ->
  wire        mem_write_4;
  // . ->
  wire [31:0] reg_write_data_4;

  wire [31:0] mem_data;

  Data_Memory data_mem(
    .clk         (clk_i),
    .addr        (alu_result_4),
    .data        (reg_2_data_4),
    .width       (mem_width_4),
    .memwrite    (mem_write_4),
    .sign_extend (mem_sign_extend_4),
    .result      (mem_data)
  );

  MUX32_4 mux_reg_write_data(
    .in0     (alu_result_4),
    .in1     (mem_data),
    .in2     (advance_pc_4),
    .in3     (32'hXXXXXXXX),
    .control (reg_src_4),
    .result  (reg_write_data_4)
  );

  // ----- Register write stage -----
  // -> . (<-)
  wire [31:0] reg_write_data_5;
  wire        reg_write_5;
  wire [4:0]  reg_write_data_addr_5;

  assign reg_write_data_back2 = reg_write_data_5;
  assign reg_write_back2 = reg_write_5;
  assign reg_write_addr_back2 = reg_write_data_addr_5;

  // ----- IF/ID -----
  IF_ID if_id(
    .clk          (clk_i),
    .now_pc_i     (now_pc_1),
    .inst_i       (instruction_1),
    .advance_pc_i (advance_pc_1),
    .now_pc_o     (now_pc_2),
    .inst_o       (instruction_2_a),
    .advance_pc_o (advance_pc_2)
  );

  // ----- ID/EX -----
  ID_EX id_ex(
    .clk                   (clk_i),
    .alu_1_opr_i           (alu_1_opr_2),
    .alu_2_opr_i           (alu_2_opr_2),
    .alu_op_i              (alu_op_2),
    .alu_flag_i            (alu_flag_2),
    .advance_pc_i          (advance_pc_2),
    .reg_2_data_i          (reg_2_data_2),
    .reg_write_i           (reg_write_2),
    .reg_write_data_addr_i (reg_write_data_addr_2),
    .mem_write_i           (mem_write_2),
    .mem_width_i           (mem_width_2),
    .mem_sign_extend_i     (mem_sign_extend_2),
    .reg_src_i             (reg_src_2),
    .alu_1_opr_o           (alu_1_opr_3_flow),
    .alu_2_opr_o           (alu_2_opr_3_flow),
    .alu_op_o              (alu_op_3),
    .alu_flag_o            (alu_flag_3),
    .advance_pc_o          (advance_pc_3),
    .reg_2_data_o          (reg_2_data_3_flow),
    .reg_write_o           (reg_write_3),
    .reg_write_data_addr_o (reg_write_data_addr_3),
    .mem_write_o           (mem_write_3),
    .mem_width_o           (mem_width_3),
    .mem_sign_extend_o     (mem_sign_extend_3),
    .reg_src_o             (reg_src_3)
  );

  // ----- EX/MEM -----
  EX_MEM ex_mem(
    .clk                   (clk_i),
    .advance_pc_i          (advance_pc_3),
    .alu_result_i          (alu_result_3),
    .reg_2_data_i          (reg_2_data_3),
    .reg_write_i           (reg_write_3),
    .reg_write_data_addr_i (reg_write_data_addr_3),
    .mem_width_i           (mem_width_3),
    .mem_sign_extend_i     (mem_sign_extend_3),
    .reg_src_i             (reg_src_3),
    .mem_write_i           (mem_write_3),
    .alu_1_src_i           (alu_1_src),
    .alu_2_src_i           (alu_2_src_2),
    .advance_pc_o          (advance_pc_4),
    .alu_result_o          (alu_result_4),
    .reg_2_data_o          (reg_2_data_4),
    .reg_write_o           (reg_write_4),
    .reg_write_data_addr_o (reg_write_data_addr_4),
    .mem_width_o           (mem_width_4),
    .mem_sign_extend_o     (mem_sign_extend_4),
    .reg_src_o             (reg_src_4),
    .mem_write_o           (mem_write_4),
    .is_reg1_o             (is_reg1),
    .alu_2_src_o           (alu_2_src_3)
  );

  // ----- MEM/WB -----
  MEM_WB mem_wb(
    .clk                   (clk_i),
    .reg_write_data_i      (reg_write_data_4),
    .reg_write_data_addr_i (reg_write_data_addr_4),
    .reg_write_i           (reg_write_4),
    .reg_write_data_o      (reg_write_data_5),
    .reg_write_data_addr_o (reg_write_data_addr_5),
    .reg_write_o           (reg_write_5)
  );

endmodule

