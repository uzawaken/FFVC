!********************************************************************
!
!   FFV : Frontflow / violet
!
!   Copyright (c) 2012 All right reserved.
!
!   Institute of Industrial Science, The University of Tokyo, Japan. 
!
!********************************************************************

!> @file   FB_util.f90
!! @brief  FlowBase utilities
!! @author kero
!<

!> ********************************************************************
!! @brief 粗い格子から密な格子への補間（ゼロ次）
!! @param dst 密な格子系
!! @param sz 配列長
!! @param g ガイドセル長
!! @param src 粗い格子系
!! @param st 粗い格子の開始インデクス
!! @param bk ブロック数
!<
subroutine fb_interp_coarse0_s(dst, sz, g, src, st, bk)
implicit none
integer                                                      ::  i, j, k          ! 粗い格子のループインデクス
integer                                                      ::  ii, jj, kk       ! 密な格子のループインデクス
integer                                                      ::  ix, jx, kx, g, si, sj, sk
integer, dimension(3)                                        ::  sz, st, bk
real                                                         ::  q
real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)       ::  dst
real, dimension(1-g:sz(1)*bk(1)/2+g, 1-g:sz(2)*bk(2)/2+g, 1-g:sz(3)*bk(3)/2+g) ::  src

ix = sz(1)
jx = sz(2)
kx = sz(3)
si = st(1)
sj = st(2)
sk = st(3)

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, si, sj, sk) &
!$OMP PRIVATE(q) &
!$OMP PRIVATE(ii, jj, kk)

!$OMP DO SCHEDULE(static)

do k=sk, sk+kx/2-1
kk = 2*k - (2*k-1)/kx * kx
do j=sj, sj+jx/2-1
jj = 2*j - (2*j-1)/jx * jx
do i=si, si+ix/2-1
ii = 2*i - (2*i-1)/ix * ix

q = src(i  , j  , k  )

dst(ii-1, jj-1, kk-1) = q
dst(ii  , jj-1, kk-1) = q
dst(ii-1, jj  , kk-1) = q
dst(ii  , jj  , kk-1) = q
dst(ii-1, jj-1, kk  ) = q
dst(ii  , jj-1, kk  ) = q
dst(ii-1, jj  , kk  ) = q
dst(ii  , jj  , kk  ) = q

end do
end do
end do

!$OMP END DO
!$OMP END PARALLEL

return
end subroutine fb_interp_coarse0_s

!> ********************************************************************
!! @brief 粗い格子から密な格子への補間（ゼロ次）
!! @param dst 密な格子系
!! @param sz 配列長
!! @param g ガイドセル長
!! @param src 粗い格子系
!! @param st 粗い格子の開始インデクス
!! @param bk ブロック数
!<
subroutine fb_interp_coarse0_v(dst, sz, g, src, st, bk)
implicit none
integer                                                         ::  i, j, k          ! 粗い格子のループインデクス
integer                                                         ::  ii, jj, kk       ! 密な格子のループインデクス
integer                                                         ::  ix, jx, kx, g, si, sj, sk
integer, dimension(3)                                           ::  sz, st, bk
real                                                            ::  q1, q2, q3
real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)       ::  dst
real, dimension(3, 1-g:sz(1)*bk(1)/2+g, 1-g:sz(2)*bk(2)/2+g, 1-g:sz(3)*bk(3)/2+g) ::  src


ix = sz(1)
jx = sz(2)
kx = sz(3)
si = st(1)
sj = st(2)
sk = st(3)

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, si, sj, sk) &
!$OMP PRIVATE(ii, jj, kk, q1, q2, q3)

!$OMP DO SCHEDULE(static)

do k=sk, sk+kx/2-1
kk = 2*k - (2*k-1)/kx * kx
do j=sj, sj+jx/2-1
jj = 2*j - (2*j-1)/jx * jx
do i=si, si+ix/2-1
ii = 2*i - (2*i-1)/ix * ix

!   u
q1 = src(1, i  , j  , k  )
q2 = src(2, i  , j  , k  )
q3 = src(3, i  , j  , k  )


dst(1, ii-1, jj-1, kk-1) = q1
dst(1, ii  , jj-1, kk-1) = q1
dst(1, ii-1, jj  , kk-1) = q1
dst(1, ii  , jj  , kk-1) = q1
dst(1, ii-1, jj-1, kk  ) = q1
dst(1, ii  , jj-1, kk  ) = q1
dst(1, ii-1, jj  , kk  ) = q1
dst(1, ii  , jj  , kk  ) = q1

dst(2, ii-1, jj-1, kk-1) = q2
dst(2, ii  , jj-1, kk-1) = q2
dst(2, ii-1, jj  , kk-1) = q2
dst(2, ii  , jj  , kk-1) = q2
dst(2, ii-1, jj-1, kk  ) = q2
dst(2, ii  , jj-1, kk  ) = q2
dst(2, ii-1, jj  , kk  ) = q2
dst(2, ii  , jj  , kk  ) = q2

dst(3, ii-1, jj-1, kk-1) = q3
dst(3, ii  , jj-1, kk-1) = q3
dst(3, ii-1, jj  , kk-1) = q3
dst(3, ii  , jj  , kk-1) = q3
dst(3, ii-1, jj-1, kk  ) = q3
dst(3, ii  , jj-1, kk  ) = q3
dst(3, ii-1, jj  , kk  ) = q3
dst(3, ii  , jj  , kk  ) = q3

end do
end do
end do

!$OMP END DO
!$OMP END PARALLEL

return
end subroutine fb_interp_coarse0_v



!> ********************************************************************
!! @brief 粗い格子から密な格子への補間
!! @param dst 密な格子系
!! @param sz 配列長
!! @param g ガイドセル長
!! @param src 粗い格子系
!! @param st 粗い格子の開始インデクス
!! @param bk ブロック数
!<
  subroutine fb_interp_coarse_s(dst, sz, g, src, st, bk)
  implicit none
  integer                                                      ::  i, j, k          ! 粗い格子のループインデクス
  integer                                                      ::  ii, jj, kk       ! 密な格子のループインデクス
  integer                                                      ::  ix, jx, kx, g, si, sj, sk
  integer, dimension(3)                                        ::  sz, st, bk
  real                                                         ::  g_x,  g_y,  g_z, q
  real                                                         ::  g_xx, g_yy, g_zz
  real                                                         ::  g_xy, g_yz, g_zx
  real                                                         ::         s_112,        s_121, s_122, s_123,        s_132
  real                                                         ::  s_211, s_212, s_213, s_221, s_222, s_223, s_231, s_232, s_233
  real                                                         ::         s_312,        s_321, s_322, s_323,        s_332
  real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)       ::  dst
  real, dimension(1-g:sz(1)*bk(1)/2+g, 1-g:sz(2)*bk(2)/2+g, 1-g:sz(3)*bk(3)/2+g) ::  src

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)
  si = st(1)
  sj = st(2)
  sk = st(3)

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, si, sj, sk) &
!$OMP PRIVATE(s_112, s_121, s_122, s_123, s_132) &
!$OMP PRIVATE(s_211, s_212, s_213, s_221, s_222, s_223, s_231, s_232, s_233) &
!$OMP PRIVATE(s_312, s_321, s_322, s_323, s_332) &
!$OMP PRIVATE(g_x, g_y, g_z, g_xx, g_yy, g_zz, g_xy, g_yz, g_zx, q) &
!$OMP PRIVATE(ii, jj, kk)

!$OMP DO SCHEDULE(static)

  do k=sk, sk+kx/2-1
    kk = 2*k - (2*k-1)/kx * kx
  do j=sj, sj+jx/2-1
    jj = 2*j - (2*j-1)/jx * jx
  do i=si, si+ix/2-1
    ii = 2*i - (2*i-1)/ix * ix

    s_112 = src(i-1, j-1, k  )
    s_121 = src(i-1, j  , k-1)
    s_122 = src(i-1, j  , k  )
    s_123 = src(i-1, j  , k+1)
    s_132 = src(i-1, j+1, k  )
        
    s_211 = src(i  , j-1, k-1)
    s_212 = src(i  , j-1, k  )
    s_213 = src(i  , j-1, k+1)
    s_221 = src(i  , j  , k-1)
    s_222 = src(i  , j  , k  )
    s_223 = src(i  , j  , k+1)
    s_231 = src(i  , j+1, k-1)
    s_232 = src(i  , j+1, k  )
    s_233 = src(i  , j+1, k+1)
            
    s_312 = src(i+1, j-1, k  )
    s_321 = src(i+1, j  , k-1)
    s_322 = src(i+1, j  , k  )
    s_323 = src(i+1, j  , k+1)
    s_332 = src(i+1, j+1, k  )

    g_x = ( s_322 - s_122 ) * 0.25
    g_y = ( s_232 - s_212 ) * 0.25
    g_z = ( s_223 - s_221 ) * 0.25

    g_xx = s_322 - 2.0 * s_222 + s_122
    g_yy = s_232 - 2.0 * s_222 + s_212
    g_zz = s_223 - 2.0 * s_222 + s_221

    g_xy = ( s_332 - s_312 - s_132 + s_112 ) * 0.25
    g_yz = ( s_233 - s_231 - s_213 + s_211 ) * 0.25
    g_zx = ( s_323 - s_123 - s_321 + s_121 ) * 0.25
    
    if (i == 1) then
      if (j == 1)  g_xy = s_332 - s_322 - s_232 + s_222
      if (j == jx) g_xy = s_322 - s_222 - s_312 + s_212
      
      if (k == 1)  g_zx = s_323 - s_322 - s_223 + s_222
      if (k == kx) g_zx = s_322 - s_321 - s_222 + s_221
    end if
    
    if (i == ix) then
      if (j == 1)  g_xy = s_232 - s_222 - s_132 + s_122
      if (j == jx) g_xy = s_222 - s_122 - s_212 + s_112
      
      if (k == 1)  g_zx = s_223 - s_222 - s_123 + s_122
      if (k == kx) g_zx = s_222 - s_221 - s_122 + s_121
    end if
    
    if (j == 1) then
      if (k == 1)  g_yz = s_233 - s_232 - s_223 + s_222
      if (k == kx) g_yz = s_232 - s_231 - s_222 + s_221
    end if

    if (j == jx) then
      if (k == 1)  g_yz = s_223 - s_222 - s_213 + s_212
      if (k == kx) g_yz = s_222 - s_221 - s_212 + s_211
    end if

    q = s_222 + 0.125 * ( g_xx + g_yy + g_zz )
    
    dst(ii-1, jj-1, kk-1) = q - g_x - g_y - g_z + 0.25 * (+ g_xy + g_yz + g_zx )
    dst(ii  , jj-1, kk-1) = q + g_x - g_y - g_z + 0.25 * (- g_xy + g_yz + g_zx )
    dst(ii-1, jj  , kk-1) = q - g_x + g_y - g_z + 0.25 * (- g_xy - g_yz + g_zx )
    dst(ii  , jj  , kk-1) = q + g_x + g_y - g_z + 0.25 * (+ g_xy - g_yz - g_zx )
    dst(ii-1, jj-1, kk  ) = q - g_x - g_y + g_z + 0.25 * (+ g_xy - g_yz - g_zx )
    dst(ii  , jj-1, kk  ) = q + g_x - g_y + g_z + 0.25 * (- g_xy - g_yz + g_zx )
    dst(ii-1, jj  , kk  ) = q - g_x + g_y + g_z + 0.25 * (- g_xy + g_yz - g_zx )
    dst(ii  , jj  , kk  ) = q + g_x + g_y + g_z + 0.25 * (+ g_xy + g_yz + g_zx )

  end do
  end do
  end do

!$OMP END DO
!$OMP END PARALLEL

  return
  end subroutine fb_interp_coarse_s

!> ********************************************************************
!! @brief 粗い格子から密な格子への補間
!! @param dst 密な格子系
!! @param sz 配列長
!! @param g ガイドセル長
!! @param src 粗い格子系
!! @param st 粗い格子の開始インデクス
!! @param bk ブロック数
!<
  subroutine fb_interp_coarse_v(dst, sz, g, src, st, bk)
  implicit none
  integer                                                         ::  i, j, k          ! 粗い格子のループインデクス
  integer                                                         ::  ii, jj, kk       ! 密な格子のループインデクス
  integer                                                         ::  ix, jx, kx, g, si, sj, sk
  integer, dimension(3)                                           ::  sz, st, bk
  real                                                            ::  u_x, u_y, u_z, u_xx, u_yy, u_zz, u_xy, u_yz, u_zx
  real                                                            ::  v_x, v_y, v_z, v_xx, v_yy, v_zz, v_xy, v_yz, v_zx
  real                                                            ::  w_x, w_y, w_z, w_xx, w_yy, w_zz, w_xy, w_yz, w_zx
  real                                                            ::         s_112,        s_121, s_122, s_123,        s_132
  real                                                            ::  s_211, s_212, s_213, s_221, s_222, s_223, s_231, s_232, s_233
  real                                                            ::         s_312,        s_321, s_322, s_323,        s_332
  real                                                            ::  q
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)       ::  dst
  real, dimension(3, 1-g:sz(1)*bk(1)/2+g, 1-g:sz(2)*bk(2)/2+g, 1-g:sz(3)*bk(3)/2+g) ::  src


  ix = sz(1)
  jx = sz(2)
  kx = sz(3)
  si = st(1)
  sj = st(2)
  sk = st(3)

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, si, sj, sk) &
!$OMP PRIVATE(s_112, s_121, s_122, s_123, s_132) &
!$OMP PRIVATE(s_211, s_212, s_213, s_221, s_222, s_223, s_231, s_232, s_233) &
!$OMP PRIVATE(s_312, s_321, s_322, s_323, s_332) &
!$OMP PRIVATE(u_x, u_y, u_z, u_xx, u_yy, u_zz, u_xy, u_yz, u_zx) &
!$OMP PRIVATE(v_x, v_y, v_z, v_xx, v_yy, v_zz, v_xy, v_yz, v_zx) &
!$OMP PRIVATE(w_x, w_y, w_z, w_xx, w_yy, w_zz, w_xy, w_yz, w_zx) &
!$OMP PRIVATE(ii, jj, kk, q)

!$OMP DO SCHEDULE(static)

  do k=sk, sk+kx/2-1
    kk = 2*k - (2*k-1)/kx * kx
  do j=sj, sj+jx/2-1
    jj = 2*j - (2*j-1)/jx * jx
  do i=si, si+ix/2-1
    ii = 2*i - (2*i-1)/ix * ix

!   u
    s_112 = src(1, i-1, j-1, k  )
    s_121 = src(1, i-1, j  , k-1)
    s_122 = src(1, i-1, j  , k  )
    s_123 = src(1, i-1, j  , k+1)
    s_132 = src(1, i-1, j+1, k  )
        
    s_211 = src(1, i  , j-1, k-1)
    s_212 = src(1, i  , j-1, k  )
    s_213 = src(1, i  , j-1, k+1)
    s_221 = src(1, i  , j  , k-1)
    s_222 = src(1, i  , j  , k  )
    s_223 = src(1, i  , j  , k+1)
    s_231 = src(1, i  , j+1, k-1)
    s_232 = src(1, i  , j+1, k  )
    s_233 = src(1, i  , j+1, k+1)
            
    s_312 = src(1, i+1, j-1, k  )
    s_321 = src(1, i+1, j  , k-1)
    s_322 = src(1, i+1, j  , k  )
    s_323 = src(1, i+1, j  , k+1)
    s_332 = src(1, i+1, j+1, k  )

    u_x = ( s_322 - s_122 ) * 0.25
    u_y = ( s_232 - s_212 ) * 0.25
    u_z = ( s_223 - s_221 ) * 0.25

    u_xx = s_322 - 2.0 * s_222 + s_122
    u_yy = s_232 - 2.0 * s_222 + s_212
    u_zz = s_223 - 2.0 * s_222 + s_221

    u_xy = ( s_332 - s_312 - s_132 + s_112 ) * 0.25
    u_yz = ( s_233 - s_231 - s_213 + s_211 ) * 0.25
    u_zx = ( s_323 - s_123 - s_321 + s_121 ) * 0.25
    
    if (i == 1) then
      if (j == 1)  u_xy = s_332 - s_322 - s_232 + s_222
      if (j == jx) u_xy = s_322 - s_222 - s_312 + s_212
      
      if (k == 1)  u_zx = s_323 - s_322 - s_223 + s_222
      if (k == kx) u_zx = s_322 - s_321 - s_222 + s_221
    end if
    
    if (i == ix) then
      if (j == 1)  u_xy = s_232 - s_222 - s_132 + s_122
      if (j == jx) u_xy = s_222 - s_122 - s_212 + s_112
      
      if (k == 1)  u_zx = s_223 - s_222 - s_123 + s_122
      if (k == kx) u_zx = s_222 - s_221 - s_122 + s_121
    end if
    
    if (j == 1) then
      if (k == 1)  u_yz = s_233 - s_232 - s_223 + s_222
      if (k == kx) u_yz = s_232 - s_231 - s_222 + s_221
    end if

    if (j == jx) then
      if (k == 1)  u_yz = s_223 - s_222 - s_213 + s_212
      if (k == kx) u_yz = s_222 - s_221 - s_212 + s_211
    end if

    q = s_222 + 0.125 * ( u_xx + u_yy + u_zz )
    
    dst(1, ii-1, jj-1, kk-1) = q - u_x - u_y - u_z + 0.25 * (+ u_xy + u_yz + u_zx )
    dst(1, ii  , jj-1, kk-1) = q + u_x - u_y - u_z + 0.25 * (- u_xy + u_yz + u_zx )
    dst(1, ii-1, jj  , kk-1) = q - u_x + u_y - u_z + 0.25 * (- u_xy - u_yz + u_zx )
    dst(1, ii  , jj  , kk-1) = q + u_x + u_y - u_z + 0.25 * (+ u_xy - u_yz - u_zx )
    dst(1, ii-1, jj-1, kk  ) = q - u_x - u_y + u_z + 0.25 * (+ u_xy - u_yz - u_zx )
    dst(1, ii  , jj-1, kk  ) = q + u_x - u_y + u_z + 0.25 * (- u_xy - u_yz + u_zx )
    dst(1, ii-1, jj  , kk  ) = q - u_x + u_y + u_z + 0.25 * (- u_xy + u_yz - u_zx )
    dst(1, ii  , jj  , kk  ) = q + u_x + u_y + u_z + 0.25 * (+ u_xy + u_yz + u_zx )


!   v
    s_112 = src(2, i-1, j-1, k  )
    s_121 = src(2, i-1, j  , k-1)
    s_122 = src(2, i-1, j  , k  )
    s_123 = src(2, i-1, j  , k+1)
    s_132 = src(2, i-1, j+1, k  )
        
    s_211 = src(2, i  , j-1, k-1)
    s_212 = src(2, i  , j-1, k  )
    s_213 = src(2, i  , j-1, k+1)
    s_221 = src(2, i  , j  , k-1)
    s_222 = src(2, i  , j  , k  )
    s_223 = src(2, i  , j  , k+1)
    s_231 = src(2, i  , j+1, k-1)
    s_232 = src(2, i  , j+1, k  )
    s_233 = src(2, i  , j+1, k+1)
            
    s_312 = src(2, i+1, j-1, k  )
    s_321 = src(2, i+1, j  , k-1)
    s_322 = src(2, i+1, j  , k  )
    s_323 = src(2, i+1, j  , k+1)
    s_332 = src(2, i+1, j+1, k  )

    v_x = ( s_322 - s_122 ) * 0.25
    v_y = ( s_232 - s_212 ) * 0.25
    v_z = ( s_223 - s_221 ) * 0.25

    v_xx = s_322 - 2.0 * s_222 + s_122
    v_yy = s_232 - 2.0 * s_222 + s_212
    v_zz = s_223 - 2.0 * s_222 + s_221

    v_xy = ( s_332 - s_312 - s_132 + s_112 ) * 0.25
    v_yz = ( s_233 - s_231 - s_213 + s_211 ) * 0.25
    v_zx = ( s_323 - s_123 - s_321 + s_121 ) * 0.25
    
    if (i == 1) then
      if (j == 1)  v_xy = s_332 - s_322 - s_232 + s_222
      if (j == jx) v_xy = s_322 - s_222 - s_312 + s_212
      
      if (k == 1)  v_zx = s_323 - s_322 - s_223 + s_222
      if (k == kx) v_zx = s_322 - s_321 - s_222 + s_221
    end if
    
    if (i == ix) then
      if (j == 1)  v_xy = s_232 - s_222 - s_132 + s_122
      if (j == jx) v_xy = s_222 - s_122 - s_212 + s_112
      
      if (k == 1)  v_zx = s_223 - s_222 - s_123 + s_122
      if (k == kx) v_zx = s_222 - s_221 - s_122 + s_121
    end if
    
    if (j == 1) then
      if (k == 1)  v_yz = s_233 - s_232 - s_223 + s_222
      if (k == kx) v_yz = s_232 - s_231 - s_222 + s_221
    end if

    if (j == jx) then
      if (k == 1)  v_yz = s_223 - s_222 - s_213 + s_212
      if (k == kx) v_yz = s_222 - s_221 - s_212 + s_211
    end if

    q = s_222 + 0.125 * ( v_xx + v_yy + v_zz )
    
    dst(2, ii-1, jj-1, kk-1) = q - v_x - v_y - v_z + 0.25 * (+ v_xy + v_yz + v_zx )
    dst(2, ii  , jj-1, kk-1) = q + v_x - v_y - v_z + 0.25 * (- v_xy + v_yz + v_zx )
    dst(2, ii-1, jj  , kk-1) = q - v_x + v_y - v_z + 0.25 * (- v_xy - v_yz + v_zx )
    dst(2, ii  , jj  , kk-1) = q + v_x + v_y - v_z + 0.25 * (+ v_xy - v_yz - v_zx )
    dst(2, ii-1, jj-1, kk  ) = q - v_x - v_y + v_z + 0.25 * (+ v_xy - v_yz - v_zx )
    dst(2, ii  , jj-1, kk  ) = q + v_x - v_y + v_z + 0.25 * (- v_xy - v_yz + v_zx )
    dst(2, ii-1, jj  , kk  ) = q - v_x + v_y + v_z + 0.25 * (- v_xy + v_yz - v_zx )
    dst(2, ii  , jj  , kk  ) = q + v_x + v_y + v_z + 0.25 * (+ v_xy + v_yz + v_zx )


!   w
    s_112 = src(3, i-1, j-1, k  )
    s_121 = src(3, i-1, j  , k-1)
    s_122 = src(3, i-1, j  , k  )
    s_123 = src(3, i-1, j  , k+1)
    s_132 = src(3, i-1, j+1, k  )
        
    s_211 = src(3, i  , j-1, k-1)
    s_212 = src(3, i  , j-1, k  )
    s_213 = src(3, i  , j-1, k+1)
    s_221 = src(3, i  , j  , k-1)
    s_222 = src(3, i  , j  , k  )
    s_223 = src(3, i  , j  , k+1)
    s_231 = src(3, i  , j+1, k-1)
    s_232 = src(3, i  , j+1, k  )
    s_233 = src(3, i  , j+1, k+1)
            
    s_312 = src(3, i+1, j-1, k  )
    s_321 = src(3, i+1, j  , k-1)
    s_322 = src(3, i+1, j  , k  )
    s_323 = src(3, i+1, j  , k+1)
    s_332 = src(3, i+1, j+1, k  )

    w_x = ( s_322 - s_122 ) * 0.25
    w_y = ( s_232 - s_212 ) * 0.25
    w_z = ( s_223 - s_221 ) * 0.25

    w_xx = s_322 - 2.0 * s_222 + s_122
    w_yy = s_232 - 2.0 * s_222 + s_212
    w_zz = s_223 - 2.0 * s_222 + s_221

    w_xy = ( s_332 - s_312 - s_132 + s_112 ) * 0.25
    w_yz = ( s_233 - s_231 - s_213 + s_211 ) * 0.25
    w_zx = ( s_323 - s_123 - s_321 + s_121 ) * 0.25
    
    if (i == 1) then
      if (j == 1)  w_xy = s_332 - s_322 - s_232 + s_222
      if (j == jx) w_xy = s_322 - s_222 - s_312 + s_212
      
      if (k == 1)  w_zx = s_323 - s_322 - s_223 + s_222
      if (k == kx) w_zx = s_322 - s_321 - s_222 + s_221
    end if
    
    if (i == ix) then
      if (j == 1)  w_xy = s_232 - s_222 - s_132 + s_122
      if (j == jx) w_xy = s_222 - s_122 - s_212 + s_112
      
      if (k == 1)  w_zx = s_223 - s_222 - s_123 + s_122
      if (k == kx) w_zx = s_222 - s_221 - s_122 + s_121
    end if
    
    if (j == 1) then
      if (k == 1)  w_yz = s_233 - s_232 - s_223 + s_222
      if (k == kx) w_yz = s_232 - s_231 - s_222 + s_221
    end if

    if (j == jx) then
      if (k == 1)  w_yz = s_223 - s_222 - s_213 + s_212
      if (k == kx) w_yz = s_222 - s_221 - s_212 + s_211
    end if

    q = s_222 + 0.125 * ( w_xx + w_yy + w_zz )
    
    dst(3, ii-1, jj-1, kk-1) = q - w_x - w_y - w_z + 0.25 * (+ w_xy + w_yz + w_zx )
    dst(3, ii  , jj-1, kk-1) = q + w_x - w_y - w_z + 0.25 * (- w_xy + w_yz + w_zx )
    dst(3, ii-1, jj  , kk-1) = q - w_x + w_y - w_z + 0.25 * (- w_xy - w_yz + w_zx )
    dst(3, ii  , jj  , kk-1) = q + w_x + w_y - w_z + 0.25 * (+ w_xy - w_yz - w_zx )
    dst(3, ii-1, jj-1, kk  ) = q - w_x - w_y + w_z + 0.25 * (+ w_xy - w_yz - w_zx )
    dst(3, ii  , jj-1, kk  ) = q + w_x - w_y + w_z + 0.25 * (- w_xy - w_yz + w_zx )
    dst(3, ii-1, jj  , kk  ) = q - w_x + w_y + w_z + 0.25 * (- w_xy + w_yz - w_zx )
    dst(3, ii  , jj  , kk  ) = q + w_x + w_y + w_z + 0.25 * (+ w_xy + w_yz + w_zx )

  end do
  end do
  end do

!$OMP END DO
!$OMP END PARALLEL

  return
  end subroutine fb_interp_coarse_v


!> ********************************************************************
!! @brief スカラー値の書き出し
!! @param v 速度ベクトル
!! @param sz 配列長
!! @param g ガイドセル長
!! @param fname ファイル名
!! @param step ステップ数
!! @param time 時刻
!! @param org 起点座標
!! @param pit 格子幅
!! @param d_type (1-float, 2-double)
!! @param gs guide cell (0-without, others-with)
!! @param avs 平均値識別子 (0-average, 1-instantaneous) 
!! @param step_avr
!! @param time_avr
!<
  subroutine fb_write_sph_s(s, sz, g, fname, step, time, org, pit, d_type, gs, avs, step_avr, time_avr)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g, step, gs, step_avr, avs
  integer                                                   ::  sv_type, d_type, imax, jmax, kmax
  integer, dimension(3)                                     ::  sz
  real                                                      ::  time, time_avr
  real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  s
  real, dimension(3)                                        ::  org, pit
  character(64)                                             ::  fname

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  sv_type = 1 ! scalar

  if ( gs == 0 ) then
    imax = ix
    jmax = jx
    kmax = kx
  else
    imax = ix + 2*g
    jmax = jx + 2*g
    kmax = kx + 2*g
  end if

  open(16, file=fname, form='unformatted')
  write(16) sv_type, d_type
  write(16) imax, jmax, kmax
  write(16) org(1), org(2), org(3)
  write(16) pit(1), pit(2), pit(3)
  write(16) step, time

  if ( gs /= 0 ) then
    write(16) (((s(i,j,k),i=1-g,ix+g),j=1-g,jx+g),k=1-g,kx+g)
  else
    write(16) (((s(i,j,k),i=1,ix),j=1,jx),k=1,kx)
  end if
  
  if ( avs == 0 ) then
    write(16) step_avr, time_avr
  end if
  
  close (unit=16)

  return
  end subroutine fb_write_sph_s


!> ********************************************************************
!! @brief ベクトル値の書き出し
!! @param v ベクトル
!! @param sz 配列長
!! @param g ガイドセル長
!! @param fname ファイル名
!! @param step ステップ数
!! @param time 時刻
!! @param org 起点座標
!! @param pit 格子幅
!! @param d_type (1-float, 2-double)
!! @param gs guide cell (0-without, others-with)
!! @param avs 平均値識別子 (0-average, 1-instantaneous) 
!! @param step_avr
!! @param time_avr
!<
  subroutine fb_write_sph_v(v, sz, g, fname, step, time, org, pit, d_type, gs, avs, step_avr, time_avr)
  implicit none
  integer                                                   ::  i, j, k, l, ix, jx, kx, g, step, gs, step_avr, avs
  integer                                                   ::  sv_type, d_type, imax, jmax, kmax
  integer, dimension(3)                                     ::  sz
  real                                                      ::  time, time_avr
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  v
  real, dimension(3)                                        ::  org, pit
  character(64)                                             ::  fname

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  sv_type = 2 ! vector

  if ( gs == 0 ) then
    imax = ix
    jmax = jx
    kmax = kx
  else
    imax = ix + 2*g
    jmax = jx + 2*g
    kmax = kx + 2*g
  end if

  open(16, file=fname, form='unformatted')
  write(16) sv_type, d_type
  write(16) imax, jmax, kmax
  write(16) org(1), org(2), org(3)
  write(16) pit(1), pit(2), pit(3)
  write(16) step, time

  if ( gs /= 0 ) then
    write(16) ((((v(l,i,j,k),l=1,3),i=1-g,ix+g),j=1-g,jx+g),k=1-g,kx+g)
  else
    write(16) ((((v(l,i,j,k),l=1,3),i=1,ix),j=1,jx),k=1,kx)
  end if
  
  if ( avs == 0 ) then
    write(16) step_avr, time_avr
  end if
  
  close (unit=16)

  return
  end subroutine fb_write_sph_v


!> ********************************************************************
!! @brief スカラ値のロード
!! @param s スカラ
!! @param sz 配列長
!! @param g ガイドセル長
!! @param fname ファイル名
!! @param step ステップ数
!! @param time 時刻
!! @param gs ガイドセルスイッチ (0-without, others-with)
!! @param avs 平均値識別子 (0-average, 1-instantaneous) 
!! @param step_avr
!! @param time_avr
!<
  subroutine fb_read_sph_s(s, sz, g, fname, step, time, gs, avs, step_avr, time_avr)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g, step, gs, step_avr, avs
  integer                                                   ::  sv_type, d_type, imax, jmax, kmax
  integer, dimension(3)                                     ::  sz
  real                                                      ::  x_org, y_org, z_org, dx, dy, dz, time, time_avr
  real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  s
  character(64)                                             ::  fname

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  open(16, file=fname, form='unformatted')

  read(16) sv_type, d_type
  if ( sv_type /= 1 ) then
    write(*,*) 'read error : scalar'
    stop
  end if
  
  read(16) imax, jmax, kmax
  !write (*,*) imax, jmax, kmax, ix, jx, kx
  if ( gs == 0 ) then
    if ( (imax /= ix) .or. (jmax /= jx) .or. (kmax /= kx) ) then
      write(*,*) 'read error : size'
      stop
    end if
  else
    if ( (imax /= (ix+2*g)) .or. (jmax /= (jx+2*g)) .or. (kmax /= (kx+2*g)) ) then
      write(*,*) 'read error : size'
      stop
    end if
  end if
  
  read(16) x_org, y_org, z_org
  read(16) dx, dy, dz
  read(16) step, time
  
  if ( gs == 0 ) then
    read(16) (((s(i,j,k),i=1,ix),j=1,jx),k=1,kx)
  else
    read(16) (((s(i,j,k),i=-1,ix+2),j=-1,jx+2),k=-1,kx+2)
  end if
  
  if ( avs == 0 ) then
    read(16) step_avr, time_avr
  end if
  
  close (unit=16)

  return
  end subroutine fb_read_sph_s
  
!> ********************************************************************
!! @brief ベクトルのロード
!! @param v ベクトル
!! @param sz 配列長
!! @param g ガイドセル長
!! @param fname ファイル名
!! @param step ステップ数
!! @param time 時刻
!! @param gs ガイドセルスイッチ (0-without, others-with)
!! @param avs 平均値識別子 (0-average, 1-instantaneous) 
!! @param step_avr
!! @param time_avr
!<
  subroutine fb_read_sph_v(v, sz, g, fname, step, time, gs, avs, step_avr, time_avr)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g, step, gs, l, step_avr, avs
  integer                                                   ::  sv_type, d_type, imax, jmax, kmax
  integer, dimension(3)                                     ::  sz
  real                                                      ::  x_org, y_org, z_org, dx, dy, dz, time, time_avr
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  v
  character(64)                                             ::  fname

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  open(16, file=fname, form='unformatted')
  
  read(16) sv_type, d_type
  if ( sv_type /= 2 ) then
    write(*,*) 'read error : vector'
    stop
  end if
  
  read(16) imax, jmax, kmax
  if ( gs == 0 ) then
    if ( (imax /= ix) .or. (jmax /= jx) .or. (kmax /= kx) ) then
      write(*,*) 'read error : size'
      stop
    end if
  else
    if ( (imax /= (ix+2*g)) .or. (jmax /= (jx+2*g)) .or. (kmax /= (kx+2*g)) ) then
      write(*,*) 'read error : size'
      stop
    end if
  end if
  
  read(16) x_org, y_org, z_org
  read(16) dx, dy, dz
  read(16) step, time
  
  if ( gs == 0 ) then
    read(16) ((((v(l,i,j,k),l=1,3),i=1,ix),j=1,jx),k=1,kx)
  else
    read(16) ((((v(l,i,j,k),l=1,3),i=-1,ix+2),j=-1,jx+2),k=-1,kx+2)
  end if

  if ( avs == 0 ) then
    read(16) step_avr, time_avr
  end if

  close (unit=16)

  return
  end subroutine fb_read_sph_v
  
  
!> ********************************************************************
!! @brief 圧力値を有次元から無次元へ変換し，scale倍して出力
!! @param s 圧力
!! @param sz 配列長（一次元）
!! @param Base_prs 基準圧力(Pa) 基準圧がゼロのとき，ゲージ圧
!! @param Ref_rho 代表密度(kg/m^3)
!! @param Ref_v 代表速度(m/s)
!! @param scale 倍数（瞬時値のとき1.0）
!! @param flop 浮動小数演算数
!<
  subroutine fb_prs_d2nd (s, sz, Base_prs, Ref_rho, Ref_v, scale, flop)
  implicit none
  integer                                                   ::  i, sz
  real                                                      ::  dp, scale, b_p
  real                                                      ::  Base_prs, Ref_rho, Ref_v
  double precision                                          ::  flop
  real, dimension(sz)                                       ::  s

  dp = scale / (Ref_rho * Ref_v * Ref_v)
  b_p = Base_prs
  flop = flop + dble(sz) * 3.0d0 + 10.0d0

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(sz, dp, b_p)
   
!$OMP DO SCHEDULE(static)

  do i=1,sz
    s(i) = ( s(i) - b_p ) * dp
  end do
!$OMP END DO

!$OMP END PARALLEL

  return
  end subroutine fb_prs_d2nd
  
!> ********************************************************************
!! @brief 圧力値を無次元から有次元へ変換し，scale倍して出力
!! @param dst 有次元
!! @param src 無次元
!! @param sz 配列長（一次元）
!! @param Base_prs 基準圧力(Pa)
!! @param Ref_rho 代表密度(kg/m^3)
!! @param Ref_v 代表速度(m/s)
!! @param mode 圧力の変換モード（１−絶対圧，2-ゲージ圧）
!! @param scale 倍数（瞬時値のとき1.0）
!! @param flop 浮動小数演算数
!<
  subroutine fb_prs_nd2d (dst, src, sz, Base_prs, Ref_rho, Ref_v, scale, flop)
  implicit none
  integer                                                   ::  i, sz
  real                                                      ::  dp, scale, b_p
  real                                                      ::  Base_prs, Ref_rho, Ref_v
  double precision                                          ::  flop
  real, dimension(sz)                                       ::  dst, src

  dp = Ref_rho * Ref_v * Ref_v * scale
  b_p = Base_prs
  flop = flop + dble(sz) * 3.0d0 + 2.0d0

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(sz, dp, b_p)

!$OMP DO SCHEDULE(static)

  do i=1,sz
    dst(i) = ( src(i) * dp + b_p ) 
  end do
!$OMP END DO

!$OMP END PARALLEL

  return
  end subroutine fb_prs_nd2d
  
  
!> ********************************************************************
!! @brief 速度ベクトルの格子速度変換
!! @param v 変換されたベクトル（平均場の場合は積算値）
!! @param sz 配列長
!! @param g ガイドセル長
!! @param v00 参照速度
!! @param sacle 倍数　（瞬時値の場合には1）
!! @param refv 代表速度
!! @param flop 浮動小数演算数
!! @note dst[] = ( src[]/refv + v00 ) * scale, 有次元のときrefvは次元速度，無次元のとき1.0
!<
  subroutine fb_shift_refv_in (v, sz, g, v00, scale, refv, flop)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g
  integer, dimension(3)                                     ::  sz
  real                                                      ::  scale, u_ref, v_ref, w_ref, refv, rr
  double precision                                          ::  flop
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  v
  real, dimension(0:3)                                      ::  v00

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)
  
  u_ref = v00(1)
  v_ref = v00(2)
  w_ref = v00(3)
  
  rr = 1.0/refv
  
  flop = flop + dble(ix)*dble(jx)*dble(kx)*9.0d0 + 8.0d0


!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, u_ref, v_ref, w_ref, scale, rr)

!$OMP DO SCHEDULE(static)

  do k=1,kx
  do j=1,jx
  do i=1,ix 
    v(1,i,j,k) = ( v(1,i,j,k) * rr + u_ref ) * scale
    v(2,i,j,k) = ( v(2,i,j,k) * rr + v_ref ) * scale
    v(3,i,j,k) = ( v(3,i,j,k) * rr + w_ref ) * scale
  end do
  end do
  end do
  
!$OMP END DO
!$OMP END PARALLEL

  return
  end subroutine fb_shift_refv_in
  
!> ********************************************************************
!! @brief 速度ベクトルの格子速度変換をして，scale倍する
!! @param vout 変換されたベクトル
!! @param vin 変換前
!! @param sz 配列長
!! @param g ガイドセル長
!! @param v00 参照速度
!! @param scale 倍数（瞬時値の場合には1）
!! @param unit_v 無次元のとき1.0，有次元のとき代表速度(m/s)
!! @param flop 浮動小数演算数
!! @note dst[] = ( src[] * stepAvr ) - v00
!<
  subroutine fb_shift_refv_out (vout, vin, sz, g, v00, scale, unit_v, flop)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g
  integer, dimension(3)                                     ::  sz
  real                                                      ::  u_ref, v_ref, w_ref, unit_v, scale, unit
  double precision                                          ::  flop
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  vout, vin
  real, dimension(0:3)                                      ::  v00

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)
  
  u_ref = v00(1)
  v_ref = v00(2)
  w_ref = v00(3)

  unit = unit_v
  
  flop = flop + dble(ix)*dble(jx)*dble(kx)*9.0d0


!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx, u_ref, v_ref, w_ref, scale, unit)

!$OMP DO SCHEDULE(static)

  do k=1,kx
  do j=1,jx
  do i=1,ix 
    vout(1,i,j,k) = ( vin(1,i,j,k) * scale - u_ref ) * unit
    vout(2,i,j,k) = ( vin(2,i,j,k) * scale - v_ref ) * unit
    vout(3,i,j,k) = ( vin(3,i,j,k) * scale - w_ref ) * unit
  end do
  end do
  end do
  
!$OMP END DO
!$OMP END PARALLEL

  return
  end subroutine fb_shift_refv_out
  
!> ********************************************************************
!! @brief 有効セルに対する，1タイムステップ進行時のベクトルの絶対値の変化量の和と平均値
!! @param d 戻り値（変化量の2乗和と平均値）
!! @param sz 配列長
!! @param g ガイドセル長
!! @param vn ベクトル値 n+1 step
!! @param vo ベクトル値 n step
!! @param bx BCindex
!! @param flop 浮動小数演算数
!<
  subroutine fb_delta_v (d, sz, g, vn, vo, bx, flop)
  implicit none
  include 'ffv_f_params.h'
  integer                                                   ::  i, j, k, ix, jx, kx, g
  integer, dimension(3)                                     ::  sz
  double precision                                          ::  u, v, w, x, y, z, actv
  double precision                                          ::  flop, av, rm
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  vn, vo
  integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bx
  double precision, dimension(2)                            ::  d

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  flop = flop + dble(ix)*dble(jx)*dble(kx)*58.0d0
  ! sqrt float->10, double->20

  av = 0.0
  rm = 0.0

!$OMP PARALLEL &
!$OMP PRIVATE(actv, u, v, w, x, y, z) &
!$OMP FIRSTPRIVATE(ix, jx, kx)

!$OMP DO SCHEDULE(static) &
!$OMP REDUCTION(+:av) &
!$OMP REDUCTION(+:rm)
  do k=1,kx
  do j=1,jx
  do i=1,ix

    actv = real(ibits(bx(i,j,k), State, 1))
    
    u = dble(vn(1,i,j,k))
    v = dble(vn(2,i,j,k))
    w = dble(vn(3,i,j,k))
    av = av + sqrt(u*u + v*v + w*w)*actv
    
    x = u - dble(vo(1,i,j,k))
    y = v - dble(vo(2,i,j,k))
    z = w - dble(vo(3,i,j,k))
    rm = rm + sqrt(x*x + y*y + z*z)*actv

  end do
  end do
  end do
!$OMP END DO
!$OMP END PARALLEL

  d(1) = rm
  d(2) = av

  return
  end subroutine fb_delta_v

!> ********************************************************************
!! @brief 有効セルに対する，1タイムステップ進行時の変化量の2乗和と平均値(RootMean)
!! @param d 戻り値（変化量の2乗和と平均値）
!! @param sz 配列長
!! @param g ガイドセル長
!! @param sn スカラー値 n+1 step
!! @param so スカラー値 n step
!! @param bx BCindex
!! @param flop 浮動小数演算数
!<
  subroutine fb_delta_s (d, sz, g, sn, so, bx, flop)
  implicit none
  include 'ffv_f_params.h'
  integer                                                   ::  i, j, k, ix, jx, kx, g
  integer, dimension(3)                                     ::  sz
  double precision                                          ::  a, s, av, rm, actv, flop
  real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  sn, so
  integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bx
  double precision, dimension(2)                            ::  d

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  flop = flop + dble(ix)*dble(jx)*dble(kx)*7.0d0

  av = 0.0
  rm = 0.0

!$OMP PARALLEL &
!$OMP PRIVATE(actv, s, a) &
!$OMP FIRSTPRIVATE(ix, jx, kx)

!$OMP DO SCHEDULE(static) &
!$OMP REDUCTION(+:av) &
!$OMP REDUCTION(+:rm)
  do k=1,kx
  do j=1,jx
  do i=1,ix
    actv = dble(ibits(bx(i,j,k), State,  1))
    
    s = dble(sn(i,j,k))
    av = av + s * actv
    
    a = ( s - dble(so(i,j,k)) )*actv
    rm = rm + a*a
  end do
  end do
  end do
!$OMP END DO
!$OMP END PARALLEL
  
  d(1) = rm
  d(2) = av

  return
  end subroutine fb_delta_s

!> ********************************************************************
!! @brief ベクトル値を加算する
!! @param avr 平均値
!! @param sz 配列長
!! @param g ガイドセル長
!! @param v ベクトル値
!! @param flop 浮動小数演算数
!<
  subroutine fb_average_v (avr, sz, g, v, flop)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g
  integer, dimension(3)                                     ::  sz
  double precision                                          ::  flop
  real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  v, avr

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  flop = flop + dble(ix)*dble(jx)*dble(kx)*3.0d0

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx)

!$OMP DO SCHEDULE(static)

  do k=1,kx
  do j=1,jx
  do i=1,ix
    avr(1,i,j,k) = avr(1,i,j,k) + v(1,i,j,k)
    avr(2,i,j,k) = avr(2,i,j,k) + v(2,i,j,k)
    avr(3,i,j,k) = avr(3,i,j,k) + v(3,i,j,k)
  end do
  end do
  end do
!$OMP END DO
!$OMP END PARALLEL

  return
  end subroutine fb_average_v

!> ********************************************************************
!! @brief スカラ値を加算する
!! @param avr 平均値
!! @param sz 配列長
!! @param g ガイドセル長
!! @param s スカラ値
!! @param flop 浮動小数演算数
!<
  subroutine fb_average_s (avr, sz, g, s, flop)
  implicit none
  integer                                                   ::  i, j, k, ix, jx, kx, g
  integer, dimension(3)                                     ::  sz
  double precision                                          ::  flop
  real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  s, avr

  ix = sz(1)
  jx = sz(2)
  kx = sz(3)

  flop = flop + dble(ix)*dble(jx)*dble(kx)*1.0d0

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx)

!$OMP DO SCHEDULE(static)

  do k=1,kx
  do j=1,jx
  do i=1,ix
    avr(i,j,k) = avr(i,j,k) + s(i,j,k)
  end do
  end do
  end do
!$OMP END DO
!$OMP END PARALLEL

  return
  end subroutine fb_average_s


!> ********************************************************************
!! @brief 全圧を計算する
!! @param tp 全圧
!! @param sz 配列長
!! @param g ガイドセル長
!! @param v 速度ベクトル
!! @param p 圧力
!! @param v00 参照速度
!! @param flop 浮動小数演算数
!<
    subroutine fb_totalp (tp, sz, g, v, p, v00, flop)
    implicit none
    integer                                                   ::  i, j, k, ix, jx, kx, g
    integer, dimension(3)                                     ::  sz
    real                                                      ::  u1, u2, u3, vx, vy, vz
    double precision                                          ::  flop
    real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  v
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  p, tp
    real, dimension(0:3)                                      ::  v00

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    vx = v00(1)
    vy = v00(2)
    vz = v00(3)

!$OMP PARALLEL &
!$OMP PRIVATE(u1, u2, u3) &
!$OMP FIRSTPRIVATE(ix, jx, kx, vx, vy, vz)

!$OMP DO SCHEDULE(static)

    do k=1,kx
    do j=1,jx
    do i=1,ix
      u1 = v(1,i,j,k) - vx
      u2 = v(2,i,j,k) - vy
      u3 = v(3,i,j,k) - vz
      tp(i,j,k) = 0.5*(u1*u1 + u2*u2 + u3*u3) + p(i,j,k)
    end do
    end do
    end do
!$OMP END DO
!$OMP END PARALLEL
        
    flop = flop + dble(ix)*dble(jx)*dble(kx)*10.0d0
    
    return
    end subroutine fb_totalp

!> ********************************************************************
!! @brief 速度の最小値と最大値を計算する
!! @param v_min 最小値
!! @param v_max 最大値
!! @param sz 配列長
!! @param g ガイドセル長
!! @param v00 参照速度
!! @param v 速度ベクトル
!! @param flop 浮動小数演算数
!<
    subroutine fb_minmax_v (v_min, v_max, sz, g, v00, v)
    implicit none
    integer                                                   ::  i, j, k, ix, jx, kx, g
    integer, dimension(3)                                     ::  sz
    real                                                      ::  v_min, v_max, u1, u2, u3, uu, flop, vx, vy, vz
    real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  v
    real, dimension(0:3)                                      ::  v00

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    vx = v00(1)
    vy = v00(2)
    vz = v00(3)
    v_min =  1.0e6
    v_max = -1.0e6
    
    ! 10 + sqrt*1 = 20 ! DP 30
    flop = flop + real(ix)*real(jx)*real(kx)*20.0d0
    ! flop = flop + real(ix)*real(jx)*real(kx)*30.0 ! DP

!$OMP PARALLEL &
!$OMP PRIVATE(u1, u2, u3, uu) &
!$OMP FIRSTPRIVATE(ix, jx, kx, vx, vy, vz)

!$OMP DO SCHEDULE(static) &

!$OMP REDUCTION(min:v_min) &
!$OMP REDUCTION(max:v_max)
    do k=1,kx
    do j=1,jx
    do i=1,ix
			u1 = v(1,i,j,k)-vx
			u2 = v(2,i,j,k)-vy
			u3 = v(3,i,j,k)-vz
			uu = sqrt( u1*u1 + u2*u2 + u3*u3 )
      v_min = min(v_min, uu)
      v_max = max(v_max, uu)
    end do
    end do
    end do
!$OMP END DO
!$OMP END PARALLEL

    return
    end subroutine fb_minmax_v

!> ********************************************************************
!! @brief スカラ値の最小値と最大値を計算する
!! @param f_min 最小値
!! @param f_max 最大値
!! @param sz 配列長
!! @param g ガイドセル長
!! @param s スカラ値
!! @param flop 浮動小数演算数
!<
    subroutine fb_minmax_s (f_min, f_max, sz, g, s, flop)
    implicit none
    integer                                                   ::  i, j, k, ix, jx, kx, g
    integer, dimension(3)                                     ::  sz
    real                                                      ::  f_min, f_max
    double precision                                          ::  flop
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  s

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    f_min =  1.0e6
    f_max = -1.0e6
    
    flop = flop + dble(ix)*dble(jx)*dble(kx)*2.0d0

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(ix, jx, kx)

!$OMP DO SCHEDULE(static) &
!$OMP REDUCTION(min:f_min) &
!$OMP REDUCTION(max:f_max)
    do k=1,kx
    do j=1,jx
    do i=1,ix
      f_min = min(f_min, s(i,j,k))
      f_max = max(f_max, s(i,j,k))
    end do
    end do
    end do
!$OMP END DO
!$OMP END PARALLEL

    return
    end subroutine fb_minmax_s

!> ********************************************************************
!! @brief ベクトル値を設定する
!! @param var ベクトル配列
!! @param sz 配列長
!! @param g ガイドセル長
!! @param val ベクトル値
!! @param bv
!<
    subroutine fb_set_vector (var, sz, g, val, bv)
    implicit none
    include '../FB/ffv_f_params.h'
    integer                                                   ::  i, j, k, ix, jx, kx, g, bvx
    integer, dimension(3)                                     ::  sz
    real                                                      ::  u1, u2, u3
    real, dimension(3)                                        ::  val
    real, dimension(3, 1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  var
    integer, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g) ::  bv

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)
    u1 = val(1)
    u2 = val(2)
    u3 = val(3)

!$OMP PARALLEL &
!$OMP FIRSTPRIVATE(u1, u2, u3) &
!$OMP FIRSTPRIVATE(ix, jx, kx, g) &
!$OMP PRIVATE(bvx)

!$OMP DO SCHEDULE(static)

    do k=1-g, kx+g
    do j=1-g, jx+g
    do i=1-g, ix+g
        bvx = ibits(bv(i,j,k), State, 1)
        var(1,i,j,k) = u1 * real(bvx)
        var(2,i,j,k) = u2 * real(bvx)
        var(3,i,j,k) = u3 * real(bvx)
    end do
    end do
    end do
!$OMP END DO
!$OMP END PARALLEL

    return
    end subroutine fb_set_vector

!> ********************************************************************
!! @brief スカラ値の値を[0, 1]に制限する
!! @param t スカラ値
!! @param sz 配列長
!! @param g ガイドセル長
!<
    subroutine fb_limit_scalar (t, sz, g)
    implicit none
    integer                                                   ::  i, j, k, ix, jx, kx, g
    integer, dimension(3)                                     ::  sz
    real                                                      ::  tmp
    real, dimension(1-g:sz(1)+g, 1-g:sz(2)+g, 1-g:sz(3)+g)    ::  t

    ix = sz(1)
    jx = sz(2)
    kx = sz(3)

!$OMP PARALLEL &
!$OMP PRIVATE(tmp) &
!$OMP FIRSTPRIVATE(ix, jx, kx)

!$OMP DO SCHEDULE(static)

    do k=1,kx
    do j=1,jx
    do i=1,ix
      tmp = t(i,j,k)
      if (tmp<0.0) t(i,j,k)=0.0
      if (tmp>1.0) t(i,j,k)=1.0
    end do
    end do
    end do
!$OMP END DO
!$OMP END PARALLEL

    return
    end subroutine fb_limit_scalar

