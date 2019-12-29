module PC (
  input        clk_i,
  input        rst_i,
  input        mem_stall_i,
  input        start_i,
  input [31:0] pc_i,
  output reg [31:0] pc_o
);
  always @(posedge clk_i or negedge rst_i) begin
    if (~rst_i) begin
      pc_o <= 32'b0;
    end
    else begin
      if (start_i && !mem_stall_i)
        pc_o <= pc_i;
    end
  end
endmodule
