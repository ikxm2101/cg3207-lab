main:
        li      sp, 9
        slli    sp, sp, 10
        addi    sp, sp, -160
        addi    a0, sp, 8
        call    init_particles
        li      s0, 0
        lui     s1, 2
        lui     a0, 244
        addi    s2, a0, 576
.LBB0_1:
        lw      s3, 1052(s1)
        addi    a0, sp, 8
        call    update_particles
        lw      s4, 1052(s1)
        addi    a0, sp, 8
        call    draw_particles
        addi    s0, s0, 1
        andi    a0, s0, 15
        sw      s0, 1048(s1)
        bnez    a0, .LBB0_3
        sub     a0, s4, s3
        call    output_performance
.LBB0_3:
        lw      a0, 1052(s1)
        add     a0, a0, s2
.LBB0_4:
        lw      a1, 1052(s1)
        bltu    a1, a0, .LBB0_4
        j       .LBB0_1

init_particles:
        li      a1, 0
        li      a2, 0
        addi    a0, a0, 8
        li      a3, 32
        li      a4, 8
.LBB1_1:
        sw      a1, -8(a0)
        sw      a3, -4(a0)
        andi    a5, a2, 1
        addi    a5, a5, -1
        ori     a5, a5, 1
        sw      a5, 0(a0)
        slli    a5, a2, 30
        srli    a5, a5, 31
        addi    a5, a5, -1
        ori     a5, a5, 1
        sw      a5, 4(a0)
        addi    a2, a2, 1
        addi    a0, a0, 16
        addi    a1, a1, 12
        bne     a2, a4, .LBB1_1
        ret

update_particles:
        addi    sp, sp, -16
        sw      s0, 12(sp)
        sw      s1, 8(sp)
        sw      s2, 4(sp)
        sw      s3, 0(sp)
        li      t4, 0
        addi    t1, a0, 28
        addi    s2, a0, 140
        li      a6, 6
        li      t3, 2
        li      t2, 1
        li      a7, -1
        li      t0, 8
.LBB2_1:
        slli    a1, t4, 4
        add     a1, a1, a0
        lw      a5, 8(a1)
        lw      t6, 0(a1)
        lw      t5, 12(a1)
        lw      a4, 4(a1)
        addi    s3, a1, 8
        add     t6, t6, a5
        sw      t6, 0(a1)
        add     a4, a4, t5
        li      s0, 95
        sw      a4, 4(a1)
        blt     s0, t6, .LBB2_4
        bgez    t6, .LBB2_5
        li      s0, 0
.LBB2_4:
        sw      s0, 0(a1)
        neg     a5, a5
        sw      a5, 0(s3)
        mv      t6, s0
.LBB2_5:
        li      s0, 63
        addi    a5, a1, 12
        blt     s0, a4, .LBB2_8
        bgez    a4, .LBB2_9
        li      s0, 0
.LBB2_8:
        addi    a1, a1, 4
        sw      s0, 0(a1)
        neg     a1, t5
        sw      a1, 0(a5)
        mv      a4, s0
.LBB2_9:
        bltu    a6, t4, .LBB2_16
        addi    t6, t6, 1
        mv      a1, t1
.LBB2_11:
        lw      s0, -12(a1)
        sub     s0, t6, s0
        bltu    t3, s0, .LBB2_15
        lw      s0, -8(a1)
        sub     s0, a4, s0
        blt     t2, s0, .LBB2_15
        blt     s0, a7, .LBB2_15
        lw      s0, -4(a1)
        lw      a3, 0(a1)
        lw      s1, 0(s3)
        lw      a2, 0(a5)
        sw      s0, 0(s3)
        sw      a3, 0(a5)
        sw      s1, -4(a1)
        sw      a2, 0(a1)
.LBB2_15:
        addi    a1, a1, 16
        bne     a1, s2, .LBB2_11
.LBB2_16:
        addi    t4, t4, 1
        addi    t1, t1, 16
        bne     t4, t0, .LBB2_1
        lw      s0, 12(sp)
        lw      s1, 8(sp)
        lw      s2, 4(sp)
        lw      s3, 0(sp)
        addi    sp, sp, 16
        ret

draw_particles:
        li      a1, 0
        lui     a2, 2
        li      a3, 2
        sw      a3, 1068(a2)
        sw      zero, 1064(a2)
        li      a3, 64
        li      a4, 96
.LBB3_1:
        li      a5, 0
        sw      a1, 1056(a2)
.LBB3_2:
        sw      a5, 1060(a2)
        addi    a5, a5, 1
        sw      zero, 1064(a2)
        bne     a5, a3, .LBB3_2
        addi    a1, a1, 1
        bne     a1, a4, .LBB3_1
        li      a6, 0
        lui     a2, 2
        sw      zero, 1068(a2)
        li      t3, 255
        sw      t3, 1064(a2)
        li      a4, 95
        li      t5, 63
        li      t0, 2
        li      a7, 8
.LBB3_5:
        slli    a1, a6, 4
        add     a1, a1, a0
        lw      t2, 4(a1)
        lw      t1, 0(a1)
        addi    t2, t2, -1
        li      t4, -1
.LBB3_6:
        add     a1, t4, t1
        li      a3, 3
        mv      a5, t2
.LBB3_7:
        bltu    a4, a1, .LBB3_11
        bltz    a5, .LBB3_11
        blt     t5, a5, .LBB3_11
        sw      a5, 1060(a2)
        sw      a1, 1056(a2)
        sw      t3, 1064(a2)
.LBB3_11:
        addi    a3, a3, -1
        addi    a5, a5, 1
        bnez    a3, .LBB3_7
        addi    t4, t4, 1
        bne     t4, t0, .LBB3_6
        addi    a6, a6, 1
        bne     a6, a7, .LBB3_5
        ret

output_performance:
        addi    sp, sp, -16
        li      a5, 0
        beqz    a0, .LBB4_4
        lui     a1, 838861
        addi    a1, a1, -819
        li      a6, 10
        addi    a7, sp, 4
        li      t0, 9
.LBB4_2:
        mv      a2, a0
        mulhu   a0, a0, a1
        srli    a0, a0, 3
        mul     a3, a0, a6
        sub     a3, a2, a3
        ori     a3, a3, 48
        add     a4, a7, a5
        addi    a5, a5, 1
        sb      a3, 0(a4)
        bltu    t0, a2, .LBB4_2
        addi    a5, a5, -1
        j       .LBB4_5
.LBB4_4:
        li      a0, 48
        sb      a0, 4(sp)
.LBB4_5:
        lui     a0, 2
        addi    a1, sp, 4
.LBB4_6:
        mv      a2, a5
.LBB4_7:
        lw      a3, 1044(a0)
        beqz    a3, .LBB4_7
        add     a3, a1, a2
        lbu     a3, 0(a3)
        sw      a3, 1036(a0)
        addi    a5, a2, -1
        bgtz    a2, .LBB4_6
        lui     a0, 2
.LBB4_10:
        lw      a1, 1044(a0)
        beqz    a1, .LBB4_10
        lui     a0, 2
        li      a1, 13
        sw      a1, 1036(a0)
.LBB4_12:
        lw      a1, 1044(a0)
        beqz    a1, .LBB4_12
        lui     a0, 2
        li      a1, 10
        sw      a1, 1036(a0)
        addi    sp, sp, 16
        ret

delay:
        lui     a1, 2
        lw      a2, 1052(a1)
        add     a0, a0, a2
.LBB5_1:
        lw      a2, 1052(a1)
        bltu    a2, a0, .LBB5_1
        ret

.data 
CYCLECOUNT_ADDR:
        .word   9244