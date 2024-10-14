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
    li s2, 48                   # value of 0 in ASCII
    li s3, 10                   # value of 10 for multiplier
    li s4, '\r'                 # value of '\r'
    li s5, SIGN_MASK
    li s6, LSB_MASK
    la s7, DIPS
    la s8, CONSOLE_OUT_ready
    la s9, CONSOLE_IN_valid
    la s10, CONSOLE
    la s11, SEVENSEG
    li a0, 0                    # X Value
    li a1, 0                    # Y Value
    li a2, 0                    # Result of X*Y
    li a3, 0                    # Result of X/Y

    
# Print welcome string and ask for X1:
    la t4, welcome_string
PRINT_WEL:			
	lw t0, (t4)		    # load the word (4 characters) to be displayed
	li t2, 4		    # byte counter
NEXT_CHAR_WEL:
	lw t1, (s8)		        # check if CONSOLE is ready to send a new character
	beqz t1, NEXT_CHAR_WEL	# not ready, continue waiting
	and t1, t0, s6 		    # apply LSB_MASK to get the least sig byte
	beqz t1, WAIT_X 	    # null terminator ('\0') detected, go to X1
	sw t1, (s10) 		    # write to UART the Byte(4-t2) of the original word (composed of 4 characters) in (7:0) of the word to be written (remember, we can only write words)
	srli t0, t0, 8	 	    # shift so that the next character comes into LSB
	addi t2, t2, -1		    # decrement the loop counter
	bnez t2, NEXT_CHAR_WEL	# check and print the next character in the word
	addi t4, t4, 4		    # point to next word (4 characters)
	jal PRINT_WEL           # Jump back to printing

    # Start reading
WAIT_X:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_X        # Not ready, continue waiting.
    lw t0, (s10)                # Read UART
    beq t0, s4, WAIT_Y          # '\r' received, goto to WAIT_Y

    # Populate the register based on characters received
    mul a0, a0, s3              # Make space for ones position                     
    addi t0, t0, -48              # integer = input - '0'
    add a0, a0, t0              # a0 = a0 + integer
    jal WAIT_X                  # jump back to receive next character

WAIT_Y:
    lw t1, (s9)                 # Read new character flag
    beq t1, zero, WAIT_Y        # Not ready, continue waiting.
    lw t0, (s10)                # Read UART
    beq t0, s4, CALC            # '\r' received, goto to WAIT_X2

    # Populate the register based on characters received
    mul a1, a1, s3              # Make space for ones position                     
    addi t0, t0, -48              # integer = input - '0'
    add a1, a1, t0              # a1 = a1 + integer
    jal WAIT_Y                  # jump back to receive next character

CALC:
    # a0: X, a1: Y, a2: X * Y, a3: X / Y
    mul a2, a0, a1      # a2 = X * Y
    divu a3, a0, a1     # a3 = X / Y

# Display data
DISPLAY_LOOP: 
    lw t4, (s7)             # Read Value of DIPS
    andi t5, t4, 1          # Get DIPS[0]
    bnez t5, DISPLAY_MUL    # Go to X * Y if not Activated

DISPLAY_DIV:
# Display X / Y if activated
    sw a3, (s11)
    jal DISPLAY_LOOP

DISPLAY_MUL:
    sw a2, (s11)
    jal DISPLAY_LOOP

    
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
welcome_string: .asciz "\r\nWelcome to desmos but taobao\r\n Enter X, Y separated by a carriage return.\r\n"

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
