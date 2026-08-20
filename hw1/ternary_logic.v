module ternary_min(
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [1:0] out
);
  wire b_not_minus;
  wire a_zero_b_not_minus;
  wire a_plus_b_zero;

  and_gate and_gate_1(
      .in1(a[1]),
      .in2(b[1]),
      .out(out[1])
  );
  or_gate or_gate_1(
      .in1(b[0]),
      .in2(b[1]),
      .out(b_not_minus)
  );
  and_gate and_gate_2(
      .in1(a[0]),
      .in2(b_not_minus),
      .out(a_zero_b_not_minus)
  );
  and_gate and_gate_3(
      .in1(a[1]),
      .in2(b[0]),
      .out(a_plus_b_zero)
  );
  or_gate or_gate_2(
      .in1(a_zero_b_not_minus),
      .in2(a_plus_b_zero),
      .out(out[0])
  );
endmodule

module ternary_max(
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [1:0] out
);
  wire no_plus;
  wire has_zero;

  or_gate or_gate_1(
      .in1(a[1]),
      .in2(b[1]),
      .out(out[1])
  );
  nor_gate nor_gate_1(
      .in1(a[1]),
      .in2(b[1]),
      .out(no_plus)
  );
  or_gate or_gate_2(
      .in1(a[0]),
      .in2(b[0]),
      .out(has_zero)
  );
  and_gate and_gate_1(
      .in1(no_plus),
      .in2(has_zero),
      .out(out[0])
  );
endmodule

module ternary_any(
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [1:0] out
);
  wire a_minus;
  wire b_minus;
  wire a_not_plus;
  wire a_zero;
  wire b_not_minus;
  wire a_minus_b_plus;
  wire a_zero_b_zero;
  wire a_plus_b_minus;
  wire opposite_pair;
  wire a_plus_b_not_minus;
  wire a_zero_b_plus;

  or_gate or_gate_1(
      .in1(b[0]),
      .in2(b[1]),
      .out(b_not_minus)
  );
  and_gate and_gate_1(
      .in1(a[1]),
      .in2(b_not_minus),
      .out(a_plus_b_not_minus)
  );
  and_gate and_gate_2(
      .in1(a[0]),
      .in2(b[1]),
      .out(a_zero_b_plus)
  );
  or_gate or_gate_2(
      .in1(a_plus_b_not_minus),
      .in2(a_zero_b_plus),
      .out(out[1])
  );
  nor_gate nor_gate_1(
      .in1(a[0]),
      .in2(a[1]),
      .out(a_minus)
  );
  and_gate and_gate_3(
      .in1(a_minus),
      .in2(b[1]),
      .out(a_minus_b_plus)
  );
  not_gate not_gate_1(
      .in (a[1]),
      .out(a_not_plus)
  );
  and_gate and_gate_4(
      .in1(a[0]),
      .in2(a_not_plus),
      .out(a_zero)
  );
  and_gate and_gate_5(
      .in1(a_zero),
      .in2(b[0]),
      .out(a_zero_b_zero)
  );
  nor_gate nor_gate_2(
      .in1(b[0]),
      .in2(b[1]),
      .out(b_minus)
  );
  and_gate and_gate_6(
      .in1(a[1]),
      .in2(b_minus),
      .out(a_plus_b_minus)
  );
  or_gate or_gate_3(
      .in1(a_minus_b_plus),
      .in2(a_zero_b_zero),
      .out(opposite_pair)
  );
  or_gate or_gate_4(
      .in1(opposite_pair),
      .in2(a_plus_b_minus),
      .out(out[0])
  );
endmodule

module ternary_consensus(
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [1:0] out
);
  wire a_not_minus;
  wire b_not_minus;
  wire not_both_minus;
  wire not_both_plus;
  wire both_plus;

  and_gate and_gate_1(
      .in1(a[1]),
      .in2(b[1]),
      .out(out[1])
  );

  and_gate and_gate_3(
      .in1(a[1]),
      .in2(b[1]),
      .out(both_plus)
  );
  not_gate not_gate_1(
      .in (both_plus),
      .out(not_both_plus)
  );
  or_gate or_gate_1(
      .in1(a[0]),
      .in2(a[1]),
      .out(a_not_minus)
  );
  or_gate or_gate_2(
      .in1(b[0]),
      .in2(b[1]),
      .out(b_not_minus)
  );
  or_gate or_gate_3(
      .in1(a_not_minus),
      .in2(b_not_minus),
      .out(not_both_minus)
  );
  and_gate and_gate_2(
      .in1(not_both_minus),
      .in2(not_both_plus),
      .out(out[0])
  );
endmodule

module or_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  wire nor_out;

  nor_gate nor_gate_1(
      .in1(in1),
      .in2(in2),
      .out(nor_out)
  );
  not_gate not_gate_1(
      .in (nor_out),
      .out(out)
  );
endmodule

module and_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  wire nand_out;

  nand_gate nand_gate_1(
      .in1(in1),
      .in2(in2),
      .out(nand_out)
  );
  not_gate not_gate_1(
      .in (nand_out),
      .out(out)
  );
endmodule

module nand_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  supply1 pwr;
  supply0 gnd;

  wire nmos_chain;

  pmos p1(out, pwr, in1);
  pmos p2(out, pwr, in2);
  nmos n1(out, nmos_chain, in1);
  nmos n2(nmos_chain, gnd, in2);
endmodule

module nor_gate(
    input  wire in1,
    input  wire in2,
    output wire out
);
  supply1 pwr;
  supply0 gnd;

  wire pmos_chain;

  pmos p1(pmos_chain, pwr, in1);
  pmos p2(out, pmos_chain, in2);
  nmos n1(out, gnd, in1);
  nmos n2(out, gnd, in2);
endmodule

module not_gate(
    input  wire in,
    output wire out
);
  supply1 pwr;
  supply0 gnd;

  pmos p1(out, pwr, in);
  nmos n1(out, gnd, in);
endmodule
