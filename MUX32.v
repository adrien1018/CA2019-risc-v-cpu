module MUX32 (
  in0,
  in1,
  control,
  result
);

  input  [31:0] in0;
  input  [31:0] in1;
  input         control;
  output [31:0] result;

  assign result = control ? in1 : in0;

endmodule
