#ifndef _IP_DUCT_H_
#define _IP_DUCT_H_

// #################################################################
//
// FFV : Frontflow / violet Cartesian
//
// Copyright (c) 2012 All right reserved.
//
// Institute of Industrial Science, The University of Tokyo, Japan. 
//
// #################################################################

/** 
 * @file   IP_Duct.h
 * @brief  IP_Duct class Header
 * @author kero
 */

#include "Intrinsic.h"
#include "IP_Define.h"

class IP_Duct : public Intrinsic {
protected:
  typedef struct {
    unsigned shape;     ///< 形状
    int direction;      ///< 方向
    REAL_TYPE diameter; ///< 直径
    REAL_TYPE length;   ///< 長さ
  } Driver_property;
  
  Driver_property driver;    ///< ドライバの特性
  
  std::string m_fluid;       ///< 流体のラベル
  std::string m_solid;       ///< 固体のラベル
  std::string m_driver;      ///< ドライバ部分のラベル
  std::string m_driver_face; ///< ドライバ指定面のラベル
  
  /** 形状 */
  enum shape_type {
    id_circular = 1,
    id_rectangular
  };
  
public:
  /** コンストラクタ */
  IP_Duct(){
    driver.shape = 0;
    driver.direction = -1;
    driver.diameter = 0.0;
    driver.length = 0.0;
  }
  
  /**　デストラクタ */
  ~IP_Duct() {}

public:
  /** パラメータをロード
   * @param [in] R      Controlクラス
   * @param [in] tpCntl テキストパーサクラス
   * @return true-成功, false-エラー
   */
  virtual bool getTP(Control* R, TPControl* tpCntl);
  
  
  /** 領域を設定する
   * @param [in]     R   Controlクラスのポインタ
   * @param [in]     sz  分割数
   * @param [in,out] org 計算領域の基点
   * @param [in,out] reg 計算領域のbounding boxサイズ
   * @param [in,out] pch セル幅
   */
  virtual void setDomain(Control* R, const int* sz, REAL_TYPE* org, REAL_TYPE* reg, REAL_TYPE* pch);
  
  
  /** Ductの計算領域のセルIDを設定する
   * @param [in,out] mid   媒質情報の配列
   * @param [in]     R     Controlクラスのポインタ
   * @param [in]     G_org グローバルな原点（無次元）
   * @param [in]     Nmax  Controlクラスのポインタ
   * @param [in]     mat   MediumListクラスのポインタ
   */
  virtual void setup(int* mid, Control* R, REAL_TYPE* G_org, const int Nmax, MediumList* mat);
  
  
  /**
   @brief パラメータの表示
   @param [in] fp ファイルポインタ
   @param [in] R  コントロールクラスのポインタ
   */
  virtual void printPara(FILE* fp, const Control* R);
  
  
  /** 
   @brief 例題の名称を返す
   */
  virtual const char* getExampleName() 
  {
    return ("Duct");
  }
};
#endif // _IP_DUCT_H_
