module alu(a, b, control, res);
  input [3:0] a, b; // Операнды
  input [2:0] control; // Управляющие сигналы для выбора операции

  output [3:0] res; // Результат
  // TODO: implementation
endmodule

module d_latch(clk, d, we, q);
  input clk; // Сигнал синхронизации
  input d; // Бит для записи в ячейку
  input we; // Необходимо ли перезаписать содержимое ячейки

  output reg q; // Сама ячейка
  // Изначально в ячейке хранится 0
  initial begin
    q <= 0;
  end
  // Значение изменяется на переданное на спаде сигнала синхронизации
  always @ (negedge clk) begin
    // Запись происходит при we = 1
    if (we) begin
      q <= d;
    end
  end
endmodule

module register_file(clk, rd_addr, we_addr, we_data, rd_data, we);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr, we_addr; // Номера регистров для чтения и записи
  input [3:0] we_data; // Данные для записи в регистровый файл
  input we; // Необходимо ли перезаписать содержимое регистра

  output [3:0] rd_data; // Данные, полученные в результате чтения из регистрового файла
  // TODO: implementation
endmodule

module counter(clk, addr, control, immediate, data);
  input clk; // Сигнал синхронизации
  input [1:0] addr; // Номер значения счетчика которое читается или изменяется
  input [3:0] immediate; // Целочисленная константа, на которую увеличивается/уменьшается значение счетчика
  input control; // 0 - операция инкремента, 1 - операция декремента

  output [3:0] data; // Данные из значения под номером addr, подающиеся на выход
  // TODO: implementation
endmodule

module mux4(
    input  wire [1:0] control,
    input  wire       data_1,
    input  wire       data_2,
    input  wire       data_3,
    input  wire       data_4,
    output wire       out
);
  wire first_half;
  wire last_half;
  mux first_half_mux(
      .control(control[0]),
      .data_1(data_1),
      .data_2(data_2),
      .out(first_half)
  );
  mux last_half_mux(
      .control(control[0]),
      .data_1(data_3),
      .data_2(data_4),
      .out(last_half)
  );
  mux total_mux(
      .control(control[1]),
      .data_1(first_half),
      .data_2(last_half),
      .out(out)
  );
endmodule

module mux(
    input  wire control,
    input  wire data_1,
    input  wire data_2,
    output wire out
);
  wire control_invert;
  wire data_1_pass;
  wire data_2_pass;

  not control_invert_gate(control_invert, control);
  or  data_1_pass_gate(data_1_pass, control, data_1);
  or  data_2_pass_gate(data_2_pass, control_invert, data_2);
  and data_output_gate(out, data_1_pass, data_2_pass);
endmodule

module ripple_adder(
    input  wire [3:0] addend_1,
    input  wire [3:0] addend_2,
    input  wire       carry_in,
    output wire       carry_out,
    output wire [3:0] sum
);
  wire carry_1;
  wire carry_2;
  wire carry_3;

  full_adder least_significant_bit(
      .addend_1(addend_1[0]),
      .addend_2(addend_2[0]),
      .carry_in(carry_in),
      .carry_out(carry_1),
      .sum(sum[0])
  );
  full_adder second_bit(
      .addend_1(addend_1[1]),
      .addend_2(addend_2[1]),
      .carry_in(carry_1),
      .carry_out(carry_2),
      .sum(sum[1])
  );
  full_adder third_bit(
      .addend_1(addend_1[2]),
      .addend_2(addend_2[2]),
      .carry_in(carry_2),
      .carry_out(carry_3),
      .sum(sum[2])
  );
  full_adder most_significant_bit(
      .addend_1(addend_1[3]),
      .addend_2(addend_2[3]),
      .carry_in(carry_3),
      .carry_out(carry_out),
      .sum(sum[3])
  );
endmodule

module full_adder(
    input  wire addend_1,  // A
    input  wire addend_2,  // B
    input  wire carry_in,
    output wire carry_out,
    output wire sum
);
  wire AB;
  wire ACin;
  wire BCin;

  xor sum_gate(sum, addend_1, addend_2, carry_in);
  and and_1(AB, addend_1, addend_2);
  and and_2(ACin, addend_1, carry_in);
  and and_3(BCin, addend_2, carry_in);
  or  carry_out_gate(carry_out, AB, ACin, BCin);
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
