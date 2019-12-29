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
  input  [`REG_LEN-1:0] data_i,
  input  [`REG_LEN-1:0] addr_i,
  input                 MemRead_i,
  input                 MemWrite_i,
  input  [1:0]          width,
  input                 sign_extend,
  output [`REG_LEN-1:0] data_o,
  output                stall_o
);
  // controller
  parameter STATE_IDLE       = 2'h0,
            STATE_READMISS   = 2'h1,
            STATE_READMISSOK = 2'h2,
            STATE_WRITEBACK  = 2'h3;
  reg [1:0] state;
  reg       mem_enable;
  reg       mem_write;
  reg       cache_we;
  reg       write_back;

  // regs & wires
  reg  [`DM_UNIT_MASK:0]      w_hit_data; //
  reg  [`REG_LEN-1:0]         data;       // use reg for simpler code
  wire [`L1_TAG_MEM_SIZE-1:0] sram_cache_tag;
  wire [`DM_UNIT_MASK:0]      sram_cache_data;

  // unaligned access
  reg  unalign_second;
  wire is_unalign = {1'b0, offset} + (1 << width) > (1 << `DM_BYTE_UNIT);
  wire [`REG_LEN-1:0] addr = unalign_second ?
                             addr_i + (1 << `DM_BYTE_UNIT) : addr_i;

  wire                      req    = MemRead_i | MemWrite_i;
  wire [`DM_BYTE_UNIT-1:0]  offset = addr[`DM_BYTE_UNIT-1:0];
  wire [`L1_INDEX_SIZE-1:0] index  = addr[`L1_SIZE-1:`DM_BYTE_UNIT];
  wire [`L1_TAG_SIZE-1:0]   tag    = addr[`REG_LEN-1:`L1_SIZE];

  assign stall_o = (~hit | (is_unalign & ~unalign_second)) & req;
  assign data_o =
      width == 2'b10 ? data :
      width == 2'b01 ? {{16{sign_extend & data[15]}}, data[15:0]} :
      width == 2'b00 ? {{24{sign_extend & data[7]}},  data[7:0]} : 0;

  // SRAM
  wire                        sram_valid = sram_cache_tag[`L1_TAG_SIZE+1];
  wire                        sram_dirty = sram_cache_tag[`L1_TAG_SIZE];
  wire [`L1_TAG_SIZE-1:0]     sram_tag   = sram_cache_tag[`L1_TAG_SIZE-1:0];
  wire [`DM_BYTE_UNIT-1:0]    cache_sram_index  = index;
  wire                        cache_sram_enable = req;
  wire                        cache_sram_write  = cache_we | write_hit;
  wire [`L1_TAG_MEM_SIZE-1:0] cache_sram_tag    = {1'b1, cache_dirty, tag};
  wire [`DM_UNIT_MASK:0]      cache_sram_data   = hit ? w_hit_data : mem_data_i;

  // memory interface
  assign mem_enable_o = mem_enable;
  assign mem_addr_o   = write_back ? {sram_tag, index, 5'b0} : {tag, index, 5'b0};
  assign mem_data_o   = sram_cache_data;
  assign mem_write_o  = mem_write;

  wire                   write_hit   = hit & MemWrite_i;
  wire                   cache_dirty = write_hit;
  wire                   hit         = sram_valid && sram_tag == tag;
  wire [`DM_UNIT_MASK:0] r_hit_data  = sram_cache_data;

  always @* begin // combo logic
    if (unalign_second) begin
      case (addr[1:0])
        2'b01: data[31:24] <= r_hit_data[7:0];
        2'b10: data[31:16] <= r_hit_data[15:0];
        2'b11: data[31:8]  <= r_hit_data[23:0];
      endcase
    end else begin
      data <= r_hit_data >> (8 * offset);
    end
  end

  wire [`DM_UNIT_MASK:0] write_mask =
      width == 2'b10 ? 256'hffffffff :
      width == 2'b01 ? 256'hffff :
      width == 2'b00 ? 256'hff : 0;
  wire [`DM_UNIT-1:0] write_shift = unalign_second ?
                                    8'h8 * (4 - offset[1:0]) : 8'h8 * offset;
  always @* begin // combo logic
    if (unalign_second) begin
      w_hit_data <= (r_hit_data & ~(write_mask >> write_shift)) |
          (data_i & write_mask) >> write_shift;
    end else begin
      w_hit_data <= (r_hit_data & ~(write_mask << write_shift)) |
          (data_i & write_mask) << write_shift;
    end
  end

  // controller
  always @(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
      state      <= STATE_IDLE;
      mem_enable <= 1'b0;
      mem_write  <= 1'b0;
      cache_we   <= 1'b0;
      write_back <= 1'b0;
      unalign_second <= 1'b0;
    end else begin
      case (state)
        STATE_IDLE: begin
          if (req) begin
            if (hit) begin
              if (is_unalign) unalign_second <= unalign_second ^ 1'b1;
            end else begin
              mem_enable <= 1'b1;
              if (sram_dirty) begin
                // write back if dirty
                write_back <= 1'b1;
                mem_write <= 1'b1;
                state <= STATE_WRITEBACK;
              end else begin
                // write allocate
                write_back <= 1'b0;
                mem_write <= 1'b0;
                state <= STATE_READMISS;
              end
            end
          end
        end
        STATE_READMISS: begin
          if (mem_ack_i) begin
            cache_we <= 1'b1;
            mem_enable <= 1'b0;
            state <= STATE_READMISSOK;
          end
        end
        STATE_READMISSOK: begin
          cache_we <= 1'b0;
          state <= STATE_IDLE;
        end
        STATE_WRITEBACK: begin
          if (mem_ack_i) begin
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
