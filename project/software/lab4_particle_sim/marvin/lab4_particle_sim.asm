main:
        li      sp, 9
        slli    sp, sp, 10
        addi    sp, sp, -96
        addi    a0, sp, 12
        call    init_particles
        li      s0, 0
        lui     s1, 2
.LBB0_1:
        lw      s2, 1052(s1)
        addi    a0, sp, 12
        call    update_particles
        lw      s3, 1052(s1)
        addi    a0, sp, 12
        call    draw_particles
        addi    s0, s0, 1
        andi    a0, s0, 15
        sw      s0, 1048(s1)
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

init_particles:
        li      a1, 0
        li      a2, 0
        addi    a0, a0, 8
        li      a6, 512
        li      a7, 1
        li      a5, 4
.LBB1_1:
        sw      a1, -8(a0)
        sw      a6, -4(a0)
        andi    a4, a2, 1
        li      a3, -4
        beqz    a4, .LBB1_3
        li      a3, 4
.LBB1_3:
        sw      a3, 0(a0)
        li      a3, 4
        bltu    a7, a2, .LBB1_5
        li      a3, -4
.LBB1_5:
        sw      a3, 4(a0)
        addi    a2, a2, 1
        addi    a0, a0, 16
        addi    a1, a1, 384
        bne     a2, a5, .LBB1_1
        ret

update_particles:
        addi    sp, sp, -32
        sw      s0, 28(sp)
        sw      s1, 24(sp)
        sw      s2, 20(sp)
        sw      s3, 16(sp)
        sw      s4, 12(sp)
        sw      s5, 8(sp)
        li      t6, 0
        addi    t3, a0, 28
        addi    s3, a0, 76
        li      a6, 1535
        li      a7, 1023
        li      t0, 2
        li      t5, 62
        li      t4, 31
        li      t1, -31
        li      t2, 4
.LBB2_1:
        slli    a1, t6, 4
        add     a1, a1, a0
        lw      a5, 8(a1)
        lw      s1, 0(a1)
        lw      s2, 12(a1)
        lw      a4, 4(a1)
        addi    s4, a1, 8
        add     s1, s1, a5
        sw      s1, 0(a1)
        add     s5, a4, s2
        sw      s5, 4(a1)
        li      s0, 1520
        blt     a6, s1, .LBB2_4
        bgez    s1, .LBB2_5
        li      s0, 0
.LBB2_4:
        sw      s0, 0(a1)
        neg     a5, a5
        sw      a5, 0(s4)
        mv      s1, s0
.LBB2_5:
        addi    a5, a1, 12
        li      s0, 1008
        blt     a7, s5, .LBB2_8
        bgez    s5, .LBB2_9
        li      s0, 0
.LBB2_8:
        addi    a1, a1, 4
        sw      s0, 0(a1)
        neg     a1, s2
        sw      a1, 0(a5)
        mv      s5, s0
.LBB2_9:
        bltu    t0, t6, .LBB2_16
        addi    s1, s1, 31
        mv      a1, t3
.LBB2_11:
        lw      s0, -12(a1)
        sub     s0, s1, s0
        bltu    t5, s0, .LBB2_15
        lw      s0, -8(a1)
        sub     s0, s5, s0
        blt     t4, s0, .LBB2_15
        blt     s0, t1, .LBB2_15
        lw      s0, -4(a1)
        lw      a3, 0(a1)
        lw      a2, 0(s4)
        lw      a4, 0(a5)
        sw      s0, 0(s4)
        sw      a3, 0(a5)
        sw      a2, -4(a1)
        sw      a4, 0(a1)
.LBB2_15:
        addi    a1, a1, 16
        bne     a1, s3, .LBB2_11
.LBB2_16:
        addi    t6, t6, 1
        addi    t3, t3, 16
        bne     t6, t2, .LBB2_1
        lw      s0, 28(sp)
        lw      s1, 24(sp)
        lw      s2, 20(sp)
        lw      s3, 16(sp)
        lw      s4, 12(sp)
        lw      s5, 8(sp)
        addi    sp, sp, 32
        ret

draw_particles:
        li      a1, 0
        lui     a2, 2
        li      a3, 2
        sw      a3, 1068(a2)
        sw      zero, 1064(a2)
        li      a3, 64
.LBB3_1:
        sw      a1, 1060(a2)
        addi    a1, a1, 1
        bne     a1, a3, .LBB3_1
        lui     a1, 2
        sw      zero, 1068(a1)
        li      a2, 255
        sw      a2, 1064(a1)
        addi    a2, a0, 4
        addi    a0, a0, 68
        li      a3, 95
        li      a6, 63
.LBB3_3:
        lw      a5, -4(a2)
        srai    a5, a5, 4
        bltu    a3, a5, .LBB3_7
        lw      a4, 0(a2)
        srai    a4, a4, 4
        bltz    a4, .LBB3_7
        blt     a6, a4, .LBB3_7
        sw      a4, 1060(a1)
        sw      a5, 1056(a1)
.LBB3_7:
        addi    a2, a2, 16
        bne     a2, a0, .LBB3_3
        ret

output_performance:
        li      a3, 24
        lui     a1, 2
.LBB4_1:
        mv      a2, a3
.LBB4_2:
        lw      a3, 1044(a1)
        beqz    a3, .LBB4_2
        srl     a3, a0, a2
        andi    a3, a3, 255
        sw      a3, 1036(a1)
        addi    a3, a2, -8
        bnez    a2, .LBB4_1
        ret
        
.data
CYCLECOUNT_ADDR:
        .word   9244
