module b_subtractor_prep (
	input  logic [15:0] b,
	input  logic        sub_op,
	output logic [15:0] b_out,
	output logic        c_in
);
	// Если sub_op = 1, инвертируем все биты B (через XOR с 1)
    // Если sub_op = 0, оставляем как есть (XOR с 0)
	assign b_out = b ^ {16{sub_op}};
	
	// Если вычитание, то добавляем +1 через вход переноса
	assign c_in = sub_op;
endmodule
