//TO-DO: Not tested if program works yet
.text
.globl main
main:
    li t1, 164

lights:
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
    

    srli t2, t1, 7     //Start of Lfsr logic
    andi t2, t2, 1
    srli t3, t1, 5
    andi t3, t3, 1
    srli t4, t1, 4
    andi t4, t4, 1
    srli t5, t1, 3
    andi t5, t5, 1

    xor t2, t2, t3
    xor t2, t2, t4
    xor t2, t2, t5

    slli t1, t1, 1
    andi t1, t1 , 255
    add t1,t1, t2

    jal ra, lfsrdelay

    j  finish

delay:
    li t0,1000
    looped: 
        addi t0, t0, -1
        bne t0, zero, looped 
    ret

lfsrdelay:
    mv t6, t1
    slli t6, t6, 6
    randomloop: 
        addi t6, t6, -1
        bne t6, zero, randomloop 
    ret

finish: 
    addi a0, a0, -31
    jal ra, delay
    j lights

