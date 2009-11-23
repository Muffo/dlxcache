/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2007 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

/* This file is designed for use with ISim build 0x381ddd3f */

#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/Filippo/XilinxProject/DLXSourceCodeVHDL/DLX 11.1 Rewrite/DLXPipe/Decode_Stage.vhd";
extern char *IEEE_P_3620187407;
extern char *WORK_P_2409548093;

int ieee_p_3620187407_sub_514432868_3620187407(char *, char *, char *);
unsigned char ieee_std_logic_unsigned_equal_stdv_stdv(char *, char *, char *, char *, char *);


static void work_a_2842394180_3507449687_p_0(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    char *t4;
    char *t5;
    unsigned char t6;
    unsigned char t7;
    unsigned char t8;
    char *t9;
    char *t10;
    char *t11;
    int t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;

LAB0:    t1 = (t0 + 2908U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(55, ng0);

LAB6:    t2 = (t0 + 3824);
    *((int *)t2) = 1;
    *((char **)t1) = &&LAB7;

LAB1:    return;
LAB4:    t9 = (t0 + 3824);
    *((int *)t9) = 0;
    xsi_set_current_line(58, ng0);
    t2 = (t0 + 1144U);
    t4 = *((char **)t2);
    t2 = (t0 + 3908);
    t5 = (t2 + 32U);
    t9 = *((char **)t5);
    t10 = (t9 + 40U);
    t11 = *((char **)t10);
    memcpy(t11, t4, 30U);
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(59, ng0);
    t2 = (t0 + 1328U);
    t4 = *((char **)t2);
    t2 = (t0 + 3944);
    t5 = (t2 + 32U);
    t9 = *((char **)t5);
    t10 = (t9 + 40U);
    t11 = *((char **)t10);
    memcpy(t11, t4, 32U);
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(62, ng0);
    t2 = (t0 + 1052U);
    t4 = *((char **)t2);
    t3 = *((unsigned char *)t4);
    t6 = (t3 == (unsigned char)2);
    if (t6 != 0)
        goto LAB11;

LAB13:    xsi_set_current_line(69, ng0);
    t2 = (t0 + 868U);
    t4 = *((char **)t2);
    t2 = (t0 + 960U);
    t5 = *((char **)t2);
    t2 = (t0 + 8064U);
    t12 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t5, t2);
    t17 = (t12 - 0);
    t18 = (t17 * 1);
    t19 = (32U * t18);
    t20 = (0U + t19);
    t9 = (t0 + 4016);
    t10 = (t9 + 32U);
    t11 = *((char **)t10);
    t13 = (t11 + 40U);
    t14 = *((char **)t13);
    memcpy(t14, t4, 32U);
    xsi_driver_first_trans_delta(t9, t20, 32U, 0LL);

LAB12:    goto LAB2;

LAB5:    t4 = (t0 + 592U);
    t5 = *((char **)t4);
    t6 = *((unsigned char *)t5);
    t7 = (t6 == (unsigned char)3);
    if (t7 == 1)
        goto LAB8;

LAB9:    t3 = (unsigned char)0;

LAB10:    if (t3 == 1)
        goto LAB4;
    else
        goto LAB6;

LAB7:    goto LAB5;

LAB8:    t4 = (t0 + 568U);
    t8 = xsi_signal_has_event(t4);
    t3 = t8;
    goto LAB10;

LAB11:    xsi_set_current_line(63, ng0);
    t2 = (t0 + 960U);
    t5 = *((char **)t2);
    t2 = (t0 + 8064U);
    t12 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t5, t2);
    t7 = (t12 == 0);
    if (t7 != 0)
        goto LAB14;

LAB16:    xsi_set_current_line(66, ng0);
    t2 = (t0 + 868U);
    t4 = *((char **)t2);
    t2 = (t0 + 960U);
    t5 = *((char **)t2);
    t2 = (t0 + 8064U);
    t12 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t5, t2);
    t17 = (t12 - 0);
    t18 = (t17 * 1);
    t19 = (32U * t18);
    t20 = (0U + t19);
    t9 = (t0 + 3980);
    t10 = (t9 + 32U);
    t11 = *((char **)t10);
    t13 = (t11 + 40U);
    t14 = *((char **)t13);
    memcpy(t14, t4, 32U);
    xsi_driver_first_trans_delta(t9, t20, 32U, 0LL);

LAB15:    goto LAB12;

LAB14:    xsi_set_current_line(64, ng0);
    t9 = xsi_get_transient_memory(32U);
    memset(t9, 0, 32U);
    t10 = t9;
    memset(t10, (unsigned char)2, 32U);
    t11 = (t0 + 3980);
    t13 = (t11 + 32U);
    t14 = *((char **)t13);
    t15 = (t14 + 40U);
    t16 = *((char **)t15);
    memcpy(t16, t9, 32U);
    xsi_driver_first_trans_delta(t11, 0U, 32U, 0LL);
    goto LAB15;

}

static void work_a_2842394180_3507449687_p_1(char *t0)
{
    unsigned char t1;
    char *t2;
    char *t3;
    unsigned char t4;
    unsigned char t5;
    char *t6;
    unsigned char t7;
    unsigned char t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    char *t17;
    char *t18;
    char *t19;
    int t20;
    int t21;
    int t22;
    int t23;
    int t24;
    int t25;
    int t26;
    int t27;
    char *t28;
    int t29;
    char *t30;
    int t31;
    char *t32;
    int t33;
    char *t34;
    int t35;
    char *t36;
    int t37;
    char *t38;
    int t39;
    char *t40;
    int t41;
    char *t42;
    int t43;
    char *t44;
    int t45;
    char *t46;
    int t47;
    char *t48;
    int t49;
    char *t50;
    int t51;
    char *t52;
    int t53;
    char *t54;
    int t55;
    char *t56;
    char *t57;
    char *t58;
    char *t59;
    char *t60;

LAB0:    xsi_set_current_line(78, ng0);
    t2 = (t0 + 684U);
    t3 = *((char **)t2);
    t4 = *((unsigned char *)t3);
    t5 = (t4 == (unsigned char)3);
    if (t5 == 1)
        goto LAB5;

LAB6:    t2 = (t0 + 776U);
    t6 = *((char **)t2);
    t7 = *((unsigned char *)t6);
    t8 = (t7 == (unsigned char)3);
    t1 = t8;

LAB7:    if (t1 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(82, ng0);
    t2 = (t0 + 2248U);
    t3 = *((char **)t2);
    t14 = (31 - 31);
    t15 = (t14 * 1U);
    t16 = (0 + t15);
    t2 = (t3 + t16);
    t6 = (t0 + 8224U);
    t9 = ((WORK_P_2409548093) + 1556U);
    t10 = *((char **)t9);
    t9 = ((WORK_P_2409548093) + 11436U);
    t1 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t6, t10, t9);
    if (t1 != 0)
        goto LAB8;

LAB10:    t2 = (t0 + 2248U);
    t3 = *((char **)t2);
    t14 = (31 - 31);
    t15 = (t14 * 1U);
    t16 = (0 + t15);
    t2 = (t3 + t16);
    t6 = (t0 + 8224U);
    t9 = ((WORK_P_2409548093) + 1624U);
    t10 = *((char **)t9);
    t9 = ((WORK_P_2409548093) + 11452U);
    t1 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t6, t10, t9);
    if (t1 != 0)
        goto LAB11;

LAB12:    xsi_set_current_line(87, ng0);
    t2 = (t0 + 2248U);
    t3 = *((char **)t2);
    t14 = (31 - 31);
    t15 = (t14 * 1U);
    t16 = (0 + t15);
    t2 = (t3 + t16);
    t6 = ((WORK_P_2409548093) + 2508U);
    t9 = *((char **)t6);
    t20 = xsi_mem_cmp(t9, t2, 6U);
    if (t20 == 1)
        goto LAB14;

LAB18:    t6 = ((WORK_P_2409548093) + 2576U);
    t10 = *((char **)t6);
    t21 = xsi_mem_cmp(t10, t2, 6U);
    if (t21 == 1)
        goto LAB14;

LAB19:    t6 = ((WORK_P_2409548093) + 2644U);
    t11 = *((char **)t6);
    t22 = xsi_mem_cmp(t11, t2, 6U);
    if (t22 == 1)
        goto LAB14;

LAB20:    t6 = ((WORK_P_2409548093) + 2712U);
    t12 = *((char **)t6);
    t23 = xsi_mem_cmp(t12, t2, 6U);
    if (t23 == 1)
        goto LAB14;

LAB21:    t6 = ((WORK_P_2409548093) + 2780U);
    t13 = *((char **)t6);
    t24 = xsi_mem_cmp(t13, t2, 6U);
    if (t24 == 1)
        goto LAB14;

LAB22:    t6 = ((WORK_P_2409548093) + 2848U);
    t17 = *((char **)t6);
    t25 = xsi_mem_cmp(t17, t2, 6U);
    if (t25 == 1)
        goto LAB14;

LAB23:    t6 = ((WORK_P_2409548093) + 2916U);
    t18 = *((char **)t6);
    t26 = xsi_mem_cmp(t18, t2, 6U);
    if (t26 == 1)
        goto LAB14;

LAB24:    t6 = ((WORK_P_2409548093) + 2984U);
    t19 = *((char **)t6);
    t27 = xsi_mem_cmp(t19, t2, 6U);
    if (t27 == 1)
        goto LAB14;

LAB25:    t6 = ((WORK_P_2409548093) + 3052U);
    t28 = *((char **)t6);
    t29 = xsi_mem_cmp(t28, t2, 6U);
    if (t29 == 1)
        goto LAB14;

LAB26:    t6 = ((WORK_P_2409548093) + 3120U);
    t30 = *((char **)t6);
    t31 = xsi_mem_cmp(t30, t2, 6U);
    if (t31 == 1)
        goto LAB14;

LAB27:    t6 = ((WORK_P_2409548093) + 3188U);
    t32 = *((char **)t6);
    t33 = xsi_mem_cmp(t32, t2, 6U);
    if (t33 == 1)
        goto LAB14;

LAB28:    t6 = ((WORK_P_2409548093) + 3256U);
    t34 = *((char **)t6);
    t35 = xsi_mem_cmp(t34, t2, 6U);
    if (t35 == 1)
        goto LAB14;

LAB29:    t6 = ((WORK_P_2409548093) + 3324U);
    t36 = *((char **)t6);
    t37 = xsi_mem_cmp(t36, t2, 6U);
    if (t37 == 1)
        goto LAB14;

LAB30:    t6 = ((WORK_P_2409548093) + 3392U);
    t38 = *((char **)t6);
    t39 = xsi_mem_cmp(t38, t2, 6U);
    if (t39 == 1)
        goto LAB14;

LAB31:    t6 = ((WORK_P_2409548093) + 3460U);
    t40 = *((char **)t6);
    t41 = xsi_mem_cmp(t40, t2, 6U);
    if (t41 == 1)
        goto LAB14;

LAB32:    t6 = ((WORK_P_2409548093) + 3528U);
    t42 = *((char **)t6);
    t43 = xsi_mem_cmp(t42, t2, 6U);
    if (t43 == 1)
        goto LAB14;

LAB33:    t6 = ((WORK_P_2409548093) + 3596U);
    t44 = *((char **)t6);
    t45 = xsi_mem_cmp(t44, t2, 6U);
    if (t45 == 1)
        goto LAB14;

LAB34:    t6 = ((WORK_P_2409548093) + 3664U);
    t46 = *((char **)t6);
    t47 = xsi_mem_cmp(t46, t2, 6U);
    if (t47 == 1)
        goto LAB14;

LAB35:    t6 = ((WORK_P_2409548093) + 3732U);
    t48 = *((char **)t6);
    t49 = xsi_mem_cmp(t48, t2, 6U);
    if (t49 == 1)
        goto LAB15;

LAB36:    t6 = ((WORK_P_2409548093) + 3800U);
    t50 = *((char **)t6);
    t51 = xsi_mem_cmp(t50, t2, 6U);
    if (t51 == 1)
        goto LAB15;

LAB37:    t6 = ((WORK_P_2409548093) + 3936U);
    t52 = *((char **)t6);
    t53 = xsi_mem_cmp(t52, t2, 6U);
    if (t53 == 1)
        goto LAB16;

LAB38:    t6 = ((WORK_P_2409548093) + 3868U);
    t54 = *((char **)t6);
    t55 = xsi_mem_cmp(t54, t2, 6U);
    if (t55 == 1)
        goto LAB16;

LAB39:
LAB17:    xsi_set_current_line(97, ng0);
    t2 = ((WORK_P_2409548093) + 1420U);
    t3 = *((char **)t2);
    t2 = (t0 + 4052);
    t6 = (t2 + 32U);
    t9 = *((char **)t6);
    t10 = (t9 + 40U);
    t11 = *((char **)t10);
    memcpy(t11, t3, 3U);
    xsi_driver_first_trans_fast_port(t2);

LAB13:
LAB9:    xsi_set_current_line(100, ng0);
    t2 = (t0 + 2248U);
    t3 = *((char **)t2);
    t2 = (t0 + 4088);
    t6 = (t2 + 32U);
    t9 = *((char **)t6);
    t10 = (t9 + 40U);
    t11 = *((char **)t10);
    memcpy(t11, t3, 32U);
    xsi_driver_first_trans_fast_port(t2);

LAB3:    t2 = (t0 + 3832);
    *((int *)t2) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(79, ng0);
    t2 = ((WORK_P_2409548093) + 1420U);
    t9 = *((char **)t2);
    t2 = (t0 + 4052);
    t10 = (t2 + 32U);
    t11 = *((char **)t10);
    t12 = (t11 + 40U);
    t13 = *((char **)t12);
    memcpy(t13, t9, 3U);
    xsi_driver_first_trans_fast_port(t2);
    xsi_set_current_line(80, ng0);
    t2 = xsi_get_transient_memory(32U);
    memset(t2, 0, 32U);
    t3 = t2;
    memset(t3, (unsigned char)3, 32U);
    t6 = (t0 + 4088);
    t9 = (t6 + 32U);
    t10 = *((char **)t9);
    t11 = (t10 + 40U);
    t12 = *((char **)t11);
    memcpy(t12, t2, 32U);
    xsi_driver_first_trans_fast_port(t6);
    goto LAB3;

LAB5:    t1 = (unsigned char)1;
    goto LAB7;

LAB8:    xsi_set_current_line(83, ng0);
    t11 = ((WORK_P_2409548093) + 1080U);
    t12 = *((char **)t11);
    t11 = (t0 + 4052);
    t13 = (t11 + 32U);
    t17 = *((char **)t13);
    t18 = (t17 + 40U);
    t19 = *((char **)t18);
    memcpy(t19, t12, 3U);
    xsi_driver_first_trans_fast_port(t11);
    goto LAB9;

LAB11:    xsi_set_current_line(85, ng0);
    t11 = ((WORK_P_2409548093) + 1284U);
    t12 = *((char **)t11);
    t11 = (t0 + 4052);
    t13 = (t11 + 32U);
    t17 = *((char **)t13);
    t18 = (t17 + 40U);
    t19 = *((char **)t18);
    memcpy(t19, t12, 3U);
    xsi_driver_first_trans_fast_port(t11);
    goto LAB9;

LAB14:    xsi_set_current_line(91, ng0);
    t6 = ((WORK_P_2409548093) + 1148U);
    t56 = *((char **)t6);
    t6 = (t0 + 4052);
    t57 = (t6 + 32U);
    t58 = *((char **)t57);
    t59 = (t58 + 40U);
    t60 = *((char **)t59);
    memcpy(t60, t56, 3U);
    xsi_driver_first_trans_fast_port(t6);
    goto LAB13;

LAB15:    xsi_set_current_line(93, ng0);
    t2 = ((WORK_P_2409548093) + 1216U);
    t3 = *((char **)t2);
    t2 = (t0 + 4052);
    t6 = (t2 + 32U);
    t9 = *((char **)t6);
    t10 = (t9 + 40U);
    t11 = *((char **)t10);
    memcpy(t11, t3, 3U);
    xsi_driver_first_trans_fast_port(t2);
    goto LAB13;

LAB16:    xsi_set_current_line(95, ng0);
    t2 = ((WORK_P_2409548093) + 1352U);
    t3 = *((char **)t2);
    t2 = (t0 + 4052);
    t6 = (t2 + 32U);
    t9 = *((char **)t6);
    t10 = (t9 + 40U);
    t11 = *((char **)t10);
    memcpy(t11, t3, 3U);
    xsi_driver_first_trans_fast_port(t2);
    goto LAB13;

LAB40:;
}

static void work_a_2842394180_3507449687_p_2(char *t0)
{
    char *t1;
    char *t2;
    unsigned int t3;
    unsigned int t4;
    unsigned int t5;
    char *t6;
    char *t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    char *t18;
    unsigned char t19;
    char *t20;
    char *t21;
    unsigned char t22;
    unsigned char t23;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    int t29;
    int t30;

LAB0:    xsi_set_current_line(112, ng0);
    t1 = (t0 + 2248U);
    t2 = *((char **)t1);
    t3 = (31 - 31);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t2 + t5);
    t6 = (t0 + 8224U);
    t7 = ((WORK_P_2409548093) + 1624U);
    t8 = *((char **)t7);
    t7 = ((WORK_P_2409548093) + 11452U);
    t9 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t1, t6, t8, t7);
    if (t9 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(126, ng0);
    t1 = (t0 + 960U);
    t2 = *((char **)t1);
    t1 = (t0 + 8064U);
    t6 = (t0 + 2248U);
    t7 = *((char **)t6);
    t3 = (31 - 25);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t6 = (t7 + t5);
    t8 = (t0 + 8256U);
    t10 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t1, t6, t8);
    if (t10 == 1)
        goto LAB20;

LAB21:    t9 = (unsigned char)0;

LAB22:    if (t9 != 0)
        goto LAB17;

LAB19:    xsi_set_current_line(129, ng0);
    t1 = (t0 + 1972U);
    t2 = *((char **)t1);
    t1 = (t0 + 2248U);
    t6 = *((char **)t1);
    t3 = (31 - 25);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t6 + t5);
    t7 = (t0 + 8256U);
    t29 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t1, t7);
    t30 = (t29 - 0);
    t15 = (t30 * 1);
    xsi_vhdl_check_range_of_index(0, 31, 1, t29);
    t16 = (32U * t15);
    t17 = (0 + t16);
    t8 = (t2 + t17);
    t11 = (t0 + 4124);
    t12 = (t11 + 32U);
    t13 = *((char **)t12);
    t14 = (t13 + 40U);
    t18 = *((char **)t14);
    memcpy(t18, t8, 32U);
    xsi_driver_first_trans_fast_port(t11);

LAB18:    xsi_set_current_line(132, ng0);
    t1 = (t0 + 960U);
    t2 = *((char **)t1);
    t1 = (t0 + 8064U);
    t6 = (t0 + 2248U);
    t7 = *((char **)t6);
    t3 = (31 - 20);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t6 = (t7 + t5);
    t8 = (t0 + 8272U);
    t10 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t1, t6, t8);
    if (t10 == 1)
        goto LAB26;

LAB27:    t9 = (unsigned char)0;

LAB28:    if (t9 != 0)
        goto LAB23;

LAB25:    xsi_set_current_line(135, ng0);
    t1 = (t0 + 1972U);
    t2 = *((char **)t1);
    t1 = (t0 + 2248U);
    t6 = *((char **)t1);
    t3 = (31 - 20);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t6 + t5);
    t7 = (t0 + 8272U);
    t29 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t1, t7);
    t30 = (t29 - 0);
    t15 = (t30 * 1);
    xsi_vhdl_check_range_of_index(0, 31, 1, t29);
    t16 = (32U * t15);
    t17 = (0 + t16);
    t8 = (t2 + t17);
    t11 = (t0 + 4160);
    t12 = (t11 + 32U);
    t13 = *((char **)t12);
    t14 = (t13 + 40U);
    t18 = *((char **)t14);
    memcpy(t18, t8, 32U);
    xsi_driver_first_trans_fast_port(t11);

LAB24:
LAB3:    t1 = (t0 + 3840);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(114, ng0);
    t11 = (t0 + 960U);
    t12 = *((char **)t11);
    t11 = (t0 + 8064U);
    t13 = (t0 + 2248U);
    t14 = *((char **)t13);
    t15 = (31 - 25);
    t16 = (t15 * 1U);
    t17 = (0 + t16);
    t13 = (t14 + t17);
    t18 = (t0 + 8256U);
    t19 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t12, t11, t13, t18);
    if (t19 == 1)
        goto LAB8;

LAB9:    t10 = (unsigned char)0;

LAB10:    if (t10 != 0)
        goto LAB5;

LAB7:    xsi_set_current_line(117, ng0);
    t1 = (t0 + 2064U);
    t2 = *((char **)t1);
    t1 = (t0 + 2248U);
    t6 = *((char **)t1);
    t3 = (31 - 25);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t6 + t5);
    t7 = (t0 + 8256U);
    t29 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t1, t7);
    t30 = (t29 - 0);
    t15 = (t30 * 1);
    xsi_vhdl_check_range_of_index(0, 31, 1, t29);
    t16 = (32U * t15);
    t17 = (0 + t16);
    t8 = (t2 + t17);
    t11 = (t0 + 4124);
    t12 = (t11 + 32U);
    t13 = *((char **)t12);
    t14 = (t13 + 40U);
    t18 = *((char **)t14);
    memcpy(t18, t8, 32U);
    xsi_driver_first_trans_fast_port(t11);

LAB6:    xsi_set_current_line(120, ng0);
    t1 = (t0 + 960U);
    t2 = *((char **)t1);
    t1 = (t0 + 8064U);
    t6 = (t0 + 2248U);
    t7 = *((char **)t6);
    t3 = (31 - 20);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t6 = (t7 + t5);
    t8 = (t0 + 8272U);
    t10 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t1, t6, t8);
    if (t10 == 1)
        goto LAB14;

LAB15:    t9 = (unsigned char)0;

LAB16:    if (t9 != 0)
        goto LAB11;

LAB13:    xsi_set_current_line(123, ng0);
    t1 = (t0 + 2064U);
    t2 = *((char **)t1);
    t1 = (t0 + 2248U);
    t6 = *((char **)t1);
    t3 = (31 - 20);
    t4 = (t3 * 1U);
    t5 = (0 + t4);
    t1 = (t6 + t5);
    t7 = (t0 + 8272U);
    t29 = ieee_p_3620187407_sub_514432868_3620187407(IEEE_P_3620187407, t1, t7);
    t30 = (t29 - 0);
    t15 = (t30 * 1);
    xsi_vhdl_check_range_of_index(0, 31, 1, t29);
    t16 = (32U * t15);
    t17 = (0 + t16);
    t8 = (t2 + t17);
    t11 = (t0 + 4160);
    t12 = (t11 + 32U);
    t13 = *((char **)t12);
    t14 = (t13 + 40U);
    t18 = *((char **)t14);
    memcpy(t18, t8, 32U);
    xsi_driver_first_trans_fast_port(t11);

LAB12:    goto LAB3;

LAB5:    xsi_set_current_line(115, ng0);
    t20 = (t0 + 868U);
    t24 = *((char **)t20);
    t20 = (t0 + 4124);
    t25 = (t20 + 32U);
    t26 = *((char **)t25);
    t27 = (t26 + 40U);
    t28 = *((char **)t27);
    memcpy(t28, t24, 32U);
    xsi_driver_first_trans_fast_port(t20);
    goto LAB6;

LAB8:    t20 = (t0 + 1052U);
    t21 = *((char **)t20);
    t22 = *((unsigned char *)t21);
    t23 = (t22 == (unsigned char)3);
    t10 = t23;
    goto LAB10;

LAB11:    xsi_set_current_line(121, ng0);
    t11 = (t0 + 868U);
    t13 = *((char **)t11);
    t11 = (t0 + 4160);
    t14 = (t11 + 32U);
    t18 = *((char **)t14);
    t20 = (t18 + 40U);
    t21 = *((char **)t20);
    memcpy(t21, t13, 32U);
    xsi_driver_first_trans_fast_port(t11);
    goto LAB12;

LAB14:    t11 = (t0 + 1052U);
    t12 = *((char **)t11);
    t19 = *((unsigned char *)t12);
    t22 = (t19 == (unsigned char)3);
    t9 = t22;
    goto LAB16;

LAB17:    xsi_set_current_line(127, ng0);
    t11 = (t0 + 868U);
    t13 = *((char **)t11);
    t11 = (t0 + 4124);
    t14 = (t11 + 32U);
    t18 = *((char **)t14);
    t20 = (t18 + 40U);
    t21 = *((char **)t20);
    memcpy(t21, t13, 32U);
    xsi_driver_first_trans_fast_port(t11);
    goto LAB18;

LAB20:    t11 = (t0 + 1052U);
    t12 = *((char **)t11);
    t19 = *((unsigned char *)t12);
    t22 = (t19 == (unsigned char)2);
    t9 = t22;
    goto LAB22;

LAB23:    xsi_set_current_line(133, ng0);
    t11 = (t0 + 868U);
    t13 = *((char **)t11);
    t11 = (t0 + 4160);
    t14 = (t11 + 32U);
    t18 = *((char **)t14);
    t20 = (t18 + 40U);
    t21 = *((char **)t20);
    memcpy(t21, t13, 32U);
    xsi_driver_first_trans_fast_port(t11);
    goto LAB24;

LAB26:    t11 = (t0 + 1052U);
    t12 = *((char **)t11);
    t19 = *((unsigned char *)t12);
    t22 = (t19 == (unsigned char)2);
    t9 = t22;
    goto LAB28;

}

static void work_a_2842394180_3507449687_p_3(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(141, ng0);

LAB3:    t1 = (t0 + 2156U);
    t2 = *((char **)t1);
    t1 = (t0 + 4196);
    t3 = (t1 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 30U);
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t7 = (t0 + 3848);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_2842394180_3507449687_p_4(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(145, ng0);

LAB3:    t1 = (t0 + 1972U);
    t2 = *((char **)t1);
    t1 = (t0 + 4232);
    t3 = (t1 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 1024U);
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t7 = (t0 + 3856);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_2842394180_3507449687_p_5(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(146, ng0);

LAB3:    t1 = (t0 + 2064U);
    t2 = *((char **)t1);
    t1 = (t0 + 4268);
    t3 = (t1 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 1024U);
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t7 = (t0 + 3864);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}


extern void work_a_2842394180_3507449687_init()
{
	static char *pe[] = {(void *)work_a_2842394180_3507449687_p_0,(void *)work_a_2842394180_3507449687_p_1,(void *)work_a_2842394180_3507449687_p_2,(void *)work_a_2842394180_3507449687_p_3,(void *)work_a_2842394180_3507449687_p_4,(void *)work_a_2842394180_3507449687_p_5};
	xsi_register_didat("work_a_2842394180_3507449687", "isim/Decode_Stage_Test_isim_beh.exe.sim/work/a_2842394180_3507449687.didat");
	xsi_register_executes(pe);
}
