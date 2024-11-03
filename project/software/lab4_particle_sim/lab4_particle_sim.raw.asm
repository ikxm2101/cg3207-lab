main:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        sw      s1, 20(sp)
        sw      s2, 16(sp)
        sw      s3, 12(sp)
        li      sp, 9
        slli    sp, sp, 10
        call    init_particles
        li      s0, 0
        lui     s1, 2
.LBB0_1:
        lw      s2, 1052(s1)
        call    update_particles
        lw      s3, 1052(s1)
        call    draw_particles
        addi    s0, s0, 1
        andi    a0, s0, 15
        bnez    a0, .LBB0_1
        sub     a0, s3, s2
        li      a2, 24
.LBB0_3:
        mv      a1, a2
.LBB0_4:
        lw      a2, 1044(s1)
        beqz    a2, .LBB0_4
        srl     a2, a0, a1
        andi    a2, a2, 255
        sw      a2, 1036(s1)
        addi    a2, a1, -8
        bnez    a1, .LBB0_3
        j       .LBB0_1

output_performance:
        li      a3, 24
        lui     a1, 2
.LBB1_1:
        mv      a2, a3
.LBB1_2:
        lw      a3, 1044(a1)
        beqz    a3, .LBB1_2
        srl     a3, a0, a2
        andi    a3, a3, 255
        sw      a3, 1036(a1)
        addi    a3, a2, -8
        bnez    a2, .LBB1_1
        ret

init_particles:
        li      a0, 0
        li      a1, 0
        lui     a2, %hi(particles+8)
        addi    a2, a2, %lo(particles+8)
        li      a6, 512
        li      a7, 16
.LBB2_1:
        sw      a0, -8(a2)
        sw      a6, -4(a2)
        andi    a4, a1, 1
        li      a5, -4
        li      a3, -4
        beqz    a4, .LBB2_3
        li      a3, 4
.LBB2_3:
        andi    a4, a1, 2
        sw      a3, 0(a2)
        beqz    a4, .LBB2_5
        li      a5, 4
.LBB2_5:
        sw      a5, 4(a2)
        addi    a1, a1, 1
        addi    a2, a2, 16
        addi    a0, a0, 96
        bne     a1, a7, .LBB2_1
        ret

update_particles:
        addi    sp, sp, -32
        sw      s0, 28(sp)
        sw      s1, 24(sp)
        sw      s2, 20(sp)
        sw      s3, 16(sp)
        sw      s4, 12(sp)
        sw      s5, 8(sp)
        li      s3, 0
        lui     a1, %hi(particles)
        addi    t1, a1, %lo(particles)
        addi    t4, t1, 28
        li      a6, 1535
        li      a7, 1023
        li      t0, 14
        li      t6, 62
        li      t5, 31
        li      t3, -31
        addi    s4, t1, 268
        li      t2, 16
.LBB3_1:
        slli    a3, s3, 4
        add     a3, a3, t1
        lw      a4, 8(a3)
        lw      s1, 0(a3)
        lw      s2, 12(a3)
        lw      a2, 4(a3)
        addi    s5, a3, 8
        add     s1, s1, a4
        sw      s1, 0(a3)
        add     a2, a2, s2
        sw      a2, 4(a3)
        li      s0, 1520
        blt     a6, s1, .LBB3_4
        bgez    s1, .LBB3_5
        li      s0, 0
.LBB3_4:
        sw      s0, 0(a3)
        neg     a4, a4
        sw      a4, 0(s5)
        mv      s1, s0
.LBB3_5:
        addi    a4, a3, 12
        li      s0, 1008
        blt     a7, a2, .LBB3_8
        bgez    a2, .LBB3_9
        li      s0, 0
.LBB3_8:
        addi    a3, a3, 4
        sw      s0, 0(a3)
        neg     a2, s2
        sw      a2, 0(a4)
        mv      a2, s0
.LBB3_9:
        bltu    t0, s3, .LBB3_16
        addi    s1, s1, 31
        mv      a3, t4
.LBB3_11:
        lw      s0, -12(a3)
        sub     s0, s1, s0
        bltu    t6, s0, .LBB3_15
        lw      s0, -8(a3)
        sub     s0, a2, s0
        blt     t5, s0, .LBB3_15
        blt     s0, t3, .LBB3_15
        lw      s0, -4(a3)
        lw      a0, 0(a3)
        lw      a1, 0(s5)
        lw      a5, 0(a4)
        sw      s0, 0(s5)
        sw      a0, 0(a4)
        sw      a1, -4(a3)
        sw      a5, 0(a3)
.LBB3_15:
        addi    a3, a3, 16
        bne     a3, s4, .LBB3_11
.LBB3_16:
        addi    s3, s3, 1
        addi    t4, t4, 16
        bne     s3, t2, .LBB3_1
        lw      s0, 28(sp)
        lw      s1, 24(sp)
        lw      s2, 20(sp)
        lw      s3, 16(sp)
        lw      s4, 12(sp)
        lw      s5, 8(sp)
        addi    sp, sp, 32
        ret

draw_particles:
        li      a0, 0
        lui     a1, 2
        li      a2, 2
        sw      a2, 1068(a1)
        sw      zero, 1064(a1)
        li      a2, 64
.LBB4_1:
        sw      a0, 1060(a1)
        addi    a0, a0, 1
        bne     a0, a2, .LBB4_1
        lui     a0, 2
        sw      zero, 1068(a0)
        li      a1, 255
        sw      a1, 1064(a0)
        lui     a1, %hi(particles)
        addi    a3, a1, %lo(particles)
        addi    a1, a3, 4
        li      a2, 95
        li      a6, 63
        addi    a4, a3, 260
.LBB4_3:
        lw      a5, -4(a1)
        srai    a5, a5, 4
        bltu    a2, a5, .LBB4_7
        lw      a3, 0(a1)
        srai    a3, a3, 4
        bltz    a3, .LBB4_7
        blt     a6, a3, .LBB4_7
        sw      a3, 1060(a0)
        sw      a5, 1056(a0)
.LBB4_7:
        addi    a1, a1, 16
        bne     a1, a4, .LBB4_3
        ret

CYCLECOUNT_ADDR:
        .word   9244

particles:
        .zero   256