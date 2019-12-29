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

  // simulating
  parameter STATE_IDLE = 1'h0,
            STATE_WAIT = 1'h1;
  reg [1:0] state;
  reg       write;

  assign ack_o  = (state == STATE_WAIT) && (count == `LATENCY-1);
  assign addr   = addr_i[`REG_LEN-1:`DM_BYTE_UNIT] & `DM_MASK;
  assign data_o = data;

  always @(negedge rst_i or posedge clk_i) begin
    if (~rst_i)
      state <= STATE_IDLE;
    else begin
      case (state)
        STATE_IDLE: begin
          if (enable_i) begin
            state <= STATE_WAIT;
            count <= 1;
          end
        end
        STATE_WAIT: begin
          if (count == `LATENCY-1) begin
            state <= STATE_IDLE;
            if (write_i) begin
              memory[addr] <= data_i;
            end else begin
              data <= memory[addr];
            end
          end else begin
            count <= count + 1;
          end
        end
      endcase
    end
  end
endmodule
