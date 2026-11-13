module b_subtractor_prep #(parameter bits = 16) (
	input  logic [bits-1:0] b,
	input  logic        sub_op,
	output logic [bits-1:0] b_out,
	output logic        c_in
);
	// Если sub_op = 1, инвертируем все биты B (через XOR с 1)
    // Если sub_op = 0, оставляем как есть (XOR с 0)
	assign b_out = b ^ {bits{sub_op}};
	
	// Если вычитание, то добавляем +1 через вход переноса
	assign c_in = sub_op;
endmodule
