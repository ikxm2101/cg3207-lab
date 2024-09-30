CG3207 Lab 02 Group 20
Members
- Irwin Kong Xunmeng A024049B
- Marvin Pranajaya A0239085X
- Teoh Xu En A0239559L

Hardware Sources Changed
- RV -> Data path and module instantiations.
- PC_Logic -> Program counter logic, takes in signal from Decoder and ALUFlags to determine next PC increment.
- Decoder -> Takes instruction and decodes then into flags for muxes
- Wrapper -> Populated instruction and memory data
- ALU -> Integrated shift module

Testbench Sources Changed
- tb_Wrapper -> testbench to verify hardware logic

ASM code is located in `asm programs/lab2.asm` and for its program flow refer to `instructions.md`
