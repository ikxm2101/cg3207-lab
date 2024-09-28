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