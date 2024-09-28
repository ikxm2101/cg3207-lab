## RISC-V Instructions to be Implemented

### Essential Instructions

| Instructions | Description                    | Implemented |
| ------------ | ------------------------------ | ----------- |
| `add`        | `rd = rs1 + rs2`               | &#9744;     |
| `addi`       | `rd = rs1 + imm`               | &#9744;     |
| `sub`        | `rd = rs1 + rs2`               | &#9744;     |
| `and`        | `rd = rs1 & rs2`               | &#9744;     |
| `andi`       | `rd = rs1 & imm`               | &#9744;     |
| `or`         | `rd = rs1 \| rs2`              | &#9744;     |
| `ori`        | `rd = rs1 \| imm`              | &#9744;     |
| `lw`         | `rd = M[rs1+imm][0:31]`        | &#9744;     |
| `sw`         | `M[rs1+imm][0:31] = rs2[0:31]` | &#9744;     |
| `beq`        | `if(rs1 == rs2) PC += imm`     | &#9744;     |
| `bne`        | `if(rs1 != rs2) PC += imm`     | &#9744;     |
| `jal`        | `rd = PC+4; PC += imm`         | &#9744;     |

### Additional Instructions
| Instructions | Description             | Implemented |
| ------------ | ----------------------- | ----------- |
| `lui`        | `rd = imm << 12`        | &#9744;     |
| `auipc`      | `rd = PC + (imm << 12)` | &#9744;     |
| `sll`        | `rd = rs1 << rs2`       | &#9744;     |
| `srl`        | `rd = rs1 >> rs2`       | &#9744;     |
| `sra`        | `rd = rs1 >> rs2`       | &#9744;     |

### Programme Flow
- Reads the Value of the DIPS Switches
- If none of the DIPS are activated, all LEDS will blink on and off
- Alternate Between showing the AND and OR value of the First and Last 8 Bits of the DIPS switches on the LEDs
