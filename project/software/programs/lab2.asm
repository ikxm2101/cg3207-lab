# This program is to evaluate the Hardware Implementation of RISC-V Processor

# ------- <code memory (ROM mapped to Instruction Memory) begins>
.text	## IROM segment 0x00000000-0x000001FC
# Total number of instructions should not exceed 128 (127 excluding the last line 'halt B halt').

main:
    la s1, LEDS # Testing auipc and addi
    li s2, 0x00002404 # to show lui
    la s3, PBS
    la s4, SEVENSEG

loop:
    # t0: value of DIPS
    # t1: DIPS [7:0]
    # t3: DIPS [15:8]
    lw t0, (s2) # Read value of DIPS

    andi t1, t0, 0xFF # DIPS [7:0]
    li t2, 0x8 
    srl t3, t0, t2 # shift right by 8 bits
    andi t3, t3, 0xFF # DIPS [15:8]

    and s6, t1, t3 # DIPS [7:0] and DIPS [15:8]
    or s7, t1, t3 # DIPS [7:0] or DIPS [15:8]

    add s8, t1, t3 # DIPS [7:0] + DIPS [15:8]
    sub s9, t1, t3 # DIPS [7:0] - DIPS [15:8]

    li, s10, 0x1 # flag for display

display_fork:
    lw s5, DELAY_VAL
    lw t4, (s3) # read button values
    andi t4, t4, 0x2 # Mask for BTN C
    bne t4, zero, button_display # if BTN C is pressed go to shifting mode
    beq s10, zero, display2 # go to display 2

display1: # display when flag is 1
    sw s6, (s1) # write to LED (result of AND)
    sw s8, (s4) # write to 7 segment (result of ADD)
    and s10, s10, zero # reset flag
    j display_wait

display2: # display when flag is 0
    sw s7, (s1) # write to LED (result of OR)
    sw s9, (s4) # write to 7 segment (result of SUB)
    li, s10, 0x1 # set flag
    j display_wait

display_wait:
    addi s5, s5, -1
    bne s5, zero, display_wait
    j display_fork

button_display:
    sw s9, (s4) # show DIPS [7:0] - DIPS [15:8] on 7 Seg
    lw t4, (s3) # read button values
    li, t6, 0x1 # set the value to shift by

    andi t5, t4, 0x2 # Mask for BTN C
    bne t5, zero, loop # if BTN C pressed go to start of loop

    andi t5, t4, 0x4 # Mask for BTN L
    bne t5, zero, left_shift # if BTN L pressed left shift
 
    andi t5, t4, 0x1 # Mask for BTN R
    bne t4, zero, right_shift # if BTN R is pressed
    
    j button_display

right_shift:
    sra s9, s9, t6
    j seven_display

left_shift:
    sll s9, s9, t6
    j seven_display

seven_display:
    sw s9, (s4) # show result of SUB on 7 Seg
    li s10, 0xFFF # debounce wait time

debounce_wait:
    addi s10, s10, -1
    bne s10, zero, debounce_wait
    j button_display



# ------- <code memory (ROM mapped to Instruction Memory) ends>			
				
								
#------- <constant memory (ROM mapped to Data Memory) begins>									
.data	## DROM segment 0x00002000-0x000021FC
# All constants should be declared in this section. This section is read only (Only lw, no sw).
# Total number of constants should not exceed 128
# If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.
DROM:
DELAY_VAL: .word 4

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