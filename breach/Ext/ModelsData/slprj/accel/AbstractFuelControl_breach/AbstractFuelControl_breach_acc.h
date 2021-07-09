#include "__cf_AbstractFuelControl_breach.h"
#ifndef RTW_HEADER_AbstractFuelControl_breach_acc_h_
#define RTW_HEADER_AbstractFuelControl_breach_acc_h_
#include <stddef.h>
#include <float.h>
#ifndef AbstractFuelControl_breach_acc_COMMON_INCLUDES_
#define AbstractFuelControl_breach_acc_COMMON_INCLUDES_
#include <stdlib.h>
#define S_FUNCTION_NAME simulink_only_sfcn 
#define S_FUNCTION_LEVEL 2
#define RTW_GENERATED_S_FUNCTION
#include "sl_AsyncioQueue/AsyncioQueueCAPI.h"
#include "simtarget/slSimTgtSigstreamRTW.h"
#include "simtarget/slSimTgtSlioCoreRTW.h"
#include "simtarget/slSimTgtSlioClientsRTW.h"
#include "rtwtypes.h"
#include "simstruc.h"
#include "fixedpoint.h"
#endif
#include "AbstractFuelControl_breach_acc_types.h"
#include "multiword_types.h"
#include "rt_zcfcn.h"
#include "mwmathutil.h"
#include "rtGetInf.h"
#include "rt_defines.h"
#include "rt_nonfinite.h"
typedef struct { real_T B_16_1_0 ; real_T B_16_4_0 ; real_T B_15_0_0 ; real_T
B_15_1_0 ; real_T B_15_2_0 ; real_T B_15_4_0 ; real_T B_15_7_0 ; real_T
B_15_8_0 ; real_T B_15_9_0 ; real_T B_15_10_0 ; real_T B_15_12_0 ; real_T
B_15_13_0 ; real_T B_15_14_0 ; real_T B_15_15_0 ; real_T B_15_16_0 ; real_T
B_15_18_0 ; real_T B_15_19_0 ; real_T B_15_20_0 ; real_T B_15_21_0 ; real_T
B_15_23_0 ; real_T B_15_24_0 ; real_T B_15_25_0 ; real_T B_15_27_0 ; real_T
B_15_32_0 ; real_T B_15_34_0 ; real_T B_15_35_0 ; real_T B_15_41_0 ; real_T
B_15_42_0 ; real_T B_15_43_0 ; real_T B_15_45_0 ; real_T B_15_46_0 ; real_T
B_15_47_0 ; real_T B_15_49_0 ; real_T B_15_50_0 ; real_T B_15_51_0 ; real_T
B_15_52_0 ; real_T B_15_53_0 ; real_T B_15_54_0 ; real_T B_15_55_0 ; real_T
B_15_56_0 ; real_T B_15_57_0 ; real_T B_15_58_0 ; real_T B_15_59_0 ; real_T
B_15_60_0 ; real_T B_15_61_0 ; real_T B_15_62_0 ; real_T B_15_63_0 ; real_T
B_15_64_0 ; real_T B_13_1_0 ; real_T B_12_4_0 ; real32_T B_9_0_0 ; real32_T
B_8_0_0 ; real32_T B_8_3_0 ; real32_T B_7_2_0 ; real32_T B_4_5_0 ; real32_T
B_4_7_0 ; real32_T B_2_6_0 ; real32_T B_2_7_0 ; real32_T B_1_13_0 ; boolean_T
B_9_3_0 ; boolean_T B_8_5_0 ; boolean_T B_7_6_0 ; boolean_T B_4_10_0 ; }
B_AbstractFuelControl_breach_T ; typedef struct { real_T nextTime ; int64_T
numCompleteCycles ; struct { real_T modelTStart ; }
fuelsystemtransportdelay_RWORK ; struct { void * AQHandles ; void * SlioLTF ;
} HiddenToAsyncQueue_InsertedFor_EngineSpeed_at_outport_0_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_PedalAngle_at_outport_0_PWORK ; struct { void
* AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_IntakeManifold_at_outport_0_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_IntakeManifold_at_outport_1_PWORK ; struct {
void * AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_Throttle_at_outport_0_PWORK ; struct { void *
AQHandles ; void * SlioLTF ; }
HiddenToAsyncQueue_InsertedFor_Wallwetting_at_outport_0_PWORK ; struct { void
* TUbufferPtrs [ 3 ] ; } fuelsystemtransportdelay_PWORK ; void *
commanded_fuel_PWORK ; void * mode_fb_PWORK ; void * mode_fb1_PWORK ; void *
DataStoreMemory_PWORK ; void * DataStoreMemory1_PWORK ; void *
DataStoreMemory2_PWORK ; void * DataStoreMemory3_PWORK ; real32_T
UnitDelay2_DSTATE ; real32_T UnitDelay1_DSTATE ; real32_T UnitDelay1_DSTATE_d
; real32_T commanded_fuel ; real32_T airbyfuel_ref ; real32_T engine_speed ;
real32_T throttle_flow ; real32_T airbyfuel_meas ; real32_T throttle_angle ;
int32_T justEnabled ; int32_T currentValue ; int32_T dsmIdx ; int32_T
dsmIdx_l ; int32_T dsmIdx_e ; int32_T dsmIdx_f ; int32_T dsmIdx_h ; int32_T
dsmIdx_ha ; int32_T dsmIdx_m ; struct { int_T Tail ; int_T Head ; int_T Last
; int_T CircularBufSize ; int_T MaxNewBufSize ; }
fuelsystemtransportdelay_IWORK ; boolean_T UnitDelay_DSTATE ; boolean_T
UnitDelay1_DSTATE_a ; boolean_T UnitDelay1_DSTATE_e ; int8_T
fuel_controller_pwon_SubsysRanBC ; int8_T
fuel_controller_mode_10ms_SubsysRanBC ; int8_T
fuel_controller_10ms_SubsysRanBC ; int8_T feedback_PI_controller_SubsysRanBC
; boolean_T controller_mode ; char_T pad_controller_mode [ 4 ] ; }
DW_AbstractFuelControl_breach_T ; typedef struct { real_T p00543bar_CSTATE ;
real_T Throttledelay_CSTATE ; real_T Integrator_CSTATE ; real_T
Integrator_CSTATE_c ; real_T Integrator_CSTATE_h ; real_T
fuelsystemtransportdelay_CSTATE ; } X_AbstractFuelControl_breach_T ; typedef
struct { real_T p00543bar_CSTATE ; real_T Throttledelay_CSTATE ; real_T
Integrator_CSTATE ; real_T Integrator_CSTATE_c ; real_T Integrator_CSTATE_h ;
real_T fuelsystemtransportdelay_CSTATE ; } XDot_AbstractFuelControl_breach_T
; typedef struct { boolean_T p00543bar_CSTATE ; boolean_T
Throttledelay_CSTATE ; boolean_T Integrator_CSTATE ; boolean_T
Integrator_CSTATE_c ; boolean_T Integrator_CSTATE_h ; boolean_T
fuelsystemtransportdelay_CSTATE ; } XDis_AbstractFuelControl_breach_T ;
typedef struct { real_T p00543bar_CSTATE ; real_T Throttledelay_CSTATE ;
real_T Integrator_CSTATE ; real_T Integrator_CSTATE_c ; real_T
Integrator_CSTATE_h ; real_T fuelsystemtransportdelay_CSTATE ; }
CStateAbsTol_AbstractFuelControl_breach_T ; typedef struct { ZCSigState
fuel_controller_pwon_Trig_ZCE ; ZCSigState fuel_controller_mode_10ms_Trig_ZCE
; ZCSigState fuel_controller_10ms_Trig_ZCE ; }
PrevZCX_AbstractFuelControl_breach_T ; typedef struct { real_T Pedal_Angle ;
real_T Engine_Speed ; } ExternalUPtrs_AbstractFuelControl_breach_T ; typedef
struct { real_T * B_16_1 ; real_T * B_16_2 ; real_T * B_16_3 ; }
ExtY_AbstractFuelControl_breach_T ; struct P_AbstractFuelControl_breach_T_ {
real_T P_0 ; real_T P_1 ; real_T P_2 ; real_T P_3 ; real_T P_4 ; real_T P_5 ;
real_T P_6 ; real_T P_7 ; real_T P_8 ; real_T P_9 ; real_T P_10 ; real_T P_11
; real_T P_12 ; real_T P_13 ; real_T P_14 ; real_T P_15 ; real_T P_16 ;
real_T P_17 ; real_T P_18 ; real_T P_19 ; real_T P_20 ; real_T P_21 [ 20 ] ;
real_T P_22 [ 5 ] ; real_T P_23 [ 4 ] ; real_T P_24 ; real_T P_25 ; real_T
P_26 ; real_T P_27 ; real_T P_28 ; real_T P_29 ; real_T P_30 ; real_T P_31 ;
real_T P_32 ; real_T P_33 ; real_T P_34 ; real_T P_35 ; real_T P_36 [ 20 ] ;
real_T P_37 [ 5 ] ; real_T P_38 [ 4 ] ; real_T P_39 ; real_T P_40 ; real_T
P_41 ; real_T P_42 ; real_T P_43 ; real_T P_44 ; real_T P_45 ; real_T P_46 [
20 ] ; real_T P_47 [ 5 ] ; real_T P_48 [ 4 ] ; real_T P_49 ; real_T P_50 ;
real_T P_51 ; real32_T P_52 ; real32_T P_53 ; real32_T P_54 ; real32_T P_55 ;
real32_T P_56 ; real32_T P_57 ; real32_T P_58 ; real32_T P_59 ; real32_T P_60
; real32_T P_61 ; real32_T P_62 ; real32_T P_63 ; real32_T P_64 ; real32_T
P_65 ; real32_T P_66 ; real32_T P_67 ; real32_T P_68 ; real32_T P_69 ;
real32_T P_70 ; real32_T P_71 ; real32_T P_72 ; real32_T P_73 ; real32_T P_74
; real32_T P_75 ; real32_T P_76 ; real32_T P_77 ; real32_T P_78 ; real32_T
P_79 ; real32_T P_80 ; real32_T P_81 ; real32_T P_82 ; real32_T P_83 ;
real32_T P_84 ; real32_T P_85 ; real32_T P_86 ; uint32_T P_87 [ 2 ] ;
uint32_T P_88 [ 2 ] ; uint32_T P_89 [ 2 ] ; boolean_T P_90 ; boolean_T P_91 ;
boolean_T P_92 ; boolean_T P_93 ; } ; extern P_AbstractFuelControl_breach_T
AbstractFuelControl_breach_rtDefaultP ;
#endif
