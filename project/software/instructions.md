## RISC-V Instructions to be Implemented

### Essential Instructions

| Instructions | Description                    | Implemented |
| ------------ | ------------------------------ | ----------- |
| `add`        | `rd = rs1 + rs2`               | &#9745;     |
| `addi`       | `rd = rs1 + imm`               | &#9745;     |
| `sub`        | `rd = rs1 + rs2`               | &#9745;     |
| `and`        | `rd = rs1 & rs2`               | &#9745;     |
| `andi`       | `rd = rs1 & imm`               | &#9745;     |
| `or`         | `rd = rs1 \| rs2`              | &#9745;     |
| `ori`        | `rd = rs1 \| imm`              | &#9745;     |
| `lw`         | `rd = M[rs1+imm][0:31]`        | &#9745;     |
| `sw`         | `M[rs1+imm][0:31] = rs2[0:31]` | &#9745;     |
| `beq`        | `if(rs1 == rs2) PC += imm`     | &#9745;     |
| `bne`        | `if(rs1 != rs2) PC += imm`     | &#9745;     |
| `jal`        | `rd = PC+4; PC += imm`         | &#9745;     |

### Additional Instructions
| Instructions | Description             | Implemented |
| ------------ | ----------------------- | ----------- |
| `lui`        | `rd = imm << 12`        | &#9745;     |
| `auipc`      | `rd = PC + (imm << 12)` | &#9745;     |
| `sll`        | `rd = rs1 << rs2`       | &#9745;     |
| `srl`        | `rd = rs1 >> rs2`       | &#9745;     |
| `sra`        | `rd = rs1 >> rs2`       | &#9745;     |

### Programme Flow
- Reads the value of DIPS switches
- Calculate what would be the result of the first 8 bit of DIPS "AND" last 8 bit of DIPS
- Calculate what would be the result of the first 8 bit of DIPS "OR" last 8 bit of DIPS
- Calculate what would be the result of the first 8 bit of DIPS "SUB" last 8 bit of DIPS
- Calculate what would be the result of the first 8 bit of DIPS "ADD" last 8 bit of DIPS
- LOOP: 
  - Check if btnC is pressed
  - If btnC is not pressed:
    - Displays result of "AND" on LED and display result of "ADD" on 7 seg
    - Delay
    - Displays result of "OR" on LED and display result of "SUB" on 7 seg
    - essentially alternating between 2 displays until center button is pressed
  - If btnC is pressed, it goes to SHIFT_LOOP
- SHIFT_LOOP:
  - Display result of "SUB" on 7 segment (allows for demo of SRA)
  - If btnL is pressed then SLL, if btnR is pressed then SRA. Both 1 shift.
  - If btnC is pressed it goes back to LOOP

### Variables
| Name  | Description                |
| ----- | -------------------------- |
| `s1`  | LEDs Address               |
| `s2`  | DIPs Address               |
| `s3`  | PBS Address                |
| `s4`  | Seven Segement Address     |
| `s5`  | Delay Value for Display    |
| `t0`  | Value of DIPs              |
| `t1`  | DIPS [7:0]                 |
| `t3`  | DIPS [15:8]                |
| `s6`  | DIPS [15:8] and DIPS [7:0] |
| `s7`  | DIPS [15:8] or DIPS [7:0]  |
| `s8`  | DIPS [15:8] + DIPS [7:0]   |
| `s9`  | DIPS [15:8] - DIPS [7:0]   |
| `s10` | Flag for Display           |
| `s11` | Debounce Delay Amount      |