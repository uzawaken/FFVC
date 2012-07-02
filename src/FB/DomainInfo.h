#ifndef _FB_DOMAIN_INFO_H_
#define _FB_DOMAIN_INFO_H_

// #################################################################
//
// CAERU Library
//
// Copyright (c) All right reserved. 2012
//
// Institute of Industrial Science, The University of Tokyo, Japan. 
//
// #################################################################

/**
 * @file   DomainInfo.h
 * @brief  FlowBase DomainInfo class Header
 * @author kero
 */

#include "cpm_ParaManager.h"

class DomainInfo {
  
public:
  cpm_ParaManager* paraMngr; ///< Cartesian Partition Manager
  
public:
  int procGrp;         ///< プロセスグループ番号
  int myRank;          ///< 自ノードのランク番号
  int numProc;         ///< 全ランク数
  
  int nID[6];          ///< 隣接ブロックのランク番号
  int head[3];         ///< 開始インデクス（グローバルインデクス, Fortran）
  
  int guide;           ///< ガイドセル数
  int G_div[3];        ///< プロセス分割数
  REAL_TYPE pch[3];    ///< 格子幅 (Non-dimensional)
  
  int size[3];         ///< 領域分割数 (Local, Non-dimensional)
  REAL_TYPE org[3];    ///< 領域基点   (Local, Non-dimensional)
  REAL_TYPE reg[3];    ///< 領域サイズ (Local, Non-dimensional)
  
  int G_size[3];       ///< 領域分割数 (Global, Non-dimensional)
  REAL_TYPE G_org[3];  ///< 領域基点   (Global, Non-dimensional)
  REAL_TYPE G_reg[3];  ///< 領域サイズ (Global, Non-dimensional)

  
public:
  
  /** コンストラクタ */
  DomainInfo() {
    procGrp = 0;
    myRank  = -1;
    numProc = 0;
    for (int i=0; i<6; i++) nID[i] = -1;
    
    for (int i=0; i<3; i++)
    {
      head[i]   = 0;
      size[i]   = 0;
      G_size[i] = 0;
      G_div[i]  = 0;
      pch[i]    = 0.0;
      org[i]    = 0.0;
      reg[i]    = 0.0;
      G_org[i]  = 0.0;
      G_reg[i]  = 0.0;
    }

    guide = 0;
    paraMngr = NULL;
  }
  
  /**　デストラクタ */
  virtual ~DomainInfo() {}
  
public:
  
  /**
   * @brief CPMのポインタをコピーし、ランク情報を設定
   * @param [in] m_paraMngr  cpm_ParaManagerクラス
   * @return  エラーコード
   */
  bool importCPM(cpm_ParaManager* m_paraMngr)
  {
    if ( !m_paraMngr ) return false;
    paraMngr = m_paraMngr;
    
    return true;
  }
  
  /**
   * @brief ランク情報をセットする
   * @param [in] m_paraMngr  CPMlibポインタ
   * @param [in] m_proGrp    プロセスグループ番号
   */
  void setDomainInfo(cpm_ParaManager* m_paraMngr, const int m_procGrp)
  {
    // ポインタコピー
    paraMngr = m_paraMngr;
    
    procGrp = m_procGrp;
    myRank  = paraMngr->GetMyRankID();
    numProc = paraMngr->GetNumRank();
  }
  
  
  /**
   * @brief 隣接情報と領域情報を設定する
   * @note cpm_ParaManager::VoxelInit()のあとにコール
   */
  void setNeighborInfo()
  {
    // 領域分割数 (Local)
    const int* l_sz = paraMngr->GetLocalVoxelSize();
    size[0] = l_sz[0];
    size[1] = l_sz[1];
    size[2] = l_sz[2];
    
    // 領域基点 (Local)
    const REAL_TYPE* l_org = paraMngr->GetLocalOrigin();
    org[0] = l_org[0];
    org[1] = l_org[1];
    org[2] = l_org[2];
    
    // 領域サイズ (Local)
    const REAL_TYPE* l_reg = paraMngr->GetLocalRegion();
    reg[0] = l_reg[0];
    reg[1] = l_reg[1];
    reg[2] = l_reg[2];
    
    // 領域分割数 (Global)
    const int* g_sz  = paraMngr->GetGlobalVoxelSize();
    G_size[0] = g_sz[0];
    G_size[1] = g_sz[1];
    G_size[2] = g_sz[2];
    
    // 領域基点   (Global)
    const REAL_TYPE* g_org = paraMngr->GetGlobalOrigin();
    G_org[0] = g_org[0];
    G_org[1] = g_org[1];
    G_org[2] = g_org[2];
    
    // 領域サイズ (Global)
    const REAL_TYPE* g_reg = paraMngr->GetGlobalRegion();
    G_reg[0] = g_reg[0];
    G_reg[1] = g_reg[1];
    G_reg[2] = g_reg[2];
    
    // 格子幅
    const REAL_TYPE* m_pch = paraMngr->GetPitch();
    pch[0] = m_pch[0];
    pch[1] = m_pch[1];
    pch[2] = m_pch[2];
    
    // プロセス分割数
    const int* g_div = paraMngr->GetDivNum();
    
    // 隣接情報
    const int* neighbour = paraMngr->GetNeighborRankID();
    for (int i=0; i<6; i++)
    {
      nID[i] = neighbour[i];
    }
    
    // 開始インデクス > Fortran index
    const int* hdx = paraMngr->GetVoxelHeadIndex();
    head[0] = hdx[0] + 1;
    head[1] = hdx[1] + 1;
    head[2] = hdx[2] + 1;
  }
  
};

#endif // _FB_DOMAIN_INFO_H_