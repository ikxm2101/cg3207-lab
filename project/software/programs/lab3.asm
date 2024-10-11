#----------------------------------------------------------------------------------
#-- (c) Rajesh Panicker
#--	License terms :
#--	You are free to use this code as long as you
#--		(i) DO NOT post it on any public repository;
#--		(ii) use it only for educational purposes;
#--		(iii) accept the responsibility to ensure that your implementation does not violate anyone's intellectual property.
#--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
#--		(v) send an email to rajesh<dot>panicker<at>ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
#--		(vi) retain this notice in this file and any files derived from this.
#----------------------------------------------------------------------------------

# This program is to evaluate the Hardware Implementation of RISC-V Processor

.eqv LSB_MASK 0xFF
.eqv SIGN_MASK 0x8000

# ------- <code memory (ROM mapped to Instruction Memory) begins>
.text	## IROM segment 0x00000000-0x000001FC
# Total number of instructions should not exceed 128 (127 excluding the last line 'halt B halt').

main: # Initialise all variables
    li s5, SIGN_MASK
    li s6, LSB_MASK
    la s7, LEDS
    la s8, CONSOLE_OUT_ready
    la s9, CONSOLE_IN_valid
    la s10, CONSOLE
    li a0, 0                    # To store X1 Coordinate
    li a1, 0
    li a2, 0
    li a3, 0
    li a4, 0                    # Gradient (Magnitude)
    li a5, 0                    # Intercept
    li t3, 10                   # To store ones position multiplier
    li t4, 0                    # To store string to be printed
    li sp, 0
    
# Print welcome string and ask for X1:
    la t4, welcome_string
PRINT_1:			
	lw t0, (t4)		    # load the word (4 characters) to be displayed
	li t2, 4		    # byte counter
NEXT_CHAR_1:
	lw t1, (s8)		    # check if CONSOLE is ready to send a new character
	beqz t1, NEXT_CHAR_1	# not ready, continue waiting
	and t1, t0, s6 		# apply LSB_MASK
	beqz t1, WAIT_X1 	# null terminator ('\0') detected, done. Proceed to X1
	sw t1, (s10) 		# write to UART the Byte(4-t2) of the original word (composed of 4 characters) in (7:0) of the word to be written (remember, we can only write words, and LEDs/UART displays only (7:0) of the written word)
	srli t0, t0, 8	 	# shift so that the next character comes into LSB
	li t1, 1		    # note : no subi instruction in RV
	sub t2, t2, t1		# decrement the loop counter
	bnez t2, NEXT_CHAR_1	# check and print the next character in the word
	addi t4, t4, 4		# point to next word (4 characters)
	jal PRINT_1

    # Start reading
WAIT_X1:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_X1       # If t1 == 0, goto WAIT_X1
    lw t0, (s10)                # Read UART
    li t2, '\r'
    beq t0, t2, WAIT_Y1         # '\r' received, goto to WAIT_Y1


    mul a0, a0, t3              # Make space for ones position                     
    li t2, 48                   # '0' ascii in int
    sub t0, t0, t2              # input_char - 48 = input_int
    # TODO: valid character checking here ???
    add a0, a0, t0              # a0 = a0 + input_int
    jal WAIT_X1                 # goto WAIT_X1

WAIT_Y1:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_Y1       # If t1 == 0, goto WAIT_Y1
    lw t0, (s10)                # Read UART
    li t2, '\r'
    beq t0, t2, WAIT_X2         # '\r' received, goto to WAIT_X2


    mul a1, a1, t3              # Make space for ones position                     
    li t2, 48                   # '0' ascii in int
    sub t0, t0, t2              # input_char - 48 = input_int
    # TODO: valid character checking here ???
    add a1, a1, t0              # a0 = a0 + input_int
    jal WAIT_Y1                 # goto WAIT_Y1

WAIT_X2:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_X2       # If t1 == 0, goto WAIT_X2
    lw t0, (s10)                # Read UART
    li t2, '\r'
    beq t0, t2, WAIT_Y2         # '\r' received, goto to WAIT_Y2


    mul a2, a2, t3              # Make space for ones position                     
    li t2, 48                   # '0' ascii in int
    sub t0, t0, t2              # input_char - 48 = input_int
    # TODO: valid character checking here ???
    add a2, a2, t0              # a0 = a0 + input_int
    jal WAIT_X2                 # goto WAIT_X2

WAIT_Y2:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_Y2       # If t1 == 0, goto WAIT_Y2
    lw t0, (s10)                # Read UART
    li t2, '\r'
    beq t0, t2, CALC            # '\r' received, goto to CALC


    mul a3, a3, t3              # Make space for ones position                     
    li t2, 48                   # '0' ascii in int
    sub t0, t0, t2              # input_char - 48 = input_int
    # TODO: valid character checking here ???
    add a3, a3, t0              # a0 = a0 + input_int
    jal WAIT_Y2                 # goto WAIT_Y2

CALC:
    # a0: X1, a1: Y1, a2: X2, a3: Y2, t5: gradient sign

    beq a0, a2, INVALID_M_INF   # x1 and x2 same, invalid
    sub t0, a0, a2              # x1 - x2
    and t1, t0, s6              # Apply SIGN MASK
    li t3, 0                    # 0 == X1 > X2      
    beqz t1, CHECK_Y            # t1 == 0, X1 > X2
    li t3, 1                    # 1 == X2 > x1

CHECK_Y:
    sub t0, a1, a3              # y1 - y2 
    li sp, 1
    beqz t0, M_ZERO             # TODO:
    li sp, 0
    and t1, t0, s5              # Apply SIGN MASK
    li t4, 0                    # 0 == Y1 > Y2
    beqz t1, CHECK_M            # t1 == 0, Y1 > Y2
    li t4, 1                    # 1 == Y2 > Y1

CHECK_M:
    li t5, 0                    
    beq t3, t4, CALC_M           # Gradient positive
    li t5, 1

CALC_M:
    add s8, a0, zero
    add s9, a1, zero
    add s10, a2, zero
    add s11, a3, zero

    # t0 t1 t2
    beqz t3, M1                 # if X1 > X2 go to M1
    # Swap a0 and a2
    add t0, s8, zero            # t0 = a0
    add s8, a2, zero            # a0 = a2
    add s10, t0, zero            # a2 = t0 = a0_ori

M1:
    beqz t4, M2                # if Y1 > Y2, go to M2:
    # Swap a1 and a3
    add t0, s9, zero            # t0 = a1
    add s9, a3, zero            # a1 = a3   
    add s11, t0, zero            # a3 = t0 = a1_ori

M2:
    sub t0, s8, s10              # t0 = a0 - a2
    sub t1, s9, s11              # t1 = a1 - a3
    divu a4, t1, t0             # t2 = t1 / t0

    mul t0, a0, a4              # t0 = X1 * Gradient
    beq t5, zero, Y_INTER       # Check gradient sign
    sub t0, zero, t0            # negative: negate t0
Y_INTER:
    sub a5, a1, t0              # y_int = Y1 - t0

# Printing data
M_ZERO:
    la t0, string_1  
PRINT_RES:
    lw t1, (t0)
    li t2, 4
NEXTCHAR:
    lw t3, (s8)         # Check if console is ready
    beqz t3, NEXTCHAR
    and t3, t1, s6
    beqz t3, CONTINUE
    sw t3, (s10)
    srli t1, t1, 8
    li t3, 1
    sub t2, t2, t1
    bnez t2, NEXTCHAR
    addi t0, t0, 4
    jal PRINT_RES

CONTINUE:
    beqz t5, CONTINUE_1
    lw t3, (s8)
    beqz t3, CONTINUE
    li t3, '-'
    sw t3, (s10)
    
    beqz sp, CONTINUE_1 

    lw t0, (a1)
    li t1, 10
    jal CONTINUE_1_DIV

CONTINUE_1:
    lw t0, (a4)       # Gradient
    li t1, 10

CONTINUE_1_DIV:
    beqz t0, CONTINUE_2
    div t0, t0, t1
    rem t2, t0, t1
    addi t2, t2, 48 # Convert to ascii
    
CONTINUE_1_WAIT:
    lw t3, (s8) # Wait for ready
    beqz t3, CONTINUE_1_WAIT
    sw t2, (s10)
    jal CONTINUE_1_DIV

CONTINUE_2:
    bnez sp, main

    lw t3, (s8)
    beqz t3, CONTINUE_2
    li t3, 'X'
    sw t3, (s10)

    and t0, a5, s5           # SIGN MASK
    li t3, '+'
    beqz t0, CONTINUE_2_SIGN  # if t0 == 0, positive
    li t3, '-'
    sub a5, zero, a5         # Magnitude of intercept

CONTINUE_2_SIGN:
    lw t0, (s8)
    beqz t0, CONTINUE_2_SIGN
    sw t3, (s10)            # Print sign

    lw t0, (a5)   # Intercept magnitude
    li t1, 10
CONTINUE_2_DIV:
    beqz t0, main
    div t0, t0, t1
    rem t2, t0, t1
    addi t2, t2, 48

CONTINUE_2_WAIT:
    lw t3, (s8) # Wait for ready
    beqz t3, CONTINUE_2_WAIT
    sw t2, (s10)
    jal CONTINUE_2_DIV


INVALID_M_INF:
    la t4, string_2
PRINT_2:			
	lw t0, (t4)		    # load the word (4 characters) to be displayed
	li t2, 4		    # byte counter
NEXT_CHAR_2:
	lw t1, (s8)		    # check if CONSOLE is ready to send a new character
	beqz t1, NEXT_CHAR_2	# not ready, continue waiting
	and t1, t0, s6 		# apply LSB_MASK
	beqz t1, main 	# null terminator ('\0') detected, done. Proceed to X1
	sw t1, (s10) 		# write to UART the Byte(4-t2) of the original word (composed of 4 characters) in (7:0) of the word to be written (remember, we can only write words, and LEDs/UART displays only (7:0) of the written word)
	srli t0, t0, 8	 	# shift so that the next character comes into LSB
	li t1, 1		    # note : no subi instruction in RV
	sub t2, t2, t1		# decrement the loop counter
	bnez t2, NEXT_CHAR_2	# check and print the next character in the word
	addi t4, t4, 4		# point to next word (4 characters)
	jal PRINT_2


    
    
# ------- <code memory (ROM mapped to Instruction Memory) ends>			
				
								
#------- <constant memory (ROM mapped to Data Memory) begins>									
.data	## DROM segment 0x00002000-0x000021FC
# All constants should be declared in this section. This section is read only (Only lw, no sw).
# Total number of constants should not exceed 128
# If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.
DROM:
DELAY_VAL: .word 0x2422
welcome_string: .asciz "Welcome to desmos but taobao"
string_1: .asciz "Equation: Y = "
string_2: .asciz "Gradient is infinity"

#------- <constant memory (ROM mapped to Data Memory) ends>	


# ------- <variable memory (RAM mapped to Data Memory) begins>
.align 9 ## DRAM segment. 0x00002200-0x000023FC #assuming rodata size of <= 512 bytes (128 words)
# All variables should be declared in this section, adjusting the space directive as necessary. This section is read-write.
# Total number of variables should not exceed 128. 
# No initialization possible in this region. In other words, you should write to a location before you can read from it (i.e., write to a location using sw before reading using lw).
DRAM:
.space 512

# ------- <variable memory (RAM mapped to Data Memory) ends>


# ------- <memory-mapped input-output (peripherals) begins>
.align 9 ## MMIO segment. 0x00002400-0x00002418
MMIO:
LEDS: .word 0x0			# 0x00002400	# Address of LEDs. //volatile unsigned int * LEDS = (unsigned int*)0x00000C00#  
DIPS: .word 0x0			# 0x00002404	# Address of DIP switches. //volatile unsigned int * DIPS = (unsigned int*)0x00000C04#
PBS: .word 0x0			# 0x00002408	# Address of Push Buttons. Used only in Lab 2
CONSOLE: .word 0x0		# 0x0000240C	# Address of UART. Used only in Lab 2 and later
CONSOLE_IN_valid: .word 0x0	# 0x00002410	# Address of UART. Used only in Lab 2 and later
CONSOLE_OUT_ready: .word 0x0	# 0x00002414	# Address of UART. Used only in Lab 2 and later
SEVENSEG: .word	0x0		# 0x00002418	# Address of 7-Segment LEDs. Used only in Lab 2 and later

# ------- <memory-mapped input-output (peripherals) ends>