module shifter(
	input logic command, // 0 -- вправо, 1 -- влево, почему нет арифметического? будет, но в FP, т.к. он только для деления нужен
	
	input logic [15:0] inp,
	output logic [15:0] out,
	output logic        c_out,
	
	output logic C, // перенос/заём
	output logic V  // переполнение
);
	logic [15:0] shift_left;
	logic [15:0] shift_right;
	
	assign shift_left = {inp[14:0], 1'b0};
	assign shift_right = {1'b0, inp[15:1]};
	
	always_comb begin
		if (command) begin
			out = shift_left;
			c_out = inp[15]; // выпавший бит
		end else begin
			out = shift_right;
			c_out = inp[0];
		end
	end
	
	//C 
	assign C = c_out;
	
	//V 
	assign V = inp[15] ^ out[15]; // сдвиг не может вызвать переполнение, лишний бит всегда уходит в c_out, сам термин переполнение не имеет здесь смысла, поэтому просто 0.


endmodule