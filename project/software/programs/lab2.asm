# This program is to evaluate the Hardware Implementation of RISC-V Processor

# ------- <code memory (ROM mapped to Instruction Memory) begins>
.text	## IROM segment 0x00000000-0x000001FC
# Total number of instructions should not exceed 128 (127 excluding the last line 'halt B halt').

main:
    la s1, LEDS             # Testing auipc and addi
    li s2, 0x00002404       # to show lui
    la s3, PBS              
    la s4, SEVENSEG
    li t6, 0x1              # Shift constant
    li a5, 0x0              # Flag for Mode
    li s10, 0x0		     # Flag for Display
    li a6, 0x0              # Previous sub value (unshifted)
    li a7, 0x0              # Shifted sub value

detect_button:
    lw t4, (s3)             # Get button values
    andi a2, t4, 0x4        # Left button flag
    andi a3, t4, 0x2        # Center button flag
    andi a4, t4, 0x1        # Right button flag
    beq t4, zero, mode_select   # if button not pressed, goto mode_select.
    lw s11, DEBOUNCE_VAL       # debounce wait time

debounce:
    addi s11, s11, -1       # decrement
    bne s11, zero, debounce

mode_select:
    # Load value of DIPS to t0
    lw t0, (s2)             # Read value of DIPS

    # Load 8 least significant value of DIPS to t1
    andi t1, t0, 0xFF       # DIPS[7:0]

    # Load 8 most signficant value of DIPS to t3
    li t2, 0x8              # Load immediate, will be decomposed to addi since imm is small
    srl t3, t0, t2          # Shift right by 8 bits
    andi t3, t3, 0xFF       # DIPS[15:8]

    # Perform AND, OR, +, - operations between t1 and t3
    and s6, t3, t1          # DIPS[15:8] and DIPS[7:0] 
    or s7, t3, t1           # DIPS[15:8] or DIPS[7:0] 
    add s8, t3, t1          # DIPS[15:8] + DIPS[7:0] 
    sub s9, t3, t1          # DIPS[15:8] - DIPS[7:0] 

    # Check for center button press
    bne a3, zero, toggle_mode   # If btnC is pressed, go to toggle_mode
    j continue              # Else go to //todo:
    
toggle_mode: 
    beq a5, zero, toggle_flag
    li a5, 0
    j continue

toggle_flag:
    li a5, 1

continue:
    beq a5, zero, normal_mode   # If flag is 0, go to normal_mode
    j shift_mode                # else, go to shift_mode

normal_mode:
    # check if s5 is zero
    beq s5, zero, change_display    # if delay expired, change display
    addi s5, s5, -1             # else decrement
    j detect_button             # and jump to detect_button

change_display:
    lw s5, DELAY_VAL
    beq s10, zero, display_f0

display_f1:             # Display when flag is 1
    sw s6, (s1)         # Write to LED (result of AND)
    sw s8, (s4)         # Write to 7 segment (result of ADD)
    and s10, s10, zero  # Reset flag
    j detect_button      

display_f0:             # Display when flag is 0
    sw s7, (s1)         # write to LED (result of OR)
    sw s9, (s4)         # write to 7 segment (result of SUB)
    li, s10, 0x1        # Set flag
    j detect_button

shift_mode:
    beq a6, s9, shift_display   # check if previous sub value == current sub value
    add a6, zero, s9            # Store sub to a6 (previous sub value)
    add a7, zero, s9            # Store sub to a7 (changed shifted value)

shift_display:
    sw zero, (s1)               # Clear LEDs
    sw a7, (s4)                 # Show shifted sub on 7-Seg
    bne a2, zero, left_shift    # Left button pressed
    bne a4, zero, right_shift   # Right button pressed
    j detect_button

right_shift:
    sra a7, a7, t6
    j detect_button

left_shift:
    sll a7, a7, t6
    j detect_button
    
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
