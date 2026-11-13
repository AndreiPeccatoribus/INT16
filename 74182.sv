/*---Аналог 74182 -- схемы объединения--
слогателей 74181 с параллельным вычислением переносов между ними
до того, как перенос дойдёт от первого к последнему--*/

module lookahead_adders_conductor (
	input  logic [3:0] g_P,
	input  logic [3:0] g_G,
	input  logic c_in,

	output logic [3:0] c_out,
	// и для того, чтобы его самого можно было объединять в глобально-глобальную схему:
	output logic       gg_P,
	output logic       gg_G
);

	assign c_out[0] = g_G[0] | (g_P[0] & c_in);
	assign c_out[1] = g_G[1] | (g_P[1] &(g_G[0] | (g_P[0] & c_in)));
	assign c_out[2] = g_G[2] | (g_P[2] & (g_G[1] | (g_P[1] &(g_G[0] | (g_P[0] & c_in)))));
	assign c_out[3] = g_G[3] | (g_P[3] & (g_G[2] | (g_P[2] & (g_G[1] | (g_P[1] &(g_G[0] | (g_P[0] & c_in)))))));
	
	assign gg_P = g_P[0] & g_P[1] & g_P[2] & g_P[3]; 
	assign gg_G = g_G[3] | (g_G[2] & g_P[3]) | (g_G[1] & g_P[2] & g_P[3]) | (g_G[0] & g_P[1] & g_P[2] & g_P[3]);
endmodule