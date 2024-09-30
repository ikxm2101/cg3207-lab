# This program is to evaluate the Hardware Implementation of RISC-V Processor

# ------- <code memory (ROM mapped to Instruction Memory) begins>
.text	## IROM segment 0x00000000-0x000001FC
# Total number of instructions should not exceed 128 (127 excluding the last line 'halt B halt').

main:
    la s1, LEDS             # Testing auipc and addi
    li s2, 0x00002404       # to show lui
    la s3, PBS              
    la s4, SEVENSEG
    li, t6, 0x1             # Shift constant

loop:
    # Load value of DIPS to t0
    lw t0, (s2)             # Read value of DIPS

    # Load 8 least significant value of DIPS to t1
    andi t1, t0, 0xFF       

    # Load 8 most signficant value of DIPS to t3
    li t2, 0x8              # Load immediate, will be decomposed to addi since imm is small
    srl t3, t0, t2          # shift right by 8 bits
    andi t3, t3, 0xFF       

    # Perform AND, OR, +, - operations between t1 and t3
    and s6, t3, t1          # DIPS [15:8] and DIPS [7:0] 
    or s7, t3, t1           # DIPS [15:8] or DIPS [7:0] 
    add s8, t3, t1          # DIPS [15:8] + DIPS [7:0] 
    sub s9, t3, t1          # DIPS [15:8] - DIPS [7:0] 

    # Flag for Display
    li, s10, 0x1

display_fork:
    lw s5, DELAY_VAL
    lw t4, (s3)                     # Read button values
    andi t4, t4, 0x2                # Mask for BTN C
    bne t4, zero, shift_display     # If BTN C is pressed go to shifting mode
    beq s10, zero, display_f0       # If flag not set, go to display_f0

display_f1:             # Display when flag is 1
    sw s6, (s1)         # Write to LED (result of AND)
    sw s8, (s4)         # Write to 7 segment (result of ADD)
    and s10, s10, zero  # Reset flag
    j display_wait      

display_f0:             # Display when flag is 0
    sw s7, (s1)         # write to LED (result of OR)
    sw s9, (s4)         # write to 7 segment (result of SUB)
    li, s10, 0x1        # Set flag
    j display_wait

display_wait:           # Delay loop
    addi s5, s5, -1
    bne s5, zero, display_wait
    j display_fork

shift_display:
    sw s9, (s4) # show DIPS [7:0] - DIPS [15:8] on 7 Seg
    sw zero, (s1) # clear LEDs

    lw s11, DEBOUNCE_VAL       # debounce wait time
    j debounce_wait     # debounce centre button

    lw t4, (s3) # read button values
    li, t6, 0x1 # set the value to shift by

    # Check for Button Press
    lw t4, (s3)         # Read button values
    andi t5, t4, 0x2    # Mask for BTN C 
    bne t5, zero, loop  # if BTN C pressed go to start of loop

    andi t5, t4, 0x4            # Mask for BTN L
    bne t5, zero, left_shift    # if BTN L pressed left shift
 
    andi t5, t4, 0x1            # Mask for BTN R
    bne t4, zero, right_shift   # if BTN R is pressed
    
    j shift_display

right_shift:
    sra s9, s9, t6
    j shift_display

left_shift:
    sll s9, s9, t6
    j shift_display

debounce_wait:
    addi s11, s11, -1
    bne s11, zero, debounce_wait
    j shift_display



# ------- <code memory (ROM mapped to Instruction Memory) ends>			
				
								
#------- <constant memory (ROM mapped to Data Memory) begins>									
.data	## DROM segment 0x00002000-0x000021FC
# All constants should be declared in this section. This section is read only (Only lw, no sw).
# Total number of constants should not exceed 128
# If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.
DROM:
DELAY_VAL: .word 4
DEBOUNCE_VAL: .word 0xFFF

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
