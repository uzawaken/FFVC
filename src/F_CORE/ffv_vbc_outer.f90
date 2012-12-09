!********************************************************************
!
!   FFV : Frontflow / violet Cartesian
!
!   Copyright (c) 2012 All right reserved.
!
!   Institute of Industrial Science, University of Tokyo, Japan. 
!
!********************************************************************

!> @file   ffv_bc_outer.f90
!! @brief  外部境界条件
!! @author kero
!<


!> ********************************************************************
!! @brief 外部速度境界条件による対流項と粘性項の流束の修正
!! @param [out] wv   疑似ベクトルの空間項の評価値
!! @param [in]  sz   配列長
!! @param [in]  g    ガイドセル長
!! @param [in]  dh   格子幅
!! @param [in]  v00  参照速度
!! @param [in]  rei  Reynolds数の逆数
!! @param [in]  v0   セルセンター速度ベクトル（n-step）
!! @param [in]  vf   セルフェイス速度ベクトル（n-step）
!! @param [in]  bv   BCindex V
!! @param [in]  vec  指定する速度ベクトル
!! @param [in]  face 外部境界処理のときの面番号
!! @param [out] flop 浮動小数点演算数
!! @note vecには，流出境界の流束はローカルのセルフェイス速度を使う．vecは使っていない
!<
    subroutine pvec_vobc_oflow (wv, sz, g, dh, v00, rei, v0, vf, bv, vec, face, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, bvx, face
    integer                                                   ::  ix, jx, kx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop
    real                                                      ::  Up0, Ue1, Uw1, Us1, Un1, Ub1, Ut1
    real                                                      ::  Vp0, Ve1, Vw1, Vs1, Vn1, Vb1, Vt1
    real                                                      ::  Wp0, We1, Ww1, Ws1, Wn1, Wb1, Wt1
    real                                                      ::  dh, dh1, dh2, rei
    real                                                      ::  u_bc, v_bc, w_bc, m
    real                                                      ::  fu, fv, fw, c, EX, EY, EZ
    real                                                      ::  w_e, w_w, w_n, w_s, w_t, w_b
    real                                                      ::  Ue, Uw, Vn, Vs, Wt, Wb
    real                                                      ::  b_w, b_e, b_s, b_n, b_b, b_t, b_p
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v0, wv, vf
    real, dimension(0:3)                                      ::  v00
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv
    real, dimension(3)                                        ::  vec
    
    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    
    dh1= 1.0/dh
    dh2= rei*dh1*dh1
    
    ! u_bcは境界速度
    u_bc = vec(1)
    v_bc = vec(2)
    w_bc = vec(3)
    
    flop = flop + 10.0d0 ! DP 15 flops

    m = 0.0
    
!$OMP PARALLEL REDUCTION(+:m) &
!$OMP FIRSTPRIVATE(ix, jx, kx, face) &
!$OMP FIRSTPRIVATE(dh1, dh2) &
!$OMP PRIVATE(i, j, k, bvx) &
!$OMP PRIVATE(Up0, Ue1, Uw1, Us1, Un1, Ub1, Ut1) &
!$OMP PRIVATE(Vp0, Ve1, Vw1, Vs1, Vn1, Vb1, Vt1) &
!$OMP PRIVATE(Wp0, We1, Ww1, Ws1, Wn1, Wb1, Wt1) &
!$OMP PRIVATE(b_w, b_e, b_s, b_n, b_b, b_t, b_p) &
!$OMP PRIVATE(w_e, w_w, w_n, w_s, w_t, w_b) &
!$OMP PRIVATE(Ue, Uw, Vn, Vs, Wt, Wb) &
!$OMP PRIVATE(fu, fv, fw, c, EX, EY, EZ)
    
    FACES : select case (face)
    case (X_minus)
      i = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          include 'd_o_o_p.h' ! 25 flop
          
          Uw1 = v0(i-1,j  ,k  ,1)
          Vw1 = v0(i-1,j  ,k  ,2)
          Ww1 = v0(i-1,j  ,k  ,3)
          c   = Uw
          if ( c>0.0 ) c=0.0
          fu  = c * Up0
          fv  = c * Vp0
          fw  = c * Wp0
          
          EX = Uw1 - Up0
          EY = Vw1 - Vp0
          EZ = Ww1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (X_plus)
      i = ix
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          include 'd_o_o_p.h'
          
          Ue1 = v0(i+1,j  ,k  ,1)
          Ve1 = v0(i+1,j  ,k  ,2)
          We1 = v0(i+1,j  ,k  ,3)
          c   = Ue
          if ( c<0.0 ) c=0.0
          fu  = c * Up0
          fv  = c * Vp0
          fw  = c * Wp0

          EX = Ue1 - Up0
          EY = Ve1 - Vp0
          EZ = We1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Y_minus)
      j = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
            
          include 'd_o_o_p.h'
          
          Us1 = v0(i  ,j-1,k  ,1)
          Vs1 = v0(i  ,j-1,k  ,2)
          Ws1 = v0(i  ,j-1,k  ,3)
          c   = Vs
          if ( c>0.0 ) c=0.0
          fu  = c * Up0
          fv  = c * Vp0
          fw  = c * Wp0
        
          EX = Us1 - Up0
          EY = Vs1 - Vp0
          EZ = Ws1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Y_plus)
      j = jx
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
            
          include 'd_o_o_p.h'
            
          Un1 = v0(i  ,j+1,k  ,1)
          Vn1 = v0(i  ,j+1,k  ,2)
          Wn1 = v0(i  ,j+1,k  ,3)
          c   = Vn
          if ( c<0.0 ) c=0.0
          fu  = c * Up0
          fv  = c * Vp0
          fw  = c * Wp0

          EX = Un1 - Up0
          EY = Vn1 - Vp0
          EZ = Wn1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Z_minus)
      k = 1

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          include 'd_o_o_p.h'
          
          Ub1 = v0(i  ,j  ,k-1,1)
          Vb1 = v0(i  ,j  ,k-1,2)
          Wb1 = v0(i  ,j  ,k-1,3)
          c   = Wb
          if ( c>0.0 ) c=0.0
          fu  = c * Up0
          fv  = c * Vp0
          fw  = c * Wp0
          
          EX = Ub1 - Up0
          EY = Vb1 - Vp0
          EZ = Wb1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Z_plus)
      k = kx
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          include 'd_o_o_p.h'
          
          Ut1 = v0(i  ,j  ,k+1,1)
          Vt1 = v0(i  ,j  ,k+1,2)
          Wt1 = v0(i  ,j  ,k+1,3)
          c   = Wt
          if ( c<0.0 ) c=0.0
          fu  = c * Up0
          fv  = c * Vp0
          fw  = c * Wp0
          
          EX = Ut1 - Up0
          EY = Vt1 - Vp0
          EZ = Wt1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case default
    end select FACES
    
!$OMP END PARALLEL

    flop = flop + dble(m)*42.0d0
      
    return
    end subroutine pvec_vobc_oflow
    
!> ********************************************************************
!! @brief 外部速度境界条件による対流項と粘性項の流束の修正
!! @param [out] wv   疑似ベクトルの空間項の評価値
!! @param [in]  sz   配列長
!! @param [in]  g    ガイドセル長
!! @param [in]  dh   格子幅
!! @param [in]  v00  参照速度
!! @param [in]  rei  Reynolds数の逆数
!! @param [in]  v0   速度ベクトル（n-step）
!! @param [in]  bv   BCindex V
!! @param [in]  vec  指定する速度ベクトル
!! @param [in]  face 外部境界処理のときの面番号
!! @param [out] flop 浮動小数点演算数
!! @note vecには，流入条件のとき指定速度
!<
    subroutine pvec_vobc_specv (wv, sz, g, dh, v00, rei, v0, bv, vec, face, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, bvx, face
    integer                                                   ::  ix, jx, kx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop
    real                                                      ::  Up0, Ue1, Uw1, Us1, Un1, Ub1, Ut1
    real                                                      ::  Vp0, Ve1, Vw1, Vs1, Vn1, Vb1, Vt1
    real                                                      ::  Wp0, We1, Ww1, Ws1, Wn1, Wb1, Wt1
    real                                                      ::  dh, dh1, dh2, EX, EY, EZ, rei
    real                                                      ::  u_ref, v_ref, w_ref, m
    real                                                      ::  fu, fv, fw, c, ac
    real                                                      ::  u_bc, v_bc, w_bc, u_bc_ref, v_bc_ref, w_bc_ref
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v0, wv
    real, dimension(0:3)                                      ::  v00
    real, dimension(3)                                        ::  vec
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv
    
    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    
    dh1= 1.0/dh
    dh2= rei*dh1*dh1

    ! 参照座標系の速度
    u_ref = v00(1)
    v_ref = v00(2)
    w_ref = v00(3)
    
    ! u_bcは境界速度
    u_bc = vec(1)
    v_bc = vec(2)
    w_bc = vec(3)
    
    ! u_bc_refは参照座標系での境界速度
    u_bc_ref = u_bc + u_ref
    v_bc_ref = v_bc + v_ref
    w_bc_ref = w_bc + w_ref
    
    flop = flop + 13.0d0 ! DP 18 flop

    m = 0.0
    
!$OMP PARALLEL REDUCTION(+:m) &
!$OMP FIRSTPRIVATE(ix, jx, kx, u_bc_ref, v_bc_ref, w_bc_ref, face) &
!$OMP FIRSTPRIVATE(dh1, dh2, u_bc, v_bc, w_bc) &
!$OMP PRIVATE(i, j, k, bvx) &
!$OMP PRIVATE(Up0, Ue1, Uw1, Us1, Un1, Ub1, Ut1) &
!$OMP PRIVATE(Vp0, Ve1, Vw1, Vs1, Vn1, Vb1, Vt1) &
!$OMP PRIVATE(Wp0, We1, Ww1, Ws1, Wn1, Wb1, Wt1) &
!$OMP PRIVATE(fu, fv, fw, EX, EY, EZ, c, ac)

    FACES : select case (face)
    case (X_minus)
      i = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Uw1 = u_bc_ref
          Vw1 = v_bc_ref
          Ww1 = w_bc_ref
          c   = u_bc
          ac  = abs(c)
          fu  = 0.5*(c*(Up0+Uw1) - ac*(Up0-Uw1))
          fv  = 0.5*(c*(Vp0+Vw1) - ac*(Vp0-Vw1))
          fw  = 0.5*(c*(Wp0+Ww1) - ac*(Wp0-Ww1))
          
          EX = Uw1 - Up0
          EY = Vw1 - Vp0
          EZ = Ww1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + ( fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (X_plus)
      i = ix
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then ! 方向によって実装が異なるのでチェック
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Ue1 = u_bc_ref
          Ve1 = v_bc_ref
          We1 = w_bc_ref
          c   = u_bc
          ac  = abs(c)
          fu  = 0.5*(c*(Ue1+Up0) - ac*(Ue1-Up0))
          fv  = 0.5*(c*(Ve1+Vp0) - ac*(Ve1-Vp0))
          fw  = 0.5*(c*(We1+Wp0) - ac*(We1-Wp0))

          EX = Ue1 - Up0
          EY = Ve1 - Vp0
          EZ = We1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Y_minus)
      j = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Us1 = u_bc_ref
          Vs1 = v_bc_ref
          Ws1 = w_bc_ref
          c   = v_bc
          ac  = abs(c)
          fu  = 0.5*(c*(Up0+Us1) - ac*(Up0-Us1))
          fv  = 0.5*(c*(Vp0+Vs1) - ac*(Vp0-Vs1))
          fw  = 0.5*(c*(Wp0+Ws1) - ac*(Wp0-Ws1))
        
          EX = Us1 - Up0
          EY = Vs1 - Vp0
          EZ = Ws1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Y_plus)
      j = jx
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Un1 = u_bc_ref
          Vn1 = v_bc_ref
          Wn1 = w_bc_ref
          c   = v_bc
          ac  = abs(c)
          fu  = 0.5*(c*(Un1+Up0) - ac*(Un1-Up0))
          fv  = 0.5*(c*(Vn1+Vp0) - ac*(Vn1-Vp0))
          fw  = 0.5*(c*(Wn1+Wp0) - ac*(Wn1-Wp0))

          EX = Un1 - Up0
          EY = Vn1 - Vp0
          EZ = Wn1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO

      
    case (Z_minus)
      k = 1
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Ub1 = u_bc_ref
          Vb1 = v_bc_ref
          Wb1 = w_bc_ref
          c   = w_bc
          ac  = abs(c)
          fu  = 0.5*(c*(Up0+Ub1) - ac*(Up0-Ub1))
          fv  = 0.5*(c*(Vp0+Vb1) - ac*(Vp0-Vb1))
          fw  = 0.5*(c*(Wp0+Wb1) - ac*(Wp0-Wb1))
          
          EX = Ub1 - Up0
          EY = Vb1 - Vp0
          EZ = Wb1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
    case (Z_plus)
      k = kx
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Ut1 = u_bc_ref
          Vt1 = v_bc_ref
          Wt1 = w_bc_ref
          c   = w_bc
          ac  = abs(c)
          fu  = 0.5*(c*(Ut1+Up0) - ac*(Ut1-Up0))
          fv  = 0.5*(c*(Vt1+Vp0) - ac*(Vt1-Vp0))
          fw  = 0.5*(c*(Wt1+Wp0) - ac*(Wt1-Wp0))
          
          EX = Ut1 - Up0
          EY = Vt1 - Vp0
          EZ = Wt1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + ( -fu*dh1 + EX*dh2 )
          wv(i,j,k,2) = wv(i,j,k,2) + ( -fv*dh1 + EY*dh2 )
          wv(i,j,k,3) = wv(i,j,k,3) + ( -fw*dh1 + EZ*dh2 )
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
    case default
    end select FACES
    
!$OMP END PARALLEL

    flop = flop + dble(m)*34.0d0
    
    return
    end subroutine pvec_vobc_specv
    
!> ********************************************************************
!! @brief 外部速度境界条件による対流項と粘性項の流束の修正
!! @param [out] wv   疑似ベクトルの空間項の評価値
!! @param [in]  sz   配列長
!! @param [in]  g    ガイドセル長
!! @param [in]  dh   格子幅
!! @param [in]  rei  Reynolds数の逆数
!! @param [in]  v0   速度ベクトル（n-step）
!! @param [in]  bv   BCindex V
!! @param [in]  face 外部境界処理のときの面番号
!! @param [out] flop 浮動小数点演算数
!! @note 境界面で対流流束はゼロ，粘性流束のみ
!<
    subroutine pvec_vobc_symtrc (wv, sz, g, dh, rei, v0, bv, face, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, bvx, face
    integer                                                   ::  ix, jx, kx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop, rix, rjx, rkx
    real                                                      ::  dh, dh1, dh2, rei
    real                                                      ::  Up0, Vp0, Wp0
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v0, wv
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv
    
    ix = sz(1)
    jx = sz(2)
    kx = sz(3)

    rix = dble(jx)*dble(kx)
    rjx = dble(ix)*dble(kx)
    rkx = dble(ix)*dble(jx)
    
    dh1= 1.0/dh
    dh2= 2.0*rei*dh1*dh1
    
    flop = flop + 14.0d0 ! DP 19 flop

!$OMP PARALLEL REDUCTION(+:flop) &
!$OMP FIRSTPRIVATE(ix, jx, kx, dh2, face) &
!$OMP PRIVATE(i, j, k, bvx, Up0, Vp0, Wp0)
    
    FACES : select case (face)
    
    case (X_minus)
      i = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          wv(i,j,k,1) = wv(i,j,k,1) + Up0*dh2
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rix*2.0d0
      

    case (X_plus)
      i = ix
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          wv(i,j,k,1) = wv(i,j,k,1) - Up0*dh2
        endif
      end do
      end do
!$OMP END DO
    
      flop = flop + rix*2.0d0
      

    case (Y_minus)
      j = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          Vp0 = v0(i,j,k,2)
          wv(i,j,k,2) = wv(i,j,k,2) + Vp0*dh2
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*2.0d0
      

    case (Y_plus)
      j = jx
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          Vp0 = v0(i,j,k,2)
          wv(i,j,k,2) = wv(i,j,k,2) - Vp0*dh2
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*2.0d0
      

    case (Z_minus)
      k = 1
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          Wp0 = v0(i,j,k,3)
          wv(i,j,k,3) = wv(i,j,k,3) + Wp0*dh2
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rkx*2.0d0
      

    case (Z_plus)
      k = kx
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          Wp0 = v0(i,j,k,3)
          wv(i,j,k,3) = wv(i,j,k,3) - Wp0*dh2
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rkx*2.0d0
      

    case default
    end select FACES
    
!$OMP END PARALLEL

    return
    end subroutine pvec_vobc_symtrc
    
!> ********************************************************************
!! @brief 外部速度境界条件による対流項と粘性項の流束の修正
!! @param [out] wv   疑似ベクトルの空間項の評価値
!! @param [in]  sz   配列長
!! @param [in]  g    ガイドセル長
!! @param [in]  dh   格子幅
!! @param [in]  v00  参照速度
!! @param [in]  rei  Reynolds数の逆数
!! @param [in]  v0   速度ベクトル（n-step）
!! @param [in]  bv   BCindex V
!! @param [in]  vec  指定する速度ベクトル
!! @param [in]  face 外部境界処理のときの面番号
!! @param [out] flop 浮動小数点演算数
!! @todo 内部と外部の分離 do loopの内側に条件分岐を入れているので修正
!<
    subroutine pvec_vobc_wall (wv, sz, g, dh, v00, rei, v0, bv, vec, face, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, bvx, face
    integer                                                   ::  ix, jx, kx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop
    real                                                      ::  Up0, Ue1, Uw1, Us1, Un1, Ub1, Ut1
    real                                                      ::  Vp0, Ve1, Vw1, Vs1, Vn1, Vb1, Vt1
    real                                                      ::  Wp0, We1, Ww1, Ws1, Wn1, Wb1, Wt1
    real                                                      ::  dh, dh1, dh2, EX, EY, EZ, rei
    real                                                      ::  u_ref, v_ref, w_ref, m
    real                                                      ::  u_bc, v_bc, w_bc, u_bc_ref, v_bc_ref, w_bc_ref
    real                                                      ::  u_bc_ref2, v_bc_ref2, w_bc_ref2
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v0, wv
    real, dimension(0:3)                                      ::  v00
    real, dimension(3)                                        ::  vec
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv
    
    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    
    dh1= 1.0/dh
    dh2= rei*dh1*dh1

    ! 参照座標系の速度
    u_ref = v00(1)
    v_ref = v00(2)
    w_ref = v00(3)
    
    ! u_bcは境界速度
    u_bc = vec(1)
    v_bc = vec(2)
    w_bc = vec(3)
    
    ! u_bc_refは参照座標系での境界速度
    u_bc_ref = u_bc + u_ref
    v_bc_ref = v_bc + v_ref
    w_bc_ref = w_bc + w_ref
    
    u_bc_ref2 = 2.0*u_bc_ref
    v_bc_ref2 = 2.0*v_bc_ref
    w_bc_ref2 = 2.0*w_bc_ref
    
    flop = flop + 16.0d0 ! DP 21 flops

    m = 0.0

!$OMP PARALLEL REDUCTION(+:m) &
!$OMP FIRSTPRIVATE(ix, jx, kx, u_bc_ref2, v_bc_ref2, w_bc_ref2, dh2, face) &
!$OMP PRIVATE(i, j, k, bvx, Up0, Vp0, Wp0, EX, EY, EZ) &
!$OMP PRIVATE(Ue1, Uw1, Us1, Un1, Ub1, Ut1) &
!$OMP PRIVATE(Ve1, Vw1, Vs1, Vn1, Vb1, Vt1) &
!$OMP PRIVATE(We1, Ww1, Ws1, Wn1, Wb1, Wt1)

    FACES : select case (face)
    
    case (X_minus)
      i = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)
          
          Uw1  = u_bc_ref2 - Up0
          Vw1  = v_bc_ref2 - Vp0
          Ww1  = w_bc_ref2 - Wp0
          
          EX = Uw1 - Up0
          EY = Vw1 - Vp0
          EZ = Ww1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + EX*dh2
          wv(i,j,k,2) = wv(i,j,k,2) + EY*dh2
          wv(i,j,k,3) = wv(i,j,k,3) + EZ*dh2
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (X_plus)
      i = ix

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          Ue1  = u_bc_ref2 - Up0
          Ve1  = v_bc_ref2 - Vp0
          We1  = w_bc_ref2 - Wp0

          EX = Ue1 - Up0
          EY = Ve1 - Vp0
          EZ = We1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + EX*dh2
          wv(i,j,k,2) = wv(i,j,k,2) + EY*dh2
          wv(i,j,k,3) = wv(i,j,k,3) + EZ*dh2
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Y_minus)
      j = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          Us1  = u_bc_ref2 - Up0
          Vs1  = v_bc_ref2 - Vp0
          Ws1  = w_bc_ref2 - Wp0
        
          EX = Us1 - Up0
          EY = Vs1 - Vp0
          EZ = Ws1 - Wp0

          wv(i,j,k,1) = wv(i,j,k,1) + EX*dh2
          wv(i,j,k,2) = wv(i,j,k,2) + EY*dh2
          wv(i,j,k,3) = wv(i,j,k,3) + EZ*dh2
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Y_plus)
      j = jx

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          Un1  = u_bc_ref2 - Up0
          Vn1  = v_bc_ref2 - Vp0
          Wn1  = w_bc_ref2 - Wp0

          EX = Un1 - Up0
          EY = Vn1 - Vp0
          EZ = Wn1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + EX*dh2
          wv(i,j,k,2) = wv(i,j,k,2) + EY*dh2
          wv(i,j,k,3) = wv(i,j,k,3) + EZ*dh2
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Z_minus)
      k = 1

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          Ub1  = u_bc_ref2 - Up0
          Vb1  = v_bc_ref2 - Vp0
          Wb1  = w_bc_ref2 - Wp0
          
          EX = Ub1 - Up0
          EY = Vb1 - Vp0
          EZ = Wb1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + EX*dh2
          wv(i,j,k,2) = wv(i,j,k,2) + EY*dh2
          wv(i,j,k,3) = wv(i,j,k,3) + EZ*dh2
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Z_plus)
      k = kx

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          Up0 = v0(i,j,k,1)
          Vp0 = v0(i,j,k,2)
          Wp0 = v0(i,j,k,3)

          Ut1  = u_bc_ref2 - Up0
          Vt1  = v_bc_ref2 - Vp0
          Wt1  = w_bc_ref2 - Wp0
          
          EX = Ut1 - Up0
          EY = Vt1 - Vp0
          EZ = Wt1 - Wp0
          
          wv(i,j,k,1) = wv(i,j,k,1) + EX*dh2
          wv(i,j,k,2) = wv(i,j,k,2) + EY*dh2
          wv(i,j,k,3) = wv(i,j,k,3) + EZ*dh2
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
  
    case default
    end select FACES
    
!$OMP END PARALLEL

    flop = flop + dble(m)*12.0d0
    
    return
    end subroutine pvec_vobc_wall


!> ********************************************************************
!! @brief ガイドセルの速度指定境界条件を設定するために必要な参照値をセットする
!! @param[out] v セルセンタ速度
!! @param sz 配列長
!! @param g ガイドセル長
!! @param v00 参照速度
!! @param bv BCindex V
!! @param face 外部境界の面番号
!! @param vec 指定する速度ベクトル
!! @note 流束型の境界条件を用いるので，内点の計算に使う参照点に値があればよい（1層）
!<
    subroutine vobc_drchlt (v, sz, g, bv, face, vec)
    implicit none
    include 'ffv_f_params.h'
    integer                                                     ::  i, j, k, g, face, ix, jx, kx, bvx
    integer, dimension(3)                                       ::  sz
    real                                                        ::  u_bc_ref, v_bc_ref, w_bc_ref
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3)   ::  v
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)   ::  bv
    real, dimension(3)                                          ::  vec

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    
    ! u_bc_refは境界速度
    u_bc_ref = vec(1)
    v_bc_ref = vec(2)
    w_bc_ref = vec(3)
    
!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, u_bc_ref, v_bc_ref, w_bc_ref, face) &
!$OMP PRIVATE(i, j, k, bvx)

    FACES : select case (face)
    
    case (X_minus)
      i = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          v(i-1, j, k, 1) = u_bc_ref
          v(i-1, j, k, 2) = v_bc_ref
          v(i-1, j, k, 3) = w_bc_ref
        endif
      end do
      end do
!$OMP END DO
      
      
    case (X_plus)
      i = ix

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
          v(i+1, j, k, 1) = u_bc_ref
          v(i+1, j, k, 2) = v_bc_ref
          v(i+1, j, k, 3) = w_bc_ref
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Y_minus)
      j = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          v(i, j-1, k, 1) = u_bc_ref
          v(i, j-1, k, 2) = v_bc_ref
          v(i, j-1, k, 3) = w_bc_ref
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Y_plus)
      j = jx

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          v(i, j+1, k, 1) = u_bc_ref
          v(i, j+1, k, 2) = v_bc_ref
          v(i, j+1, k, 3) = w_bc_ref
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Z_minus)
      k = 1

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          v(i, j, k-1, 1) = u_bc_ref
          v(i, j, k-1, 2) = v_bc_ref
          v(i, j, k-1, 3) = w_bc_ref
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Z_plus)
      k = kx

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          v(i, j, k+1, 1) = u_bc_ref
          v(i, j, k+1, 2) = v_bc_ref
          v(i, j, k+1, 3) = w_bc_ref
        endif
      end do
      end do
!$OMP END DO
      
    case default
    end select FACES

!$OMP END PARALLEL
    
    return
    end subroutine vobc_drchlt

!> ********************************************************************
!! @brief 遠方境界の近似
!! @param v 速度ベクトル
!! @param sz 配列長
!! @param g ガイドセル長
!! @param face 外部境界面の番号
!<
    subroutine vobc_neumann (v, sz, g, face)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, ix, jx, kx, face, g
    integer, dimension(3)                                     ::  sz
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, g, face) &
!$OMP PRIVATE(i, j, k)

    FACES : select case (face)
    case (X_minus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        v(0, j, k, 1) = v(1, j, k, 1)
        v(0, j, k, 2) = v(1, j, k, 2)
        v(0, j, k, 3) = v(1, j, k, 3)
      end do
      end do
!$OMP END DO
      

    case (X_plus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        v(ix+1, j, k, 1) = v(ix, j, k, 1)
        v(ix+1, j, k, 2) = v(ix, j, k, 2)
        v(ix+1, j, k, 3) = v(ix, j, k, 3)
      end do
      end do
!$OMP END DO
      

    case (Y_minus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        v(i, 0, k, 1) = v(i, 1, k, 1)
        v(i, 0, k, 2) = v(i, 1, k, 2)
        v(i, 0, k, 3) = v(i, 1, k, 3)
      end do
      end do
!$OMP END DO
      

    case (Y_plus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix      
        v(i, jx+1, k, 1) = v(i, jx, k, 1)
        v(i, jx+1, k, 2) = v(i, jx, k, 2)
        v(i, jx+1, k, 3) = v(i, jx, k, 3)
      end do
      end do
!$OMP END DO
      

    case (Z_minus)

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        v(i, j, 0, 1) = v(i, j, 1, 1)
        v(i, j, 0, 2) = v(i, j, 1, 2)
        v(i, j, 0, 3) = v(i, j, 1, 3)
      end do
      end do
!$OMP END DO
      

    case (Z_plus)

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        v(i, j, kx+1, 1) = v(i, j, kx, 1)
        v(i, j, kx+1, 2) = v(i, j, kx, 2)
        v(i, j, kx+1, 3) = v(i, j, kx, 3)
      end do
      end do
!$OMP END DO


    case default
    end select FACES

!$OMP END PARALLEL

    return 
    end subroutine vobc_neumann

!> ********************************************************************
!! @brief 外部流出境界で，次ステップの流出速度を対流流出条件で予測し，ガイドセルに参照値として代入する
!! @param [out]    v    速度 u^*
!! @param [in]     sz   配列長
!! @param [in]     g    ガイドセル長
!! @param [in]     c    uc*dt/dh
!! @param [in]     bv   BCindex V
!! @param [in]     face 外部境界の面番号
!! @param [in]     v0   セルセンタ速度 u^n
!! @param [in,out] flop 浮動小数点演算数
!<
    subroutine vobc_outflow (v, sz, g, c, bv, face, v0, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, idx, face, ix, jx, kx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop, rix, rjx, rkx
    real                                                      ::  Ue, Uw, Un, Us, Ut, Ub
    real                                                      ::  Ve, Vw, Vn, Vs, Vt, Vb
    real                                                      ::  We, Ww, Wn, Ws, Wt, Wb
    real                                                      ::  c
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v, v0
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    rix = dble(jx)*dble(kx)
    rjx = dble(ix)*dble(kx)
    rkx = dble(ix)*dble(jx)
    
!$OMP PARALLEL REDUCTION(+:flop) &
!$OMP FIRSTPRIVATE(ix, jx, kx, face, c) &
!$OMP PRIVATE(i, j, k, idx) &
!$OMP PRIVATE(Ue, Uw, Un, Us, Ut, Ub) &
!$OMP PRIVATE(Ve, Vw, Vn, Vs, Vt, Vb) &
!$OMP PRIVATE(We, Ww, Wn, Ws, Wt, Wb)
    
    FACES : select case (face)
    case (X_minus)
      if ( c>0.0 ) c=0.0
      i = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        idx = bv(i,j,k)
        if ( ibits(idx, bc_face_W, bitw_5) == obc_mask ) then
          Uw = v0(i-1,j  ,k  , 1)
          Ue = v0(i  ,j  ,k  , 1)
          Vw = v0(i-1,j  ,k  , 2)
          Ve = v0(i  ,j  ,k  , 2)
          Ww = v0(i-1,j  ,k  , 3)
          We = v0(i  ,j  ,k  , 3)

          v(i-1, j  ,k  , 1) = Uw - c*(Ue-Uw)
          v(i-1, j  ,k  , 2) = Vw - c*(Ve-Vw)
          v(i-1, j  ,k  , 3) = Ww - c*(We-Ww)
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rix*9.0d0
      
      
    case (X_plus)
      if ( c<0.0 ) c=0.0
      i = ix
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        idx = bv(i,j,k)
        if ( ibits(idx, bc_face_E, bitw_5) == obc_mask ) then
          Uw = v0(i  ,j  ,k  , 1)
          Ue = v0(i+1,j  ,k  , 1)
          Vw = v0(i  ,j  ,k  , 2)
          Ve = v0(i+1,j  ,k  , 2)
          Ww = v0(i  ,j  ,k  , 3)
          We = v0(i+1,j  ,k  , 3)
          
          v(i+1, j  ,k  , 1) = Ue - c*(Ue-Uw)
          v(i+1, j  ,k  , 2) = Ve - c*(Ve-Vw)
          v(i+1, j  ,k  , 3) = We - c*(We-Ww)
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rix*9.0d0
      
      
    case (Y_minus)
    if ( c>0.0 ) c=0.0
      j = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        idx = bv(i,j,k)
        if ( ibits(idx, bc_face_S, bitw_5) == obc_mask ) then
          Us = v0(i  ,j-1,k  , 1)
          Un = v0(i  ,j  ,k  , 1)
          Vs = v0(i  ,j-1,k  , 2)
          Vn = v0(i  ,j  ,k  , 2)
          Ws = v0(i  ,j-1,k  , 3)
          Wn = v0(i  ,j  ,k  , 3)

          v(i  ,j-1, k  , 1) = Us - c*(Un-Us)
          v(i  ,j-1, k  , 2) = Vs - c*(Vn-Vs)
          v(i  ,j-1, k  , 3) = Ws - c*(Wn-Ws)
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*9.0d0
      
      
    case (Y_plus)
      if ( c<0.0 ) c=0.0
      j = jx
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        idx = bv(i,j,k)
        if ( ibits(idx, bc_face_N, bitw_5) == obc_mask ) then
          Us = v0(i  ,j  ,k  , 1)
          Un = v0(i  ,j+1,k  , 1)
          Vs = v0(i  ,j  ,k  , 2)
          Vn = v0(i  ,j+1,k  , 2)
          Ws = v0(i  ,j  ,k  , 3)
          Wn = v0(i  ,j+1,k  , 3)

          v(i  ,j+1, k  , 1) = Un - c*(Un-Us)
          v(i  ,j+1, k  , 2) = Vn - c*(Vn-Vs)
          v(i  ,j+1, k  , 3) = Wn - c*(Wn-Ws)
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*9.0d0
      
      
    case (Z_minus)
    if ( c>0.0 ) c=0.0
      k = 1
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        idx = bv(i,j,k)
        if ( ibits(idx, bc_face_B, bitw_5) == obc_mask ) then
          Ub = v0(i  ,j  ,k-1, 1)
          Ut = v0(i  ,j  ,k  , 1)
          Vb = v0(i  ,j  ,k-1, 2)
          Vt = v0(i  ,j  ,k  , 2)
          Wb = v0(i  ,j  ,k-1, 3)
          Wt = v0(i  ,j  ,k  , 3)

          v(i  ,j  , k-1, 1) = Ub - c*(Ut-Ub)
          v(i  ,j  , k-1, 2) = Vb - c*(Vt-Vb)
          v(i  ,j  , k-1, 3) = Wb - c*(Wt-Wb)
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rkx*9.0d0
      
      
    case (Z_plus)
      if ( c<0.0 ) c=0.0
      k = kx
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        idx = bv(i,j,k)
        if ( ibits(idx, bc_face_T, bitw_5) == obc_mask ) then
          Ub = v0(i  ,j  ,k  , 1)
          Ut = v0(i  ,j  ,k+1, 1)
          Vb = v0(i  ,j  ,k  , 2)
          Vt = v0(i  ,j  ,k+1, 2)
          Wb = v0(i  ,j  ,k  , 3)
          Wt = v0(i  ,j  ,k+1, 3)

          v(i  ,j  , k+1, 1) = Ut - c*(Ut-Ub)
          v(i  ,j  , k+1, 2) = Vt - c*(Vt-Vb)
          v(i  ,j  , k+1, 3) = Wt - c*(Wt-Wb)
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rkx*9.0d0
      
    case default
    end select FACES
    
!$OMP END PARALLEL
    
    return
    end subroutine vobc_outflow

!> ********************************************************************
!! @brief 速度の外部境界：　トラクションフリー
!! @param v 速度ベクトル
!! @param sz 配列長
!! @param g ガイドセル長
!! @param face 外部境界面の番号
!! @param flop 浮動小数演算数
!! @note トラクションフリー面は全て流体のこと
!<
    subroutine vobc_tfree (v, sz, g, face, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, ix, jx, kx, face, g, ii, jj, kk
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop, rix, rjx, rkx
    real                                                      ::  v1, v2, v3, v4
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  v

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    rix = dble(jx)*dble(kx)
    rjx = dble(ix)*dble(kx)
    rkx = dble(ix)*dble(jx)

!$OMP PARALLEL REDUCTION(+:flop) &
!$OMP FIRSTPRIVATE(ix, jx, kx, rix, rjx, rkx, g, face) &
!$OMP PRIVATE(i, j, k, ii, jj, kk, v1, v2, v3, v4)

    FACES : select case (face)
    case (X_minus)
      i = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx

        v1 = 0.5 * (v(i-1, j+1, k  , 1) + v(i, j+1, k  , 1))
        v2 = 0.5 * (v(i-1, j-1, k  , 1) + v(i, j-1, k  , 1))
        v3 = 0.5 * (v(i-1, j  , k+1, 1) + v(i, j  , k+1, 1))
        v4 = 0.5 * (v(i-1, j  , k-1, 1) + v(i, j  , k-1, 1))

        v(i-1, j, k, 1) = v(i, j, k, 1)
        v(i-1, j, k, 2) = v(i, j, k, 2) + 0.5 * (v1 - v2)
        v(i-1, j, k, 3) = v(i, j, k, 3) + 0.5 * (v3 - v4)

      end do
      end do
!$OMP END DO
      
      flop = flop + rix*12.0d0
      

    case (X_plus)
      i = ix

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx

        v1 = 0.5 * (v(i+1, j+1, k  , 1) + v(i, j+1, k  , 1))
        v2 = 0.5 * (v(i+1, j-1, k  , 1) + v(i, j-1, k  , 1))
        v3 = 0.5 * (v(i+1, j  , k+1, 1) + v(i, j  , k+1, 1))
        v4 = 0.5 * (v(i+1, j  , k-1, 1) + v(i, j  , k-1, 1))
        
        v(i+1, j, k, 1) = v(i, j, k, 1)
        v(i+1, j, k, 2) = v(i, j, k, 2) - 0.5 * (v1 - v2)
        v(i+1, j, k, 3) = v(i, j, k, 3) - 0.5 * (v3 - v4)

      end do
      end do
!$OMP END DO
      
      flop = flop + rix*12.0d0
      

    case (Y_minus)
      j = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix

        v1 = 0.5 * (v(i+1, j-1, k  , 2) + v(i+1, j, k  , 2))
        v2 = 0.5 * (v(i-1, j-1, k  , 2) + v(i-1, j, k  , 2))
        v3 = 0.5 * (v(i  , j-1, k+1, 2) + v(i  , j, k+1, 2))
        v4 = 0.5 * (v(i  , j-1, k-1, 2) + v(i  , j, k-1, 2))
                
        v(i, j-1, k, 1) = v(i, j, k, 1) + 0.5 * (v1 - v2)
        v(i, j-1, k, 2) = v(i, j, k, 2)
        v(i, j-1, k, 3) = v(i, j, k, 3) + 0.5 * (v3 - v4)

      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*12.0d0
      

    case (Y_plus)
      j = jx

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix

        v1 = 0.5 * (v(i+1, j+1, k  , 2) + v(i+1, j, k  , 2))
        v2 = 0.5 * (v(i-1, j+1, k  , 2) + v(i-1, j, k  , 2))
        v3 = 0.5 * (v(i  , j+1, k+1, 2) + v(i  , j, k+1, 2))
        v4 = 0.5 * (v(i  , j+1, k-1, 2) + v(i  , j, k-1, 2))
                
        v(i, j+1, k, 1) = v(i, j, k, 1) - 0.5 * (v1 - v2)
        v(i, j+1, k, 2) = v(i, j, k, 2)
        v(i, j+1, k, 3) = v(i, j, k, 3) - 0.5 * (v3 - v4)

      end do
      end do
!$OMP END DO

      flop = flop + rjx*12.0d0
      

    case (Z_minus)
      k=1
      
!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix

        v1 = 0.5 * (v(i+1, j  , k-1, 3) + v(i+1, j  , k, 3))
        v2 = 0.5 * (v(i-1, j  , k-1, 3) + v(i-1, j  , k, 3))
        v3 = 0.5 * (v(i  , j+1, k-1, 3) + v(i  , j+1, k, 3))
        v4 = 0.5 * (v(i  , j-1, k-1, 3) + v(i  , j-1, k, 3))
                
        v(i, j, k-1, 1) = v(i, j, k, 1) + 0.5 * (v1 - v2)
        v(i, j, k-1, 2) = v(i, j, k, 2) + 0.5 * (v3 - v4)
        v(i, j, k-1, 3) = v(i, j, k, 3)

      end do
      end do
!$OMP END DO

      flop = flop + rkx*12.0d0
      

    case (Z_plus)
      k = kx

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix

        v1= 0.5 * (v(i+1, j  , k+1, 3) + v(i+1, j  , k, 3))
        v2= 0.5 * (v(i-1, j  , k+1, 3) + v(i-1, j  , k, 3))
        v3= 0.5 * (v(i  , j+1, k+1, 3) + v(i  , j+1, k, 3))
        v4= 0.5 * (v(i  , j-1, k+1, 3) + v(i  , j-1, k, 3))
                
        v(i, j, k+1, 1) = v(i, j, k, 1) - 0.5 * (v1 - v2)
        v(i, j, k+1, 2) = v(i, j, k, 2) - 0.5 * (v3 - v4)
        v(i, j, k+1, 3) = v(i, j, k, 3)

      end do
      end do
!$OMP END DO

      flop = flop + rkx*12.0d0
      

    case default
    end select FACES

!$OMP END PARALLEL

    return 
    end subroutine vobc_tfree

!> ********************************************************************
!! @brief 疑似速度から次ステップ速度へ参照する速度をコピーする
!! @param[out] v 速度ベクトル（セルセンタ）
!! @param sz 配列長
!! @param g ガイドセル長
!! @param vc セルセンタ疑似速度 u^*
!! @param face 面番号
!<
    subroutine vobc_update (v, sz, g, vc, face)
    implicit none
    include 'ffv_f_params.h'
    integer                                                     ::  i, j, k, g, ix, jx, kx, face
    integer, dimension(3)                                       ::  sz
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3)   ::  v, vc

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    
!$OMP PARALLEL &
!$OMP PRIVATE(i, j, k) &
!$OMP FIRSTPRIVATE(ix, jx, kx, face)
    
    FACES : select case (face)
    case (X_minus)
      i = 0

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        v(i,j,k,1) = vc(i,j,k,1)
        v(i,j,k,2) = vc(i,j,k,2)
        v(i,j,k,3) = vc(i,j,k,3)
      end do
      end do
!$OMP END DO
      
    case (X_plus)
      i = ix+1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        v(i,j,k,1) = vc(i,j,k,1)
        v(i,j,k,2) = vc(i,j,k,2)
        v(i,j,k,3) = vc(i,j,k,3)
      end do
      end do
!$OMP END DO
      
    case (Y_minus)
      j = 0

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        v(i,j,k,1) = vc(i,j,k,1)
        v(i,j,k,2) = vc(i,j,k,2)
        v(i,j,k,3) = vc(i,j,k,3)
      end do
      end do
!$OMP END DO
      
    case (Y_plus)
      j = jx+1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        v(i,j,k,1) = vc(i,j,k,1)
        v(i,j,k,2) = vc(i,j,k,2)
        v(i,j,k,3) = vc(i,j,k,3)
      end do
      end do
!$OMP END DO
      
    case (Z_minus)
      k = 0

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        v(i,j,k,1) = vc(i,j,k,1)
        v(i,j,k,2) = vc(i,j,k,2)
        v(i,j,k,3) = vc(i,j,k,3)
      end do
      end do
!$OMP END DO
      
    case (Z_plus)
      k = kx+1

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        v(i,j,k,1) = vc(i,j,k,1)
        v(i,j,k,2) = vc(i,j,k,2)
        v(i,j,k,3) = vc(i,j,k,3)
      end do
      end do
!$OMP END DO
      
    case default
    end select FACES

!$OMP END PARALLEL
    
    return
    end subroutine vobc_update


!> ********************************************************************
!! @brief 外部指定境界条件による速度の発散の修正
!! @param [in,out] div   速度の発散
!! @param [in]     sz    配列長
!! @param [in]     g     ガイドセル長
!! @param [in]     face  面番号
!! @param [in]     bv    BCindex V
!! @param [in]     vec   指定する速度ベクトル
!! @param [in,out] flop  flop count
!! @note 指定面でも固体部分は対象外とするのでループ中に判定あり
!<
    subroutine div_obc_drchlt (div, sz, g, face, bv, vec, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, ix, jx, kx, face, bvx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop, rix, rjx, rkx
    real                                                      ::  u_bc_ref, v_bc_ref, w_bc_ref
    real, dimension(3)                                        ::  vec
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  div
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)

    rix = dble(jx)*dble(kx)
    rjx = dble(ix)*dble(kx)
    rkx = dble(ix)*dble(jx)
    
    u_bc_ref = vec(1)
    v_bc_ref = vec(2)
    w_bc_ref = vec(3)
    
    flop = flop + 3.0d0

!$OMP PARALLEL REDUCTION(+:flop) &
!$OMP FIRSTPRIVATE(ix, jx, kx, u_bc_ref, v_bc_ref, w_bc_ref, face) &
!$OMP PRIVATE(i, j, k, bvx)

    FACES : select case (face)
    case (X_minus)
      i = 1
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          div(i,j,k) = div(i,j,k) - u_bc_ref * real(ibits(bvx, State, 1))
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rix*3.0d0 ! 2+ real*1
      
      
    case (X_plus)
      i = ix
      
!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
          div(i,j,k) = div(i,j,k) + u_bc_ref * real(ibits(bvx, State, 1))
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rix*3.0d0 ! 2+ real*1
      
      
    case (Y_minus)
      j = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          div(i,j,k) = div(i,j,k) - v_bc_ref * real(ibits(bvx, State, 1))
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*3.0d0 ! 2+ real*1
      
      
    case (Y_plus)
      j = jx

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          div(i,j,k) = div(i,j,k) + v_bc_ref * real(ibits(bvx, State, 1))
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rjx*3.0d0 ! 2+ real*1
    
    
    case (Z_minus)
      k = 1

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          div(i,j,k) = div(i,j,k) - w_bc_ref * real(ibits(bvx, State, 1))
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rkx*3.0d0 ! 2+ real*1
      
      
    case (Z_plus)
      k = kx

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          div(i,j,k) = div(i,j,k) + w_bc_ref * real(ibits(bvx, State, 1))
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rkx*3.0d0 ! 2+ real*1
    
    case default
    end select FACES

!$OMP END PARALLEL

    return
    end subroutine div_obc_drchlt

!> ********************************************************************
!! @brief 外部流出境界条件による疑似速度ベクトルの発散の修正
!! @param [in,out] div   速度の発散
!! @param [in]     sz    配列長
!! @param [in]     g     ガイドセル長
!! @param [in]     face  面番号
!! @param [in]     v_out u_out*dt/dh
!! @param [in]     bv    BCindex V
!! @param [in]     vf    セルフェイス速度ベクトル（n-step）
!! @param [out]    flop  flop count
!! @note 指定面でも固体部分は対象外とするのでループ中に判定あり
!<
    subroutine div_obc_oflow_pvec (div, sz, g, face, v_out, bv, vf, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, ix, jx, kx, face, bvx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop
    real                                                      ::  v_out, m
    real                                                      ::  b_w, b_e, b_s, b_n, b_b, b_t, b_p
    real                                                      ::  w_e, w_w, w_n, w_s, w_t, w_b
    real                                                      ::  Ue, Uw, Vn, Vs, Wt, Wb
    real                                                      ::  Ue_t, Uw_t, Vn_t, Vs_t, Wt_t, Wb_t
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  div
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g, 3) ::  vf

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)

    m = 0.0

!$OMP PARALLEL REDUCTION(+:m) &
!$OMP FIRSTPRIVATE(ix, jx, kx, face, v_out) &
!$OMP PRIVATE(i, j, k, bvx) &
!$OMP PRIVATE(Ue, Uw, Vn, Vs, Wt, Wb) &
!$OMP PRIVATE(Ue_t, Uw_t, Vn_t, Vs_t, Wt_t, Wb_t) &
!$OMP PRIVATE(w_e, w_w, w_n, w_s, w_t, w_b) &
!$OMP PRIVATE(b_w, b_e, b_s, b_n, b_b, b_t, b_p)


    FACES : select case (face)
    
    case (X_minus)
      if ( v_out>0.0 ) v_out=0.0
      i = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
        
          include 'd_o_o_p.h' ! 42 flops
          
          Uw = Ue + (Vn - Vs + Wt - Wb) ! 連続の式から流出面の速度を推定，これは移動座標系上の速度成分
          Uw_t = Uw - v_out*(Ue-Uw)
          div(i,j,k) = div(i,j,k) - Uw_t
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (X_plus)
      if ( v_out<0.0 ) v_out=0.0
      i = ix

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
        
          include 'd_o_o_p.h'
          
          Ue = Uw - (Vn - Vs + Wt - Wb)
          Ue_t = Ue - v_out*(Ue-Uw)
          div(i,j,k) = div(i,j,k) + Ue_t
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO


    case (Y_minus)
      if ( v_out>0.0 ) v_out=0.0
      j = 1

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
        
          include 'd_o_o_p.h'
        
          Vs = Vn + (Ue - Uw + Wt - Wb)
          Vs_t = Vs - v_out*(Vn-Vs)
          div(i,j,k) = div(i,j,k) - Vs_t
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Y_plus)
      if ( v_out<0.0 ) v_out=0.0
      j = jx

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
        
          include 'd_o_o_p.h'
        
          Vn = Vs - (Ue - Uw + Wt - Wb)
          Vn_t = Vn - v_out*(Vn-Vs)
          div(i,j,k) = div(i,j,k) + Vn_t
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
    
    
    case (Z_minus)
      if ( v_out>0.0 ) v_out=0.0
      k = 1

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
        
          include 'd_o_o_p.h'
        
          Wb = Wt + (Ue - Uw + Vn - Vs)
          Wb_t = Wb - v_out*(Wt-Wb)
          div(i,j,k) = div(i,j,k) - Wb_t
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
      
      
    case (Z_plus)
      if ( v_out<0.0 ) v_out=0.0
      k = kx

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,k)
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
        
          include 'd_o_o_p.h'
        
          Wt = Wb - (Ue - Uw + Vn - Vs)
          Wt_t = Wt - v_out*(Wt-Wb)
          div(i,j,k) = div(i,j,k) + Wt_t
          m = m + 1.0
        endif
      end do
      end do
!$OMP END DO
    
    case default
    end select FACES

!$OMP END PARALLEL
    
    flop = flop + dble(m)*50.0d0

    return
    end subroutine div_obc_oflow_pvec

!> ********************************************************************
!! @brief 外部流出境界条件による速度ベクトルの発散の修正
!! @param [in,out] div  \sum{u}
!! @param [in]     sz   配列長
!! @param [in]     g    ガイドセル長
!! @param [in]     face 面番号
!! @param [in]     bv   BCindex V
!! @param [out]    aa   領域境界の積算値
!! @param [out]    flop flop count 近似
!! @note 指定面でも固体部分は対象外とするのでループ中に判定あり
!!       div(u)=0から，内部流出境界のセルで計算されたdivが流出速度となる
!<
    subroutine div_obc_oflow_vec (div, sz, g, face, bv, aa, flop)
    implicit none
    include 'ffv_f_params.h'
    integer                                                   ::  i, j, k, g, ix, jx, kx, face, bvx
    integer, dimension(3)                                     ::  sz
    double precision                                          ::  flop, rix, rjx, rkx
    real                                                      ::  dv, a1, a2, a3
    real, dimension(3)                                        ::  aa
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  div
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    rix = dble(jx)*dble(kx)
    rjx = dble(ix)*dble(kx)
    rkx = dble(ix)*dble(jx)

    a1 = 0.0   ! sum
    a2 = 1.0e6 ! min
    a3 =-1.0e6 ! max
    
    
!$OMP PARALLEL &
!$OMP REDUCTION(+:a1) &
!$OMP REDUCTION(min:a2) &
!$OMP REDUCTION(max:a3) &
!$OMP REDUCTION(+:flop) &
!$OMP FIRSTPRIVATE(ix, jx, kx, rix, rjx, rkx, face) &
!$OMP PRIVATE(i, j, k, bvx, dv)

    FACES : select case (face)
    
    case (X_minus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(1,j,k)
        if ( ibits(bvx, bc_face_W, bitw_5) == obc_mask ) then
          dv = div(1,j,k)
          a1 = a1 + dv
          a2 = min(a2, dv)
          a3 = max(a3, dv)
          div(1,j,k) = 0.0 ! 対象セルは発散をゼロにする
        endif
      end do
      end do
!$OMP END DO
      
      flop = flop + rix*4.0d0
      
      
    case (X_plus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do j=1,jx
        bvx = bv(ix,j,k)
        if ( ibits(bvx, bc_face_E, bitw_5) == obc_mask ) then
          dv = -div(ix,j,k)
          a1 = a1 + dv
          a2 = min(a2, dv)
          a3 = max(a3, dv)
          div(ix,j,k) = 0.0
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rix*4.0d0
      
      
    case (Y_minus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,1,k)
        if ( ibits(bvx, bc_face_S, bitw_5) == obc_mask ) then
          dv = div(i,1,k)
          a1 = a1 + dv
          a2 = min(a2, dv)
          a3 = max(a3, dv)
          div(i,1,k) = 0.0
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rjx*4.0d0
      
      
    case (Y_plus)

!$OMP DO SCHEDULE(static)
      do k=1,kx
      do i=1,ix
        bvx = bv(i,jx,k)
        if ( ibits(bvx, bc_face_N, bitw_5) == obc_mask ) then
          dv = -div(i,jx,k)
          a1 = a1 + dv
          a2 = min(a2, dv)
          a3 = max(a3, dv)
          div(i,jx,k) = 0.0
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rjx*4.0d0
    
    
    case (Z_minus)

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,1)
        if ( ibits(bvx, bc_face_B, bitw_5) == obc_mask ) then
          dv = div(i,j,1)
          a1 = a1 + dv
          a2 = min(a2, dv)
          a3 = max(a3, dv)
          div(i,j,1) = 0.0
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rkx*4.0d0
      
      
    case (Z_plus)

!$OMP DO SCHEDULE(static)
      do j=1,jx
      do i=1,ix
        bvx = bv(i,j,kx)
        if ( ibits(bvx, bc_face_T, bitw_5) == obc_mask ) then
          dv = -div(i,j,kx)
          a1 = a1 + dv
          a2 = min(a2, dv)
          a3 = max(a3, dv)
          div(i,j,kx) = 0.0
        endif
      end do
      end do
!$OMP END DO

      flop = flop + rkx*4.0d0
    
    case default
    end select FACES

!$OMP END PARALLEL
    
    aa(1) = a1 ! sum
    aa(2) = a2 ! min
    aa(3) = a3 ! max

    return
    end subroutine div_obc_oflow_vec
    