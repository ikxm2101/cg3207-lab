CG3207 Lab 03 Group 20
Members
- Irwin Kong Xunmeng A0246049B
- Marvin Pranajaya A0239085X
- Teoh Xu En A0239559L

Hardware Sources Changed
- MCycle.v -> implemented Booth's algorithm for signed multiplication. implemented division
- RV.v -> added datapaths for multi-cycle instructions
- Decoder.sv -> implemented decoding M instruction extension

Testbench Sources Changed
- test_Wrapper.sv -> testbench for Wrapper.v (simulate asm implementation)
- test_MCycle.sv -> testbench for MCycle.v (simulate mul, divu instructions)

ASM code is 'lab3.asm' with its flow described in 'lab3flow.md'