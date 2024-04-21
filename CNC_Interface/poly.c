//
//  spline.c
//  CNC_Interface
//
//  Created by Ruedi Heimlicher on 09.01.2023.
//  Copyright © 2023 Ruedi Heimlicher. All rights reserved.
//

#include "poly.h"
#include <stdio.h>
#include <stdlib.h>


#include<math.h>

/*******
 Function that performs Gauss-Elimination and returns the Upper triangular matrix and solution of equations:
There are two options to do this in C.
1. Pass the augmented matrix (a) as the parameter, and calculate and store the upperTriangular(Gauss-Eliminated Matrix) in it.
2. Use malloc and make the function of pointer type and return the pointer.
This program uses the first option.
********/

void setPolyPixelInt(int x, int y)
{
   printf("%d\t%d ",x,y);
}
void setPolyPixelDouble(double x, double y)
{
   printf("%lf\t%lf ",x,y);
}

// koeffizienten fuer polynom aus bereich punkten von startindex bis startindex+bereich
void koeffarray(double* x, double* y, int startindex, int bereich, int length, double* koeff, double wert)
{
   int endindex = startindex + bereich;
   
   for (int index=0;index < bereich; index++)
   {
      koeff[index] = 1;
      printf("\n");
      for (int k=0;k<bereich;k++)
      {
         printf("%d\t %d \t %lf \t",index,k,x[startindex+index]);
         if(k==index) // eigene pos
         {
            printf("\t    k==index %d\t",k);
         }
         else
         {
            double element = (wert-x[startindex+k])/(x[startindex+index]-x[startindex+k]);
            koeff[index] *= (wert-x[startindex+k])/(x[startindex+index]-x[startindex+k]);
            printf("\t* %lf *\t",element);
         }
         printf("%d\t %d \t %lf \n",index,k,koeff[index]);
      }
   }
}

double lagrangewert(double* x, double* y, int firstindex, int bereich, int length,  double wert)
{
   /*
   x,y: Bereiche von x,y in bereich, angefangen bei firstindex
   startindex: index der ersten Stuetzstelle
    length: unbenutzt
    koeffarray: array fuer koeffizienden des polynoms, lokal
    wert: x-wert fuer den y-rueckgabewert, gemessen ab stuetzstelle an startindex
    
    */
   double koeffarray[bereich];
   double werty=0; // 
  // int endindex = firstindex + bereich;
   
   for (int index=0;index < bereich; index++) // Iterieren ueber Stuetzstellen
   {
      koeffarray[index] = 1;
 //     printf("\nindex: %d\n",index);
      for (int k=0;k<bereich;k++)
      {
  //       printf("%d \t %lf \t",k,x[startindex+index]);
         if(k==index) // aktuelle pos, auslassen
         {
  //          printf("\t  k==index k: %d\t",k);
         }
         else // werte der anderen positionen verwenden
         {
            double element = (wert-x[firstindex+k])/(x[firstindex+index]-x[firstindex+k]);
            //printf("\t*** %dn\t%lf\t%lf\t***\t",k,wert,element);
            koeffarray[index] *= (wert-x[firstindex+k])/(x[firstindex+index]-x[firstindex+k]);
  //          printf("\t* %lf *\t",element);
         }
         //printf("%d\t %d \t %lf \t werty: %lf \n",index,k,koeff[index],werty);
 //        printf("\n");
      }
      werty += koeffarray[index]*y[firstindex+index];
      
   }
   //printf("lagrangewert von \t%lf\t: firstx:\t %lf\tlastx: \t%lf\t  ist werty:\t %lf\n",wert,x[firstindex],x[firstindex+bereich-1],werty);
   return werty;
}


// werte fuer erstes Intervall
double lagrangewertstart(double* x, double* y, int bereich, double wert)
{
   double werty=0; // 
   int startindex = 0;
   double koeffarray[bereich];
   for (int index=0;index < bereich; index++)
   {
      koeffarray[index] = 1;
 //     printf("\nindex: %d\n",index);
      for (int k=0;k<bereich;k++)
      {
  //       printf("%d \t %lf \t",k,x[startindex+index]);
         if(k==index) // eigene pos
         {
  //          printf("\t  k==index k: %d\t",k);
         }
         else
         {
            double element = (wert-x[startindex+k])/(x[startindex+index]-x[startindex+k]);
            koeffarray[index] *= (wert-x[startindex+k])/(x[startindex+index]-x[startindex+k]);
  //          printf("\t* %lf *\t",element);
         }
         //printf("%d\t %d \t %lf \t werty: %lf \n",index,k,koeff[index],werty);
 //        printf("\n");
      }
      werty += koeffarray[index]*y[startindex+index];
   }
   return werty;
}
