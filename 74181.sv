/*---4-битный компонент, выполняющий суммирование с
параллельным (одновременным) вычислением переноса.
Из него можно составить любой длины (например 16) Сумматор (аналог 74181)---*/

module lookahead_4_adder (
	input  logic [3:0] a,
	input  logic [3:0] b,
	input  logic       c_in,
	
	output logic [3:0] a_out,
	output logic       g_P,
	output logic       g_G,
	output logic    c_out // оставлено для использования по отдельности
);

	logic [3:0] p;
	logic [3:0] g;
	logic c_0;
	logic c_1;
	logic c_2;

	always_comb begin
		for (int i = 0; i < 4; i++) begin
			p[i] = a[i] ^ b[i];
			g[i] = a[i] & b[i];
		end
	end

	// Формулы внутренних переносов
	assign c_0 = g[0] | (p[0] & c_in);
	assign c_1 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c_in);
	assign c_2 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c_in);
	assign c_out = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c_in); // теперь это не надо подключать я вынес это в 74182 
	
	// Формулы глобальной пропаганды и глобального поколения (звучит невероятно пафосно)
	assign g_P = p[0] & p[1] & p[2] & p[3];
	assign g_G = g[3] | (g[2] & p[3]) | (g[1] & p[2] & p[3]) | (g[0] & p[1] & p[2] & p[3]); // сигнал где-то рождается и не глохнет
	
	/*	
	assign a_out[0] =   ~a[0] && ~b[0] &&  c_in ||
						~a[0] &&  b[0] && ~c_in ||
						 a[0] && ~b[0] && ~c_in ||
						 a[0] &&  b[0] &&  c_in;
    If you look at this later and do not believe -- just unfold XOR and you will get the same expression.
    XOR performs better because of p = a ^ b trick.
    Если ты смотришь на код ниже и не понимаешь, почему XOR -- раскрой его и примени законы Моргана, ты получишь то же выражение.
    XOR выгоднее, так как a[0] ^ b[0] это уже синтезированный ранее кусок логики: p[0].
    Также ИИ говорит (и я с ним согласен), что XOR это стандартная операция, реализованная в одном LUT, так что это работает на FPGA.
    */				
	assign a_out[0] = p[0] ^ c_in;
	assign a_out[1] = p[1] ^ c_0;
	assign a_out[2] = p[2] ^ c_1;
	assign a_out[3] = p[3] ^ c_2;

endmodule