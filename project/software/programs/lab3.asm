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
.eqv SIGN_MASK 0x80000000

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
    la s11, SEVENSEG
    li a0, 0                    # X1 Coordinate
    li a1, 0                    # Y1 Coordinate
    li a2, 0                    # X2 Coordinate
    li a3, 0                    # Y2 Coordinate
    li a4, 0                    # Gradient (Magnitude)
    li a5, 0                    # Intercept
    li a6, 0                    # Gradient (Sign)
    li s1, 0                    # flag for Y-line (ie. y1 == y2)
    li s2, 48                   # value of 0 in ASCII
    li s3, 10                   # value of 10 for multiplier
    li s4, '\r'                 # value of '\r'
    
# Print welcome string and ask for X1:
    la t4, welcome_string
PRINT_WEL:			
	lw t0, (t4)		    # load the word (4 characters) to be displayed
	li t2, 4		    # byte counter
NEXT_CHAR_WEL:
	lw t1, (s8)		        # check if CONSOLE is ready to send a new character
	beqz t1, NEXT_CHAR_WEL	# not ready, continue waiting
	and t1, t0, s6 		    # apply LSB_MASK to get the least sig byte
	beqz t1, WAIT_X1 	    # null terminator ('\0') detected, go to X1
	sw t1, (s10) 		    # write to UART the Byte(4-t2) of the original word (composed of 4 characters) in (7:0) of the word to be written (remember, we can only write words)
	srli t0, t0, 8	 	    # shift so that the next character comes into LSB
	addi t2, t2, -1		    # decrement the loop counter
	bnez t2, NEXT_CHAR_WEL	# check and print the next character in the word
	addi t4, t4, 4		    # point to next word (4 characters)
	jal PRINT_WEL           # Jump back to printing

    # Start reading
WAIT_X1:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_X1       # Not ready, continue waiting.
    lw t0, (s10)                # Read UART
    # and t0, t0, s6 		        # apply LSB_MASK to get the least sig byte
    sw t0, (s11)                # HACK
    beq t0, s4, WAIT_Y1         # '\r' received, goto to WAIT_Y1

    # Populate the register based on characters received
    mul a0, a0, s3              # Make space for ones position                     
    sub t0, t0, s2              # integer = input - '0'
    add a0, a0, t0              # a0 = a0 + integer
    jal WAIT_X1                 # jump back to receive next character

WAIT_Y1:
    # sw a0, (s11)                # write a0 to s11
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_Y1       # Not ready, continue waiting.
    lw t0, (s10)                # Read UART
    # and t0, t0, s6 		        # apply LSB_MASK to get the least sig byte
    sw t0, (s11)                # HACK
    beq t0, s4, WAIT_X2         # '\r' received, goto to WAIT_X2

    # Populate the register based on characters received
    mul a1, a1, s3              # Make space for ones position                     
    sub t0, t0, s2              # integer = input - '0'
    add a1, a1, t0              # a1 = a1 + integer
    jal WAIT_Y1                 # jump back to receive next character

WAIT_X2:
    # sw a1, (s11)                # write a1 to s11
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_X2       # Not ready, continue waiting.
    lw t0, (s10)                # Read UART
    # and t0, t0, s6 		        # apply LSB_MASK to get the least sig byte
    sw t0, (s11)                # HACK
    beq t0, s4, WAIT_Y2         # '\r' received, goto to WAIT_Y2

    # Populate the register based on characters received
    mul a2, a2, s3              # Make space for ones position                     
    sub t0, t0, s2              # integer = input - '0'
    add a2, a2, t0              # a2 = a2 + integer
    jal WAIT_X2                 # jump back to receive next character

WAIT_Y2:
    # sw a2, (s11)                # write a2 to s11
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_Y2       # Not ready, continue waiting.
    lw t0, (s10)                # Read UART
    # and t0, t0, s6 		        # apply LSB_MASK to get the least sig byte
    sw t0, (s11)                # HACK
    beq t0, s4, CALC            # '\r' received, goto to CALC

    # Populate the register based on characters received
    mul a3, a3, s3              # Make space for ones position                     
    sub t0, t0, s2              # integer = input - '0'
    add a3, a3, t0              # a3 = a3 + integer
    jal WAIT_Y2                 # jump back to receive next character

CALC:
    # sw a3, (s11)                # write a3 to s11
    # a0: X1, a1: Y1, a2: X2, a3: Y2, a6: gradient sign

    beq a0, a2, INVALID_M_INF   # x1 and x2 same, m is infinite
    sub t0, a0, a2              # x1 - x2
    and t1, t0, s5              # Apply SIGN MASK
    li t3, 0                    # 0 == X1 > X2      
    beqz t1, CHECK_Y            # t1 == 0, X1 > X2
    li t3, 1                    # 1 == X2 > x1

CHECK_Y:
    sub t0, a1, a3              # y1 - y2 
    li s1, 1                    # Set Y1 == Y2 flag
    beqz t0, M_ZERO             # If Y1 == Y2, then immediately print out
    li s1, 0                    # Reset Y1 == Y2 flag
    and t1, t0, s5              # Apply SIGN MASK
    li t4, 0                    # 0 == Y1 > Y2
    beqz t1, CHECK_M            # t1 == 0, Y1 > Y2
    li t4, 1                    # 1 == Y2 > Y1

CHECK_M:
    li a6, 0                    # Set gradient sign to pos 
    beq t3, t4, CALC_M          # Gradient positive
    li a6, 1                    # Set gradient sign to neg

CALC_M:
    add s8, a0, zero            # Temp value for X1
    add s9, a1, zero            # Temp value for Y1
    add s10, a2, zero           # Temp value for X2
    add s11, a3, zero           # Temp value for Y2

    beqz t3, M1                 # if X1 > X2 go to M1
    # otherwise we swap s8 and s10 (for unsigned division purposes)
    add t0, s8, zero            # t0 = s8 (X1)
    add s8, s10, zero           # s8 = s10 (X2)
    add s10, t0, zero           # s10 = t0 (X1)

M1:
    beqz t4, M2                 # if Y1 > Y2, go to M2
    # otherwise we swap s9 and s11 (for unsigned division purposes)
    add t0, s9, zero            # t0 = s9 (Y1)
    add s9, s11, zero           # s9 = s11 (Y2) 
    add s11, t0, zero           # s11 = t0 (Y1)

M2:
    sub t0, s8, s10             # t0 = delta of X
    sub t1, s9, s11             # t1 = delta of Y
    divu a4, t1, t0             # a4 = t1 / t0
    sw a4, (s11)                # HACK: doesnt reach here
    mul t0, a0, a4              # t0 = X1 * Gradient
    beq a6, zero, Y_INTER       # Check gradient sign
    sub t0, zero, t0            # negative: negate t0
Y_INTER:
    sub a5, a1, t0              # y_int = Y1 - t0

# Reinitialise S8, S9, S10
    la s8, CONSOLE_OUT_ready
    la s9, CONSOLE_IN_valid
    la s10, CONSOLE
    la s11, SEVENSEG

# Printing data
M_ZERO:
    la t0, string_1             # Load address of string
PRINT_RES:
    lw t1, (t0)                 # Load word (4 chars)
    li t2, 4                    # Byte counter
NEXT_CHAR_RES:
    lw t3, (s8)                 # Check if console is ready
    beqz t3, NEXT_CHAR_RES      # Not ready, continue waiting
    and t3, t1, s6              # Apply LSB_MASK
    beqz t3, CONTINUE           # "\0" detected, finish printing
    sw t3, (s10)                # Write to CONSOLE
    srli t1, t1, 8              # shift next char
	addi t2, t2, -1		        # decrement the loop counter
    bnez t2, NEXT_CHAR_RES      # print next char in current word
    addi t0, t0, 4              # load next word in string
    jal PRINT_RES               # repeat word print

CONTINUE:
    beqz a6, CONTINUE_1         # if gradient is positive, no need print sign
    lw t3, (s8)                 # Check if console is ready
    beqz t3, CONTINUE           # Not ready, continue waiting
    li t3, '-'                  # Load '-' for printing
    sw t3, (s10)                # Print to console

CONTINUE_1:
    add t0, zero, a4            # Load gradient (magnitude)
    addi sp, sp, -48            # stack grow donwards
    li t4, 0                    # counter for number of characters
    add t5, sp, zero            # stack pointer for storing digits

    beqz s1, CONTINUE_1_DIV     #  if Y1 != Y2, go to printing gradient
    add t0, zero, a1            # otherwise load Y1

CONTINUE_1_DIV:
    beqz t0, PRINT_GRADIENT_CONTINUE    # If nothing to add to stack, go to print
    rem t2, t0, s3                      # extract the remainder (last digit in base10)
    div t0, t0, s3                      # remove the last digit in base 10
    add t2, t2, s2                      # Convert to ascii
    
CONTINUE_1_WAIT:
    sw t2, (t5)                 # store digit into stack
    addi t4, t4, 1              # increase number of characters
    addi t5, t5, 4              # move pointer to next memory location    
    jal CONTINUE_1_DIV          # Repeat printing digits

PRINT_GRADIENT_CONTINUE:
    beqz t4, CONTINUE_2     # If nothing else to print go to intercept
    addi t4, t4, -1         # decrement number of characters
    addi t5, t5, -4         # move to next character

PRINT_GRADIENT_WAIT:
    lw t0, (s8)                     # check if console is ready
    beqz t0, PRINT_GRADIENT_WAIT    # Not ready, continue waiting
    lw t3, (t5)                     # load char from memory
    sw t3, (s10)                    # Print char to Console
    jal PRINT_GRADIENT_CONTINUE

CONTINUE_2:
    bnez s1, main               # if Y1 == Y2, go back to top

    lw t3, (s8)                 # Check if console is ready
    beqz t3, CONTINUE_2         # Not ready, continue waiting
    li t3, 'X'                  # Load 'X' to be printed
    sw t3, (s10)                # Write to CONSOLE

    beqz a5, main               # if y-intercept is 0, go back to top

    and t0, a5, s5              # Apply SIGN MASK to Y-Intercept
    li t3, '+'                  # Load '+' sign
    beqz t0, CONTINUE_2_SIGN    # if Y-intercept positive, print sign
    li t3, '-'                  # otherwise load '-' sign
    sub a5, zero, a5            # Magnitude of intercept

CONTINUE_2_SIGN:
    lw t0, (s8)                 # Check if console is ready
    beqz t0, CONTINUE_2_SIGN    # Not ready, continue waiting
    sw t3, (s10)                # Print sign

    add t0, zero, a5            # Temporary for y-intercept mag
    addi sp, sp, -48            # stack grow donwards
    li t4, 0                    # counter for number of characters
    add t5, sp, zero            # stack pointer for storing digits
    
CONTINUE_2_DIV:     
    beqz t0, PRINT_INT_CONTINUE     # If no more digits, go to print      
    rem t2, t0, s3                  # Extract remainder (last digit of base-10)
    div t0, t0, s3                  # Remove last digit of base-10
    add t2, t2, s2                  # Convert to ASCII

CONTINUE_2_WAIT:
    sw t2, (t5)                 # store digit into stack
    addi t4, t4, 1              # increase number of characters
    addi t5, t5, 4              # move pointer to next memory location

    jal CONTINUE_2_DIV          # Continue printing next digit

PRINT_INT_CONTINUE:
    beqz t4, main           # If nothing else to print go to main
    addi t4, t4, -1         # decrement number of characters
    addi t5, t5, -4         # move to next character

PRINT_INT_WAIT:
    lw t0, (s8)                     # check if console is ready
    beqz t0, PRINT_INT_WAIT    # Not ready, continue waiting
    lw t3, (t5)                     # load char from memory
    sw t3, (s10)                    # Print char to Console
    jal PRINT_INT_CONTINUE

INVALID_M_INF:
    la t4, string_2         # Load invalid string
PRINT_2:			
	lw t0, (t4)		        # load the word (4 characters) to be displayed
	li t2, 4		        # byte counter
NEXT_CHAR_2:
	lw t1, (s8)		        # check if CONSOLE is ready to send a new character
	beqz t1, NEXT_CHAR_2	# not ready, continue waiting
	and t1, t0, s6 		    # apply LSB_MASK
	beqz t1, main 	        # null terminator ('\0') detected, done. Return to Programme Start
	sw t1, (s10) 		    # write to UART the Byte(4-t2) of the original word (composed of 4 characters) in (7:0) of the word to be written (remember, we can only write words, and LEDs/UART displays only (7:0) of the written word)
	srli t0, t0, 8	 	    # shift so that the next character comes into LSB
	addi t2, t2, -1		    # decrement the loop counter
	bnez t2, NEXT_CHAR_2	# check and print the next character in the word
	addi t4, t4, 4		    # point to next word (4 characters)
	jal PRINT_2             # continue printing
    
    
# ------- <code memory (ROM mapped to Instruction Memory) ends>			
				
								
#------- <constant memory (ROM mapped to Data Memory) begins>									
.data	## DROM segment 0x00002000-0x000021FC
# All constants should be declared in this section. This section is read only (Only lw, no sw).
# Total number of constants should not exceed 128
# If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.
# Alignment is needed such that when the string is loaded the address would be valid
DROM:
.align 4
DELAY_VAL: .word 0x2422
.align 4
welcome_string: .asciz "\r\nWelcome to desmos but taobao\r\n Enter X1, Y1, X2, Y2 separated by a carriage return.\r\n"
.align 4
string_1: .asciz "\r\nEquation: Y = "
.align 4
string_2: .asciz "\r\nGradient is infinity\r\n"

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
