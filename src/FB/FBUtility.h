#ifndef _FB_UTY_H_
#define _FB_UTY_H_

/*
 * SPHERE - Skeleton for PHysical and Engineering REsearch
 *
 * Copyright (c) RIKEN, Japan. All right reserved. 2004-2012
 *
 */

//@file FBUtility.h
//@brief FlowBase FBUtility class Header
//@author keno, FSI Team, VCAD, RIKEN

#include <math.h>
#include <string>
#include <string.h>
#include <stdio.h>
#include "FB_Define.h"
#include "mpi.h"

class FBUtility {

public:
  FBUtility() {}
  ~FBUtility() {}
  
protected:
  static void MemoryRequirement(const char* mode, const unsigned long Memory, const unsigned long l_memory, FILE* fp);
  
public:  
  static std::string getDirection(const unsigned dir);
  
  static void displayMemory (const char* mode, const unsigned long Memory, const unsigned long l_memory, FILE* fp, FILE* mp);
  static void printVersion  (FILE* fp, const char* str, const unsigned ver);

	/**
   @fn static REAL_TYPE convND2Kelvin(const REAL_TYPE var, const REAL_TYPE base, const REAL_TYPE diff)
   @brief 無次元温度varを有次元(Kelvin)にして返す
   @param var 無次元温度
   @param base Control::BaseTemp
   @param diff Control::DiffTemp
   */
  static REAL_TYPE convND2Kelvin(const REAL_TYPE var, const REAL_TYPE base, const REAL_TYPE diff) {
    return ( base + diff*var );
  }
  
  /**
   @fn static REAL_TYPE convD2ND(const REAL_TYPE var, const REAL_TYPE base, const REAL_TYPE diff, const unsigned Unit)
   @brief 有次元温度varを無次元にして返す
   @param var 有次元温度(Kelvin or Celsius)
   @param base Control::BaseTemp
   @param diff Control::DiffTemp
   @param Unit 温度の単位
   */
  static REAL_TYPE convD2ND(const REAL_TYPE var, const REAL_TYPE base, const REAL_TYPE diff, const unsigned Unit) {
    REAL_TYPE tmp = convTemp2K(var, Unit);
    return ( (tmp - base) / (REAL_TYPE)fabs(diff) );
  }
  
  /**
   @fn static REAL_TYPE convK2ND(const REAL_TYPE var, const REAL_TYPE base, const REAL_TYPE diff)
   @brief 有次元温度var(Kelvin)を無次元にして返す
   @param var 有次元温度(Kelvin)
   @param base Control::BaseTemp
   @param diff Control::DiffTemp
   */
  static REAL_TYPE convK2ND(const REAL_TYPE var, const REAL_TYPE base, const REAL_TYPE diff) {
    return ( (var - base) / (REAL_TYPE)fabs(diff) );
  }

  /**
   @fn static inline REAL_TYPE convK2Temp(const REAL_TYPE var, const unsigned Unit)
   @brief 有次元の温度varを指定された温度単位にして返す
   @param var 有次元温度(Kelvin)
   @param Unit 温度の単位
   */
  static REAL_TYPE convK2Temp(const REAL_TYPE var, const unsigned Unit) {
    return ( (Unit==Unit_KELVIN) ? var : var-KELVIN );
  }
  
  /**
   @fn static REAL_TYPE convTemp2K(const REAL_TYPE var, const unsigned Unit)
   @brief 有次元の温度varを(Kelvin)にして返す
   @param var 有次元温度(Kelvin or Celsius)
   @param Unit 温度の単位
   */
  static REAL_TYPE convTemp2K(const REAL_TYPE var, const unsigned Unit) {
    return ( (Unit==Unit_KELVIN) ? var : var+KELVIN );
  }
  
  /**
   @fn static REAL_TYPE convD2ND_V(const REAL_TYPE var, const REAL_TYPE refv)
   @brief 有次元速度を無次元にして返す
   @retval 無次元速度
   @param var 有次元速度
   @param refv 代表速度
   */
  static REAL_TYPE convD2ND_V(const REAL_TYPE var, const REAL_TYPE RefV) {
    return ( var / RefV );
  }
  
  /**
   @fn static REAL_TYPE convD2ND_Hsrc(REAL_TYPE var, REAL_TYPE RefV, REAL_TYPE RefL, REAL_TYPE diff, REAL_TYPE rho, REAL_TYPE C)
   @brief 発熱量(W/m^3)を無次元にして返す
   @param var 有次元発熱量(W/m^3)
   @param RefV 代表速度
   @param RefL 代表長さ
   @param diff 代表温度差
   @param rho 媒質密度
   @param C 媒質比熱
   */
  static REAL_TYPE convD2ND_Hsrc(const REAL_TYPE var, 
                                       const REAL_TYPE RefV, 
                                       const REAL_TYPE RefL, 
                                       const REAL_TYPE diff, 
                                       const REAL_TYPE rho, 
                                       const REAL_TYPE C) {
    return ( var*RefL / (RefV*diff*rho*C) );
  }
  
  /**
   @fn static REAL_TYPE convND2D_Hsrc(const REAL_TYPE var, const REAL_TYPE RefV, const REAL_TYPE RefL, const REAL_TYPE diff, const REAL_TYPE rho, const REAL_TYPE C)
   @brief 発熱量を有次元(W/m^3)にして返す
   @param var 無次元発熱量
   @param RefV 代表速度
   @param RefL 代表長さ
   @param diff 代表温度差
   @param rho 媒質密度
   @param C 媒質比熱
   */
  static REAL_TYPE convND2D_Hsrc(const REAL_TYPE var, 
                                       const REAL_TYPE RefV, 
                                       const REAL_TYPE RefL, 
                                       const REAL_TYPE diff, 
                                       const REAL_TYPE rho, 
                                       const REAL_TYPE C) {
    return ( var* RefV*diff*rho*C / RefL );
  }
  
  /**
   @fn static REAL_TYPE convD2ND_P(const REAL_TYPE var, const REAL_TYPE bp, const REAL_TYPE rho, const REAL_TYPE RefV, const unsigned mode)
   @brief 圧力を無次元にして返す
   @param var 有次元圧力(absolute or gauge)
   @param bp 基準圧力
   @param rho 媒質密度
   @param RefV 代表速度
   @param mode (absolute or gauge)
   */
  static REAL_TYPE convD2ND_P(const REAL_TYPE var, 
                                    const REAL_TYPE bp, 
                                    const REAL_TYPE rho, 
                                    const REAL_TYPE RefV, 
                                    const unsigned mode) {
    const REAL_TYPE a = (mode==Unit_Absolute) ? (var-bp) : var;
    return (  a / (RefV*RefV*rho) );
  }
  
  /**
   @fn static REAL_TYPE convND2D_P(const REAL_TYPE var, const REAL_TYPE bp, const REAL_TYPE rho, const REAL_TYPE RefV)
   @brief 圧力を有次元(absolute or gauge)にして返す
   @param var 無次元圧力
   @param bp 基準圧力
   @param rho 媒質密度
   @param RefV 代表速度
   @param mode (absolute or gauge)
   */
  static REAL_TYPE convND2D_P(const REAL_TYPE var, const REAL_TYPE bp, const REAL_TYPE rho, const REAL_TYPE RefV, const unsigned mode) {
    const REAL_TYPE a = var * (RefV*RefV*rho);
    return ( (mode==Unit_Absolute) ? bp+a : a );
  }
  
  /**
   @fn static inline unsigned getFindexS3D(const unsigned* sz, unsigned gc, int i, int j, int k)
   @brief Fortranの3次元インデックスから1次元インデックスを取得する
   @param sz    I,J,K方向サイズ（ガイドセルを含まない）
   @param gc    ガイドセル
   @param i     I方向インデックス（ガイドセルを含まない）
   @param j     J方向インデックス（ガイドセルを含まない）
   @param k     K方向インデックス（ガイドセルを含まない）
   @return      1次元インデックス
   */
  static inline unsigned getFindexS3D(const unsigned* sz, unsigned gc, int i, int j, int k) {
    //return ( (sz[0]+gc*2)*(sz[1]+gc*2)*(k+gc-1) + (sz[0]+gc*2)*(j+gc-1) + i+gc-1 );
    int t1 = gc*2;
    int t2 = gc-1;
    int t3 = sz[0]+t1;
    return ( t3*( (sz[1]+t1)*(k+t2) + j+t2 ) + i+t2 );
  }
  
  /**
   @fn static inline unsigned getFindexV3DEx(const unsigned* sz, unsigned gc, int l, int i, int j, int k)
   @brief Fortranの3次元Exベクトルインデックスから1次元インデックスを取得する
   @param sz    I,J,K方向サイズ（ガイドセルを含まない）
   @param gc    ガイドセル
   @param l     ベクトルインデックス
   @param i     I方向インデックス（ガイドセルを含まない）
   @param j     J方向インデックス（ガイドセルを含まない）
   @param k     K方向インデックス（ガイドセルを含まない）
   @return      1次元インデックス
   */
  static inline unsigned getFindexV3DEx(const unsigned* sz, unsigned gc, int l, int i, int j, int k) {
    int t1 = gc*2;
    int t2 = gc-1;
    int t3 = sz[0]+t1;
    return ( 3*(t3*(sz[1]+t1)*(k+t2) + t3*(j+t2) + i+t2) + l );
    //return ( 3*(sz[0]+gc*2)*(sz[1]+gc*2)*(k+gc-1) + 3*(sz[0]+gc*2)*(j+gc-1) + 3*(i+gc-1) + l );
  }
  
  /**
   @fn static inline unsigned getFindexS3Dcut(const unsigned* sz, unsigned gc, int l, int i, int j, int k)
   @brief Fortranの3次元cut用インデックスから1次元インデックスを取得する
   @param sz    I,J,K方向サイズ（ガイドセルを含まない）
   @param gc    ガイドセル
   @param l     方向インデックス[0,5]
   @param i     I方向インデックス（ガイドセルを含まない）
   @param j     J方向インデックス（ガイドセルを含まない）
   @param k     K方向インデックス（ガイドセルを含まない）
   @return      1次元インデックス
   */
  static inline unsigned getFindexS3Dcut(const unsigned* sz, unsigned gc, int l, int i, int j, int k) {
    int t1 = gc*2;
    int t2 = gc-1;
    int t3 = sz[0]+t1;
    return ( 6*(t3*(sz[1]+t1)*(k+t2) + t3*(j+t2) + i+t2) + l );
  }
  
  /**
   @fn static inline unsigned getFindexBID8(const unsigned* sz, unsigned gc, int l, int i, int j, int k)
   @brief Fortranの3次元cut用Bid8インデックスから1次元インデックスを取得する
   @param sz    I,J,K方向サイズ（ガイドセルを含まない）
   @param gc    ガイドセル
   @param i     I方向インデックス（ガイドセルを含まない）
   @param j     J方向インデックス（ガイドセルを含まない）
   @param k     K方向インデックス（ガイドセルを含まない）
   @return      1次元インデックス
   */
  static inline unsigned getFindexBID8(const unsigned* sz, unsigned gc, int i, int j, int k) {
    int t1 = gc*2;
    int t2 = gc-1;
    int t3 = sz[0]+t1;
    return ( 2*(t3*(sz[1]+t1)*(k+t2) + t3*(j+t2) + i+t2) );
  }
  
  
  /// 桁あふれ対策の代替関数 > MPI_INT*1, MPI_SUM
  static void int_sum_Allreduce(int* sbuf, int* rbuf) {
#ifdef __ARCH_FX
    float my_send = (float)*sbuf;
    float my_recv = (float)*rbuf;
    MPI_Allreduce(&my_send, &my_recv, 1, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
    rbuf = (int*)&my_recv;
#else
    MPI_Allreduce(sbuf, rbuf, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数 > MPI_INT*1, MPI_MAX
  static void int_max_Allreduce(int* sbuf, int* rbuf) {
#ifdef __ARCH_FX
    float my_send = (float)*sbuf;
    float my_recv = (float)*rbuf;
    MPI_Allreduce(&my_send, &my_recv, 1, MPI_FLOAT, MPI_MAX, MPI_COMM_WORLD);
    rbuf = (int*)&my_recv;
#else
    MPI_Allreduce(sbuf, rbuf, 1, MPI_INT, MPI_MAX, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数 > MPI_INT*msg, MPI_SUM
  static void int_array_sum_Allreduce(int* sbuf, int* rbuf, const int msg) {
#ifdef __ARCH_FX
    float* my_send = new float [msg];
    float* my_recv = new float [msg];
    for (int i=0; i<msg; i++) {
      my_send[i] = (float)sbuf[i];
    }
    MPI_Allreduce(my_send, my_recv, msg, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
    for (int i=0; i<msg; i++) {
      rbuf[i] = (int)my_recv[i];
    }
    if ( my_send ) { delete [] my_send; my_send = NULL; }
    if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
#else
    MPI_Allreduce(sbuf, rbuf, msg, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数 > MPI_INT*msg, MPI_MAX
  static void int_array_max_Allreduce(int* sbuf, int* rbuf, const int msg) {
#ifdef __ARCH_FX
    float* my_send = new float [msg];
    float* my_recv = new float [msg];
    for (int i=0; i<msg; i++) {
      my_send[i] = (float)sbuf[i];
    }
    MPI_Allreduce(my_send, my_recv, msg, MPI_FLOAT, MPI_MAX, MPI_COMM_WORLD);
    for (int i=0; i<msg; i++) {
      rbuf[i] = (int)my_recv[i];
    }
    if ( my_send ) { delete [] my_send; my_send = NULL; }
    if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
#else
    MPI_Allreduce(sbuf, rbuf, msg, MPI_INT, MPI_MAX, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数
  static void int_Gather(int* sbuf, int* rbuf, const int msg) {
#ifdef __ARCH_FX
    float* my_send = new float [msg];
    float* my_recv = new float [msg];
    for (int i=0; i<msg; i++) {
      my_send[i] = (float)sbuf[i];
    }
    MPI_Gather(my_send, msg, MPI_FLOAT, my_recv, msg, MPI_FLOAT, 0, MPI_COMM_WORLD);
    for (int i=0; i<msg; i++) {
      rbuf[i] = (int)my_recv[i];
    }
    if ( my_send ) { delete [] my_send; my_send = NULL; }
    if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
#else
    MPI_Gather(sbuf, msg, MPI_INT, rbuf, msg, MPI_INT, 0, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数 > MPI_UINT*1, MPI_SUM
  static void uint_sum_Allreduce(unsigned* sbuf, unsigned* rbuf) {
#ifdef __ARCH_FX
    float my_send = (float)*sbuf;
    float my_recv = (float)*rbuf;
    MPI_Allreduce(&my_send, &my_recv, 1, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
    rbuf = (unsigned*)&my_recv;
#else
    MPI_Allreduce(sbuf, rbuf, 1, MPI_UNSIGNED, MPI_SUM, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数 > MPI_UINT*msg, MPI_SUM
  static void uint_array_sum_Allreduce(unsigned* sbuf, unsigned* rbuf, const int msg) {
#ifdef __ARCH_FX
    float* my_send = new float [msg];
    float* my_recv = new float [msg];
    for (int i=0; i<msg; i++) {
      my_send[i] = (float)sbuf[i];
    }
    MPI_Allreduce(my_send, my_recv, msg, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
    for (int i=0; i<msg; i++) {
      rbuf[i] = (unsigned)my_recv[i];
    }
    if ( my_send ) { delete [] my_send; my_send = NULL; }
    if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
#else
    MPI_Allreduce(sbuf, rbuf, msg, MPI_UNSIGNED, MPI_SUM, MPI_COMM_WORLD);
#endif
  }
  
  /// 桁あふれ対策の代替関数
  static void uint_Gather(unsigned* sbuf, unsigned* rbuf, const int msg) {
#ifdef __ARCH_FX
    float* my_send = new float [msg];
    float* my_recv = new float [msg];
    for (int i=0; i<msg; i++) {
      my_send[i] = (float)sbuf[i];
    }
    MPI_Gather(my_send, msg, MPI_FLOAT, my_recv, msg, MPI_FLOAT, 0, MPI_COMM_WORLD);
    for (int i=0; i<msg; i++) {
      rbuf[i] = (unsigned)my_recv[i];
    }
    if ( my_send ) { delete [] my_send; my_send = NULL; }
    if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
#else
    MPI_Gather(sbuf, msg, MPI_UNSIGNED, rbuf, msg, MPI_UNSIGNED, 0, MPI_COMM_WORLD);
#endif
  }
  
  /// 浮動小数のラッパー関数
  static void real_Gather(REAL_TYPE* sbuf, REAL_TYPE* rbuf, const int msg) {
    
    if ( sizeof(REAL_TYPE) == sizeof(float) ) {
      float* my_send = new float [msg];
      float* my_recv = new float [msg];
      for (int i=0; i<msg; i++) {
        my_send[i] = sbuf[i];
      }
      MPI_Gather(my_send, msg, MPI_FLOAT, my_recv, msg, MPI_FLOAT, 0, MPI_COMM_WORLD);
      for (int i=0; i<msg; i++) {
        rbuf[i] = my_recv[i];
      }
      if ( my_send ) { delete [] my_send; my_send = NULL; }
      if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
    }
    else {
      double* my_send = new double [msg];
      double* my_recv = new double [msg];
      for (int i=0; i<msg; i++) {
        my_send[i] = sbuf[i];
      }
      MPI_Gather(my_send, msg, MPI_DOUBLE, my_recv, msg, MPI_DOUBLE, 0, MPI_COMM_WORLD);
      for (int i=0; i<msg; i++) {
        rbuf[i] = my_recv[i];
      }
      if ( my_send ) { delete [] my_send; my_send = NULL; }
      if ( my_recv ) { delete [] my_recv; my_recv = NULL; }
    }
  }
  
};

#endif // _FB_UTY_H_
