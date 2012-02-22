#ifndef _SKL_FB_vec3f_func_h
#define _SKL_FB_vec3f_func_h

/*
 * SPHERE - Skeleton for PHysical and Engineering REsearch
 *
 * Copyright (c) RIKEN, Japan. All right reserved. 2004-2012
 *
 */

//@file vec3f_func.h
//@brief FlowBase class geometry functions
//@author T. Tawara and keno, FSI Team, VCAD, RIKEN

/**
 @fn inline void vec3f_copy(float to[3], const float from[3])
 @brief copy data
 */
inline
void vec3f_copy(float to[3], const float from[3])
{
	to[0] = from[0];
	to[1] = from[1];
	to[2] = from[2];
}

/**
 @fn inline void vec3f_set(float v[3], float x, float y, float z)
 @brief set data
 */
inline
void vec3f_set(float v[3], float x, float y, float z)
{
	v[0] = x;
	v[1] = y;
	v[2] = z;
}

/**
 @fn inline void vec3f_min(float c[3], const float a[3], const float b[3])
 @brief get minimum
 */
inline
void vec3f_min(float c[3], const float a[3], const float b[3])
{
	c[0] = (a[0] < b[0]) ? a[0] : b[0];
	c[1] = (a[1] < b[1]) ? a[1] : b[1];
	c[2] = (a[2] < b[2]) ? a[2] : b[2];
}

/**
 @fn inline void vec3f_max(float c[3], const float a[3], const float b[3])
 @brief get maximum
 */
inline
void vec3f_max(float c[3], const float a[3], const float b[3])
{
	c[0] = (a[0] > b[0]) ? a[0] : b[0];
	c[1] = (a[1] > b[1]) ? a[1] : b[1];
	c[2] = (a[2] > b[2]) ? a[2] : b[2];
}

/**
 @fn inline void vec3f_plus(float c[3], const float a[3], const float b[3])
 @brief c[] = a[] + b[]
 */
inline
void vec3f_plus(float c[3], const float a[3], const float b[3])
{
	c[0] = a[0] + b[0];
	c[1] = a[1] + b[1];
	c[2] = a[2] + b[2];
}

/**
 @fn inline void vec3f_minus(float c[3], const float a[3], const float b[3])
 @brief c[] = a[] - b[]
 */
inline
void vec3f_minus(float c[3], const float a[3], const float b[3])
{
	c[0] = a[0] - b[0];
	c[1] = a[1] - b[1];
	c[2] = a[2] - b[2];
}

/**
 @fn inline void vec3f_multi(float c[3], const float a[3], const float b[3])
 @brief c[] = a[] * b[]
 */
inline
void vec3f_multi(float c[3], const float a[3], const float b[3])
{
	c[0] = a[0] * b[0];
	c[1] = a[1] * b[1];
	c[2] = a[2] * b[2];
}

/**
 @fn inline void vec3f_multi(float c[3], const float a[3], const float b)
 @brief c[] = a[] * b
 */
inline
void vec3f_multi(float c[3], const float a[3], const float b)
{
	c[0] = a[0] * b;
	c[1] = a[1] * b;
	c[2] = a[2] * b;
}

/**
 @fn inline void vec3f_div(float c[3], const float a[3], const float b[3])
 @brief c[] = a[] / b[]
 */
inline
void vec3f_div(float c[3], const float a[3], const float b[3])
{
	c[0] = a[0] / b[0];
	c[1] = a[1] / b[1];
	c[2] = a[2] / b[2];
}

/**
 @fn inline void vec3f_div(float c[3], const float a[3], const float b)
 @brief c[] = a[] / b
 */
inline
void vec3f_div(float c[3], const float a[3], const float b)
{
	float inv = 1.f / b;
	c[0] = a[0] * inv;
	c[1] = a[1] * inv;
	c[2] = a[2] * inv;
}

/**
 @fn inline float vec3f_dot(const float a[3], const float b[3])
 @brief return inner product (a[],b[])
 */
inline
float vec3f_dot(const float a[3], const float b[3])
{
	return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

/**
 @fn inline void vec3f_cross(float c[3], const float a[3], const float b[3])
 @brief cross product c[] = a[] x b[]
 */
inline
void vec3f_cross(float c[3], const float a[3], const float b[3])
{
	c[0] = a[1] * b[2] - a[2] * b[1];
	c[1] = a[2] * b[0] - a[0] * b[2];
	c[2] = a[0] * b[1] - a[1] * b[0];
}

/**
 @fn inline float vec3f_sqdist(const float a[3], const float b[3])
 @brief return squared distance between a[] and b[]
 */
inline
float vec3f_sqdist(const float a[3], const float b[3])
{
	float x = a[0] - b[0];
	float y = a[1] - b[1];
	float z = a[2] - b[2];
	return x*x + y*y + z*z;
}

/**
 @fn inline float vec3f_dist(const float a[3], const float b[3])
 @brief return distance between a[] and b[]
 */
inline
float vec3f_dist(const float a[3], const float b[3])
{
	return sqrtf(vec3f_sqdist(a, b));
}

#endif  // _SKL_FB_vec3f_func_h
