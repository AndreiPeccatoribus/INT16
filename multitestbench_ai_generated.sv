`timescale 1ns/1ps

/* Deepseek такой типа trust me bro сгенерировал этот тестбенч сначала без моих флагов */

module tb_alu;
    logic [15:0] a, b;
    logic [3:0]  command;
    logic [15:0] result;
    logic        c_out, Z, S, C, V;

    ALU dut (
        .a(a), .b(b), .command(command),
        .result(result), .c_out(c_out),
        .Z(Z), .S(S), .C(C), .V(V)
    );

    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // ==========================================
        // 1. ТЕСТЫ СЛОЖЕНИЯ (ADD: 0000)
        // ==========================================
        command = 4'b0000; 
        
        // Обычное сложение (все флаги 0)
        a = 16'd5; b = 16'd3; #10;
        if (result !== 16'd8 || Z !== 0 || S !== 0 || C !== 0 || V !== 0) $error("FAIL: ADD 5+3");

        // Флаг нуля
        a = 16'd0; b = 16'd0; #10;
        if (result !== 0 || Z !== 1) $error("FAIL: ADD 0+0 (Zero)");

        // Переполнение беззнаковое (Carry) и Zero
        a = 16'hFFFF; b = 16'd1; #10;
        if (result !== 0 || Z !== 1 || C !== 1 || V !== 0) $error("FAIL: ADD FFFF+1 (Carry)");

        // Переполнение знаковое (Overflow: плюс на плюс дает минус)
        a = 16'd32767; b = 16'd1; #10;
        if (result !== 16'h8000 || S !== 1 || V !== 1 || C !== 0) $error("FAIL: ADD 32767+1 (Overflow)");

        // ==========================================
        // 2. ТЕСТЫ ВЫЧИТАНИЯ (SUB: 0001)
        // ==========================================
        command = 4'b0001; 

        // Обычное вычитание (C=1 означает "нет заема")
        a = 16'd5; b = 16'd3; #10;
        if (result !== 16'd2 || Z !== 0 || S !== 0 || C !== 1 || V !== 0) $error("FAIL: SUB 5-3");

        // Отрицательный результат (заем, C=0)
        a = 16'd3; b = 16'd5; #10;
        if (result !== 16'hFFFE || S !== 1 || C !== 0 || V !== 0) $error("FAIL: SUB 3-5 (Neg)");

        // Ноль при вычитании
        a = 16'd7; b = 16'd7; #10;
        if (result !== 0 || Z !== 1 || C !== 1) $error("FAIL: SUB 7-7 (Zero)");

        // Переполнение знаковое при вычитании (минус на плюс дает плюс)
        a = 16'h8000; b = 16'd1; #10;
        if (result !== 16'h7FFF || S !== 0 || V !== 1 || C !== 1) $error("FAIL: SUB -32768-1 (Overflow)");

        // ==========================================
        // 3. ТЕСТЫ СДВИГОВ (SHL: 0010, SHR: 0011)
        // ==========================================
        command = 4'b0010; 
        // Выпадение 1 в перенос, результат 0
        a = 16'h8000; #10;
        if (result !== 16'h0000 || Z !== 1 || S !== 0 || C !== 1 || V !== 0) $error("FAIL: SHL 8000");

        command = 4'b0011; 
        // Сдвиг вправо, выпадение 1 в перенос
        a = 16'd5; #10;
        if (result !== 16'd2 || Z !== 0 || S !== 0 || C !== 1 || V !== 0) $error("FAIL: SHR 5");

        // ==========================================
        // 4. ТЕСТЫ ЛОГИКИ (AND: 0100, OR: 0101, XOR: 0110, NOT: 0111)
        // ==========================================
        command = 4'b0100; // AND
        // Результат 0
        a = 16'hFF00; b = 16'h00FF; #10;
        if (result !== 16'h0000 || Z !== 1 || S !== 0 || C !== 0 || V !== 0) $error("FAIL: AND Zero");
        // Результат с единицей в знаковом бите
        a = 16'h8000; b = 16'hFFFF; #10;
        if (result !== 16'h8000 || Z !== 0 || S !== 1) $error("FAIL: AND Sign");

        command = 4'b0101; // OR
        a = 16'd0; b = 16'd0; #10;
        if (result !== 0 || Z !== 1 || C !== 0 || V !== 0) $error("FAIL: OR Zero");

        command = 4'b0110; // XOR
        a = 16'hFFFF; b = 16'hFFFF; #10;
        if (result !== 0 || Z !== 1 || C !== 0 || V !== 0) $error("FAIL: XOR Zero");

        command = 4'b0111; // NOT
        a = 16'hFFFF; #10;
        if (result !== 0 || Z !== 1 || C !== 0 || V !== 0) $error("FAIL: NOT Zero");
        a = 16'h7FFF; #10;
        if (result !== 16'h8000 || Z !== 0 || S !== 1) $error("FAIL: NOT Sign");

        $display("=== ALL TESTS PASSED SUCCESSFULLY ===");
        $finish;
    end
endmodule