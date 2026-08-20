module alu(a, b, control, res);
  input  [3:0] a, b;
  input  [2:0] control;

  output [3:0] res;

  supply0 zero;

  wire         invert_b;
  wire   [3:0] b_effective;
  wire   [3:0] and_result;
  wire   [3:0] or_result;
  wire   [3:0] sum;
  wire         carry_out;
  wire         same_sign;
  wire         different_sign;
  wire         overflow;
  wire         less;

  xor invert_b_gate(invert_b, control[2], control[0]);
  xor b_invert_gate[3:0] (b_effective, b, invert_b);

  and and_operation[3:0] (and_result, a, b_effective);
  or  or_operation[3:0] (or_result, a, b_effective);

  ripple_adder adder(
      .addend_1(a),
      .addend_2(b_effective),
      .carry_in(invert_b),
      .carry_out(carry_out),
      .sum(sum)
  );

  xnor same_sign_gate(same_sign, a[3], b_effective[3]);
  xor  different_sign_gate(different_sign, a[3], sum[3]);
  and  overflow_gate(overflow, same_sign, different_sign);
  xor  less_gate(less, sum[3], overflow);

  mux4_4 result_mux(
      .control(control[2:1]),
      .data_0(and_result),
      .data_1(or_result),
      .data_2(sum),
      .data_3({zero, zero, zero, less}),
      .out(res)
  );
endmodule

module d_latch(clk, d, we, q);
  input clk;
  input d;
  input we;

  output reg q;

  initial begin
    q <= 0;
  end
  always @ (negedge clk) begin
    if (we) begin
      q <= d;
    end
  end
endmodule

module register_file(clk, rd_addr, we_addr, we_data, rd_data, we);
  input        clk;
  input  [1:0] rd_addr, we_addr;
  input  [3:0] we_data;
  input        we;
  output [3:0] rd_data;

  wire   [3:0] write_enable;
  wire   [3:0] register_0;
  wire   [3:0] register_1;
  wire   [3:0] register_2;
  wire   [3:0] register_3;

  decoder_2_4 write_decoder(
      .control(we_addr),
      .enable(we),
      .out(write_enable)
  );

  register_4 storage_0(.clk(clk), .we(write_enable[0]), .d(we_data), .q(register_0));
  register_4 storage_1(.clk(clk), .we(write_enable[1]), .d(we_data), .q(register_1));
  register_4 storage_2(.clk(clk), .we(write_enable[2]), .d(we_data), .q(register_2));
  register_4 storage_3(.clk(clk), .we(write_enable[3]), .d(we_data), .q(register_3));

  mux4_4 read_mux(
      .control(rd_addr),
      .data_0(register_0),
      .data_1(register_1),
      .data_2(register_2),
      .data_3(register_3),
      .out(rd_data)
  );
endmodule

module counter(clk, addr, control, immediate, data);
  input        clk;
  input  [1:0] addr;
  input  [3:0] immediate;
  input        control;
  output [3:0] data;

  supply1 write_always;

  wire   [3:0] write_enable;
  wire   [3:0] value_0;
  wire   [3:0] value_1;
  wire   [3:0] value_2;
  wire   [3:0] value_3;
  wire   [3:0] immediate_effective;
  wire   [3:0] next_value;
  wire         carry_out;

  xor immediate_invert[3:0] (immediate_effective, immediate, control);

  ripple_adder adder(
      .addend_1(data),
      .addend_2(immediate_effective),
      .carry_in(control),
      .carry_out(carry_out),
      .sum(next_value)
  );

  decoder_2_4 write_decoder(
      .control(addr),
      .enable(write_always),
      .out(write_enable)
  );

  register_4 storage_0(.clk(clk), .we(write_enable[0]), .d(next_value), .q(value_0));
  register_4 storage_1(.clk(clk), .we(write_enable[1]), .d(next_value), .q(value_1));
  register_4 storage_2(.clk(clk), .we(write_enable[2]), .d(next_value), .q(value_2));
  register_4 storage_3(.clk(clk), .we(write_enable[3]), .d(next_value), .q(value_3));

  mux4_4 read_mux(
      .control(addr),
      .data_0(value_0),
      .data_1(value_1),
      .data_2(value_2),
      .data_3(value_3),
      .out(data)
  );
endmodule

module mux4_1(
    input  wire [1:0] control,
    input  wire       data_0,
    input  wire       data_1,
    input  wire       data_2,
    input  wire       data_3,
    output wire       out
);
  wire first_half;
  wire last_half;

  mux2_1 first_half_mux(
      .control(control[0]),
      .data_0(data_0),
      .data_1(data_1),
      .out(first_half)
  );
  mux2_1 last_half_mux(
      .control(control[0]),
      .data_0(data_2),
      .data_1(data_3),
      .out(last_half)
  );
  mux2_1 total_mux(
      .control(control[1]),
      .data_0(first_half),
      .data_1(last_half),
      .out(out)
  );
endmodule

module mux2_1(
    input  wire control,
    input  wire data_0,
    input  wire data_1,
    output wire out
);
  wire control_invert;
  wire data_0_pass;
  wire data_1_pass;

  not control_invert_gate(control_invert, control);
  or  data_0_pass_gate(data_0_pass, control, data_0);
  or  data_1_pass_gate(data_1_pass, control_invert, data_1);
  and data_output_gate(out, data_0_pass, data_1_pass);
endmodule

module mux4_4(
    input  wire [1:0] control,
    input  wire [3:0] data_0,
    input  wire [3:0] data_1,
    input  wire [3:0] data_2,
    input  wire [3:0] data_3,
    output wire [3:0] out
);
  mux4_1 bit_mux[3:0] (
      .control(control),
      .data_0(data_0),
      .data_1(data_1),
      .data_2(data_2),
      .data_3(data_3),
      .out(out)
  );
endmodule

module decoder_2_4(
    input  wire [1:0] control,
    input  wire       enable,
    output wire [3:0] out
);
  wire control_0_invert;
  wire control_1_invert;

  not control_0_invert_gate(control_0_invert, control[0]);
  not control_1_invert_gate(control_1_invert, control[1]);

  and out_0_gate(out[0], enable, control_1_invert, control_0_invert);
  and out_1_gate(out[1], enable, control_1_invert, control[0]);
  and out_2_gate(out[2], enable, control[1], control_0_invert);
  and out_3_gate(out[3], enable, control[1], control[0]);
endmodule

module register_4(
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] d,
    output wire [3:0] q
);
  d_latch bit_cell[3:0] (
      .clk(clk),
      .d(d),
      .we(we),
      .q(q)
  );
endmodule

module ripple_adder(
    input  wire [3:0] addend_1,
    input  wire [3:0] addend_2,
    input  wire       carry_in,
    output wire       carry_out,
    output wire [3:0] sum
);
  wire carry_0;
  wire carry_1;
  wire carry_2;

  full_adder least_significant_bit(
      .addend_1(addend_1[0]),
      .addend_2(addend_2[0]),
      .carry_in(carry_in),
      .carry_out(carry_0),
      .sum(sum[0])
  );
  full_adder second_bit(
      .addend_1(addend_1[1]),
      .addend_2(addend_2[1]),
      .carry_in(carry_0),
      .carry_out(carry_1),
      .sum(sum[1])
  );
  full_adder third_bit(
      .addend_1(addend_1[2]),
      .addend_2(addend_2[2]),
      .carry_in(carry_1),
      .carry_out(carry_2),
      .sum(sum[2])
  );
  full_adder most_significant_bit(
      .addend_1(addend_1[3]),
      .addend_2(addend_2[3]),
      .carry_in(carry_2),
      .carry_out(carry_out),
      .sum(sum[3])
  );
endmodule

module full_adder(
    input  wire addend_1,
    input  wire addend_2,
    input  wire carry_in,
    output wire carry_out,
    output wire sum
);
  wire carry_out_operands;
  wire carry_out_in;
  wire sum_operands;

  half_adder add_operands(
      .addend_1(addend_1),
      .addend_2(addend_2),
      .carry_out(carry_out_operands),
      .sum(sum_operands)
  );
  half_adder add_carry_in(
      .addend_1(sum_operands),
      .addend_2(carry_in),
      .carry_out(carry_out_in),
      .sum(sum)
  );
  or carry(carry_out, carry_out_operands, carry_out_in);

endmodule

module half_adder(
    input  wire addend_1,
    input  wire addend_2,
    output wire carry_out,
    output wire sum
);
  and carry_out_gate(carry_out, addend_1, addend_2);
  xor sum_gate(sum, addend_1, addend_2);
endmodule
