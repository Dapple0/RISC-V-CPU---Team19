# Module interfaces

## data_mem (rtl/data_mem.sv), owner: Josh

128 KB data memory (addresses 0x00000-0x1FFFF). Used by loads (lb, lh, lw, lbu, lhu) and stores (sb, sh, sw).

### How it connects

```
                  instr[14:12] ─────────────────────► funct3
 Control unit ─── MemWrite ─────────────────────────► WE
 Register file ── RD1 (rs1) ──► ALU (rs1 + imm) ────► A         ┌──────────┐
 Register file ── RD2 (rs2) ────────────────────────► WD        │ data_mem │ RD ──► result mux ──► register file (rd)
 clock ─────────────────────────────────────────────► clk       └──────────┘
```

### Inputs (what other modules must send to data_mem)

| Port | Bits | Comes from | Why |
| `A` | 32 | ALU result | the address: base register + offset, e.g. `8(x6)` gives x6 + 8 |
| `WD` | 32 | register file `RD2` (rs2) | the value a store writes, e.g. x7 in `sw x7, 4(x6)` |
| `WE` | 1 | control unit `MemWrite` | 1 for stores only, 0 for everything else |
| `funct3` | 3 | instruction bits [14:12] | says the size: byte, half-word or word |
| `clk` | 1 | the clock | stores happen on the rising edge |

### Output (what data_mem sends back)

| Port | Bits | Goes to | Why |
| `RD` | 32 | result mux | the loaded value, already sign/zero-extended. Control must set `ResultSrc` to pick it for loads |

### Example: what the ports see

| Instruction | `A` | `WD` | `WE` | `funct3` | `RD` |
| `lw x5, 8(x6)` | x6 + 8 | (unused) | 0 | 010 | word at A, goes to x5 |
| `lbu x5, 0(x6)` | x6 | (unused) | 0 | 100 | byte at A, zero-extended |
| `sw x7, 4(x6)` | x6 + 4 | x7 | 1 | 010 | (unused) |
| `sb x7, 0(x6)` | x6 | x7 (low byte stored) | 1 | 000 | (unused) |
| `add x1, x2, x3` | (anything) | (anything) | 0 | (anything) | (ignored by result mux) |

### funct3 codes

| funct3 | Load | Store |
| 000 | `lb` (sign-extend byte) | `sb` |
| 001 | `lh` (sign-extend half) | `sh` |
| 010 | `lw` | `sw` |
| 100 | `lbu` (zero-extend byte) | - |
| 101 | `lhu` (zero-extend half) | - |

### What the control unit (Alistair) needs to provide

1. `MemWrite = 1` for sb/sh/sw, 0 otherwise.
2. A `ResultSrc` value that selects `RD` for loads.

### Timing

- Reads are combinational: `RD` changes as soon as `A` or `funct3` changes.
- Writes happen on the rising clock edge, only when `WE = 1`.
- `data.hex` is loaded into memory at address 0x10000 at startup.
