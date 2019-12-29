`define CYCLE_TIME 50

module TestBench;

reg           Clk;
reg           Start;
reg           Reset;
integer       i, outfile, outfile2, counter;
reg           flag;
reg  [26:0]   address;
reg  [23:0]   tag;
reg  [4:0]    index;
reg  [1023:0] file;

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
  $dumpfile ("invchn26.vcd");
  $dumpvars;
  counter = 0;
  // initialize instruction memory (1KB)
  for (i=0; i<=`IM_MASK; i=i+1) begin
    CPU.instruction_memory.memory[i] = 32'b0;
  end
  // initialize data memory    (16KB)
  for (i=0; i<=`DM_MASK; i=i+1) begin
    data_memory.memory[i] = 256'b0;
  end
  // initialize cache memory    (1KB)
  for (i=0; i<=`L1_INDEX_MASK; i=i+1) begin
    CPU.dcache.dcache_sram.tag_memory[i] = 24'b0;
    CPU.dcache.dcache_sram.data_memory[i] = 256'b0;
  end
  // initialize Register File
  for (i=0; i<32; i=i+1) begin
    CPU.registers.register[i] = 32'b0;
  end
  // initialize pipeline registers
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

  // Load instructions into instruction memory
  if ($value$plusargs("file=%s", file))
    $readmemb(file, CPU.instruction_memory.memory);
  else
    $readmemb("../testdata/instruction.txt", CPU.instruction_memory.memory);

  // Open output file
  outfile = $fopen("../testdata/output.txt");
  outfile2 = $fopen("../testdata/cache.txt");
  //outfile = $fopen("../testdata/output.txt") | 1;
  //outfile2 = $fopen("../testdata/cache.txt") | 1;

  // Set Input n into data memory at 0x00
  data_memory.memory[0] = 256'h5;        // n = 5 for example

  Clk = 0;
  Reset = 0;
  Start = 0;

  #(`CYCLE_TIME/4)
  Reset = 1;
  Start = 1;
end

always@(posedge Clk) begin
  if(counter == 150) begin    // store cache to memory
    $fdisplay(outfile, "Flush Cache! \n");
    for(i=0; i<32; i=i+1) begin
      tag = CPU.dcache.dcache_sram.tag_memory[i];
      index = i;
      address = {tag[21:0], index};
      data_memory.memory[address] = CPU.dcache.dcache_sram.data_memory[i];
    end
  end
  if(counter > 150) begin    // stop
    $finish;
  end

  // print PC
  $fdisplay(outfile, "cycle = %0d, Start = %b\nPC = %d", counter, Start, CPU.PC.pc_o);

  if (0) begin // debug
    $fdisplay(outfile, "read%b, write%b, p1_req%b, sram_tag = %x, cache_tag = %x, state = %d",
        CPU.dcache.p1_MemRead_i,
        CPU.dcache.p1_MemWrite_i,
        CPU.dcache.p1_req,
        CPU.dcache.sram_cache_tag,
        CPU.dcache.cache_sram_tag,
        CPU.dcache.state
    );
  end

  // print Registers
  $fdisplay(outfile, "Registers");
  $fdisplay(outfile, "x0 = %h, x8  = %h, x16 = %h, x24 = %h", CPU.registers.register[0], CPU.registers.register[8] , CPU.registers.register[16], CPU.registers.register[24]);
  $fdisplay(outfile, "x1 = %h, x9  = %h, x17 = %h, x25 = %h", CPU.registers.register[1], CPU.registers.register[9] , CPU.registers.register[17], CPU.registers.register[25]);
  $fdisplay(outfile, "x2 = %h, x10 = %h, x18 = %h, x26 = %h", CPU.registers.register[2], CPU.registers.register[10], CPU.registers.register[18], CPU.registers.register[26]);
  $fdisplay(outfile, "x3 = %h, x11 = %h, x19 = %h, x27 = %h", CPU.registers.register[3], CPU.registers.register[11], CPU.registers.register[19], CPU.registers.register[27]);
  $fdisplay(outfile, "x4 = %h, x12 = %h, x20 = %h, x28 = %h", CPU.registers.register[4], CPU.registers.register[12], CPU.registers.register[20], CPU.registers.register[28]);
  $fdisplay(outfile, "x5 = %h, x13 = %h, x21 = %h, x29 = %h", CPU.registers.register[5], CPU.registers.register[13], CPU.registers.register[21], CPU.registers.register[29]);
  $fdisplay(outfile, "x6 = %h, x14 = %h, x22 = %h, x30 = %h", CPU.registers.register[6], CPU.registers.register[14], CPU.registers.register[22], CPU.registers.register[30]);
  $fdisplay(outfile, "x7 = %h, x15 = %h, x23 = %h, x31 = %h", CPU.registers.register[7], CPU.registers.register[15], CPU.registers.register[23], CPU.registers.register[31]);

  // print Data Memory
  $fdisplay(outfile, "Data Memory: 0x0000 = %h", data_memory.memory[0]);
  $fdisplay(outfile, "Data Memory: 0x0020 = %h", data_memory.memory[1]);
  $fdisplay(outfile, "Data Memory: 0x0040 = %h", data_memory.memory[2]);
  $fdisplay(outfile, "Data Memory: 0x0060 = %h", data_memory.memory[3]);
  $fdisplay(outfile, "Data Memory: 0x0080 = %h", data_memory.memory[4]);
  $fdisplay(outfile, "Data Memory: 0x00A0 = %h", data_memory.memory[5]);
  $fdisplay(outfile, "Data Memory: 0x00C0 = %h", data_memory.memory[6]);
  $fdisplay(outfile, "Data Memory: 0x00E0 = %h", data_memory.memory[7]);
  $fdisplay(outfile, "Data Memory: 0x0400 = %h", data_memory.memory[32]);

  $fdisplay(outfile, "\n");

  // print Data Cache Status
  if(CPU.dcache.p1_stall_o && CPU.dcache.state==0) begin
    if(CPU.dcache.sram_dirty) begin
      if(CPU.dcache.p1_MemWrite_i)
        $fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h (Write Back!)", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
      else if(CPU.dcache.p1_MemRead_i)
        $fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h (Write Back!)", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
    end
    else begin
      if(CPU.dcache.p1_MemWrite_i)
        $fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
      else if(CPU.dcache.p1_MemRead_i)
        $fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
    end
    flag = 1'b1;
  end
  else if(!CPU.dcache.p1_stall_o) begin
    if(!flag) begin
      if(CPU.dcache.p1_MemWrite_i)
        $fdisplay(outfile2, "Cycle: %d, Write Hit , Address: %h, Write Data: %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_i);
      else if(CPU.dcache.p1_MemRead_i)
        $fdisplay(outfile2, "Cycle: %d, Read Hit  , Address: %h, Read Data : %h", counter, CPU.dcache.p1_addr_i, CPU.dcache.p1_data_o);
    end
    flag = 1'b0;
  end
  counter = counter + 1;
end

endmodule
