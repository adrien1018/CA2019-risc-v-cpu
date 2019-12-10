`define CYCLE_TIME 50

module TestBench;

reg          Clk;
reg          Reset;
reg          Start;
reg [1023:0] file;
reg [5:1]    stall;
reg [31:0]   insr[5:1];
reg [31:0]   pc[5:1];
integer      i;

always #(`CYCLE_TIME/2) Clk = ~Clk;

CPU CPU(
  .clk_i  (Clk),
  .rst_i  (Reset),
  .start_i(Start)
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
  CPU.id_ex.mem_write_o = 1'b0;
  CPU.ex_mem.reg_addr_o = 5'b0;
  CPU.ex_mem.mem_write_o = 1'b0;
  CPU.mem_wb.write_addr_o = 5'b0;
  // Initialize instruction memory
  for (i=0; i<256; i=i+1)
    CPU.Instruction_Memory.memory[i] = 32'b0;
  // Initialize data memory
  for (i=0; i<1024; i=i+1)
    CPU.data_mem.memory[i] = 32'b0;
  // Initialize register File
  for (i=0; i<32; i=i+1)
    CPU.Registers.register[i] = 32'b0;
  // Load instructions into instruction memory
  if ($value$plusargs("file=%s", file))
    $readmemb(file, CPU.Instruction_Memory.memory);
  else
    $readmemb("instruction.txt", CPU.Instruction_Memory.memory);
  // Rotate instruction memory to the correct position
  for (i=0; i<256; i=i+1)
    CPU.Instruction_Memory.memory[(i+2)&255] <= CPU.Instruction_Memory.memory[i];

  Clk = 0;
  Reset = 0;
  Start = 0;

  #(`CYCLE_TIME/4)
  Reset = 1;
  Start = 1;
  // Set PC & registers to match `jupiter` results
  CPU.PC.pc_o = 65544;
  CPU.Registers.register[2] = 32'hbffffff0;
  CPU.Registers.register[3] = 32'h10008000;
  CPU.Registers.register[6] = 32'h10000;
end

always@(posedge Clk) begin
  if (0) // used for debugging
    $display("pc1=%d pc2=%d pc_stage1=%d stall=%b",
      pc[1],
      pc[2],
      CPU.now_pc_1,
      stall,
    );
  if (!stall[4])
    $display("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d 0x%x",
      $signed(CPU.Registers.register[ 0]),
      $signed(CPU.Registers.register[ 1]),
      $signed(CPU.Registers.register[ 2]),
      $signed(CPU.Registers.register[ 3]),
      $signed(CPU.Registers.register[ 4]),
      $signed(CPU.Registers.register[ 5]),
      $signed(CPU.Registers.register[ 6]),
      $signed(CPU.Registers.register[ 7]),
      $signed(CPU.Registers.register[ 8]),
      $signed(CPU.Registers.register[ 9]),
      $signed(CPU.Registers.register[10]),
      $signed(CPU.Registers.register[11]),
      $signed(CPU.Registers.register[12]),
      $signed(CPU.Registers.register[13]),
      $signed(CPU.Registers.register[14]),
      $signed(CPU.Registers.register[15]),
      $signed(CPU.Registers.register[16]),
      $signed(CPU.Registers.register[17]),
      $signed(CPU.Registers.register[18]),
      $signed(CPU.Registers.register[19]),
      $signed(CPU.Registers.register[20]),
      $signed(CPU.Registers.register[21]),
      $signed(CPU.Registers.register[22]),
      $signed(CPU.Registers.register[23]),
      $signed(CPU.Registers.register[24]),
      $signed(CPU.Registers.register[25]),
      $signed(CPU.Registers.register[26]),
      $signed(CPU.Registers.register[27]),
      $signed(CPU.Registers.register[28]),
      $signed(CPU.Registers.register[29]),
      $signed(CPU.Registers.register[30]),
      $signed(CPU.Registers.register[31]),
      pc[4],
      insr[4],
    );
  if (insr[4] == 32'b0) // instruction end
    $finish;
  for (i=2; i<=5; i=i+1) begin
    insr[i] <= insr[i-1];
    pc[i] <= pc[i-1];
  end
  insr[1] <= CPU.instruction_1;
  pc[1] <= CPU.now_pc_1;
  stall <= {stall[4:2], stall[1] | CPU.hazard_stall, CPU.next_nop};
end

endmodule
