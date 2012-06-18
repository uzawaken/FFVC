#ifndef _IP_RECT_H_
#define _IP_RECT_H_

/*
 * SPHERE - Skeleton for PHysical and Engineering REsearch
 *
 * Copyright (c) RIKEN, Japan. All right reserved. 2004-2012
 *
 */

//@file IP_Rect.h
//@brief IP_Rect class Header
//@author keno, FSI Team, VCAD, RIKEN

#include "../FB/Intrinsic.h"
#include "IP_Define.h"

class IP_Rect : public Intrinsic {
protected:
  unsigned even;
  
public:
  std::string m_fluid;
  std::string m_solid;
  
public:
  IP_Rect(){
    even = OFF;
  }
  ~IP_Rect() {}

public:
  virtual bool getTP(Control* R, TPControl* tpCntl);
  
  virtual void setDomain(Control* R, unsigned sz[3], REAL_TYPE org[3], REAL_TYPE wth[3], REAL_TYPE pch[3]);
  virtual void setup(int* mid, Control* R, REAL_TYPE* G_org, const int Nmax, MediumList* mat);
  
  virtual const char* getExampleName(void) {
    return ("Rectangular");
  }
};
#endif // _IP_RECT_H_
