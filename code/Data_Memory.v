// Note: macros for sizes moved to CPU.v

`define LATENCY 10

module Data_Memory (
  input                    clk_i,
  input                    rst_i,
  input [`REG_LEN-1:0]     addr_i,
  input [`DM_UNIT_MASK:0]  data_i,
  input                    enable_i,
  input                    write_i,
  output                   ack_o,
  output [`DM_UNIT_MASK:0] data_o
);

  reg  [`DM_UNIT_MASK:0]          memory[0:`DM_MASK];
  reg  [3:0]                      count;
  reg  [`DM_UNIT_MASK:0]          data;
  wire [`REG_LEN-`DM_BYTE_UNIT:0] addr;

  parameter STATE_IDLE = 1'h0,
            STATE_WAIT = 1'h1;
  reg [1:0] state;

  assign ack_o  = (state == STATE_WAIT) && (count == `LATENCY-1);
  assign addr   = addr_i[`REG_LEN-1:`DM_BYTE_UNIT];
  assign data_o = data;

  always @(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
      state <= STATE_IDLE;
      count <= 4'd0;
    end
    else begin
      case (state)
        STATE_IDLE: begin
          if(enable_i) begin
            state <= STATE_WAIT;
            count <= count + 1;
          end
        end
        STATE_WAIT: begin
          if(count == `LATENCY-1) begin
            state <= STATE_IDLE;
            count <= 0;
          end
          else begin
            count <= count + 1;
          end
        end
      endcase
    end
  end

  always@(posedge clk_i) begin
    if (ack_o) begin
      if (write_i) begin
        memory[addr] <= data_i;
        data <= data_i;
      end
      else begin
        data = memory[addr];
      end
    end
  end
endmodule

/*

`define DM_BITS 10 // 4 KiB
`define DM_MASK ((1<<`DM_BITS)-1)

module Data_Memory (
  input         clk,
  input  [31:0] addr,
  input  [31:0] data,
  input  [1:0]  width, // ins[13:12] (00: 8-bit, 01: 16-bit, 10: 32-bit)
  input         memwrite,
  input         sign_extend,
  output [31:0] result
);

  reg  [31:0] memory[0:`DM_MASK];

  wire [31:0] full_result;
  wire [`DM_BITS-1:0] entry = addr[31:2] & `DM_MASK;

  // Written for simplicity. This can result in out-of-bounds access, so some
  //   of the bits in `full_result` may be invalid even if the access is valid.
  //   However, `result` will always be valid.
  assign full_result =
      addr[1:0] == 2'b00 ? memory[entry] :
      addr[1:0] == 2'b01 ? {memory[(entry+1)&`DM_MASK][7:0], memory[entry][31:8]} :
      addr[1:0] == 2'b10 ? {memory[(entry+1)&`DM_MASK][15:0], memory[entry][31:16]} :
                           {memory[(entry+1)&`DM_MASK][23:0], memory[entry][31:24]};
  assign result =
    width == 2'b10 ? full_result :
    width == 2'b01 ? {{16{sign_extend & full_result[15]}}, full_result[15:0]} :
                     {{24{sign_extend & full_result[7]}},  full_result[7:0]};

  always @(posedge clk) begin
    if (memwrite) begin
      case (width)
        2'b11:; // nothing
        2'b10:
          case (addr[1:0])
            2'b00: memory[entry] <= data;
            2'b01: {memory[(entry+1)&`DM_MASK][7:0], memory[entry][31:8]} <= data;
            2'b10: {memory[(entry+1)&`DM_MASK][15:0], memory[entry][31:16]} <= data;
            2'b11: {memory[(entry+1)&`DM_MASK][23:0], memory[entry][31:24]} <= data;
          endcase
        2'b01:
          if (addr[1:0] != 2'b11)
            memory[entry][addr[1:0]*8+:16] <= data[15:0];
          else
            {memory[(entry+1)&`DM_MASK][7:0], memory[entry][31:24]} <= data[15:0];
        2'b00:
          memory[entry][addr[1:0]*8+:8] <= data[7:0];
      endcase
    end
  end
endmodule*/
