#ifndef _FB_SAMPLING_H_
#define _FB_SAMPLING_H_

//##################################################################################
//
// Flow Base class
//
// Copyright (c) 2007-2011 VCAD System Research Program, RIKEN.
// All rights reserved.
//
// Copyright (c) 2011-2013 Institute of Industrial Science, The University of Tokyo.
// All rights reserved.
//
// Copyright (c) 2012-2013 Advanced Institute for Computational Science, RIKEN.
// All rights reserved.
//
//##################################################################################

//@file   Sampling.h
//@brief  FlowBase Sampling class Header
//@author kero

#include "FB_Define.h"
#include "vec3.h"
#include "basic_func.h"

//using namespace FB;

/**
 * Samplingクラス
 *
 *   サンプリング基底クラス(アブストラクト)
 */
class Sampling {
public:

  /// モニタ点状態型
  enum PointStatus {
    POINT_STATUS_OK,   ///< 正常
    UNEXPECTED_SOLID,  ///< 流体セルを指定したが固体だった
    UNEXPECTED_FLUID,  ///< 固体セルを指定したが流体だった
  };

protected:
  int mode;          ///< サンプリングモード
  int size[3];       ///< セル(ローカル)サイズ
  int guide;         ///< ガイドセル数

  FB::Vec3i cIndex; ///< モニタ点を含むセルのインデックス
  FB::Vec3r pch;    ///< セル幅
  FB::Vec3r v00;    ///< 座標系移動速度
  int* bcd;         ///< BCindex B
  
public:
  /// ディフォルトコンストラクタ.
  Sampling() {}

  /// コンストラクタ.
  ///
  ///   @param[in] mode  サンプリングモード
  ///   @param[in] size  ローカルセル数
  ///   @param[in] guide ガイドセル数
  ///   @param[in] crd   モニタ点座標
  ///   @param[in] org   ローカル領域基点座標
  ///   @param[in] pch   セル幅
  ///   @param[in] v00   座標系移動速度
  ///   @param[in] bcd   BCindex B
  ///
  Sampling(int mode,
           int size[],
           int guide,
           FB::Vec3r crd,
           FB::Vec3r org,
           FB::Vec3r pch,
           FB::Vec3r v00,
           int* bcd) {
    
    this->mode = mode;
    this->size[0] = size[0];
    this->size[1] = size[1];
    this->size[2] = size[2];
    this->guide = guide;
    this->pch = pch;
    this->v00 = v00;
    this->bcd = bcd;

    FB::Vec3r c = (crd - org) / pch;
    cIndex.x = (int)(c.x) + 1;
    cIndex.y = (int)(c.y) + 1;
    cIndex.z = (int)(c.z) + 1;
  } 

  /// デストラクタ.
  virtual ~Sampling() {}

  /// モニタ点の状態を返す.
  PointStatus checkMonitorPoint() {
    if      (mode == SAMPLING_FLUID_ONLY && !isFluid(cIndex)) return UNEXPECTED_SOLID;
    else if (mode == SAMPLING_SOLID_ONLY &&  isFluid(cIndex)) return UNEXPECTED_FLUID;
    else return POINT_STATUS_OK;   // mode == ALL
  }

  /// 速度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  virtual FB::Vec3r samplingVelocity(const REAL_TYPE* v) = 0;

  /// 圧力をサンプリング.
  ///
  ///   @param[in] p サンプリング元圧力配列
  ///
  virtual REAL_TYPE samplingPressure(const REAL_TYPE* p) = 0;

  /// 温度をサンプリング.
  ///
  ///   @param[in] t サンプリング元温度配列
  ///
  virtual REAL_TYPE samplingTemperature(const REAL_TYPE* t) = 0;

  /// 全圧をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///   @param[in] p サンプリング元圧力配列
  ///
  virtual REAL_TYPE samplingTotalPressure(const REAL_TYPE* v, const REAL_TYPE* p) = 0;

  /// 渦度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  virtual FB::Vec3r samplingVorticity(const REAL_TYPE* v) = 0;

protected:
  /// 全圧を計算.
  ///
  ///   @param[in] v  速度
  ///   @param[in] p  圧力
  ///   @return 全圧
  REAL_TYPE calcTotalPressure(const FB::Vec3r v, REAL_TYPE p) {
    FB::Vec3r v1 = v - v00;
    return 0.5 * v1.lengthSquared() + p;
  }

  /// 渦度を計算
  ///
  ///   @param[in] v 速度配列
  ///   @param[in] index セルインデックス
  ///   @return 渦度ベクトル
  ///
  FB::Vec3r calcVorticity(const REAL_TYPE* v, FB::Vec3i index);


  /// セルインデックスを(1,0,0)シフト.
  FB::Vec3i shift1(FB::Vec3i index) { return FB::Vec3i(index.x+1, index.y  , index.z  ); }

  /// セルインデックスを(0,1,0)シフト.
  FB::Vec3i shift2(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y+1, index.z  ); }

  /// セルインデックスを(1,1,0)シフト.
  FB::Vec3i shift3(FB::Vec3i index) { return FB::Vec3i(index.x+1, index.y+1, index.z  ); }

  /// セルインデックスを(0,0,1)シフト.
  FB::Vec3i shift4(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y  , index.z+1); }

  /// セルインデックスを(1,0,1)シフト.
  FB::Vec3i shift5(FB::Vec3i index) { return FB::Vec3i(index.x+1, index.y  , index.z+1); }

  /// セルインデックスを(0,1,1)シフト.
  FB::Vec3i shift6(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y+1, index.z+1); }

  /// セルインデックスを(1,1,1)シフト.
  FB::Vec3i shift7(FB::Vec3i index) { return FB::Vec3i(index.x+1, index.y+1, index.z+1); }

  /// セルインデックスを-xシフト.
  FB::Vec3i shift_xm(FB::Vec3i index) { return FB::Vec3i(index.x-1, index.y  , index.z  ); }

  /// セルインデックスを+xシフト.
  FB::Vec3i shift_xp(FB::Vec3i index) { return FB::Vec3i(index.x+1, index.y  , index.z  ); }

  /// セルインデックスを-yシフト.
  FB::Vec3i shift_ym(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y-1, index.z  ); }

  /// セルインデックスを+yシフト.
  FB::Vec3i shift_yp(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y+1, index.z  ); }

  /// セルインデックスを-zシフト.
  FB::Vec3i shift_zm(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y  , index.z-1); }

  /// セルインデックスを+zシフト.
  FB::Vec3i shift_zp(FB::Vec3i index) { return FB::Vec3i(index.x  , index.y  , index.z+1); }

  /// セルが流体セルかどうか調べる.
  ///
  ///    @param[in] index セルインデックス
  ///
  bool isFluid(FB::Vec3i index) {
    size_t m =_F_IDX_S3D(index.x, index.y, index.z, size[0], size[1], size[2], guide);
    return IS_FLUID(bcd[m]);
  }

  /// セルでのスカラー値を取得.
  ///
  ///    @param [in] s スカラー配列
  ///    @param [in] index セルインデックス
  ///    @return セルでのスカラー値
  ///
  REAL_TYPE getScalar(const REAL_TYPE* s, FB::Vec3i index) {
    size_t m =_F_IDX_S3D(index.x, index.y, index.z, size[0], size[1], size[2], guide);
    return s[m];
  }

  /// セルでのベクトル値を取得.
  ///
  ///    @param [in] v ベクトル配列
  ///    @param [in] index セルインデックス
  ///    @return セルでのベクトル値
  ///
  FB::Vec3r getVector(const REAL_TYPE* v, FB::Vec3i index) {
    FB::Vec3r vRet;
    int ix = size[0];
    int jx = size[1];
    int kx = size[2];
    int gd = guide;
    
    size_t m_x = _F_IDX_V3D(index.x, index.y, index.z, 0, ix, jx, kx, gd);
    size_t m_y = _F_IDX_V3D(index.x, index.y, index.z, 1, ix, jx, kx, gd);
    size_t m_z = _F_IDX_V3D(index.x, index.y, index.z, 2, ix, jx, kx, gd);
    vRet.x = v[m_x];
    vRet.y = v[m_y];
    vRet.z = v[m_z];
    
    return vRet;
  }

};

/**
  * Nearestクラス.
  *
  *    - モニタ点を含むセルの値をサンプリングする．
  */
class Nearest : public Sampling {
protected:

  /// スカラー変数をサンプリング.
  ///
  ///   @param[in] s サンプリング元スカラー変数配列
  ///
  REAL_TYPE samplingScalar(const REAL_TYPE* s);

public:

  /// コンストラクタ.
  ///
  ///   @param [in] mode   サンプリングモード
  ///   @param [in] size   ローカルセル数
  ///   @param [in] guide  ガイドセル数
  ///   @param [in] crd    モニタ点座標
  ///   @param [in] org    ローカル領域基点座標
  ///   @param [in] pch    セル幅
  ///   @param [in] v00    座標系移動速度
  ///   @param [in] bcd    BCindex B
  ///
  Nearest(int mode,
          int size[],
          int guide,
          FB::Vec3r crd,
          FB::Vec3r org,
          FB::Vec3r pch,
          FB::Vec3r v00,
          int* bcd);

  /// デストラクタ.
  ~Nearest() {}

  /// 速度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVelocity(const REAL_TYPE* v);

  /// 圧力をサンプリング.
  ///
  ///   @param[in] p サンプリング元圧力配列
  ///
  REAL_TYPE samplingPressure(const REAL_TYPE* p) { return samplingScalar(p); }

  /// 温度をサンプリング.
  ///
  ///   @param[in] t サンプリング元温度配列
  ///
  REAL_TYPE samplingTemperature(const REAL_TYPE* t) { return samplingScalar(t); }

  /// 全圧をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///   @param[in] p サンプリング元圧力配列
  ///
  REAL_TYPE samplingTotalPressure(const REAL_TYPE*v, const REAL_TYPE* p);

  /// 渦度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVorticity(const REAL_TYPE* v);
};


/**
 * Smoothingクラス
 *
 *   - モニタ点を含むセルとその隣接セルを用いて平均値を計算する.
 *   - モードがallの場合は、6個の全隣接セルを用いる.
 *   - モードがfluidの場合は、隣接セルとしては流体セルのみを用いる.
 *   - モードがsolidの場合は、隣接セルとしては固体セルのみを用いる.
 */
class Smoothing : public Sampling {

protected:

  bool add_xm;  ///< -xセルを平均値計算に参加させるかどうかのフラグ
  bool add_xp;  ///< +xセルを平均値計算に参加させるかどうかのフラグ
  bool add_ym;  ///< -yセルを平均値計算に参加させるかどうかのフラグ
  bool add_yp;  ///< +yセルを平均値計算に参加させるかどうかのフラグ
  bool add_zm;  ///< -zセルを平均値計算に参加させるかどうかのフラグ
  bool add_zp;  ///< +zセルを平均値計算に参加させるかどうかのフラグ

  int nAdd;  ///< 平均値計算参加セル数

  /// そのセルを平均値計算に使用するかどうか判定する.
  ///
  ///    @param[in] index セルインデックス
  ///
  bool permitToAdd(FB::Vec3i index) {
    if      (mode == SAMPLING_FLUID_ONLY) return isFluid(index);
    else if (mode == SAMPLING_SOLID_ONLY) return !isFluid(index);
    else return true;  // モードがallの場合はセルのfluid/solidは考慮しない
  }

  /// スカラー変数をサンプリング.
  ///
  ///   @param[in] s サンプリング元スカラー変数配列
  ///
  REAL_TYPE samplingScalar(const REAL_TYPE* s);

public:

  /// コンストラクタ.
  ///
  ///   隣接セルに対して局所平均計算に使用するかどうかのフラグを立てる.
  ///
  ///   @param [in] mode   サンプリングモード
  ///   @param [in] size   ローカルセル数
  ///   @param [in] guide  ガイドセル数
  ///   @param [in] crd    モニタ点座標
  ///   @param [in] org    ローカル領域基点座標
  ///   @param [in] pch    セル幅
  ///   @param [in] v00    座標系移動速度
  ///   @param [in] bcd    BCindex B
  ///
  Smoothing(int mode,
            int size[],
            int guide,
            FB::Vec3r crd,
            FB::Vec3r org,
            FB::Vec3r pch,
            FB::Vec3r v00,
            int* bcd);

  /// デストラクタ.
  ~Smoothing() {}

  /// 速度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVelocity(const REAL_TYPE* v);

  /// 圧力をサンプリング.
  ///
  ///   @param[in] p サンプリング元圧力配列
  ///
  REAL_TYPE samplingPressure(const REAL_TYPE* p) { return samplingScalar(p); }

  /// 温度をサンプリング.
  ///
  ///   @param[in] t サンプリング元温度配列
  ///
  REAL_TYPE samplingTemperature(const REAL_TYPE* t) { return samplingScalar(t); }

  /// 全圧をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///   @param[in] p サンプリング元圧力配列
  ///
  REAL_TYPE samplingTotalPressure(const REAL_TYPE*v, const REAL_TYPE* s);

  /// 渦度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVorticity(const REAL_TYPE* v);

};


/**
 * Interpolationクラス
 *
 *   - モニタ点をはさむ8セルから三重線形補間により計算する．
 *   - モードがfluidで、モニタ点を含むセル以外の7セルのどれかが固体セルの
 *     場合は，Nearest(モニタ点を含むセルの値)によりサンプリング.
 *   - モードがsolidで、モニタ点を含むセル以外の7セルのどれかが流体セルの
 *     場合は，Nearest(モニタ点を含むセルの値)によりサンプリング.
 */
class Interpolation : public Sampling {
protected:
  FB::Vec3i base;       ///< 線形補間基準セルのインデックス
  REAL_TYPE coef[3]; ///< 線形補間係数

  bool onBoundary;  ///< 8セルにモードと違う態(流体/固体)があるかどうかのフラグ

  /// そのセルがモードと違うかどうか調べる.
  bool checkBoundary(FB::Vec3i index) {
    if      (mode == SAMPLING_FLUID_ONLY) return !isFluid(index);
    else if (mode == SAMPLING_SOLID_ONLY) return isFluid(index);
    else return false;  // モードがallの場合はセルのfluid/solidは考慮しない
  }

  /// スカラー変数をサンプリング.
  ///
  ///   @param[in] s サンプリング元スカラー変数配列
  ///
  REAL_TYPE samplingScalar(const REAL_TYPE* s);

public:

  /// コンストラクタ.
  ///
  ///   補間計算の基準セルのインデックスおよび補間係数を計算.
  ///   流体-固体境界に接しているかをチェック.
  ///
  ///   @param [in] mode   サンプリングモード
  ///   @param [in] size   ローカルセル数
  ///   @param [in] guide  ガイドセル数
  ///   @param [in] crd    モニタ点座標
  ///   @param [in] org    ローカル領域基点座標，セル幅
  ///   @param [in] pch    セル幅
  ///   @param [in] v00    座標系移動速度
  ///   @param [in] bcd    BCindex B
  ///
  Interpolation(int mode,
                int size[],
                int guide,
                FB::Vec3r crd,
                FB::Vec3r org,
                FB::Vec3r pch,
                FB::Vec3r v00,
                int* bcd);

  /// デストラクタ.
  ~Interpolation() {}

  /// 速度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVelocity(const REAL_TYPE* v);

  /// 圧力をサンプリング.
  ///
  ///   @param[in] p サンプリング元圧力配列
  ///
  REAL_TYPE samplingPressure(const REAL_TYPE* p) { return samplingScalar(p); }

  /// 温度をサンプリング.
  ///
  ///   @param[in] t サンプリング元温度配列
  ///
  REAL_TYPE samplingTemperature(const REAL_TYPE* t) { return samplingScalar(t); }

  /// 全圧をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///   @param[in] p サンプリング元圧力配列
  ///
  REAL_TYPE samplingTotalPressure(const REAL_TYPE* v, const REAL_TYPE* p);

  /// 渦度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVorticity(const REAL_TYPE* v);
};


/**
 * InterpolationStgVクラス
 *
 *   - スタガード速度配置用の三重線形補間
 *   - Interpolationクラスを継承
 *   - 旧版との比較用(全圧と渦度には未対応)
 */
class InterpolationStgV : public Interpolation {
protected:
  FB::Vec3i base_s;        ///< 線形補間基準セルのインデックス(スタガード配置)
  REAL_TYPE coef_s[3];  ///< 線形補間係数(スタガード配置)

public:

  /// コンストラクタ.
  ///
  ///   @param [in] mode  サンプリングモード
  ///   @param [in] size  ローカルセル数
  ///   @param [in] guide ガイドセル数
  ///   @param [in] crd   モニタ点座標
  ///   @param [in] org   ローカル領域基点座標
  ///   @param [in] pch   セル幅
  ///   @param [in] v00   座標系移動速度
  ///   @param [in] bcd   BCindex B
  ///
  InterpolationStgV(int mode,
                    int size[],
                    int guide,
                    FB::Vec3r crd,
                    FB::Vec3r org,
                    FB::Vec3r pch,
                    FB::Vec3r v00,
                    int* bcd);

  /// デストラクタ.
  ~InterpolationStgV() {}

  /// 速度をサンプリング.
  ///
  ///   @param[in] v サンプリング元速度配列
  ///
  FB::Vec3r samplingVelocity(const REAL_TYPE* v);

};

#endif // _FB_SAMPLING_H_
