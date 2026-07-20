# Compile the .asm file into an independent object file (.o)
riscv64-unknown-elf-gcc -c -march=rv32im -mabi=ilp32 math_ops.asm -o math_ops.o

# Alternatively, compile and link it directly with a main C file test harness
riscv64-unknown-elf-gcc -O2 -march=rv32im -mabi=ilp32 main.c math_ops.asm -o application.elf
clang -target riscv32 -march=rv32im -mabi=ilp32 -c math_ops.asm -o math_ops.o
# Disassemble your compiled binary code file to check the generated instructions
riscv64-unknown-elf-objdump -d main.elf | grep -E "mul|div|rem"

# General Syntax for Compilation
riscv64-unknown-elf-gcc -O2 -march=<ARCH_STRING> -mabi=<ABI_STRING> main.c -o main.elf
