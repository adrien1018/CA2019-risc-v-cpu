module Sign_Extend (
  in,
  result
);

  input  [11:0] in;
  output [31:0] result;

  assign result = {{20{in[11]}}, in};

endmodule
