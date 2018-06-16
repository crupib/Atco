// Define to prevent recursive inclusion ------------------------------------- //
#ifndef __LIB3D_H
#define __LIB3D_H

#include "stm32f7xx.h"
#include "stm32f7xx_hal.h"
#include "stmF7_gfx.h"
#include "stm32_ub_fatfs.h"
#include <math.h>

// 3D Point structure
typedef struct {
	float x;						
	float y;						
	float z;						
} Pts3D;							// 12 bytes for this structure

// 3D Angle structure
typedef struct {
	int16_t x;						
	int16_t y;						
	int16_t z;						
} Angle3D;							// 12 bytes for this structure

// 3D Face structure
typedef struct {
	uint32_t p1;				
	uint32_t p2;				
	uint32_t p3;				
	uint16_t incolor;
	uint16_t outcolor;
} Face3D;							// 16 bytes for this structure

// 3D zBuffer Face structure
typedef struct {
	uint32_t p1;
	uint32_t p2;
	uint32_t p3;
	uint16_t incolor;
	uint16_t outcolor;
	uint16_t objnum;
} zBuff3D;							// 18 bytes for this structure

#define Max3DPoint					600
#define Max3DFace					600
// 3D Object Structure
typedef struct {
	Pts3D 		Coord;				// 12 bytes
	Angle3D		Angle;				// 12 bytes
	float 		Zoom;				//  4 bytes
	Pts3D		Pts[Max3DPoint];	//600 points - 7200 bytes
	Pts3D		CalcPts[Max3DPoint];//600 points - 7200 bytes
	Face3D		Face[Max3DFace];	//600 faces  - 9600 bytes
	uint32_t	NbPoint;			//  4 bytes
	uint32_t	NbFace;				//  4 bytes
	uint8_t		Loaded;				//	1 byte
	uint8_t		Active;				//	1 byte
} Obj3D;							// 24038 bytes for this structure

// Variable for 3D Objects
#define MaxP3D					 	15000
#define MaxFce					 	15000
#define MaxObj					 	25

// This ones have to be initialized in "lib3d.c"
// and section have to be declared in LinkerScript.ld
// 1Mbytes (1024K) are reserved in SDRAM for 3D
extern Obj3D		Object3D[];
extern zBuff3D		zBuffer[];
extern float		zBuffVal[];

extern uint16_t		VisibleFaces;

// Precalculated sine and cosine in degrees from 0 to 360
extern const float calcsi[];
extern const float calcco[];

void Init3d(void);
uint8_t Load_3DObj(const char* filename , uint16_t ObjectNum, uint16_t incolor, uint16_t outcolor);
void Compute3D(void);
void zBuff(uint16_t nb);
void Cache3D(void);
void Show_3DObject(uint8_t Filled , uint8_t BuffNum);

#endif // __LIB3D_H //
