module ALU (
	input logic [15:0] a,
	input logic [15:0] b,
	input logic [3:0] command, 
	/* 
	0000 сложение, 
	0001 вычитание, ВАЖНО! Для тех, ктоо будет пользованться: если вам нужно сравнить два числа, то используйте вычитание и флаги 
	0010 сдвиго влево,
	0011 сдвиг вправо
	0100 AND
	0101 OR
	0110 XOR
	0111 NOT (CMA в 8085)
	(UPD: умножение INT нужно только при выделении памяти, а это делается сдвигом, так что его не будет)
	*/
	output logic [15:0] result,
	output logic c_out,
	// флаги
	output logic Z, // ноль
	output logic S, // число положительное
	output logic C, // перенос/заём
	output logic V  // переполнение
);

	// Параметры сложения и вычитания
	// мы можем выполнять или сложение или вычитание одновременно
	// это не закрывает возможности реализовать параллельное вычисление других команд
	// но вряд ли нам понадобится и сложить и вычесть два числа на одном такте
	logic subtraction;
	logic c_in;
	logic [15:0] b_out;

	logic [15:0] add_result;
	logic add_c_out;
	logic add_C; // перенос/заём
	logic add_V; // переполнение
	
	// Параметры сдвига
	logic shift_command;
	
	logic [15:0] shift_result;
	logic shift_c_out;
	logic shift_C; // перенос/заём
	logic shift_V; // переполнение
	
	// Параметры и сразу реализация логики
	logic [15:0] and_result;
	logic [15:0] or_result;
	logic [15:0] xor_result;
	logic [15:0] not_result;
	
	assign and_result = a & b;
    assign or_result  = a | b;
    assign xor_result = a ^ b;
    assign not_result = ~a;
	
	// Мультиплексоры (и входной и выходной)
	always_comb begin
		case (command[3:0]) // если что, command больше, он рассчитан на 16 команд
			4'b0000: begin 	subtraction = 0; 		// сложение
					shift_command = 0; 
					result = add_result; 
					c_out = add_c_out;
					C = add_C;
					V = add_V;
			end
			4'b0001: begin	subtraction = 1;		// вычитание
					shift_command = 0; 
					result = add_result;
					c_out = add_c_out;
					C = add_C;
					V = add_V;
			end
			4'b0010: begin	subtraction = 0;		// сдвиг влево
					shift_command = 1; 
					result = shift_result;
					c_out = shift_c_out;
					C = shift_C;
					V = shift_V;
			end
			4'b0011: begin	subtraction = 0;		// сдвиг вправо
					shift_command = 0; 
					result = shift_result;
					c_out = shift_c_out;
					C = shift_C;
					V = shift_V;
			end
			4'b0100: begin	subtraction = 0;		// AND
					shift_command = 0; 
					result = and_result;
					c_out = 1'b0;
					C = 1'b0;
					V = 1'b0;
			end
			4'b0101: begin	subtraction = 0;		// OR
					shift_command = 0; 
					result = or_result;
					c_out = 1'b0;
					C = 1'b0;
					V = 1'b0;
			end
			4'b0110: begin	subtraction = 0;		// XOR
					shift_command = 0; 
					result = xor_result;
					c_out = 1'b0;
					C = 1'b0;
					V = 1'b0;
			end
			4'b0111: begin	subtraction = 0;		// NOT
					shift_command = 0; 
					result = not_result;
					c_out = 1'b0;
					C = 1'b0;
					V = 1'b0;
			end
			// и многие другие команды с их уникальными фичами
			default:	subtraction = 0;	// просто всё по нулям
						shift_command = 0; 
						result = 16'h0000;
						c_out = 1'b0;
						C = 1'b0;
						V = 1'b0;
		endcase
	end
	
	b_subtractor_prep preparator (
		.b(b[15:0]),
		.sub_op(subtraction),
		.b_out(b_out),
		.c_in(c_in)
	);
	
	int_16_adder adder (
		.a(a),
		.b(b_out),
		.c_in(c_in),
		
		.sum(add_result),
		.c_out(add_c_out),
		
		.C(add_C), // перенос/заём
		.V(add_V)  // переполнение
	);
	
	shifter shifter_inst (
		.command(shift_command), // 0 -- вправо, 1 -- влево, почему нет арифметического? будет, но в FP, т.к. он только для деления нужен
		
		.inp(a),
		.out(shift_result),
		.c_out(shift_c_out),
		
		.C(shift_C), // перенос/заём
		.V(shift_V)  // переполнение
	);
	
	assign Z = (result == 16'h0000);
	assign S = result[15];
	
endmodule