# ==============================================================================
# FILE: math_ops.asm
# DESCRIPTION: RISC-V M-Extension Arithmetic Routines (RV32IM / RV64IM)
# ==============================================================================

.section .text                  # Define the executable code section
.align 2                        # Align instructions on 4-byte boundaries

# ------------------------------------------------------------------------------
# FUNCTION: dot_product
# Signature: int64_t dot_product(const int32_t *A, const int32_t *B, size_t len)
# Inputs:    a0 = Address of Array A, a1 = Address of Array B, a2 = Length (len)
# Outputs:   a0 = Lower 32-bits, a1 = Upper 32-bits of the 64-bit result
# ------------------------------------------------------------------------------
.global dot_product
dot_product:
    li      t0, 0               # t0 = Accumulator Low
    li      t1, 0               # t1 = Accumulator High
    li      t2, 0               # t2 = Loop index counter (i = 0)

.Lloop_start:
    bge     t2, a2, .Lloop_end  # If i >= len, exit loop structure

    lw      t3, 0(a0)           # Load A[i] signed word
    lw      t4, 0(a1)           # Load B[i] signed word

    # Hardware M-Extension Multiplication Phase
    mul     t5, t3, t4          # t5 = Lower 32-bits of product
    mulh    t6, t3, t4          # t6 = Upper 32-bits of product (signed)

    # 64-bit Accumulation Cycle (t1:t0 += t6:t5)
    add     t0, t0, t5          # Add lower word
    sltu    t5, t0, t5          # Carry check: t5 = 1 if an overflow occurred
    add     t1, t1, t6          # Add upper word
    add     t1, t1, t5          # Apply the lower carry bit to the upper word

    # Advance pointers and loop index
    addi    a0, a0, 4           # Move Array A pointer by 4 bytes (sizeof(int32_t))
    addi    a1, a1, 4           # Move Array B pointer by 4 bytes
    addi    t2, t2, 1           # Increment index counter (i++)
    j       .Lloop_start

.Lloop_end:
    mv      a0, t0              # Load return lower word
    mv      a1, t1              # Load return upper word
    ret                         # Return control flow to caller

# ------------------------------------------------------------------------------
# FUNCTION: safe_divide
# Signature: int32_t safe_divide(int32_t dividend, int32_t divisor, int32_t *rem_out)
# Inputs:    a0 = Dividend, a1 = Divisor, a2 = Pointer to store remainder
# Outputs:   a0 = Quotient result, and stores remainder dynamically to *rem_out
# ------------------------------------------------------------------------------
.global safe_divide
safe_divide:
    # Check for division by zero to prevent unexpected mathematical pipelines
    beqz    a1, .Ldiv_by_zero

    # Compute division and remainder using native hardware circuits
    div     t0, a0, a1          # t0 = Quotient (a0 / a1)
    rem     t1, a0, a1          # t1 = Remainder (a0 % a1)
    
    sw      t1, 0(a2)           # Write the computed remainder to memory pointer *rem_out
    mv      a0, t0              # Pass quotient back as the functional return value
    ret

.Ldiv_by_zero:
    li      t0, 0
    sw      t0, 0(a2)           # Set remainder value explicitly to 0
    li      a0, -1              # Return explicit -1 failure code flag
    ret
