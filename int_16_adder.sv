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
	
	output logic C, // перенос/заём
	output logic V  // переполнение
);
	logic [3:0] global_propagation;
	logic [3:0] global_generation;
	logic [3:0] c_massive;
	
	assign c_out = c_massive[3];
	
    lookahead_adders_conductor conductor(
		.g_P(global_propagation),
		.g_G(global_generation),
		.c_in(c_in),

		.c_out(c_massive),
		// и для того, чтобы его самого можно было объединять в глобально-глобальную схему:
		.gg_P(),
		.gg_G()
	);
	
	lookahead_4_adder adder0 (
		.a(a[3:0]),
		.b(b[3:0]),
		.c_in(c_in),
		.a_out(sum[3:0]),
		.g_P(global_propagation[0]),
		.g_G(global_generation[0]),
		.c_out()
	);
	
	lookahead_4_adder adder1 (
		.a(a[7:4]),
		.b(b[7:4]),
		.c_in(c_massive[0]),
		.a_out(sum[7:4]),
		.g_P(global_propagation[1]),
		.g_G(global_generation[1]),
		.c_out()
	);
	
	lookahead_4_adder adder2 (
		.a(a[11:8]), .b(b[11:8]),
		.c_in(c_massive[1]),
		.a_out(sum[11:8]),
		.g_P(global_propagation[2]),
		.g_G(global_generation[2]),
		.c_out()
	);
	
	lookahead_4_adder adder3 (
		.a(a[15:12]),
		.b(b[15:12]),
		.c_in(c_massive[2]),
		.a_out(sum[15:12]),
		.g_P(global_propagation[3]),
		.g_G(global_generation[3]),
		.c_out()
	);
	
	//C 
	assign C = c_out;
	
	//V (знак результата не равен знаку слагаемых)
	assign V = (a[15] & b[15] & ~sum[15]) | (~a[15] & ~b[15] & sum[15]); // btw & это побитовое И, а && -- логическое

endmodule
