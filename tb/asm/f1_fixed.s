.text
.globl main
main:
    li a0, 0           // register that contains the state of the lightbulbs
    addi a0, a0, 1
    jal ra, delay
    addi a0, a0, 2
    jal ra, delay
    addi a0, a0, 4
    jal ra, delay
    addi a0, a0, 8
    jal ra, delay
    addi a0, a0, 16
    jal ra, delay
    j  finish

delay:
    li t0,1000
    looped: 
        addi t0, t0, -1
        bne t0, zero, looped 
    ret

finish: 
    addi a0, a0, -31
_wait:
    j _wait
