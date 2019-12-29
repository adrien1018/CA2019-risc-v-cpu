`define CYCLE_TIME 50

module TestBench;

reg          Clk;
reg          Reset;
reg          Start;
reg [1023:0] file;
reg [4:1]    stall;
reg [31:0]   insr[4:2];
reg [31:0]   pc[4:2];
reg          prev_stall;
integer      i;

wire [`DM_UNIT_MASK:0] mem_cpu_data;
wire                   mem_cpu_ack;
wire [`DM_UNIT_MASK:0] cpu_mem_data;
wire [`REG_LEN-1:0]    cpu_mem_addr;
wire                   cpu_mem_enable;
wire                   cpu_mem_write;

always #(`CYCLE_TIME/2) Clk = ~Clk;

CPU CPU(
  .clk_i        (Clk),
  .rst_i        (Reset),
  .start_i      (Start),
  .mem_data_i   (mem_cpu_data),
  .mem_ack_i    (mem_cpu_ack),
  .mem_data_o   (cpu_mem_data),
  .mem_addr_o   (cpu_mem_addr),
  .mem_enable_o (cpu_mem_enable),
  .mem_write_o  (cpu_mem_write)
);

Data_Memory data_memory(
  .clk_i    (Clk),
  .rst_i    (Reset),
  .addr_i   (cpu_mem_addr),
  .data_i   (cpu_mem_data),
  .enable_i (cpu_mem_enable),
  .write_i  (cpu_mem_write),
  .ack_o    (mem_cpu_ack),
  .data_o   (mem_cpu_data)
);

initial begin
  // Initialize state printing helper values
  for (i=1; i<=5; i=i+1) begin
    insr[i] = 32'hXXXXXXXX;
    pc[i] = 32'hXXXXXXXX;
  end
  stall = 5'b11111;
  // Initialize pipeline registers
  CPU.if_id.now_pc_o = 32'b0;
  CPU.if_id.inst_o = 32'b10011; // NOP
  CPU.if_id.prev_jalr_o = 1'b0;
  CPU.id_ex.reg_addr_o = 5'b0;
  CPU.id_ex.mem_read_o = 1'b0;
  CPU.id_ex.mem_write_o = 1'b0;
  CPU.ex_mem.reg_addr_o = 5'b0;
  CPU.ex_mem.mem_read_o = 1'b0;
  CPU.ex_mem.mem_write_o = 1'b0;
  CPU.mem_wb.write_addr_o = 5'b0;
  // initialize instruction memory
  for (i=0; i<=`IM_MASK; i=i+1)
    CPU.instruction_memory.memory[i] = 32'b0;
  // initialize data memory
  for (i=0; i<=`DM_MASK; i=i+1)
    data_memory.memory[i] = 256'b0;
  // initialize cache memory
  for (i=0; i<=`L1_INDEX_MASK; i=i+1) begin
    CPU.dcache.dcache_sram.tag_memory[i] = 24'b0;
    CPU.dcache.dcache_sram.data_memory[i] = 256'b0;
  end
  // initialize register file
  for (i=0; i<=`REG_NUM_MASK; i=i+1)
    CPU.registers.register[i] = 32'b0;

  // Load instructions into instruction memory
  if ($value$plusargs("file=%s", file))
    $readmemb(file, CPU.instruction_memory.memory);
  else
    $readmemb("../testdata/instruction.txt", CPU.instruction_memory.memory);
  // Rotate instruction memory to the correct position
  for (i=0; i<=`IM_MASK; i=i+1)
    CPU.instruction_memory.memory[(i+2)&`IM_MASK] <= CPU.instruction_memory.memory[i];

  Clk = 0;
  Reset = 0;
  Start = 0;
  prev_stall = 0;

  #(`CYCLE_TIME/4)
  Reset = 1;
  Start = 1;
  // Set PC & registers to match `jupiter` results
  CPU.PC.pc_o = 65544;
  CPU.registers.register[2] = 32'hbffffff0;
  CPU.registers.register[3] = 32'h10008000;
  CPU.registers.register[6] = 32'h10000;
end

always @(posedge Clk) begin
  if (0) // used for debugging
    $display("taken = %b, isbranch = %b, pc = %d, reg1/2 = %d/%d, fw4-2/3-2 = %b/%b, stall = %b",
      CPU.taken,
      CPU.is_branch,
      CPU.now_pc_2,
      CPU.reg_1_data,
      CPU.reg_2_data_2,
      CPU.fw_dm_reg2,
      CPU.fw_alu_reg2,
      CPU.hazard_stall,
    );

  if (!prev_stall) begin
    if (!stall[4])
      $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d 0x%x",
        $signed(CPU.registers.register[ 0]),
        $signed(CPU.registers.register[ 1]),
        $signed(CPU.registers.register[ 2]),
        $signed(CPU.registers.register[ 3]),
        $signed(CPU.registers.register[ 4]),
        $signed(CPU.registers.register[ 5]),
        $signed(CPU.registers.register[ 6]),
        $signed(CPU.registers.register[ 7]),
        $signed(CPU.registers.register[ 8]),
        $signed(CPU.registers.register[ 9]),
        $signed(CPU.registers.register[10]),
        $signed(CPU.registers.register[11]),
        $signed(CPU.registers.register[12]),
        $signed(CPU.registers.register[13]),
        $signed(CPU.registers.register[14]),
        $signed(CPU.registers.register[15]),
        $signed(CPU.registers.register[16]),
        $signed(CPU.registers.register[17]),
        $signed(CPU.registers.register[18]),
        $signed(CPU.registers.register[19]),
        $signed(CPU.registers.register[20]),
        $signed(CPU.registers.register[21]),
        $signed(CPU.registers.register[22]),
        $signed(CPU.registers.register[23]),
        $signed(CPU.registers.register[24]),
        $signed(CPU.registers.register[25]),
        $signed(CPU.registers.register[26]),
        $signed(CPU.registers.register[27]),
        $signed(CPU.registers.register[28]),
        $signed(CPU.registers.register[29]),
        $signed(CPU.registers.register[30]),
        $signed(CPU.registers.register[31]),
        pc[4],
        insr[4],
      );
    if (insr[4] == 32'b0) // instruction end
      $finish;
    for (i=3; i<=4; i=i+1) begin
      insr[i] <= insr[i-1];
      pc[i] <= pc[i-1];
    end
    insr[2] <= CPU.instruction_2;
    pc[2] <= CPU.now_pc_2;
    stall <= {stall[3:2], stall[1] | CPU.hazard_stall, CPU.next_nop};
  end
  prev_stall <= CPU.mem_stall_4;
end

endmodule
