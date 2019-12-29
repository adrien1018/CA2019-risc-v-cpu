`define L1_SIZE 10
`define L1_TAG_SIZE (`REG_LEN-`L1_SIZE)
`define L1_TAG_MEM_SIZE (`L1_TAG_SIZE+2) // +valid/dirty bits
`define L1_INDEX_SIZE (`L1_SIZE-`DM_BYTE_UNIT)
`define L1_INDEX_MASK ((1<<`L1_INDEX_SIZE)-1)

module DCache_Top(
  // System clock, start
  input                    clk_i,
  input                    rst_i,
  // to Data Memory interface
  input  [`DM_UNIT_MASK:0] mem_data_i,
  input                    mem_ack_i,
  output [`DM_UNIT_MASK:0] mem_data_o,
  output [`REG_LEN-1:0]    mem_addr_o,
  output                   mem_enable_o,
  output                   mem_write_o,
  // to core interface
  input  [`REG_LEN-1:0] p1_data_i,
  input  [`REG_LEN-1:0] p1_addr_i,
  input                 p1_MemRead_i,
  input                 p1_MemWrite_i,
  output [`REG_LEN-1:0] p1_data_o,
  output                p1_stall_o
);

wire [`DM_BYTE_UNIT-1:0]    cache_sram_index;
wire                        cache_sram_enable;
wire [`L1_TAG_MEM_SIZE-1:0] cache_sram_tag;
wire [`DM_UNIT_MASK:0]      cache_sram_data;
wire                        cache_sram_write;
wire [`L1_TAG_MEM_SIZE-1:0] sram_cache_tag;
wire [`DM_UNIT_MASK:0]      sram_cache_data;
wire                        sram_valid;
wire                        sram_dirty;

// controller
parameter STATE_IDLE       = 2'h0,
          STATE_READMISS   = 2'h1,
          STATE_READMISSOK = 2'h2,
          STATE_WRITEBACK  = 2'h3;
reg [1:0] state;
reg       mem_enable;
reg       mem_write;
reg       cache_we;
wire      cache_dirty;
reg       write_back;

// regs & wires
wire    [`DM_BYTE_UNIT-1:0]  p1_offset;
wire    [`L1_INDEX_SIZE-1:0] p1_index;
wire    [`L1_TAG_SIZE-1:0]   p1_tag;
wire    [`DM_UNIT_MASK:0]    r_hit_data;
wire    [`L1_TAG_SIZE-1:0]   sram_tag;
wire                         hit;
reg     [`DM_UNIT_MASK:0]    w_hit_data;
wire                         write_hit;
wire                         p1_req;
reg     [`REG_LEN-1:0]       p1_data;

// project1 interface
assign    p1_req     = p1_MemRead_i | p1_MemWrite_i;
assign    p1_offset  = p1_addr_i[`DM_BYTE_UNIT-1:0];
assign    p1_index   = p1_addr_i[`L1_SIZE-1:`DM_BYTE_UNIT];
assign    p1_tag     = p1_addr_i[`REG_LEN-1:`L1_SIZE];
assign    p1_stall_o = ~hit & p1_req;
//assign    p1_data_o  = r_hit_data >> (32 * p1_offset);
assign    p1_data_o  = p1_data;

// SRAM interface
assign    sram_valid = sram_cache_tag[`L1_TAG_SIZE+1];
assign    sram_dirty = sram_cache_tag[`L1_TAG_SIZE];
assign    sram_tag   = sram_cache_tag[`L1_TAG_SIZE-1:0];
assign    cache_sram_index  = p1_index;
assign    cache_sram_enable = p1_req;
assign    cache_sram_write  = cache_we | write_hit;
assign    cache_sram_tag    = {1'b1, cache_dirty, p1_tag};
assign    cache_sram_data   = (hit) ? w_hit_data : mem_data_i;

// memory interface
assign    mem_enable_o = mem_enable;
assign    mem_addr_o   = (write_back) ? {sram_tag, p1_index, 5'b0} : {p1_tag, p1_index, 5'b0};
assign    mem_data_o   = sram_cache_data;
assign    mem_write_o  = mem_write;

assign    write_hit    = hit & p1_MemWrite_i;
assign    cache_dirty  = write_hit;

   // tag comparator
   assign hit = sram_valid && sram_tag == p1_tag;
   assign r_hit_data = sram_cache_data;

   // read data :  256-bit to 32-bit
   always @(p1_offset or r_hit_data) begin
     p1_data <= r_hit_data >> (8 * p1_offset);
   end

   // write data :  32-bit to 256-bit
   always @(p1_offset or r_hit_data or p1_data_i) begin
      w_hit_data <= (r_hit_data & ~(256'hffffffff << (8 * p1_offset))) |
          {224'b0, p1_data_i} << (8 * p1_offset);
   end

   // controller
   always@(posedge clk_i or negedge rst_i) begin
      if(~rst_i) begin
         state      <= STATE_IDLE;
         mem_enable <= 1'b0;
         mem_write  <= 1'b0;
         cache_we   <= 1'b0;
         write_back <= 1'b0;
      end
      else begin
         case(state)
           STATE_IDLE: begin
              if(p1_req && !hit) begin
                mem_enable <= 1'b1;
                if(sram_dirty) begin
                  // write back if dirty
                  mem_write <= 1'b1;
                  state <= STATE_WRITEBACK;
                end
                else begin
                  // write allocate
                  write_back <= 1'b0;
                  mem_write <= 1'b0;
                  state <= STATE_READMISS;
                end
              end
              else begin
                 state <= STATE_IDLE;
              end
           end
           STATE_READMISS: begin
              if(mem_ack_i) begin
                 cache_we <= 1'b1;
                 mem_enable <= 1'b0;
                 state <= STATE_READMISSOK;
              end
           end
           STATE_READMISSOK: begin
              // wait for data memory acknowledge
              cache_we <= 1'b0;
              state <= STATE_IDLE;
           end
           STATE_WRITEBACK: begin
              if(mem_ack_i) begin
                 // wait for data memory acknowledge
                 mem_enable <= 1'b1;
                 write_back <= 1'b0;
                 mem_write <= 1'b0;
                 state <= STATE_READMISS;
              end
           end
         endcase
      end
   end

DCache_SRAM dcache_sram(
  .clk_i    (clk_i),
  .addr_i   (cache_sram_index),
  .data_i   (cache_sram_data),
  .tag_i    (cache_sram_tag),
  .enable_i (cache_sram_enable),
  .write_i  (cache_sram_write),
  .data_o   (sram_cache_data),
  .tag_o    (sram_cache_tag)
);

endmodule
