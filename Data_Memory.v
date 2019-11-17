module Data_Memory (
  clk,
  addr,
  data,
  width,
  memwrite,
  sign_extend,
  result
);

  input         clk;
  input  [31:0] addr;
  input  [31:0] data;
  input  [1:0]  width; // ins[13:12] (00: 8-bit, 01: 16-bit, 10: 32-bit)
  input         memwrite;
  input         sign_extend;
  output [31:0] result;

  reg    [31:0] memory[0:1023]; // 4KiB

  wire   [31:0] full_result;
  wire   [29:0] entry = addr[31:2];

  // Written for simplicity. This can results in out-of-bounds access, so some
  //   of the bits in `full_result` may be 'X' even if the access is valid.
  //   However, `result` will always be valid.
  assign full_result =
      addr[1:0] == 2'b00 ? memory[entry] :
      addr[1:0] == 2'b01 ? {memory[entry+1][7:0], memory[entry][31:8]} :
      addr[1:0] == 2'b10 ? {memory[entry+1][15:0], memory[entry][31:16]} :
                           {memory[entry+1][23:0], memory[entry][31:24]};
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
            2'b00: memory[entry] = data;
            2'b01: {memory[entry+1][7:0], memory[entry][31:8]} = data;
            2'b10: {memory[entry+1][15:0], memory[entry][31:16]} = data;
            2'b11: {memory[entry+1][23:0], memory[entry][31:24]} = data;
          endcase
        2'b01:
          if (addr[1:0] != 2'b11)
            memory[entry][addr[1:0]*8+:16] = data[15:0];
          else
            {memory[entry+1][7:0], memory[entry][31:24]} = data[15:0];
        2'b00:
          memory[entry][addr[1:0]*8+:8] = data[7:0];
      endcase
    end
  end
endmodule
