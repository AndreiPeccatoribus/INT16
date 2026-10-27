/*---Этот 16-битный сумматор (аналог 74181) собран из 4 блоков суммировния lookahead_4_adder с параллельным переносом,
что делает его быстрее, что важно для высокочастотных устройств.
Также этот сумматор может быть вычитателем. Но для этого АЛУ задйствует внешний маленький модуль b_subtractro_prep,
который инвертирует вычитаемое и устанавливает c_in = 1 (единственный случай, когда он равен 1).---*/

module int_16_adder (
	input logic [15:0] a,
	input logic [15:0] b,
	input logic        c_in,
	
	output logic [15:0] sum,
	output logic        c_out,
	
	output logic Z, // ноль
	output logic S, // число положительное
	output logic C, // перенос/заём
	output logic V  // переполнение
);

	logic c_1;
	
	lookahead_4_adder adder0 (
		.a(a[3:0]), .b(b[3:0]), .c_in(c_in),
		.a_out(sum[3:0]), .c_out(c_1)
	);
	
	logic c_2;
	
	lookahead_4_adder adder1 (
		.a(a[7:4]), .b(b[7:4]), .c_in(c_1),
		.a_out(sum[7:4]), .c_out(c_2)
	);
	
	logic c_3;
	
	lookahead_4_adder adder2 (
		.a(a[11:8]), .b(b[11:8]), .c_in(c_2),
		.a_out(sum[11:8]), .c_out(c_3)
	);
	
	lookahead_4_adder adder3 (
		.a(a[15:12]), .b(b[15:12]), .c_in(c_3),
		.a_out(sum[15:12]), .c_out(c_out)
	);
	
	//Z
	assign Z = (sum == 16'h0000);
	
	//S 
	assign S = sum[15];
	
	//C 
	assign C = c_out;
	
	//V (знак результата не равен знаку слагаемых)
	assign V = (a[15] & b[15] & ~sum[15]) | (~a[15] & ~b[15] & sum[15]); // btw & это побитовое И, а && -- логическое

endmodule
