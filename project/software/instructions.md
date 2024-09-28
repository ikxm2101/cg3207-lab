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
- Check if btnC is pressed
- If btnC is not pressed:
   - Displays result of "AND" on LED and display result of "ADD" on 7 seg
   - Delay
   - Displays result of "OR" on LED and display result of "SUB" on 7 seg
   - essentially alternating between 2 displays until center button is pressed
- If btnC is pressed:
  - Display result of "SUB" on 7 segment (allows for demo of SRA)
  - If btnL is pressed then SLL, if btnR is pressed then SRA
  - If btnC is pressed it goes to start of loop