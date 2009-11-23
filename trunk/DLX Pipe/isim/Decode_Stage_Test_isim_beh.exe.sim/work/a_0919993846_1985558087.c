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
static const char *ng0 = "C:/Users/Filippo/XilinxProject/DLXSourceCodeVHDL/DLX 11.1 Rewrite/DLXPipe/Decode_Stage_Test.vhd";
extern char *WORK_P_2409548093;



static void work_a_0919993846_1985558087_p_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    int64 t7;
    int64 t8;

LAB0:    t1 = (t0 + 2516U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(109, ng0);
    t2 = (t0 + 2892);
    t3 = (t2 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    *((unsigned char *)t6) = (unsigned char)2;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(110, ng0);
    t2 = ((WORK_P_2409548093) + 1012U);
    t3 = *((char **)t2);
    t7 = *((int64 *)t3);
    t8 = (t7 / 2);
    t2 = (t0 + 2416);
    xsi_process_wait(t2, t8);

LAB6:    *((char **)t1) = &&LAB7;

LAB1:    return;
LAB4:    xsi_set_current_line(111, ng0);
    t2 = (t0 + 2892);
    t3 = (t2 + 32U);
    t4 = *((char **)t3);
    t5 = (t4 + 40U);
    t6 = *((char **)t5);
    *((unsigned char *)t6) = (unsigned char)3;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(112, ng0);
    t2 = ((WORK_P_2409548093) + 1012U);
    t3 = *((char **)t2);
    t7 = *((int64 *)t3);
    t8 = (t7 / 2);
    t2 = (t0 + 2416);
    xsi_process_wait(t2, t8);

LAB10:    *((char **)t1) = &&LAB11;
    goto LAB1;

LAB5:    goto LAB4;

LAB7:    goto LAB5;

LAB8:    goto LAB2;

LAB9:    goto LAB8;

LAB11:    goto LAB9;

}

static void work_a_0919993846_1985558087_p_1(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    int t4;
    int t5;
    char *t6;
    char *t7;
    int t8;
    int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    int64 t19;

LAB0:    t1 = (t0 + 2660U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(116, ng0);
    t2 = (t0 + 8816);
    *((int *)t2) = 0;
    t3 = (t0 + 8820);
    *((unsigned int *)t3) = 32U;
    t4 = 0;
    t5 = 32U;

LAB4:    if (t4 <= t5)
        goto LAB5;

LAB7:    goto LAB2;

LAB5:    xsi_set_current_line(117, ng0);
    t6 = (t0 + 1960U);
    t7 = *((char **)t6);
    t6 = (t0 + 8816);
    t8 = *((int *)t6);
    t9 = (t8 - 0);
    t10 = (t9 * 1);
    xsi_vhdl_check_range_of_index(0, 31, 1, *((int *)t6));
    t11 = (32U * t10);
    t12 = (0 + t11);
    t13 = (t7 + t12);
    t14 = (t0 + 2928);
    t15 = (t14 + 32U);
    t16 = *((char **)t15);
    t17 = (t16 + 40U);
    t18 = *((char **)t17);
    memcpy(t18, t13, 32U);
    xsi_driver_first_trans_fast(t14);
    xsi_set_current_line(118, ng0);
    t2 = ((WORK_P_2409548093) + 1012U);
    t3 = *((char **)t2);
    t19 = *((int64 *)t3);
    t2 = (t0 + 2560);
    xsi_process_wait(t2, t19);

LAB10:    *((char **)t1) = &&LAB11;

LAB1:    return;
LAB6:    t2 = (t0 + 8816);
    t4 = *((int *)t2);
    t3 = (t0 + 8820);
    t5 = *((unsigned int *)t3);
    if (t4 == t5)
        goto LAB7;

LAB12:    t8 = (t4 + 1);
    t4 = t8;
    t6 = (t0 + 8816);
    *((int *)t6) = t4;
    goto LAB4;

LAB8:    goto LAB6;

LAB9:    goto LAB8;

LAB11:    goto LAB9;

}


extern void work_a_0919993846_1985558087_init()
{
	static char *pe[] = {(void *)work_a_0919993846_1985558087_p_0,(void *)work_a_0919993846_1985558087_p_1};
	xsi_register_didat("work_a_0919993846_1985558087", "isim/Decode_Stage_Test_isim_beh.exe.sim/work/a_0919993846_1985558087.didat");
	xsi_register_executes(pe);
}
