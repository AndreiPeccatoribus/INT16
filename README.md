# <p align="center"> FP16 </p>

<p align="center">
  <img src="https://img.shields.io/badge/SystemVerilog-1A1A1A?style=for-the-badge&logo=systemverilog&logoColor=white" alt="SystemVerilog">
  <img src="https://img.shields.io/badge/Altera-00549F?style=for-the-badge&logo=intel&logoColor=white" alt="Altera">
  <img src="https://img.shields.io/github/stars/AndreiPeccatoribus/INT16?style=for-the-badge&logo=github&color=yellow" alt="Repo stars">
  <img src="https://img.shields.io/github/license/AndreiPeccatoribus/INT16?style=for-the-badge&logo=open-source-initiative&logoColor=green" alt="License">
</p>

<p align="center">
<img src="logo.gif" alt="FP16 Core Logo" width="600" />
</p>

# Chapter: 16-bit Integer ALU service core

![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)
![GitHub top language](https://img.shields.io/github/languages/top/AndreiPeccatoribus/INT16?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/AndreiPeccatoribus/INT16?style=for-the-badge)

Арифметико-логическое устройство (АЛУ) для 16-битного процессора. 
Спроектировано с использованием сумматора с параллельным переносом (Carry Lookahead Adder) для максимального быстродействия.

## Features
* 16-битные входы/выходы.
* Поддержка арифметики (ADD, SUB), сдвигов (SHL, SHR) и логических операций (AND, OR, XOR, NOT).
* Аппаратное вычисление флагов (Zero, Sign, Carry, Overflow).
* Параллельное вычисление арифметики, логики и сдвигов (выбор результата через выходной мультиплексор).

## Interface
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | Input | 16 | Первый операнд |
| `b` | Input | 16 | Второй операнд |
| `command` | Input | 4 | Код операции |
| `result` | Output | 16 | Результат операции |
| `c_out` | Output | 1 | Перенос из 16-го разряда / Выпавший бит при сдвиге |
| `Z` | Output | 1 | Флаг нуля (Result == 0) |
| `S` | Output | 1 | Флаг знака (Result[15]) |
| `C` | Output | 1 | Флаг переноса/заёма |
| `V` | Output | 1 | Флаг переполнения (только для знаковых операций) |

## Operations (Instruction Set)
| Command | Operation | Description |
| :--- | :--- | :--- |
| `4'b0000` | ADD | `result = a + b` |
| `4'b0001` | SUB | `result = a - b` (также используется для сравнения чисел по флагам) |
| `4'b0010` | SHL | `result = a << 1` (логический сдвиг влево) |
| `4'b0011` | SHR | `result = a >> 1` (логический сдвиг вправо) |
| `4'b0100` | AND | `result = a & b` |
| `4'b0101` | OR  | `result = a \| b` |
| `4'b0110` | XOR | `result = a ^ b` |
| `4'b0111` | NOT | `result = ~a` |

## Architecture
Модуль спроектирован по принципу параллельных вычислений:
1. **`b_subtractor_prep`**: подготавливает операнд B (инверсия и +1) для вычитания.
2. **`int_16_adder`**: 16-битный сумматор (4 блока `lookahead_4_adder`), вычисляет сумму/разность и флаги.
3. **`shifter`**: выполняет сдвиги влево/вправо (реализован простой коммутацией проводов, не занимает LUT).
4. **Логический блок**: параллельно вычисляет AND, OR, XOR, NOT.
5. **Выходной мультиплексор**: на основе `command` выбирает нужный результат и соответствующие ему флаги.
