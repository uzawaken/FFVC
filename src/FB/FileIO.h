#ifndef _SKL_FB_FILE_IO_H_
#define _SKL_FB_FILE_IO_H_

/*
 * SPHERE - Skeleton for PHysical and Engineering REsearch
 *
 * Copyright (c) RIKEN, Japan. All right reserved. 2004-2012
 *
 */

//@file FileIO.h
//@brief FlowBase FileIO class Header
//@author keno, FSI Team, VCAD, RIKEN

#include "Skl.h"
#include "SklSolverBase.h"
#include "FBDefine.h"
#include "mydebug.h"
#include "SklUtil.h"
#include <fstream>
#include "Parallel_node.h"
#include "fileio/SklSbxDataSet.h"
#include "parallel/SklParaComponent.h"
#include <math.h>
#include <time.h>
#include <fcntl.h>
#include "FBUtility.h"
#include "FB_Ffunc.h"

#ifndef _WIN32
#include <unistd.h>
#include <strings.h>
#else
#include "sph_win32_util.h"
#endif
#include <sys/types.h>

#if defined(IA32_LINUX) || defined(IA64_LINUX) || defined(SGI_ALTIX)
#include <sys/stat.h>
#endif

#ifdef MacOSX
#include <sys/uio.h>
#endif

class FileIO : public Parallel_Node {
  
public:
  FileIO() {}
  ~FileIO() {}
  
protected:
  /// sphファイルのスカラ/ベクトルの種別
  enum sv_type {
    kind_scalar=1,
    kind_vector
  };
  
  void loadSBXfile (SklSolverBase* obj, FILE* fp, const char* name, unsigned* size, unsigned guide, SklScalar3D<unsigned char>* data);
  void loadSBXfile (SklSolverBase* obj, FILE* fp, const char* name, unsigned* size, unsigned guide, SklScalar3D<int>* mid_data, 
                    SklScalar3D<REAL_TYPE>* vol_data = NULL);
  
public:
  void cnv_Div           (SklScalar3D<REAL_TYPE>* dst, const SklScalar3D<REAL_TYPE>* src, const REAL_TYPE coef, REAL_TYPE& flop);
  void cnv_P_D2ND        (SklScalar3D<REAL_TYPE>* dst, const REAL_TYPE Base_prs, const REAL_TYPE Ref_rho, const REAL_TYPE Ref_v, const unsigned mode);
  void cnv_P_ND2D        (SklScalar3D<REAL_TYPE>* dst, const SklScalar3D<REAL_TYPE>* src, 
                          const REAL_TYPE Base_prs, const REAL_TYPE Ref_rho, const REAL_TYPE Ref_v, const unsigned mode, REAL_TYPE& flop);
  void cnv_T_D2ND        (SklScalar3D<REAL_TYPE>* dst, const REAL_TYPE Base_tmp, const REAL_TYPE Diff_tmp, const unsigned Unit);
  void cnv_T_ND2D        (SklScalar3D<REAL_TYPE>* dst, const SklScalar3D<REAL_TYPE>* src, const REAL_TYPE Base_tmp, const REAL_TYPE Diff_tmp, 
                          const unsigned Unit, REAL_TYPE& flop);
  void cnv_TP_ND2D       (SklScalar3D<REAL_TYPE>* dst, const SklScalar3D<REAL_TYPE>* src, const REAL_TYPE Ref_rho, const REAL_TYPE Ref_v, REAL_TYPE& flop);
  void cnv_V_D2ND        (SklVector3DEx<REAL_TYPE>* dst, const REAL_TYPE Ref_v);
  void cnv_V_ND2D        (SklVector3DEx<REAL_TYPE>* dst, const SklVector3DEx<REAL_TYPE>* src, const REAL_TYPE v00[3], const REAL_TYPE Ref_v, 
                          REAL_TYPE& flop, unsigned stepAvr=1);
  void loadSphScalar3D   (SklSolverBase* obj, FILE* fp, const char* fname, const unsigned* size, const unsigned guide, 
                          SklScalar3D<REAL_TYPE>* dc_s, int& step, REAL_TYPE& time, unsigned Dmode);
  void loadSphScalar4D   (SklSolverBase* obj, FILE* fp, const char* fname, const unsigned* size, const unsigned guide, 
                          SklScalar4D<REAL_TYPE>* dc_s, int& step, REAL_TYPE& time, unsigned Dmode);
  void loadSphVector3D   (SklSolverBase* obj, FILE* fp, const char* fname, const unsigned* size, const unsigned guide, 
                          SklVector3DEx<REAL_TYPE>* dc_v, int& step, REAL_TYPE& time, REAL_TYPE *v00, unsigned Dmode);
  void loadSphScalar3DAvr(SklSolverBase* obj, FILE* fp, const char* fname, const unsigned* size, const unsigned guide, 
                          SklScalar3D<REAL_TYPE>* dc_s, int& step, REAL_TYPE& time, unsigned Dmode);
  void loadSphVector3DAvr(SklSolverBase* obj, FILE* fp, const char* fname, const unsigned* size, const unsigned guide, 
                          SklVector3DEx<REAL_TYPE>* dc_v, int& step, REAL_TYPE& time, REAL_TYPE *v00, unsigned Dmode);
  void readSBX           (SklSolverBase* obj, FILE* fp, const char* file_attr, unsigned* size, unsigned guide, 
                          SklScalar3D<unsigned char>* dc_mid);
  void readSBX           (SklSolverBase* obj, FILE* fp, const char* mid_str, unsigned* size, unsigned guide, 
                          SklScalar3D<int>* dc_mid, SklScalar3D<REAL_TYPE>* dc_vol = NULL);
  void readSVX           (SklSolverBase* obj, FILE* fp, const char* fname, unsigned* size, unsigned guide, 
                          SklScalar3D<int>* dc_mid, bool vf_mode=false, SklScalar3D<REAL_TYPE>* dc_ws=NULL);
  void writeRawSPH       (const REAL_TYPE *vf, const unsigned* size, const unsigned gc, const REAL_TYPE* org, const REAL_TYPE* ddx, 
                          const unsigned m_ModePrecision);
  
  bool shiftVin3D  (SklVector3DEx<REAL_TYPE>* dst, const SklVector3DEx<REAL_TYPE>* src, REAL_TYPE v00[3], unsigned stepAvr=1);
  bool shiftVout3D (SklVector3DEx<REAL_TYPE>* dst, const SklVector3DEx<REAL_TYPE>* src, REAL_TYPE v00[3], unsigned stepAvr=1);
  
  /**
   @fn inline void CalcIndex(cosnt unsigned dst_ilen, const unsigned dst_jlen, const unsigned dst_klen, cosnt unsigned dst_gc, const unsigned src_gc, 
   unsigned& dst_ix, unsigned& dst_jx, unsigned& dst_kx, int& diff, unsigned& sta)
   @brief calculation of index, this method is taken from SklUtil class
   @param dst_ilen dimension size /w guide cell for dst
   @param dst_jlen 
   @param dst_klen 
   @param dst_gc size of guide cell
   @param src_gc 
   @param dst_ix return value
   @param dst_jx 
   @param dst_kx 
   @param diff 
   @param sta 
   */
  inline void CalcIndex(const unsigned dst_ilen,
                               const unsigned dst_jlen,
                               const unsigned dst_klen,
                               const unsigned dst_gc,
                               const unsigned src_gc,
                               unsigned& dst_ix,
                               unsigned& dst_jx,
                               unsigned& dst_kx,
                               int& diff,
                               unsigned& sta) {
    diff = src_gc - dst_gc;
    if( src_gc >= dst_gc ){
      sta = 0;
      dst_ix = dst_ilen; dst_jx = dst_jlen; dst_kx = dst_klen;
    }
    else {
      sta = abs(diff);
      dst_ix = dst_ilen+diff; 
      dst_jx = dst_jlen+diff; 
      dst_kx = dst_klen+diff;
    }
  }
  
};
#endif // _SKL_FB_FILE_IO_H_
