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


# ------- <code memory (ROM mapped to Instruction Memory) begins>
.text	## IROM segment 0x00000000-0x000001FC
# Total number of instructions should not exceed 128 (127 excluding the last line 'halt B halt').

    la s1, SEVENSEG
init:
    sw zero, (s1)   # 0
    li s3, 10
    li s4, 23
    li s5, 34
    la t1, VALUE_DUMMY

test_hazard_data_forward:
    add s8, s4, s5  # 57
    sub s2, s8, s3  # 47
    or s9, s4, s8   # 63
    and s7, s8, s3  # 8

display_a:
    sw s8, (s1)
    sw s2, (s1)
    sw s9, (s1)
    sw s7, (s1)

test_hazard_m2m:
    lw s3, (t1)     # 69
    sw s3, (s1)

test_hazard_lw:
    lw s7, (t1)     # 69
    and s8, s7, s4  # 5
    or t2, s5, s7   # 103
    sub s3, s7, s2  # 22

display_b:
    sw s8, (s1)     
    sw t2, (s1)
    sw s3, (s1)

test_hazard_control:
    bne s3, s8, control_ok
    sub s8, t2, s3  # 81
    sw s8, (s1)     
    or s9, t2, s3

control_ok:
    addi s8, s8, 10 # 15
    sw s8, (s1) 


final:
    jal init





# ------- <code memory (ROM mapped to Instruction Memory) ends>			
				
								
#------- <constant memory (ROM mapped to Data Memory) begins>									
.data	## DROM segment 0x00002000-0x000021FC
# All constants should be declared in this section. This section is read only (Only lw, no sw).
# Total number of constants should not exceed 128
# If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.
DROM:
VALUE_DUMMY: .word 0x0045
string1:
.asciz "\r\nWelcome to CG3207..\r\n"

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
