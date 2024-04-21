//
//  spline.c
//  CNC_Interface
//
//  Created by Ruedi Heimlicher on 09.01.2023.
//  Copyright © 2023 Ruedi Heimlicher. All rights reserved.
//

#include "spline.h"
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

void setPixelInt(int x, int y)
{
   printf("%d\t%d ",x,y);
}
void setPixelDouble(double x, double y)
{
   printf("%lf\t%lf ",x,y);
}
void gaussEliminationLS(int m, int n, double a[m][n], double x[n-1]){
    int i,j,k;
    for(i=0;i<m-1;i++){
        /*//Partial Pivoting
        for(k=i+1;k<m;k++){
            //If diagonal element(absolute vallue) is smaller than any of the terms below it
            if(fabs(a[i][i])<fabs(a[k][i])){
                //Swap the rows
                for(j=0;j<n;j++){                
                    double temp;
                    temp=a[i][j];
                    a[i][j]=a[k][j];
                    a[k][j]=temp;
                }
            }
        }*/
        //Begin Gauss Elimination
        for(k=i+1;k<m;k++){
            double  term=a[k][i]/ a[i][i];
            for(j=0;j<n;j++){
                a[k][j]=a[k][j]-term*a[i][j];
            }
        }
         
    }
    //Begin Back-substitution
    for(i=m-1;i>=0;i--){
        x[i]=a[i][n-1];
        for(j=i+1;j<n-1;j++){
            x[i]=x[i]-a[i][j]*x[j];
        }
        x[i]=x[i]/a[i][i];
    }
             
}
/********************
Cubic Spline coefficients calculator
Function that calculates the values of ai, bi, ci, and di's for the cubic splines:
ai(x-xi)^3+bi(x-xi)^2+ci(x-xi)+di
********************/
void cSCoeffCalc(int n, double h[n], double sig[n+1], double y[n+1], double a[n], double b[n], double c[n], double d[n]){
    int i;
    for(i=0;i<n;i++){
        d[i]=y[i];
        b[i]=sig[i]/2.0;
        a[i]=(sig[i+1]-sig[i])/(h[i]*6.0);
        c[i]=(y[i+1]-y[i])/h[i]-h[i]*(2*sig[i]+sig[i+1])/6.0;
    }
}
/********************
Function to generate the tridiagonal augmented matrix 
for cubic spline for equidistant data-points
Parameters:
n: no. of data-points
h: array storing the succesive interval widths
a: matrix that will hold the generated augmented matrix
y: array containing the y-axis data-points 
********************/
void tridiagonalCubicSplineGen(int n, double h[n], double a[n-1][n], double y[n+1]){
    int i;
    for(i=0;i<n-1;i++){
        a[i][i]=2*(h[i]+h[i+1]);
    }
    for(i=0;i<n-2;i++){
        a[i][i+1]=h[i+1];
        a[i+1][i]=h[i+1];
    }
    for(i=1;i<n;i++){
        a[i-1][n-1]=(y[i+1]-y[i])*6/(double)h[i]-(y[i]-y[i-1])*6/(double)h[i-1];
    }
} 
/*******
Function that prints the elements of a matrix row-wise
Parameters: rows(m),columns(n),matrix[m][n] 
*******/
void printMatrix(int m, int n, double matrix[m][n]){
    int i,j;
    for(i=0;i<m;i++){
        for(j=0;j<n;j++){
            printf("%lf\t",matrix[i][j]);
        }
        printf("\n");
    } 
}
/*******
Function that copies the elements of a matrix to another matrix
Parameters: rows(m),columns(n),matrix1[m][n] , matrix2[m][n]
*******/
void copyMatrix(int m, int n, double matrix1[m][n], double matrix2[m][n]){
    int i,j;
    for(i=0;i<m;i++){
        for(j=0;j<n;j++){
            matrix2[i][j]=matrix1[i][j];
        }
    } 
}
void makespline()
{
    int m,i;
   printf("\n\nmakespline\n");
    printf("Enter the no. of data-points:\n");
    m = 4;
    int n=m-1;  //Now (n+1) is the total no. of data-points, following our convention
    double x[n+1]; //array to store the x-axis points
    double y[n+1]; //array to store the y-axis points
    double h[n];   ////array to store the successive interval widths
   // printf("Enter the x-axis values:\n");
    
   x[0] = 1.0;
   x[1] = 1.1;
   x[2] = 1.2;
   x[3] = 1.3;

   y[0] = 0.1;
   y[1] = 0.25;
   y[2] = 0.4;
   y[3] = 0.7;
   printf("makespline values:\n");
   for(i=0;i<n+1;i++)
   {
      printf("i: %d \t x: \t%lf\t y: \t\t%lf\n",i,x[i],y[i]);
   }
   for(i=0;i<n;i++){
       h[i]=x[i+1]-x[i];
   }

   
    double a[n]; //array to store the ai's
    double b[n]; //array to store the bi's
    double c[n]; //array to store the ci's
    double d[n]; //array to store the di's
    double sig[n+1]; //array to store Si's
    double sigTemp[n-1]; //array to store the Si's except S0 and Sn
    sig[0]=0;
    sig[n]=0;
    double tri[n-1][n]; //matrix to store the tridiagonal system of equations that will solve for Si's
    tridiagonalCubicSplineGen(n,h,tri,y); //to initialize tri[n-1][n]
    printf("The tridiagonal system for the Natural spline is:\n\n");
    printMatrix(n-1,n,tri);
    //Perform Gauss Elimination 
    gaussEliminationLS(n-1,n,tri,sigTemp);
    for(i=1;i<n;i++){
        sig[i]=sigTemp[i-1];
    }
    //Print the values of Si's
    for(i=0;i<n+1;i++){
        printf("\nSig[%d] = %lf\n",i,sig[i]);   
    }
    //calculate the values of ai's, bi's, ci's, and di's
    cSCoeffCalc(n,h,sig,y,a,b,c,d);
    printf("The equations of cubic interpolation polynomials between the successive intervals are:\n\n");
    for(i=0;i<n;i++){
        printf("P%d(x) b/w [%lf,%lf] = %lf*(x-%lf)^3+%lf*(x-%lf)^2+%lf*(x-%lf)+%lf\n",i,x[i],x[i+1],a[i],x[i],b[i],x[i],c[i],x[i],d[i]);
    }
         
     
     
}


void splinearrayfunc(double* x, double* y, int m, double* a, double* b, double* c, double* d)
{
   printf("\nsplinearrayfunc:\n");
    int i;
    //m=4;
    int n=m-1;  //Now (n+1) is the total no. of data-points, following our convention
//    double x[n+1] ; //array to store the x-axis points
//    double y[n+1]; //array to store the y-axis points
   double h[n] ;   ////array to store the successive interval widths
   double sig[n+1]; //array to store Si's
   double sigTemp[n-1]; //array to store the Si's except S0 and Sn

   /*
   x[0] = 1.0;
   x[1] = 0.9998;
   x[2] = 0.9991;
   x[3] = 0.9978;

   y[0] = -0.0005;
   y[1] = -0.0011;
   y[2] = -0.0021;
   y[3] = -0.0033;
    */
   /*
   x[0] = 1.0;
   x[1] = 1.1;
   x[2] = 1.2;
   x[3] = 1.3;

   y[0] = 0.1;
   y[1] = 0.25;
   y[2] = 0.4;
   y[3] = 0.7;
    */
   printf("values:\n");
   for(i=0;i<n+1;i++)
   {
      printf("i: %d \t x: \t%lf\t y: \t\t%lf\n",i,x[i],y[i]);
   }

   
    for(i=0;i<n;i++)
    {
        h[i]=x[i+1]-x[i];
       sig[i] = 0;
    }
   /*
    double a[n]; //array to store the ai's
    double b[n]; //array to store the bi's
    double c[n]; //array to store the ci's
    double d[n]; //array to store the di's
    */
     sig[0]=0;
    sig[n]=0;
   
   for(i=0;i<n;i++)
   {
      printf("%d\t%f\n",i,sig[i]);
   }

    double tri[n-1][n]; //matrix to store the tridiagonal system of equations that will solve for Si's
    tridiagonalCubicSplineGen(n,h,tri,y); //to initialize tri[n-1][n]
    printf("splinearrayfunc The tridiagonal system for the Natural spline is:\n");
    printMatrix(n-1,n,tri);
    //Perform Gauss Elimination 
    gaussEliminationLS(n-1,n,tri,sigTemp);
    for(i=1;i<n;i++)
    {
        sig[i]=sigTemp[i-1];
    }
    //Print the values of Si's
   
    for(i=0;i<n+1;i++){
        printf("\nSig[%d] = %lf",i,sig[i]);   
    }
    //calculate the values of ai's, bi's, ci's, and di's
    cSCoeffCalc(n,h,sig,y,a,b,c,d);
    printf("\nsplinearrayfunc: The equations of cubic interpolation polynomials between the successive intervals are:\n\n");
   for(i=0;i<n;i++){
      printf("P%d(x) b/w [%lf,%lf] = %lf*(x-%lf)^3+%lf*(x-%lf)^2+%lf*(x-%lf)+%lf\n",i,x[i],x[i+1],    a[i],x[i],b[i],x[i],c[i],x[i],d[i]);
      // Bereich x[0] - <x[1]:  y[x] =  a[i]*(x-x[0])^3 + b[i]*(x-x[0])^2 + c[i]*(x-x[0] + d[i]
   }
         
     
     
}
void splinefunc()
{
    int m,i;
    m=4;
    int n=m-1;  //Now (n+1) is the total no. of data-points, following our convention
    double x[n+1] ; //array to store the x-axis points
    double y[n+1]; //array to store the y-axis points
    double h[n];   ////array to store the successive interval widths
   /*
   x[0] = 1.0;
   x[1] = 0.9998;
   x[2] = 0.9991;
   x[3] = 0.9978;

   y[0] = -0.0005;
   y[1] = -0.0011;
   y[2] = -0.0021;
   y[3] = -0.0033;
    */
   x[0] = 1.0;
   x[1] = 1.1;
   x[2] = 1.2;
   x[3] = 1.3;

   y[0] = 0.1;
   y[1] = 0.25;
   y[2] = 0.4;
   y[3] = 0.7;
   printf("values:\n");
   for(i=0;i<n+1;i++)
   {
      printf("i: %d \t x: \t%lf\t y: \t\t%lf\n",i,x[i],y[i]);
   }

   
    for(i=0;i<n;i++){
        h[i]=x[i+1]-x[i];
    }
    double a[n]; //array to store the ai's
    double b[n]; //array to store the bi's
    double c[n]; //array to store the ci's
    double d[n]; //array to store the di's
    double sig[n+1]; //array to store Si's
    double sigTemp[n-1]; //array to store the Si's except S0 and Sn
    sig[0]=0;
    sig[n]=0;
    double tri[n-1][n]; //matrix to store the tridiagonal system of equations that will solve for Si's
    tridiagonalCubicSplineGen(n,h,tri,y); //to initialize tri[n-1][n]
    printf("The tridiagonal system for the Natural spline is:\n\n");
    printMatrix(n-1,n,tri);
    //Perform Gauss Elimination 
    gaussEliminationLS(n-1,n,tri,sigTemp);
    for(i=1;i<n;i++){
        sig[i]=sigTemp[i-1];
    }
    //Print the values of Si's
    for(i=0;i<n+1;i++){
        printf("\nSig[%d] = %lf\n",i,sig[i]);   
    }
    //calculate the values of ai's, bi's, ci's, and di's
    cSCoeffCalc(n,h,sig,y,a,b,c,d);
    printf("The equations of cubic interpolation polynomials between the successive intervals are:\n\n");
   for(i=0;i<n;i++){
      printf("P%d(x) b/w [%lf,%lf] = %lf*(x-%lf)^3+%lf*(x-%lf)^2+%lf*(x-%lf)+%lf\n",i,x[i],x[i+1],a[i],x[i],b[i],x[i],c[i],x[i],d[i]);
      
   }
         
     
     
}



void plotBasicBezier(int x0, int y0, int x1, int y1, int x2, int y2)
{                            
   int sx = x2-x1, sy = y2-y1;
   long xx = x0-x1, yy = y0-y1, xy;         /* relative values for checks */
   double dx, dy, err, cur = xx*sy-yy*sx;                    /* curvature */

   //assert(xx*sx <= 0 && yy*sy <= 0);  /* sign of gradient must not change */
   if (sx*(long)sx+sy*(long)sy > xx*xx+yy*yy) { /* begin with longer part */ 
      x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;  /* swap P0 P2 */
   }  
   if (cur != 0) {                                    /* no straight line */
      xx += sx; xx *= sx = x0 < x2 ? 1 : -1;           /* x step direction */
      yy += sy; yy *= sy = y0 < y2 ? 1 : -1;           /* y step direction */
      xy = 2*xx*yy; xx *= xx; yy *= yy;          /* differences 2nd degree */
      if (cur*sx*sy < 0) {                           /* negated curvature? */
         xx = -xx; yy = -yy; xy = -xy; cur = -cur;
      }
      dx = 4.0*sy*cur*(x1-x0)+xx-xy;             /* differences 1st degree */
      dy = 4.0*sx*cur*(y0-y1)+yy-xy;
      xx += xx; yy += yy; err = dx+dy+xy;                /* error 1st step */    
      do {                              
         //setPixel(x0,y0);         
         fprintf(stderr," %d \t%d\n",x0,y0);/* plot curve */
         if (x0 == x2 && y0 == y2) return;  /* last pixel -> curve finished */
         y1 = 2*err < dx;                  /* save value for test of y step */
         if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; } /* x step */
         if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; } /* y step */
      } while (dy < 0 && dx > 0);   /* gradient negates -> algorithm fails */
   }
   //plotLine(x0,y0, x2,y2);                  /* plot remaining part to end */
}  

//This program example plots a quadratic Bézier curve limited to gradients without sign change.
void plotBasicBezier2(int x0, int y0, int x1, int y1, int x2, int y2) 
{
   int sx = x0<x2 ? 1 : -1, sy = y0<y2 ? 1 : -1; /* step direction */ 
   printf("sx: %d sy: %d\n",sx,sy);
   double cur = sx*sy*((x0-x1)*(y2-y1)-(x2-x1)*(y0-y1)); /* curvature */ 
   double x = x0-2*x1+x2, y = y0-2*y1+y2, xy = 2*x*y*sx*sy;
   
   /* compute error increments of P0 */
   double dx = (1-2*abs(x0-x1))*y*y+abs(y0-y1)*xy-2*cur*abs(y0-y2); 
   double dy = (1-2*abs(y0-y1))*x*x+abs(x0-x1)*xy+2*cur*abs(x0-x2);
   /* compute error increments of P2 */
   double ex = (1-2*abs(x2-x1))*y*y+abs(y2-y1)*xy+2*cur*abs(y0-y2); 
   double ey = (1-2*abs(y2-y1))*x*x+abs(x2-x1)*xy-2*cur*abs(x0-x2);
   /* sign of gradient must not change */
   //assert((x0-x1)*(x2-x1) <= 0 && (y0-y1)*(y2-y1) <= 0);
   printf("cur: %lf\n",cur);
   if (cur==0) 
   {
      printf("cur=0, linie\n");
      //plotLine(x0,y0,x2,y2); 
      return; 
      
   } /* straight line */
   
   x *= 2*x; 
   y *= 2*y; 
   if (cur < 0) 
   {
      
      x = -x; 
      dx = -dx; 
      ex = -ex;
      xy = -xy;
      y = -y; 
      dy = -dy;
      ey = -ey;
   }
   //algorithm fails for almost negated curvature 
   if (dx >= -y || dy <= -x || ex <= -y || ey >= -x)
   {
      //plotLine(x0,y0,x1,y1); 
      printf("zu gerade\n");
      return;
   }
   
   dx -= xy; 
   ex = dx+dy; 
   dy -= xy;
   
   for(;;) 
   { 
     // setPixel(x0,y0); 
      fprintf(stderr,"x0:\t %d \t y0: \t%d\n",x0,y0);
      ey = 2*ex-dy;
      if (2*ex >= dx) {
         if (x0 == x2) break;
         x0 += sx; dy -= xy; ex += dx += y; }
      if (ey <= 0) {
         if (y0 == y2) break;
         y0 += sy; dx -= xy; ex += dy += x;
      } 
      
   }
}


void plotCircle(int xm, int ym, int r) 
{
   int x = -r, y = 0, err = 2-2*r; //II. Quadrant */ 
   do 
   {
      setPixelInt(xm-x, ym+y); //  I. Quadrant 
      setPixelInt(xm-y, ym-x); //  II. Quadrant 
      setPixelInt(xm+x, ym-y); // III. Quadrant 
      setPixelInt(xm+y, ym+x); // IV. Quadrant 
      //printf("\n");
      r = err;
      if (r > x) err += ++x*2+1; // * e_xy+e_x >0
      if (r <= y) err += ++y*2+1; // * e_xy+e_y < 0
      
   } while (x < 0);
}

void plotQuadBezierSeg(int x0, int y0, int x1, int y1, int x2, int y2)
{                            
  int sx = x2-x1, sy = y2-y1;
  long xx = x0-x1, yy = y0-y1, xy;         /* relative values for checks */
  double dx, dy, err, cur = xx*sy-yy*sx;                    /* curvature */

  //assert(xx*sx <= 0 && yy*sy <= 0);  /* sign of gradient must not change */

  if (sx*(long)sx+sy*(long)sy > xx*xx+yy*yy) { /* begin with longer part */ 
    x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;  /* swap P0 P2 */
  }  
  if (cur != 0) {                                    /* no straight line */
    xx += sx; xx *= sx = x0 < x2 ? 1 : -1;           /* x step direction */
    yy += sy; yy *= sy = y0 < y2 ? 1 : -1;           /* y step direction */
    xy = 2*xx*yy; xx *= xx; yy *= yy;          /* differences 2nd degree */
    if (cur*sx*sy < 0) {                           /* negated curvature? */
      xx = -xx; yy = -yy; xy = -xy; cur = -cur;
    }
    dx = 4.0*sy*cur*(x1-x0)+xx-xy;             /* differences 1st degree */
    dy = 4.0*sx*cur*(y0-y1)+yy-xy;
    xx += xx; yy += yy; err = dx+dy+xy;                /* error 1st step */    
    do {                              
       setPixelInt(x0,y0);printf("\n");                                     /* plot curve */
      if (x0 == x2 && y0 == y2) 
      {
         printf("return\n");
         return;
      }
       /* last pixel -> curve finished */
      y1 = 2*err < dx;                  /* save value for test of y step */
      if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; } /* x step */
      if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; } /* y step */
    } while (dy < dx );           /* gradient negates -> algorithm fails */
  }
  //plotLine(x0,y0, x2,y2);                  /* plot remaining part to end */
}  

void quadraticBezierCurve(double x0, double y0, double x1, double y1, double x2, double y2)
{
   printf("quadraticBezierCurve\n"); 
   //https://www.desmos.com/calculator/j3shfjmzt3?lang=de
   double alpha = 0;
   double anz = 8;
   for (int pos = 0;pos <= anz; pos++)
   {
      alpha = pos/anz;
      printf("%d\t%lf\t",pos,alpha); 
      double x = (1-alpha)*(1-alpha)* x0 + 2*alpha*(1-alpha)*x1 + alpha*alpha*x2;
      double y = (1-alpha)*(1-alpha)* y0 + 2*alpha*(1-alpha)*y1 + alpha*alpha*y2;
      setPixelDouble(x,y);printf("\n");  
   }
   
}
