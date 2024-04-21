//
//  poly.h
//  CNC_Interface
//
//  Created by Ruedi Heimlicher on 09.01.2023.
//  Copyright © 2023 Ruedi Heimlicher. All rights reserved.
//

#ifndef poly_h
#define poly_h

#include <stdio.h>

extern void koeffarray(double* x, double* y, int startindex, int bereich, int length, double* koeff, double wert);
extern double lagrangewert(double* x, double* y, int startindex, int bereich, int length, double wert);
extern double lagrangewertstart(double* x, double* y, int bereich, double wert);
#endif /* poly_h */
