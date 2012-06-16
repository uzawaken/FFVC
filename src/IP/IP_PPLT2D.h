#ifndef _IP_PPLT2D_H_
#define _IP_PPLT2D_H_

/*
 * SPHERE - Skeleton for PHysical and Engineering REsearch
 *
 * Copyright (c) RIKEN, Japan. All right reserved. 2004-2012
 *
 */

//@file IP_PPLT2D.h
//@brief IP_PPLT2D class Header
//@author keno, FSI Team, VCAD, RIKEN

#include "../FB/Intrinsic.h"
#include "IP_Define.h"

class IP_PPLT2D : public Intrinsic {
public:
  std::string m_fluid;
  std::string m_solid;
  
public:
  IP_PPLT2D(){}
  ~IP_PPLT2D() {}
  
protected:

public:
  virtual bool getTP(Control* R, TPControl* tpCntl);
  
  virtual void setDomain(Control* R, unsigned sz[3], REAL_TYPE org[3], REAL_TYPE wth[3], REAL_TYPE pch[3]);
  virtual void setup(int* mid, Control* R, REAL_TYPE* G_org, const int Nmax, IDtable* itbl);
  
  virtual const char* getExampleName(void) {
    return ("Parallel Plate 2D");
  }
};
#endif // _IP_PPLT2D_H_
