//
//  rCNC.m
//  IOW_Stepper
//
//  Created by Sysadmin on 26.April.11.
//  Copyright 2011 Ruedi Heimlicher. All rights reserved.
//

#import "rCNC.h"
#include <math.h>
#include "poly.h"

#import "CNC_Interface-Swift.h"

uint8_t vs[4]={9,5,6,10};	//Tabelle Vollschritt Rechtslauf
uint8_t hs[8]={9,1,5,4,6,2,10,8}; //Tabelle Halbschritt Rechtslauf

float full_pwm = 1;

#define MOTOR_A 0
#define MOTOR_B 1
#define MOTOR_C 2
#define MOTOR_D 3

float det(float v0[],float v1[])
{
   return ( v0[0]*v1[1]-v0[1]*v1[0]);
}

//float (^determinante)(float[],float[]);

float (^determinante)(float*,float*) = ^(float* a, float* b)
{
   return (float) a[0]*b[1]-a[1]*b[0];
};



float (^hypotenuse)(float, float) = ^(float x, float y)
{
   return (float)sqrt(x*x+y*y);
};



@implementation rCNC
- (id)init
{
if ((self = [super init]) != nil) 
{
	DatenArray = [[NSMutableArray alloc]init];
	
	speed=7;
	steps=48;
   micro = 1;
   red_pwm = 0.4;

return self;
}
return NULL;
}


- (int)steps
{
 return steps;
}

- (int)micro
{
 return micro;
}


- (void)setSteps:(int)dieSteps
{
	steps = dieSteps;
}

- (void)setSchalendicke:(float)dieDicke
{
   schalendicke = dieDicke;
}

- (float)schalendicke
{
   return schalendicke;
}


- (void)setDatenArray:(NSArray*)derDatenArray
{
	DatenArray = (NSMutableArray*)derDatenArray;
}
- (NSArray*)DatenArray
{
	return DatenArray;
}



- (float) EndleistenwinkelvonProfil_old:(NSArray*)profil
{
   fprintf(stderr,"EndleistenwinkelvonProfil begin\n");
   for (int i=0;i<profil.count;i++)
   {
      float ax = [[[profil objectAtIndex:i]objectForKey:@"x"]floatValue];
      float ay = [[[profil objectAtIndex:i]objectForKey:@"y"]floatValue];
       
   fprintf(stderr,"%d \t%2.8f \t  %2.8f \n",i,ax,ay);

   }
   fprintf(stderr,"EndleistenwinkelvonProfil End\n");

   float steigungo=0, steigungu=0;
 // Oberseite
   int anzWerteO=0;
   int anzWerteU=0;
   int anfangsindex=3;
   // Bereich der Berechnung festlegen
   int endindex=8;
   float steigung = 0;
   float deltay = 0;
   float deltax = 0;
   int oberseiteindex = anfangsindex;
   int unterseiteindex = anfangsindex;
   //for (i=anfangsindex;i<endindex;i++)
   NSLog(@"EndleistenwinkelvonProfil Oberseite:");
   
   while (oberseiteindex < endindex)
   {
      float xA = [[[profil objectAtIndex:oberseiteindex+1]objectForKey:@"x"]floatValue];
      float xB = [[[profil objectAtIndex:oberseiteindex-1]objectForKey:@"x"]floatValue];

      deltax = xA - xB;
      if (deltax == 0)
      {
         NSLog(@"EndleistenwinkelvonProfil Oberseite deltax ist 0");
      }
      else
      {
         deltay = [[[profil objectAtIndex:oberseiteindex+1]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:oberseiteindex-1]objectForKey:@"y"]floatValue];
         float arc = deltay/deltax;
         steigung = atanf(deltay/deltax);
         NSLog(@"O index: %d \t  %2.6f  \t %2.6f \t deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t arc: %2.6f",oberseiteindex,xA,xB,deltax,deltay,steigung, arc);

         //      steigung *= -1;
         steigungo+=steigung;
         anzWerteO++;
      }
 
 //     NSLog(@"O oberseiteindex: %d \t  %2.6f  \t %2.6f \t deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t grad: %2.6f",oberseiteindex,xA,xB,deltax,deltay,steigung, steigung/M_PI*180);
      oberseiteindex++;
   }// while
   NSLog(@"EndleistenwinkelvonProfil Oberseite end");

   
   
   // Unterseite
   //for (i=anfangsindex;i<endindex;i++)
   NSLog(@"EndleistenwinkelvonProfil Unterseite:");
   while (unterseiteindex < endindex)

   {
      float xA = [[[profil objectAtIndex:[profil count]-1-unterseiteindex-1]objectForKey:@"x"]floatValue];
      float xB = [[[profil objectAtIndex:[profil count]-1-unterseiteindex+1]objectForKey:@"x"]floatValue];

      int endi=[profil count]-1-unterseiteindex;
      deltax = [[[profil objectAtIndex:[profil count]-1-unterseiteindex-1]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:[profil count]-1-unterseiteindex+1]objectForKey:@"x"]floatValue];
      if (deltax == 0)
      {
         NSLog(@"EndleistenwinkelvonProfil Unterseite deltax ist 0");
      }
      else
      {
         deltay = [[[profil objectAtIndex:[profil count]-1-unterseiteindex-1]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:[profil count]-1-unterseiteindex+1]objectForKey:@"y"]floatValue];
         float arc = deltay/deltax;
         steigung = atanf(deltay/deltax);
         NSLog(@"U index: %d  \t %2.6f  \t %2.6f \t   deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t arc: %2.6f",unterseiteindex,xA,xB,deltax,deltay,steigung, arc);

         //      steigung *= -1;
         steigungu+= steigung;
         //NSLog(@"U unterseiteindex: %d  \t deltax:  \t %2.6f  \t deltay:  \t %2.6f   \t steigung u:  \t %2.6f  \t grad: %2.6f",unterseiteindex,deltax,deltay,steigung, steigung/M_PI*180);
         anzWerteU++;
         unterseiteindex++;
      }
      
   }// while
   NSLog(@"EndleistenwinkelvonProfil Unterseite end");
   if (anzWerteU == 0)
   {
      NSLog(@"EndleistenwinkelvonProfil anzwerte = 0");
      return 0;
   }
   steigungo /=anzWerteO;
   steigungu /=anzWerteU;
   NSLog(@"Steigung raw steigungo: %1.2f steigungu: %2.2f",steigungo,steigungu);
   NSLog(@"steigungo: %1.2f steigungu: %2.2f",steigungo*180/M_PI,steigungu*180/M_PI);
   float mittelwert = (steigungo+steigungu)/2; // Winkelhalbierende
   
   return mittelwert;
}

- (void)setSpeed:(float)dieGeschwindigkeit
{
	speed = dieGeschwindigkeit; // Vorschubgeschwindigkeit
}

- (void)setredpwm:(float)red_pwmwert
{
	red_pwm = red_pwmwert; // reduzierte Heizleistung
}


- (float)speed
{
   return speed;
}

/*
Berechnet Angaben fuer den StepperController aus den Koordinaten von Startpunkt, Endpunkt, zoomfaktor.
 fuer einen linearen Abschnitt
Rueckgabe:
Dic mit Daten:
schrittex, schrittey: Schritte in x und y-Richtung
 
 Datenbreite ist 15 bit. 
 Negative Zahlen werden invertiert und 0x8000 dazugezaehlt 
 
delayx, delayy:	Zeit fuer einen Schritt in x/y-Richtung, Einheit 100us
*/
- (NSDictionary*)SteuerdatenVonDic:(NSDictionary*)derDatenDic
{
// Aufbereitung der Werte für die Uebergabe an Teensy, als uint8_t-Werte
   uint16_t dicindex = [[derDatenDic objectForKey:@"index"]intValue];
//   NSLog(@"index: %d SteuerdatenVonDic: %@",dicindex, [derDatenDic description]);
	int  anzSchritte;
   int  anzaxplus=0;
   int  anzaxminus=0;
   int  anzayplus=0;
   int  anzayminus=0;

   int  anzbxplus=0;
   int  anzbxminus=0;
   int  anzbyplus=0;
   int  anzbyminus=0;
   

	if ([derDatenDic count]==0) 
	{
		return NULL;
	}
   
   // home detektieren
   int code=0;
   if ([derDatenDic objectForKey:@"code"])
        {
           code = [[derDatenDic objectForKey:@"code"]intValue];
        }
   
	float zoomfaktor = [[derDatenDic objectForKey:@"zoomfaktor"]floatValue];
	//NSLog(@"zoomfaktor: %.3f",zoomfaktor);
	zoomfaktor=1;
   
     
	NSPoint StartPunkt= NSPointFromString([derDatenDic objectForKey:@"startpunkt"]);
	NSPoint StartPunktA= NSPointFromString([derDatenDic objectForKey:@"startpunkta"]);
	NSPoint StartPunktB= NSPointFromString([derDatenDic objectForKey:@"startpunktb"]);
	//StartPunkt.x *=zoomfaktor;
	//StartPunkt.y *=zoomfaktor;
	
	NSPoint EndPunkt=NSPointFromString([derDatenDic objectForKey:@"endpunkt"]);
	NSPoint EndPunktA=NSPointFromString([derDatenDic objectForKey:@"endpunkta"]);
	NSPoint EndPunktB=NSPointFromString([derDatenDic objectForKey:@"endpunktb"]);
   
  	//EndPunkt.x *=zoomfaktor;
	//EndPunkt.y *=zoomfaktor;
	//NSLog(@"StartPunkt x: %.2f y: %.2f EndPunkt.x: %.2f y: %.2f",StartPunkt.x,StartPunkt.y,EndPunkt.x, EndPunkt.y);
	
	//NSMutableDictionary* tempDatenDic=[[[NSMutableDictionary alloc]initWithDictionary:derDatenDic]autorelease];
	NSMutableDictionary* tempDatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   
   // Daten von derDatendic uebernehmen
   
   [tempDatenDic addEntriesFromDictionary:derDatenDic];
   
	float DistanzX= EndPunkt.x - StartPunkt.x;
	float DistanzAX= EndPunktA.x - StartPunktA.x;
	float DistanzBX= EndPunktB.x - StartPunktB.x;

	float DistanzY= EndPunkt.y - StartPunkt.y;
	float DistanzAY= EndPunktA.y - StartPunktA.y;
	float DistanzBY= EndPunktB.y - StartPunktB.y;
   float steigung = 0;
   if(DistanzAX)
   {
      steigung = DistanzAY / DistanzAX;
   }
   
   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzAX] forKey: @"distanzax"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzAY] forKey: @"distanzay"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzBX] forKey: @"distanzbx"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzBY] forKey: @"distanzby"];

   
	float Distanz= sqrt(pow(DistanzX,2)+ pow(DistanzY,2));	// effektive Distanz
	float DistanzA= hypotf(DistanzAX,DistanzAY);	// effektive Distanz A
	float DistanzB= hypotf(DistanzBX,DistanzBY);	// effektive Distanz B
   
   

   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzA] forKey: @"distanza"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzB] forKey: @"distanzb"];
   
   [tempDatenDic setObject:[NSNumber numberWithFloat:steigung] forKey:@"steigung"];

   if (DistanzA< 0.5 || DistanzB < 0.5)
   {
   //   NSLog(@"i:  DistanzA: %2.2f DistanzB: %2.2f",DistanzA,DistanzB);
   }
	
   float Zeit = Distanz/speed;												//	Schnittzeit für Distanz
   float ZeitA = DistanzA/speed;												//	Schnittzeit für Distanz A
   float ZeitB = DistanzB/speed;												//	Schnittzeit für Distanz B
   int relevanteSeite=0; // seite A
   float relevanteZeit = 0;
   
   int motorstatus=0;
   
   if (ZeitB > ZeitA)
   {
      relevanteZeit = ZeitB;
      relevanteSeite=1; // Seite B
      if (fabs(DistanzBY) > fabs(DistanzBX))
      {
         motorstatus |= (1<<MOTOR_D);
      }
      else 
      {
         motorstatus |= (1<<MOTOR_C);
      }
   }
   else 
   {
      relevanteZeit = ZeitA;
      if (fabs(DistanzAY) > fabs(DistanzAX))
      {
          motorstatus |= (1<<MOTOR_B);
      }
      else 
      {
          motorstatus |= (1<<MOTOR_A);
      }

   }
   
   //NSLog(@" DistanzAX:\t%2.2f\t DistanzAY:\t%2.2f\t DistanzBX:\t%2.2f\t DistanzBY:\t%2.2f\tmotorstatus: %d",DistanzAX,DistanzAY,DistanzBX,DistanzBY,motorstatus);

//   NSLog(@"motorstatus: %d",motorstatus);

   float relZeit= fmaxf(ZeitA,ZeitB);                             // relevante Zeit: grössere Zeit gibt korrekte max Schnittgeschwindigkeit 
   
   [tempDatenDic setObject:[NSNumber numberWithFloat:relZeit] forKey: @"relevantezeit"];

   //NSLog(@"ZeitA: %2.4f ZeitB: %2.4f",ZeitA,ZeitB);
	int SchritteX=steps*DistanzX;													//	Schritte in X-Richtung
	int SchritteAX=steps*DistanzAX;													//	Schritte in X-Richtung A
	int SchritteBX=steps*DistanzBX;													//	Schritte in X-Richtung B
  
	/*
    int  anzayplus=0;
    int  anzayminus=0;
    int  anzaxplus=0;
    int  anzaxminus=0;
    
    int  anzbxplus=0;
    int  anzbxminus=0;
    int  anzbyplus=0;
    int  anzbyminus=0;
 
    */

   [tempDatenDic setObject:[NSNumber numberWithInt:motorstatus] forKey: @"motorstatus"];
   
   [tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteX] forKey: @"schrittex"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteAX] forKey: @"schritteax"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteBX] forKey: @"schrittebx"];

	//NSLog(@"SchritteX raw %d",SchritteX);
	
	int SchritteY=steps*DistanzY;	//	Schritte in Y-Richtung
	int SchritteAY=steps*DistanzAY;	//	Schritte in Y-Richtung A
	int SchritteBY=steps*DistanzBY;	//	Schritte in Y-Richtung B
   
    
   if (DistanzA< 0.5 || DistanzB < 0.5)
   {
      //NSLog(@"DistanzA: %2.2f DistanzB: %2.2f * SchritteAX: %d SchritteAY: %d * SchritteBX: %d SchritteBY: %d",DistanzAX,DistanzAY,SchritteAX,SchritteAY,SchritteBX,SchritteBY);
   }

	[tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteY] forKey: @"schrittey"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteAY] forKey: @"schritteay"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteBY] forKey: @"schritteby"];
   
	
   //NSLog(@"SchritteY raw %d",SchritteY);
	
	if (SchritteX < 0) // negative Zahl
	{
		SchritteX *= -1;
		SchritteX &= 0x7FFF;
		//NSLog(@"SchritteX nach *-1 und 0x7FFFF %d",SchritteX);
		SchritteX |= 0x8000;
	}
   
	if (SchritteAX < 0) // negative Zahl
	{
      anzaxminus += SchritteAX;
		SchritteAX *= -1;
		SchritteAX &= 0x7FFF;
		//NSLog(@"SchritteAX nach *-1 und 0x7FFFF %d",SchritteAX);
		SchritteAX |= 0x8000;
      //NSLog(@"SchritteAX negativ");
	}
   else
   {
      anzaxplus += SchritteAX;
      //NSLog(@"SchritteAX positiv");
   }
   
 	if (SchritteBX < 0) // negative Zahl
	{
      anzbxminus += SchritteBX;
		SchritteBX *= -1;
		SchritteBX &= 0x7FFF;
		SchritteBX |= 0x8000;
      //NSLog(@"SchritteBX negativ");
	}
   else
   {
      anzbxplus += SchritteBX;
      //NSLog(@"SchritteBX positiv");
   }
   
  
	
	 
	if (SchritteY < 0) // negative Zahl
	{
		SchritteY= SchritteY *-1;
		SchritteY &= 0x7FFF;
		SchritteY |= 0x8000;
		//NSLog(@"SchritteY negativ: %d",SchritteY);
	}
   
	if (SchritteAY < 0) // negative Zahl
	{
      anzayminus += SchritteAY;
		SchritteAY *= -1;
		SchritteAY &= 0x7FFF;
		SchritteAY |= 0x8000;
	}
   else
   {
      anzayplus += SchritteAY;
   }
   
	if (SchritteBY < 0) // negative Zahl
	{
      anzbyminus += SchritteBY;
		SchritteBY *= -1;
		SchritteBY &= 0x7FFF;
		SchritteBY |= 0x8000;
	}
   else
   {
      anzbyplus += SchritteBY;
   }
   
   [tempDatenDic setObject:[NSNumber numberWithInt:anzaxplus] forKey:@"anzaxplus"];
   [tempDatenDic setObject:[NSNumber numberWithInt:anzaxminus] forKey:@"anzaxminus"];
   [tempDatenDic setObject:[NSNumber numberWithInt:anzayplus] forKey:@"anzayplus"];
   [tempDatenDic setObject:[NSNumber numberWithInt:anzayminus] forKey:@"anzayminus"];
   
   [tempDatenDic setObject:[NSNumber numberWithInt:anzbxplus] forKey:@"anzbxplus"];
   [tempDatenDic setObject:[NSNumber numberWithInt:anzbxminus] forKey:@"anzbxminus"];
   [tempDatenDic setObject:[NSNumber numberWithInt:anzbyplus] forKey:@"anzbyplus"];
   [tempDatenDic setObject:[NSNumber numberWithInt:anzbyminus] forKey:@"anzbyminus"];

   
	// schritt x
	

	[tempDatenDic setObject:[NSNumber numberWithFloat:(SchritteAX & 0xFF)] forKey: @"schritteaxl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:((SchritteAX >> 8) & 0xFF)] forKey: @"schritteaxh"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(SchritteBX & 0xFF)] forKey: @"schrittebxl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:((SchritteBX >> 8) & 0xFF)] forKey: @"schrittebxh"];
	


	// schritte y

   [tempDatenDic setObject:[NSNumber numberWithFloat:(SchritteAY & 0xFF)] forKey: @"schritteayl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:((SchritteAY >> 8) & 0xFF)] forKey: @"schritteayh"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:(SchritteBY & 0xFF)] forKey: @"schrittebyl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:((SchritteBY >> 8) & 0xFF)] forKey: @"schrittebyh"];

   
	
   float delayX = 0;							// Zeit fuer einen Schritt in 100us-Einheit
	float delayAX= 0;							// Zeit fuer einen Schritt AX in 100us-Einheit
	float delayBX= 0;							// Zeit fuer einen Schritt BX in 100us-Einheit
	
      
   float delayY = 0;
   float delayAY =0 ;
   float delayBY= 0;

   if(SchritteX)
   {
      delayX = ((relZeit/(SchritteX & 0x7FFF))*100000)/10; // Zeit fuer einen Schritt in 100us-Einheit
   }
   if(SchritteAX)
   {
      delayAX= ((relZeit/(SchritteAX & 0x7FFF))*100000)/10;                     // Zeit fuer einen Schritt AX in 100us-Einheit
   }
   if(SchritteBX)
   {
      delayBX= ((relZeit/(SchritteBX & 0x7FFF))*100000)/10;                     // Zeit fuer einen Schritt BX in 100us-Einheit
   }
      
   if(SchritteY)
   {
      delayY = ((relZeit/(SchritteY & 0x7FFF))*100000)/10;
   }
   if(SchritteAY)
   {
      delayAY= ((relZeit/(SchritteAY & 0x7FFF))*100000)/10;
   }
   if(SchritteBY)
   {
      delayBY= ((relZeit/(SchritteBY & 0x7FFF))*100000)/10;
   }

	//NSLog(@"DistanzX: \t%.2f \tDistanzY: \t%.2f \tDistanz: \t%.2f \tZeit: \t%.3f  \tdelayX: \t%.1f\t  delayY: \t%.1f \tSchritteX: \t%d \tSchritteY: \t%d",DistanzX,DistanzY,Distanz, Zeit, delayX, delayY, SchritteX,SchritteY);
	
	
	

   [tempDatenDic setObject:[NSNumber numberWithFloat:delayAX] forKey: @"delayax"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:delayAY] forKey: @"delayay"];

   [tempDatenDic setObject:[NSNumber numberWithFloat:((int)delayAX & 0xFF)] forKey: @"delayaxl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(((int)delayAX >> 8) & 0xFF)] forKey: @"delayaxh"];

   [tempDatenDic setObject:[NSNumber numberWithFloat:delayBX] forKey: @"delaybx"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:delayBY] forKey: @"delayby"];
   
   [tempDatenDic setObject:[NSNumber numberWithFloat:((int)delayBX & 0xFF)] forKey: @"delaybxl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(((int)delayBX >> 8) & 0xFF)] forKey: @"delaybxh"];



   [tempDatenDic setObject:[NSNumber numberWithFloat:((int)delayAY & 0xFF)] forKey: @"delayayl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(((int)delayAY >> 8) & 0xFF)] forKey: @"delayayh"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:((int)delayBY & 0xFF)] forKey: @"delaybyl"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(((int)delayBY >> 8) & 0xFF)] forKey: @"delaybyh"];
   
	[tempDatenDic setObject:[NSNumber numberWithInt :code] forKey: @"code"];
	[tempDatenDic setObject:[NSNumber numberWithInt :code] forKey: @"codea"];
	[tempDatenDic setObject:[NSNumber numberWithInt :0] forKey: @"codeb"];
   
   // relevanter Motor
   
    
   // index
   int index=[[derDatenDic objectForKey:@"index"]intValue];
   int indexl, indexh;
   indexl=index & 0xFF;
   indexh=((index >> 8) & 0xFF);
   [tempDatenDic setObject:[NSNumber numberWithInt:(index & 0xFF)] forKey: @"indexl"];
	[tempDatenDic setObject:[NSNumber numberWithInt:((index >> 8) & 0xFF)] forKey: @"indexh"];
   //NSLog(@"SteuerdatenVonDic index: %d indexl: %d indexh: %d", index, indexl, indexh);
   //NSLog(@"SteuerdatenVonDic ZeitA: %1.5f  ZeitB: %1.5f relSeite: %d code: %d",ZeitA,ZeitB,relevanteSeite,code);
	//NSLog(@"SteuerdatenVonDic tempDatenDic: %@",[tempDatenDic description]);
	return tempDatenDic;
}




- (NSArray*)SteuerdatenArrayVonDic:(NSDictionary*)derDatenDic // Rampen am Anfang und Ende
{
      // CNC mit Rampe
   NSLog(@"SteuerdatenArrayVonDic: %@",[derDatenDic description]);
	int  anzSchritte;
	if ([derDatenDic count]==0) 
	{
		return NULL;
	}
	float zoomfaktor = [[derDatenDic objectForKey:@"zoomfaktor"]floatValue];
	//NSLog(@"zoomfaktor: %.3f",zoomfaktor);
	zoomfaktor=1;
	NSPoint StartPunkt= NSPointFromString([derDatenDic objectForKey:@"startpunkt"]);
	//StartPunkt.x *=zoomfaktor;
	//StartPunkt.y *=zoomfaktor;
	
	NSPoint EndPunkt=NSPointFromString([derDatenDic objectForKey:@"endpunkt"]);
	//EndPunkt.x *=zoomfaktor;
	//EndPunkt.y *=zoomfaktor;
	//NSLog(@"StartPunkt x: %.2f y: %.2f EndPunkt.x: %.2f y: %.2f",StartPunkt.x,StartPunkt.y,EndPunkt.x, EndPunkt.y);
	
	//NSMutableDictionary* tempDatenDic=[[[NSMutableDictionary alloc]initWithDictionary:derDatenDic]autorelease];
	NSMutableDictionary* tempDatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [tempDatenDic addEntriesFromDictionary:derDatenDic];
	float DistanzX= EndPunkt.x - StartPunkt.x;
	float DistanzY= EndPunkt.y - StartPunkt.y;
	//float Distanz= sqrt(pow(DistanzX,2)+ pow(DistanzY,2));         // effektive Distanz
   float Distanz = hypot(DistanzX,DistanzY);
   
	float Zeit = Distanz/speed;												//	Schnittzeit für Distanz
   
	int SchritteX=steps*DistanzX;												//	Schritte in X-Richtung
   int SchritteY=steps*DistanzY;                                  //	Schritte in Y-Richtung
   
   //NSLog(@"SchritteX raw %d",SchritteX);
   int relevanteSchritte = SchritteX;
   if (SchritteY > SchritteX)
   {
      relevanteSchritte = SchritteY;
   }
   NSLog(@"SteuerdatenVonDic relevanteSchritte: %d",relevanteSchritte);
	if (relevanteSchritte < 96) // Rampen lohnt sich nicht
   {
      return [NSArray arrayWithObject:[self SteuerdatenVonDic:derDatenDic]];
   }
   
   int teilabschnitt=24; // Abschnitt mit konstanter Geschwindigkeit
   
   int anzTeile=relevanteSchritte / teilabschnitt; // mindestens 4
   int Rampenstufen=anzTeile/2;                    // symmetrische Rampen, mindestens 2
   int stufe=0;
   NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   int i=0;
   for (i=0; i<relevanteSchritte; i++)
   {
      if (i<anzTeile) 
      {
         
         stufe++;
      }
   }
   [tempDatenDic setObject:[NSNumber numberWithFloat:(float)Distanz] forKey: @"distanz"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteX] forKey: @"schrittex"];
	[tempDatenDic setObject:[NSNumber numberWithFloat:(float)SchritteY] forKey: @"schrittey"];
	//NSLog(@"SchritteY raw %d",SchritteY);
   return tempArray;
}

// ohne Abbrand

- (NSArray*)SchnittdatenVonDic:(NSDictionary*)derDatenDic
{
   
   /*
    Bereitet die Angaben im Steuerdatenarray für die Uebergabe an den USB vor.
    Alle 16Bit-Zahlen werden aufgeteilt in highbyte und lowbyte
    
    Aufbau:
    
    delayx = 269;
    delayy = 115;
    endpunkt = "{50, 50.2}";
    schrittex = "-18";
    schrittey = "-42";
    startpunkt = "{52, 54.9}";
    zoomfaktor = "1.0";
    
    Array:
    
    schritteax lb
    schritteax hb
    schritteay lb
    schritteay hb
    
    delayax lb
    delayax hb
    delayay lb
    delayay hb
    
    schrittebx lb
    schrittebx hb
    schritteby lb
    schritteby hb
    
    delaybx lb
    delaybx hb
    delayby lb
    delayby hb
    
    code
    position // first, last, ...
    indexh
    indexl
    
    pwm (pos 20)
    motorstatus (pos 21)
    
    steps // 48, 200
    micro // microsteps, 1,2 4
    */
   
   if ([[derDatenDic objectForKey:@"indexl"]intValue] < 3)
   {
      //NSLog(@"SchnittdatenVonDic derDatenDic: %@",[derDatenDic description]);
   }
   //NSLog(@"SchnittdatenVonDic index: %d",[[derDatenDic objectForKey:@"indexl"]intValue]);
   
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	int tempDataL=0;
	int tempDataH=0;
	tempDataL=[[derDatenDic objectForKey:@"schrittex"]intValue]& 0xFF;
	tempDataH=([[derDatenDic objectForKey:@"schrittex"]intValue]>>8)&0xFF;
	//NSLog(@"tempData int: %d hex: %X tempDataL int: %d hex: %X tempDataH int: %d hex: %X",tempData,tempData,tempDataL,tempDataL,tempDataH,tempDataH);
   //NSLog(@"tempData int: %d tempDataL int: %d  tempDataH int: %d ",tempData,tempDataL,tempDataH);
   
   // Seite A
   [tempArray addObject:[derDatenDic objectForKey:@"schritteaxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schritteaxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schritteayl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schritteayh"]];
   
   
   [tempArray addObject:[derDatenDic objectForKey:@"delayaxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delayaxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delayayl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delayayh"]];
   
   
   // Seite B
   [tempArray addObject:[derDatenDic objectForKey:@"schrittebxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schrittebxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schrittebyl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schrittebyh"]];
   
   [tempArray addObject:[derDatenDic objectForKey:@"delaybxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delaybxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delaybyl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delaybyh"]];
   
   
	[tempArray addObject:[derDatenDic objectForKey:@"code"]];
   
   
   if ([derDatenDic objectForKey:@"position"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"position"]]; 
   }
   else
   {
      [tempArray addObject:[NSNumber numberWithInt:0]];
   }// Beschreibung der Lage innerhalb des Schnitt-Polygons: first, last, 
   
   
	[tempArray addObject:[derDatenDic objectForKey:@"indexh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"indexl"]];
   
   if ([derDatenDic objectForKey:@"pwm"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"pwm"]];
   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:0]];
   }
   
   if ([derDatenDic objectForKey:@"motorstatus"])
   {
      //NSLog(@"Schnittdaten motorstatus: %d",[[derDatenDic objectForKey:@"motorstatus"]intValue]);
      
       
      [tempArray addObject:[derDatenDic objectForKey:@"motorstatus"]];

   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }

   if ([derDatenDic objectForKey:@"zoomfaktor"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"zoomfaktor"]];
   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }
 
// Steps einfuegen
   if ([derDatenDic objectForKey:@"steps"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"steps"]];
   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:48]];
   }

   // Faktor fuer microsteps einfuegen
   if ([derDatenDic objectForKey:@"micro"])
   {
     // [tempArray addObject:[derDatenDic objectForKey:@"micro"]];
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }

   
   // Zusaetzliche Objekte einfuegen bis 36
   //for (uint8_t addindex = 0;addindex < 14; addindex++)
   while ([tempArray count] < 36)
   {
      [tempArray addObject:[NSNumber numberWithInt:0]];
   }
   // steigung einsetzen
   uint8_t steigungh = 0;
   uint8_t steigungl = 0;
   int steigungint = [[derDatenDic objectForKey:@"steigung"]floatValue]*1000;
   
   //NSLog(@"steigungint: %d steigungfloat: %.3f",steigungint,[[derDatenDic objectForKey:@"steigung"]floatValue]);
   if (steigungint > 0)
   {
      int aa = (1234 & 0xFF00)>>8;
      steigungl = (steigungint & 0xFF);
      steigungh = (steigungint>>8) & 0xFF;
   }
   else
   {
      uint16_t steigunguint = abs(steigungint);
      
      //NSLog(@"steigungin inv: %d steigunguint: %d",steigungint,steigunguint);
      steigungl = (steigunguint & 0x00FF);
      steigungh = (steigunguint>>8) & 0xFF;
      steigungh |= 0x80;
      
   }
   //NSLog(@"steigungint: %d steigungfloat: %.3f steigungl: %d steigungh: %d",steigungint,[[derDatenDic objectForKey:@"steigung"]floatValue],steigungl, steigungh);
   [tempArray replaceObjectAtIndex:33 withObject:[NSNumber numberWithInt:steigungl]];
   [tempArray replaceObjectAtIndex:34 withObject:[NSNumber numberWithInt:steigungh]];
   
   [tempArray replaceObjectAtIndex:31 withObject:[NSNumber numberWithInt:17]];

   [tempArray replaceObjectAtIndex:32 withObject:[NSNumber numberWithInt:3]];
   
   //NSLog(@"tempArray indexl: %d",[[derDatenDic objectForKey:@"indexl"]intValue]);
   //NSLog(@"SchnittdatenVonDic tempArray: %@",[tempArray description]);
   //NSLog(@"SchnittdatenVonDic tempArray count: %d",[tempArray count]);
   
   
   return tempArray;
}


// mit Abbrand

- (NSArray*)SchnittdatenVonDic:(NSDictionary*)derDatenDic mitAbbrand:(int)mitabbrand
{
   
   /*
    Bereitet die Angaben im Steuerdatenarray für die Uebergabe an den USB vor.
    Alle 16Bit-Zahlen werden aufgeteilt in highbyte und lowbyte
    
    Aufbau:
    
    delayx = 269;
    delayy = 115;
    endpunkt = "{50, 50.2}";
    schrittex = "-18";
    schrittey = "-42";
    startpunkt = "{52, 54.9}";
    zoomfaktor = "1.0";
    
    Array:
    
    schritteax lb
    schritteax hb
    schritteay lb
    schritteay hb
    
    delayax lb
    delayax hb
    delayay lb
    delayay hb

    schrittebx lb
    schrittebx hb
    schritteby lb
    schritteby hb
    
    delaybx lb
    delaybx hb
    delayby lb
    delayby hb

    code
    position // first, last, ...
    indexh
    indexl
    
    pwm (pos 20)
    motorstatus (pos 21)
    */
	//NSLog(@"SchnittdatenVonDic derDatenDic: %@",[derDatenDic description]);
   //NSLog(@"SchnittdatenVonDic index: %d",[[derDatenDic objectForKey:@"indexl"]intValue]);
   
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	int tempDataL=0;
	int tempDataH=0;
	tempDataL=[[derDatenDic objectForKey:@"schrittex"]intValue]& 0xFF;
	tempDataH=([[derDatenDic objectForKey:@"schrittex"]intValue]>>8)&0xFF;
	//NSLog(@"tempData int: %d hex: %X tempDataL int: %d hex: %X tempDataH int: %d hex: %X",tempData,tempData,tempDataL,tempDataL,tempDataH,tempDataH);
   //NSLog(@"tempData int: %d tempDataL int: %d  tempDataH int: %d ",tempData,tempDataL,tempDataH);
   
    // Seite A
   [tempArray addObject:[derDatenDic objectForKey:@"schritteaxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schritteaxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schritteayl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schritteayh"]];
   
   
   [tempArray addObject:[derDatenDic objectForKey:@"delayaxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delayaxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delayayl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delayayh"]];
   
   
   // Seite B
   [tempArray addObject:[derDatenDic objectForKey:@"schrittebxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schrittebxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schrittebyl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"schrittebyh"]];

   [tempArray addObject:[derDatenDic objectForKey:@"delaybxl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delaybxh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delaybyl"]];
	[tempArray addObject:[derDatenDic objectForKey:@"delaybyh"]];
  
   
	[tempArray addObject:[derDatenDic objectForKey:@"code"]];
    
   
   if ([derDatenDic objectForKey:@"position"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"position"]]; 
   }
   else
   {
      [tempArray addObject:[NSNumber numberWithInt:0]];
   }// Beschreibung der Lage innerhalb des Schnitt-Polygons: first, last, 

	[tempArray addObject:[derDatenDic objectForKey:@"indexh"]];
	[tempArray addObject:[derDatenDic objectForKey:@"indexl"]];
   
   if ([derDatenDic objectForKey:@"pwm"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"pwm"]];
   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:0]];
   }

   if ([derDatenDic objectForKey:@"motorstatus"])
   {
      //NSLog(@"Schnittdaten motorstatus: %d",[[derDatenDic objectForKey:@"motorstatus"]intValue]);
      [tempArray addObject:[derDatenDic objectForKey:@"motorstatus"]];
   }
   else 
   {
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }
   
   //NSLog(@"SchnittdatenVonDic tempArray: %@",[tempArray description]);
   //NSLog(@"SchnittdatenVonDic tempArray count: %d",[tempArray count]);
   
   return tempArray;
}

/*
- (void)makeVollschritt:(int)anzSchritte inRichtung:(int)richtung mitDelay:(int)delay
{
uint16_t	z;
uint8_t n
for (z=0; z<anzSchritte; z++)
{ 
PortA=vs[n & 3]; warte10ms(); n++;
}

}

//Schrittmotor-Steuerprogramm in C
//In C schreibt man die Folge der Bytewerte zum Ansteuern des Schrittmotor am besten in Arrays:
uint8_t vs[4]={9,5,6,10},	//Tabelle Vollschritt Rechtslauf 
hs[8]={9,1,5,4,6,2,10,8}; //Tabelle Halbschritt Rechtslauf
//Will man nun z.B. 1000 Schritte benötigt man eine Variable z zum Zählen der Anzahl der durchgeführten Schritte und eine Variable n für die Schrittnummer:
uint16_t	z, n=0;
//Das Programm für Vollschrittbetrieb kann dann so aussehen:
DDRA=0x0f; //Motor ist an Bit 0,1, 2 und 3 von Port A angeschlossen. 
for (z=0; z<1000; z++)
{ 
PortA=vs[n & 3]; warte10ms(); n++;
}
//Mit der Und-Verknüpfung n & 3 werden aus der Schrittvariablen n die letzten beiden Bits ausmaskiert. n & 3 durchläuft so beim Hochzählen von n periodisch die Werte 0, 1, 2 und 3. Mit PortA=vs[n & 3] wird der Bytewert aus der Tabelle vz gelesen und zum Schrittmotor übertragen.
//Die Funktion warte10ms() sorgt dann für notwendige die Schaltverzögerung von 10 ms.
*/

- (NSArray*)PfeilvonPunkt:(NSPoint) Startpunkt mitLaenge:(int)laenge inRichtung:(int)richtung
{
   int schritte=laenge*steps;
 	NSMutableArray* PfeilKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0];
   /*
    richtung
    right: 0
    up:   1
    left:   2
    down:  3
    */
   
   // Schrittlaenge
	float schrittlaenge=1.0;
	
	// Anzahl Schritte:
	int anzSchritte =laenge/schrittlaenge;

   float deltaX=0.0;
   float deltaY=0.0;
   
  	switch (richtung) 
   {
      case 0: // rechts
      {
         deltaX = 1.0;
         deltaY = 0.0;
      }
         break;
         
      case 1: // up
      {
         deltaX = 0.0;
         deltaY = 1.0;
      }
         break;
         
      case 2: // left
      {
         //Startpunkt.x = laenge;    
         deltaX = -1.0;
         deltaY = 0.0;
      }
         break;
         
      case 3: // down
      {
         //Startpunkt.y = laenge;
         deltaX = 0.0;
         deltaY = -1.0;
      }
         break;
         
      default:
         break;
   } // switch

   float tempX= Startpunkt.x;
   float tempY= Startpunkt.y;
   
   int index;
	for(index = 0;index < anzSchritte;index++)
	{
      NSNumber* KoordinateX=[NSNumber numberWithFloat:tempX];
      NSNumber* KoordinateY=[NSNumber numberWithFloat:tempY];

      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index",[NSNumber numberWithFloat:full_pwm], nil];
		[PfeilKoordinatenArray addObject:tempDic];

      tempX += deltaX;
      tempY += deltaY;
      
   }
   
   //NSLog(@"PfeilKoordinatenArray: %@",[PfeilKoordinatenArray description]);

   return PfeilKoordinatenArray;
}

- (NSArray*)LinieVonPunkt:(NSPoint)Anfangspunkt mitLaenge:(float)laenge mitWinkel:(int)winkel
{
   //Winkel 0 ist Richtung der x-Achse, CCW
   NSMutableArray* LinienKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0];
   float deltaX = laenge * cos(winkel*(M_PI/180));
   float deltaY = laenge * sin(winkel*(M_PI/180));
   
   NSPoint Startpunkt = Anfangspunkt;
   NSPoint Endpunkt = Startpunkt;
   Endpunkt.x += deltaX;
   Endpunkt.y += deltaY;
   
   [LinienKoordinatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
                              NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1.0],@"zoomfaktor",[NSNumber numberWithInt:0],@"index" ,NULL]];

      return LinienKoordinatenArray;
}


- (NSArray*)QuadratVonPunkt:(NSPoint)EckeLinksUnten mitSeite:(float)Seite mitLage:(int)Lage
{
	NSLog(@"QuadratVonPunkt: EckeLinksUnten x: %2.2f y: %2.2f Seite: %2.2f",EckeLinksUnten.x, EckeLinksUnten.y, Seite);
	NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	// waagrecht rechts
	//NSPoint Startpunkt=NSMakePoint(0,0);
	NSPoint Startpunkt= EckeLinksUnten;
	NSPoint Endpunkt=EckeLinksUnten;//NSMakePoint(Seite,0);
	float X=EckeLinksUnten.x;
	float Y=EckeLinksUnten.y;
	
	int anzSchritte =4;
	
	NSMutableArray* PolygonpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
	/*
	 Lage: 
	 0: rechts oben von Startpunkt		|_
	 
	 1: links oben von Startpunkt		  _|
    
    2: links unten von Startpunkt	  ¯|
	 
	 3: rechts unten von Startpunkt		|¯
	 */
	
	int index;
   
	switch (Lage)
	{
		case 0:
		{
			// waagrecht rechts
			Endpunkt.x = X+Seite;
			int anzDaten=0x20;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor",[NSNumber numberWithInt:0],@"index" ,NULL]];
			// senkrecht up
			Startpunkt=Endpunkt;
			Endpunkt.y=Y+Seite;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:1],@"index" ,NULL]];
			
			// waagrecht links
			Startpunkt=Endpunkt;
			Endpunkt.x=X;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:2],@"index" ,NULL]];
			
			// senkrecht down
			Startpunkt=Endpunkt;
			Endpunkt.y=Y;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:3],@"index" ,NULL]];
			
		}break;
         
      case 1:
		{
			// waagrecht links
			Endpunkt.x = X-Seite;
			int anzDaten=0x20;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:0],@"index" ,NULL]];
			// senkrecht up
			Startpunkt=Endpunkt;
			Endpunkt.y=Y+Seite;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:1],@"index" ,NULL]];
			
			// waagrecht rechts
			Startpunkt=Endpunkt;
			Endpunkt.x=X;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:2],@"index" ,NULL]];
			
			// senkrecht down
			Startpunkt=Endpunkt;
			Endpunkt.y=Y;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:3],@"index" ,NULL]];
		}break;
         
      case 2:
		{
			// waagrecht links
			Endpunkt.x = X-Seite;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:0],@"index" ,NULL]];
			// senkrecht down
			Startpunkt=Endpunkt;
			Endpunkt.y=Y-Seite;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:1],@"index" ,NULL]];
			
			// waagrecht rechts
			Startpunkt=Endpunkt;
			Endpunkt.x=X;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:2],@"index" ,NULL]];
			
			// senkrecht up
			Startpunkt=Endpunkt;
			Endpunkt.y=Y;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:3],@"index" ,NULL]];
		}break;
         
		case 3:
		{
			// waagrecht rechts
			Endpunkt.x = X+Seite;
			int anzDaten=0x20;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:0],@"index" ,NULL]];
			// senkrecht down
			Startpunkt=Endpunkt;
			Endpunkt.y=Y-Seite;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:1],@"index" ,NULL]];
			
			// waagrecht links
			Startpunkt=Endpunkt;
			Endpunkt.x=X;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:2],@"index" ,NULL]];
			
			// senkrecht up
			Startpunkt=Endpunkt;
			Endpunkt.y=Y;
			[tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromPoint(Startpunkt), @"startpunkt",
												NSStringFromPoint(Endpunkt), @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:3],@"index" ,NULL]];
		}break;
         
         
         
	}//switch lage
	
	
	
	
	
	return tempDatenArray;
}


- (NSArray*)QuadratKoordinatenMitSeite:(float)Seite mitWinkel:(float)Winkel
{
   NSLog(@"QuadratKoordinatenMitSeite: %2.2f  Winkel: %2.2f", Seite,Winkel);
   NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
   // waagrecht rechts
   NSPoint Eckpunkt=NSMakePoint(0,0);
   
   int anzSchritte =4;
   int index=0;
   NSMutableArray* PolygonpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   /*
    Winkel: Grad, waagrecht nach rechts = 0°   CCW */
   //      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index", nil];
   
   // Startpunkt
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   float winkel=Winkel*M_PI/180;
   NSLog(@"QuadratmitSeite winkel rad: %2.2f", winkel);
   // waagrecht rechts
   
   Eckpunkt.x +=Seite*cos(winkel);
   Eckpunkt.y +=Seite*sin(winkel);

   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

    // nach oben
   index++;
   Eckpunkt.x -= Seite*sin(winkel);
   Eckpunkt.y += Seite*cos(winkel);
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   // nach links
   index++;
   Eckpunkt.x -= Seite*cos(winkel);
   Eckpunkt.y -= Seite*sin(winkel);
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   // nach unten
   index++;
   
   Eckpunkt = NSMakePoint(0,0);;
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   
   

   NSLog(@"QuadratmitSeite: tempDatenArray: %@",[tempDatenArray description]);
   
   
   
   return tempDatenArray;
}

- (NSArray*)RechteckKoordinatenMitSeiteA:(float)SeiteA SeiteB:(float)SeiteB  mitWinkel:(float)Winkel
{
	NSLog(@"RechteckKoordinatenMitSeiteA: %2.2f SeiteB: %2.2f  Winkel: %2.2f", SeiteA,SeiteB, Winkel);
	NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	// waagrecht rechts
	NSPoint Eckpunkt=NSMakePoint(0,0);
	
	int anzSchritte =4;
	int index=0;
	NSMutableArray* PolygonpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
	/*
    Winkel: Grad, waagrecht nach rechts = 0°	CCW */
	//      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index", nil];
   
   // Startpunkt
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

	
   float winkel=Winkel*M_PI/180;
   NSLog(@"QuadratmitSeite winkel rad: %2.2f", winkel);
   // waagrecht rechts
   
   Eckpunkt.x +=SeiteA*cos(winkel);
   Eckpunkt.y +=SeiteA*sin(winkel);

   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

    // nach oben
   index++;
   Eckpunkt.x -= SeiteB*sin(winkel);
   Eckpunkt.y += SeiteB*cos(winkel);
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   // nach links
   index++;
   Eckpunkt.x -= SeiteA*cos(winkel);
   Eckpunkt.y -= SeiteA*sin(winkel);
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   // nach unten
   index++;
   
   Eckpunkt = NSMakePoint(0,0);;
   [tempDatenArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:Eckpunkt.x],@"x",[NSNumber numberWithFloat:Eckpunkt.y],@"y",[NSNumber numberWithInt:index],@"index" ,NULL]];

   
   
   

   NSLog(@"QuadratmitSeite: tempDatenArray: %@",[tempDatenArray description]);
	
	
	
	return tempDatenArray;
}



- (NSArray*)KreisVonPunkt:(NSPoint)Startpunkt mitRadius:(float)Radius mitLage:(int)Lage
{
	NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSPoint Mittelpunkt;
	/*
	 Lage: 0: ueber Startpunkt
	 1: links von Startpunkt
	 2: unter Startpunkt
	 3: rechts von Startpunkt
	 */
	switch (Lage)
	{
		case 0:
		{
			Mittelpunkt.x = Startpunkt.x;
			Mittelpunkt.y = Startpunkt.y + Radius;
		}break;
			
		case 1:
		{
			Mittelpunkt.x = Startpunkt.x - Radius;
			Mittelpunkt.y = Startpunkt.y;
		}break;
			
		case 2:
		{
			Mittelpunkt.x = Startpunkt.x;
			Mittelpunkt.y = Startpunkt.y - Radius;
		}break;
			
		case 3:
		{
			Mittelpunkt.x = Startpunkt.x + Radius;
			Mittelpunkt.y = Startpunkt.y;
		}break;
			
	}// switch Lage
	//NSLog(@"KreisVonPunkt: lage: %d Startpunkt x: %2.2f y: %2.2f Radius: %2.2f",Lage, Startpunkt.x, Startpunkt.y, Radius);
	
	// Schrittlaenge
	float Schrittlaenge=1.5;
	
	// Anzahl Schritte:
	float Umfang = Radius * M_PI;
	int anzSchritte =Umfang/Schrittlaenge;
   
 	//NSLog(@"Umfang: %2.2f anzSchritte: %d",Umfang, anzSchritte);
	
	NSMutableArray* KreispunktArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	int index;
	for(index=0;index<anzSchritte;index++)
	{
      float tempX=0;
      float tempY=0;
         switch (Lage)
      {
         case 3:
            tempX=Radius*cos(2*M_PI/anzSchritte*index)*-1;
            tempY=Radius*sin(2*M_PI/anzSchritte*index);
            break;
         case 1:
            tempX=Radius*cos(2*M_PI/anzSchritte*index);
            tempY=Radius*sin(2*M_PI/anzSchritte*index);
            break;

         case 2:
            tempX=Radius*sin(2*M_PI/anzSchritte*index);
            tempY=Radius*cos(2*M_PI/anzSchritte*index);
            break;
         case 0:
            tempX=Radius*sin(2*M_PI/anzSchritte*index);
            tempY=Radius*cos(2*M_PI/anzSchritte*index)*-1;
            break;
      }
		NSPoint tempKreisPunkt=NSMakePoint(tempX, tempY);
		[KreispunktArray addObject:NSStringFromPoint(tempKreisPunkt)];
		
	}// for index
	NSLog(@"KreispunktArray: %@",[KreispunktArray description]);
	
	for(index=0;index<anzSchritte-1;index++)
	{
		NSMutableDictionary*	tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[KreispunktArray objectAtIndex:index], @"startpunkt",
										  [KreispunktArray objectAtIndex:index+1], @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" , [NSNumber numberWithInt:index],@"index",NULL];
		[tempDatenArray addObject:tempDic];
		
	}
	// Kreis schliessen zu Anfangspunkt
	NSMutableDictionary*	tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[KreispunktArray lastObject], @"startpunkt",
									  [KreispunktArray objectAtIndex:0], @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:anzSchritte-1],@"index",NULL];
	[tempDatenArray addObject:tempDic];
	
	//NSLog(@"tempDatenArray: %@",[tempDatenArray description]);
	
	return tempDatenArray;
}



- (NSArray*)KreisKoordinatenMitRadius:(float)Radius mitLage:(int)Lage
{
	NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSPoint Mittelpunkt = NSMakePoint(0, 0);
	/*
	 Lage: 0: ueber Startpunkt
	 1: links von Startpunkt
	 2: unter Startpunkt
	 3: rechts von Startpunkt
    4: zentriert
	 */
	switch (Lage)
	{
		case 0:
		{
			Mittelpunkt.y += Radius;
		}break;
			
		case 1:
		{
			Mittelpunkt.x -= Radius;
		}break;
			
		case 2:
		{
			Mittelpunkt.y -= Radius;
		}break;
			
		case 3:
		{
			Mittelpunkt.x +=  Radius;
		}break;
         
      case 4:
      {
        // Mittelpunkt.x +=  Radius/2;
        // Mittelpunkt.y +=  Radius/2;
      }
			
	}// switch Lage
	//NSLog(@"KreisVonPunkt: lage: %d Startpunkt x: %2.2f y: %2.2f Radius: %2.2f",Lage, Startpunkt.x, Startpunkt.y, Radius);
	
	// Schrittlaenge
	float Schrittlaenge=1.5;
	
	// Anzahl Schritte:
	float Umfang = Radius * M_PI;
	int anzSchritte =Umfang/Schrittlaenge;
   
 	//NSLog(@"Umfang: %2.2f anzSchritte: %d",Umfang, anzSchritte);
	
	NSMutableArray* KreispunktKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	int index;
	for(index=0;index<anzSchritte;index++)
	{
      float tempX=0;
      float tempY=0;
      float phi=2*M_PI/anzSchritte*index;
      switch (Lage)
      {
         case 3:
            tempX=Radius*cos(phi)*-1;
            tempY=Radius*sin(phi);
            break;
         case 1:
            tempX=Radius*cos(phi);
            tempY=Radius*sin(phi);
            break;
            
         case 2:
            tempX=Radius*sin(phi);
            tempY=Radius*cos(phi);
            break;
         case 0:
            tempX=Radius*sin(phi);
            tempY=Radius*cos(phi)*-1;
            break;
      }
      tempX += Mittelpunkt.x;
      tempY += Mittelpunkt.y;
      
      NSNumber* KoordinateX=[NSNumber numberWithFloat:tempX];
      NSNumber* KoordinateY=[NSNumber numberWithFloat:tempY];
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index", nil];
		[KreispunktKoordinatenArray addObject:tempDic];
		
	}// for index
   
   [KreispunktKoordinatenArray addObject:[KreispunktKoordinatenArray objectAtIndex:0]];
   
	//NSLog(@"KreispunktArray: %@",[KreispunktKoordinatenArray description]);
	
   return KreispunktKoordinatenArray;
   
}

- (NSArray*)KreisKoordinatenMitRadius:(float)Radius mitLage:(int)Lage  mitAnzahlPunkten:(int)anzahlPunkte;
{
	NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSPoint Mittelpunkt = NSMakePoint(0, 0);
	/*
	 Lage: 0: ueber Startpunkt
	 1: links von Startpunkt
	 2: unter Startpunkt
	 3: rechts von Startpunkt
	 */
	switch (Lage)
	{
		case 0:
		{
			Mittelpunkt.y += Radius;
		}break;
			
		case 1:
		{
			Mittelpunkt.x -= Radius;
		}break;
			
		case 2:
		{
			Mittelpunkt.y -= Radius;
		}break;
			
		case 3:
		{
			Mittelpunkt.x +=  Radius;
		}break;
		
      case 4:
      {
         //Mittelpunkt.x +=  Radius/2;
        // Mittelpunkt.y +=  Radius/2;
      }break;

	}// switch Lage
	//NSLog(@"KreisVonPunkt: lage: %d Startpunkt x: %2.2f y: %2.2f Radius: %2.2f",Lage, Startpunkt.x, Startpunkt.y, Radius);
	
	// Schrittlaenge
	float Schrittlaenge=1.5;
	
	// Anzahl Schritte:
	float Umfang = Radius * M_PI;
	int anzSchritte =0;
   if (anzahlPunkte == -1)
   {
      anzSchritte =Umfang/Schrittlaenge;
   }
   else
   {
      anzSchritte = anzahlPunkte;
   }

 	//NSLog(@"Umfang: %2.2f anzSchritte: %d",Umfang, anzSchritte);
	
	NSMutableArray* KreispunktKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	int index;
	for(index=0;index<anzSchritte;index++)
	{
      float tempX=0;
      float tempY=0;
      float phi=2*M_PI/anzSchritte*index;
      switch (Lage)
      {
         case 3:
            tempX=Radius*cos(phi)*-1;
            tempY=Radius*sin(phi);
            break;
         case 1:
            tempX=Radius*cos(phi);
            tempY=Radius*sin(phi);
            break;
            
         case 2:
            tempX=Radius*sin(phi);
            tempY=Radius*cos(phi);
            break;
         case 0:
            tempX=Radius*sin(phi);
            tempY=Radius*cos(phi)*-1;
            break;
         case 4:
            tempX=Radius/2*sin(phi);
            tempY=Radius/2*cos(phi)*-1;

      }
      tempX += Mittelpunkt.x;
      tempY += Mittelpunkt.y;
      
      NSNumber* KoordinateX=[NSNumber numberWithFloat:tempX];
      NSNumber* KoordinateY=[NSNumber numberWithFloat:tempY];
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index", nil];
		[KreispunktKoordinatenArray addObject:tempDic];
		
	}// for index
   
   [KreispunktKoordinatenArray addObject:[KreispunktKoordinatenArray objectAtIndex:0]];
   
	//NSLog(@"KreispunktArray count: %d",[KreispunktKoordinatenArray count]);
	NSLog(@"KreispunktArray: %@",[KreispunktKoordinatenArray description]);
	
   return KreispunktKoordinatenArray;
   
}

- (NSArray*)EllipsenKoordinatenMitRadiusA:(float)RadiusA mitRadiusB:(float)RadiusB mitLage:(int)Lage
{
	NSPoint Mittelpunkt = NSMakePoint(0, 0);
	/*
	 Lage: 0: ueber Startpunkt
	 1: links von Startpunkt
	 2: unter Startpunkt
	 3: rechts von Startpunkt
    
    www.mathematische-basteleien.de/ellipse.htm
    x=a*cos(t) /\ y=b*sin(t). 
    Der Umfang kann nicht durch eine elementare Funktion angegeben werden, nur als "elliptisches" Integral 
    Man kann das Integral näherungsweise über eine Reihenentwicklung des Integranden bestimmen. Man erhält  
    epsilon = (ra^2-rb^2)ra^2
    
	 */
   
   float epsilon = (powf(RadiusA,2)-powf(RadiusB,2))/powf(RadiusA,2);
	switch (Lage)
	{
		case 0:
		{
			Mittelpunkt.y += RadiusA;
		}break;
			
		case 1:
		{
			Mittelpunkt.x -= RadiusA;
		}break;
			
		case 2:
		{
			Mittelpunkt.y -= RadiusA;
		}break;
			
		case 3:
		{
			Mittelpunkt.x +=  RadiusA;
		}break;
			
	}// switch Lage
	//NSLog(@"KreisVonPunkt: lage: %d Startpunkt x: %2.2f y: %2.2f Radius: %2.2f",Lage, Startpunkt.x, Startpunkt.y, Radius);
	
	// Schrittlaenge
	float Schrittlaenge=1.5;
	
	// Anzahl Schritte:
	float Umfang = 2*M_PI*RadiusA*(1-powf(epsilon, 2)/4 -3*powf(epsilon,4)/64);
   //NSLog(@"Ellipsenumfang: %2.2f",Umfang);
	
   int anzSchritte =Umfang/Schrittlaenge;
   
 	//NSLog(@"Umfang: %2.2f anzSchritte: %d",Umfang, anzSchritte);
	
	NSMutableArray* EllipsenpunktKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	int index;
	for(index=0;index<anzSchritte;index++)
	{
      float tempX=0;
      float tempY=0;
      float phi=2*M_PI/anzSchritte*index;
      switch (Lage)
      {
         case 3:
            tempX=RadiusA*cos(phi)*-1;
            tempY=RadiusB*sin(phi);
            break;
         case 1:
            tempX=RadiusA*cos(phi);
            tempY=RadiusB*sin(phi);
            break;
            
         case 2:
            tempX=RadiusA*sin(phi);
            tempY=RadiusB*cos(phi);
            break;
         case 0:
            tempX=RadiusA*sin(phi);
            tempY=RadiusB*cos(phi)*-1;
            break;
      }
      tempX += Mittelpunkt.x;
      tempY += Mittelpunkt.y;
      
      NSNumber* KoordinateX=[NSNumber numberWithFloat:tempX];
      NSNumber* KoordinateY=[NSNumber numberWithFloat:tempY];
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index", nil];
		[EllipsenpunktKoordinatenArray addObject:tempDic];
		
	}// for index
   
   [EllipsenpunktKoordinatenArray addObject:[EllipsenpunktKoordinatenArray objectAtIndex:0]];
   
	//NSLog(@"EllipsenKoordinaten: %@",[EllipsenpunktKoordinatenArray description]);
	
   return EllipsenpunktKoordinatenArray;
}

- (NSArray*)EllipsenKoordinatenMitRadiusA:(float)RadiusA mitRadiusB:(float)RadiusB mitLage:(int)Lage mitAnzahlPunkten:(int)anzahlPunkte
{
	NSPoint Mittelpunkt = NSMakePoint(0, 0);
	/*
    anzahlPunkte: wenn =-1: Masterform berechnen
    sonst: Slaveform 
	 Lage: 0: ueber Startpunkt
	 1: links von Startpunkt
	 2: unter Startpunkt
	 3: rechts von Startpunkt
    
    www.mathematische-basteleien.de/ellipse.htm
    x=a*cos(t) /\ y=b*sin(t). 
    Der Umfang kann nicht durch eine elementare Funktion angegeben werden, nur als "elliptisches" Integral 
    Man kann das Integral näherungsweise über eine Reihenentwicklung des Integranden bestimmen. Man erhält  
    epsilon = (ra2-rb2)ra2
    
	 */
   
   
	switch (Lage)
	{
		case 0:
		{
			Mittelpunkt.y += RadiusB;
		}break;
			
		case 1:
		{
			Mittelpunkt.x -= RadiusA;
		}break;
			
		case 2:
		{
			Mittelpunkt.y -= RadiusB;
		}break;
			
		case 3:
		{
			Mittelpunkt.x +=  RadiusA;
		}break;
			
	}// switch Lage
   
	//NSLog(@"KreisVonPunkt: lage: %d Startpunkt x: %2.2f y: %2.2f Radius: %2.2f",Lage, Startpunkt.x, Startpunkt.y, Radius);
	
	// Schrittlaenge
	float Schrittlaenge=1.5;
  // Berechnung Umfang:
   float epsilon = (powf(RadiusA,2)-powf(RadiusB,2))/powf(RadiusA,2);

	// Anzahl Schritte:
	float Umfang = 2*M_PI*RadiusA*(1-powf(epsilon, 2)/4 -3*powf(epsilon,4)/64);
   //NSLog(@"Ellipsenumfang: %2.2f",Umfang);
	int anzSchritte =0;
   if (anzahlPunkte == -1)
   {
      anzSchritte =Umfang/Schrittlaenge;
   }
   else
   {
      anzSchritte = anzahlPunkte;
   }
   
 	//NSLog(@"Umfang: %2.2f anzSchritte: %d",Umfang, anzSchritte);
	
	NSMutableArray* EllipsenpunktKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	int index;
	for(index=0;index<anzSchritte;index++)
	{
      float tempX=0;
      float tempY=0;
      float phi=2*M_PI/anzSchritte*index;
      switch (Lage)
      {
         case 3:
            tempX=RadiusA*cos(phi)*-1;
            tempY=RadiusB*sin(phi);
            break;
         case 1:
            tempX=RadiusA*cos(phi);
            tempY=RadiusB*sin(phi);
            break;
            
         case 2:
            tempX=RadiusA*sin(phi);
            tempY=RadiusB*cos(phi);
            break;
         case 0:
            tempX=RadiusA*sin(phi);
            tempY=RadiusB*cos(phi)*-1;
            break;
      }
      tempX += Mittelpunkt.x;
      tempY += Mittelpunkt.y;
      
      NSNumber* KoordinateX=[NSNumber numberWithFloat:tempX];
      NSNumber* KoordinateY=[NSNumber numberWithFloat:tempY];
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateX, @"x",KoordinateY,@"y" ,[NSNumber numberWithInt:index],@"index", nil];
		[EllipsenpunktKoordinatenArray addObject:tempDic];
		
	}// for index
   
   [EllipsenpunktKoordinatenArray addObject:[EllipsenpunktKoordinatenArray objectAtIndex:0]];
   
	//NSLog(@"EllipsenKoordinaten: %@",[EllipsenpunktKoordinatenArray description]);
	
   return EllipsenpunktKoordinatenArray;
}

- (NSArray*)SegmentKoordinatenMitRadiusA:(float)RadiusA mitRadiusB:(float)RadiusB mitWinkel:(float)Winkel mitLage:(int)Lage mitAnzahlPunkten:(int)anzahlPunkte vonStartpunktA:(NSPoint)startpunktA vonStartpunktB:(NSPoint)startpunktB 
{
   NSMutableArray* segmentKoordinatenArray=[[NSMutableArray alloc]initWithCapacity:0]; // Dics 
 
   // linksbogen
   /*
    Lage: 
    0: nach rechts oben ueber Startpunkt
    1: nach links oben von Startpunkt
   
    2: nach links unten von Startpunkt
    3: nach rechts unten von Startpunkt
*/
   NSPoint StartpunktA = startpunktA;
   NSPoint MittelpunktA = startpunktA;

   NSPoint StartpunktB = startpunktB;
   NSPoint MittelpunktB = startpunktB;
   
   switch (Lage)
   {
      case 0: // nach rechts oben ueber Startpunkt
      {
         MittelpunktA.y -= RadiusA;
         MittelpunktB.y -= RadiusB;
      }break;

      case 1: // nach links oben von Startpunkt
      {
         MittelpunktA.x -= RadiusA;
         MittelpunktA.x -= RadiusB;
      }break;
 
      case 2: // nach links unten von Startpunkt
      {
         MittelpunktA.y += RadiusA;
         MittelpunktB.y += RadiusB;
      }break;
         
      case 3: // nach rechts unten von Startpunkt
      {
         MittelpunktA.x += RadiusA;
         MittelpunktA.x += RadiusB;
      }break;
         
          
   }// switch Lage
   
   
   float winkelschritt = Winkel/anzahlPunkte*M_PI/180;
   
   int index;
   for(index=0;index<anzahlPunkte+1;index++) // incl. letzten Punkt
   {
      float tempAX=0;
      float tempAY=0;
      
      float tempBX=0;
      float tempBY=0;

      //float phi=2*M_PI/anzahlPunkte*index;
      float phi=winkelschritt*index;
      switch (Lage)
      {
         case 0: // nach rechts oben ueber Startpunkt
            tempAX=RadiusA*sin(phi);
            tempAY=RadiusA*(1-cos(phi));
 
            tempBX=RadiusB*sin(phi);
            tempBY=RadiusB*(1-cos(phi));
            
            break;
         case 1: // nach links oben von Startpunkt
            tempAX=RadiusA*(1-cos(phi))*-1;
            tempAY=RadiusA*sin(phi);
            tempBX=RadiusB*(1-cos(phi))*-1;
            tempBY=RadiusB*sin(phi);
            
            break;
            
         case 2:
            tempAX=RadiusA*sin(phi)*-1;
            tempAY=RadiusA*(1-cos(phi))*-1;

            tempBX=RadiusB*sin(phi)*-1;
            tempBY=RadiusB*(1-cos(phi))*-1;
            
            break;

         case 3:  // nach links unten von Startpunkt
            tempAX=RadiusA*(1-cos(phi));
            tempAY=RadiusA*sin(phi)*-1;
            
            tempBX=RadiusB*(1-cos(phi));
            tempBY=RadiusB*sin(phi)*-1;

  
            break;

      }
      tempAX += startpunktA.x;
      tempAY += startpunktA.y;

      tempBX += startpunktB.x;
      tempBY += startpunktB.y;
      
      NSNumber* KoordinateAX=[NSNumber numberWithFloat:tempAX];
      NSNumber* KoordinateAY=[NSNumber numberWithFloat:tempAY];

      NSNumber* KoordinateBX=[NSNumber numberWithFloat:tempBX];
      NSNumber* KoordinateBY=[NSNumber numberWithFloat:tempBY];

      
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:KoordinateAX, @"ax",KoordinateAY,@"ay" ,KoordinateBX, @"bx",KoordinateBY,@"by" ,[NSNumber numberWithInt:index],@"index", nil];
      [segmentKoordinatenArray addObject:tempDic];


   } // for i
   return segmentKoordinatenArray;
}

- (NSArray*)KreisabschnitteVonKreiskoordinaten:(NSArray*)dieKreiskoordiaten  mitRadius:(float)Radius
{
   NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
   // Schrittlaenge
	float Schrittlaenge=1.5;
	
	// Anzahl Schritte:
	float Umfang = Radius * M_PI;
	int anzSchritte =Umfang/Schrittlaenge;
   
   int index=0;
	for(index=0;index<anzSchritte-1;index++)
	{
		NSMutableDictionary*	tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dieKreiskoordiaten objectAtIndex:index], @"startpunkt",
                                      [dieKreiskoordiaten objectAtIndex:index+1], @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" , [NSNumber numberWithInt:index],@"index",NULL];
		[tempDatenArray addObject:tempDic];
		
	}
	// Kreis schliessen zu Anfangspunkt
	NSMutableDictionary*	tempDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dieKreiskoordiaten lastObject], @"startpunkt",
                                   [dieKreiskoordiaten objectAtIndex:0], @"endpunkt",[NSNumber numberWithFloat:1],@"zoomfaktor" ,[NSNumber numberWithInt:anzSchritte-1],@"index",NULL];
	[tempDatenArray addObject:tempDic];
	
	//NSLog(@"tempDatenArray: %@",[tempDatenArray description]);
	
	return tempDatenArray;
   
   
}

- (NSArray*)ProfilVonPunkt:(NSPoint)Startpunkt mitProfil:(NSDictionary*)ProfilDic mitProfiltiefe:(int)Profiltiefe mitScale:(int)Scale
{
   NSLog(@"AVR openProfil");
	
//	NSString* ProfilName;
	NSArray* ProfilArray;
	
   ProfilArray=[ProfilDic objectForKey:@"profilarray"];
//	ProfilName=[ProfilDic objectForKey:@"profilname"];
   
//	[ProfilNameFeldA setStringValue:ProfilName];
	//ProfilArray=[Utils readProfil];
	//KoordinatenTabelle=(NSMutableArray*)[Utils readProfil];
	//	[KoordinatenTabelle setArray:(NSMutableArray*)ProfilArray];
	//NSLog(@"AVR ProfilArray: %@",[ProfilArray description]);
	// Annahme fuer Nullpunkt des Profils
	
	// Listen leeren
	int i;
	int maxX = 100;
	maxX = Profiltiefe; // Profiltiefe in mm
   
   // Startpunkt ist an Endleiste
   Startpunkt.x -= Profiltiefe;
	float minX=1.0;	// Startwert fuer Suche nach vordestem Punkt des Profils. Muss nicht 0.0 sein.
	int minIndex=0;	// Index des vordersten Punktes im Array
	
   NSMutableArray* ProfilpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* ProfilOpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* ProfilUpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   for (i=0;i<[ProfilArray count];i++)
	{
		
		// Profildatenpaare aus Datei mit dem Offset des Profilnullpunktes versehen
		//NSLog(@"ProfilArray index: %d Data: %@",i,[[ProfilArray objectAtIndex:i]description]);
		// X-Achse, 
		float tempX = [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
      //NSLog(@"tempX: %2.2f ",tempX);
      
      int seitenindex=0;// Oberseite
		if (tempX < minX) // Minimum noch nicht erreicht, Oberseite
      {
         minX = tempX;
         minIndex=i;
      }
      else
      {
         seitenindex=1; // Unterseite
      }
      //NSLog(@"minX: %2.2f ",minX);
      tempX *= maxX;						// Wert in mm 
      // NSLog(@"tempX: %2.2f ",tempX);
		tempX += Startpunkt.x;	// offset in mm
      
		//tempX *= Scale;
		NSNumber* tempNumberX=[NSNumber numberWithFloat:tempX];
		//NSLog(@"tempX: %2.2f tempNumberX: %@",tempX, tempNumberX);
		//Y-Achse
		float tempY = [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
		tempY *= maxX;						// Wert in mm 
		tempY += Startpunkt.y;	// Offset in mm
		//tempY *= Scale;
		NSNumber* tempNumberY=[NSNumber numberWithFloat:tempY];
		
      //ProfilpunktArray fuellen
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX, @"x",tempNumberY,@"y" ,[NSNumber numberWithInt:i],@"index", nil];
      [ProfilpunktArray addObject: tempDic];
      if (seitenindex) // Unterseite
      {
         [ProfilUpunktArray addObject: tempDic];
      }
      else
      {
         [ProfilOpunktArray addObject: tempDic];
      }
      
      
   } // for i
   //NSLog(@"minIndex: %2.2f minX: %2.2f ",minIndex, minX);
   // Profillinie schliessen:
      
  // [ProfilpunktArray addObject: [ProfilpunktArray objectAtIndex:0]];
   
   return ProfilpunktArray;
}



- (NSDictionary*)HolmDicVonPunkt:(NSPoint)Startpunkt mitProfil:(NSArray*)ProfilArray mitProfiltiefe:(int)Profiltiefe mitScale:(int)Scale
{
   float Holmposition = 0.66; // Lage des Holms von der Endleiste an gemessen
	float basisbreite = 10; // Breite der Basis unten in mm
      
   // basisbreite auf 1 normieren
   basisbreite /= Profiltiefe;
   
   // schalendicke auf 1 normieren
   schalendicke /= Profiltiefe;

   
   //NSArray* ProfilArrayA;
   NSMutableDictionary* HolmpunktDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   
    
   int holmpos = 0; // Position an Unterseite
   
   for (int i=0; i<[ProfilArray count]; i++)
   {
      //NSLog(@"i: %d x: %.3f",i,[[[Profil1Array objectAtIndex:i]objectForKey:@"x"]floatValue]);
      
      // Koord x laeuft auf der Unterseite von 1 an rueckwaerts. pruefen ob immer npch groesser als Holmposition
      if (i>[ProfilArray count]/2 && [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue] > Holmposition)
      {
         holmpos = i;
      }
   }
   
   //       NSLog(@"holmpos: %d x: %.3f y: %.3f",holmpos,[[[ProfilArray objectAtIndex:holmpos]objectForKey:@"x"]floatValue],[[[ProfilArray objectAtIndex:holmpos]objectForKey:@"y"]floatValue] );
   //        NSLog(@"x0: %.5f x1: %.5f",[[[ProfilArray objectAtIndex:holmpos-2]objectForKey:@"x"]floatValue],[[[ProfilArray objectAtIndex:holmpos+2]objectForKey:@"x"]floatValue]);
   //        NSLog(@"y0: %.5f y1: %.5f",[[[ProfilArray objectAtIndex:holmpos-2]objectForKey:@"y"]floatValue],[[[ProfilArray objectAtIndex:holmpos+2]objectForKey:@"y"]floatValue]);
   
   // Startpunkte der Diagonalen auf der unteren Profillinie
   NSPoint Startpunktnachvorn = NSMakePoint([[[ProfilArray objectAtIndex:holmpos]objectForKey:@"x"]floatValue], [[[ProfilArray objectAtIndex:holmpos]objectForKey:@"y"]floatValue]);
   NSPoint Startpunktnachhinten = Startpunktnachvorn; // Ausgangspunkt fuer Suche nach Punkt in genuegender Distanz
   NSPoint tempStartpunktnachhinten = Startpunktnachvorn; // Ausgangspunkt fuer Suche nach Punkt in genuegender Distanz
   
   
   int schritte; // Anzahl Koordinatenpunkte, welche fuer eine ausreichende Breite der Grundflaeche notwendig sind.
   float distanzreal = 0;
   
   schritte=0; // mindestens eine Schrittweite
   
   while ((holmpos + schritte) < [ProfilArray count] && distanzreal < 8)
   {
      schritte++;

      Startpunktnachhinten = NSMakePoint([[[ProfilArray objectAtIndex:(holmpos + schritte)]objectForKey:@"x"]floatValue], [[[ProfilArray objectAtIndex:(holmpos + schritte)]objectForKey:@"y"]floatValue]);
      //NSLog(@"schritte: %d temppunkt.x: %.3f temppunkt.y: %.3f",schritte,Startpunktnachhinten.x*Profiltiefe,Startpunktnachhinten.y*Profiltiefe);
      distanzreal = (Startpunktnachvorn.x-Startpunktnachhinten.x)*Profiltiefe;
      //NSLog(@"schritte: %d distanzreal: %.2fmm", schritte,distanzreal);
   }
   
   
   //NSLog(@"schritte: %d distanzreal: %.2fmm",schritte,distanzreal);
   // Holmansatzpunkte unten
   int holmposvorn = holmpos;
   int holmposhinten = holmpos + schritte;
   
   // neu
   holmposhinten = holmposvorn + 2;
   
   // Koordinatenunterschiede
   float deltay = [[[ProfilArray objectAtIndex:holmposhinten]objectForKey:@"y"]floatValue]-[[[ProfilArray objectAtIndex:holmposvorn]objectForKey:@"y"]floatValue]; // index verlaeuft gegen Endleiste zu
   float deltax = [[[ProfilArray objectAtIndex:holmposhinten]objectForKey:@"x"]floatValue]-[[[ProfilArray objectAtIndex:holmposvorn]objectForKey:@"x"]floatValue];
   //NSLog(@"deltax : %.5f deltay: %.5f",deltax,deltay);
   //NSLog(@"deltax real: %.5fmm ",deltax*Profiltiefe);
   
   // Steigung der Tangente und Einheitsvektor
   float steigungunten = 0;
   if(deltax)
   {
      steigungunten = deltay/deltax; // tangente
   }
   // Berechnung Startpunktnachhinten im Abstand basisbreite aus Startpunkt nachvorn und steigungunten 
   
   
  // NSLog(@"alt: Startpunktnachvorn.x: %.3f Startpunktnachvorn.y: %.5f",Startpunktnachvorn.x,Startpunktnachvorn.y);
  // NSLog(@"alt: Startpunktnachhinten.x: %.3f Startpunktnachhinten.y: %.5f",Startpunktnachhinten.x,Startpunktnachhinten.y);
   Startpunktnachhinten.x = Startpunktnachvorn.x - basisbreite;
   Startpunktnachhinten.y = Startpunktnachvorn.y - basisbreite * steigungunten;
  // NSLog(@"neu: Startpunktnachhinten.x: %.3f Startpunktnachhinten.y: %.5f",Startpunktnachhinten.x,Startpunktnachhinten.y);
 
   // schalendicke zu Startpunkten 2* addieren
   Startpunktnachvorn.y += 2*schalendicke;
   Startpunktnachhinten.y += 2*schalendicke;
   
   
   NSPoint vektortang = NSMakePoint(cos(steigungunten), sin(steigungunten));
   
  
   // Steigung der Senkrechten und Einheitvektor
   float steigungsenkrecht = -deltax/deltay; // senkrechte
   NSPoint vektorsenkr = NSMakePoint(cos(steigungsenkrecht), sin(steigungsenkrecht));
   
   // Vektor der Winkelhalbierenden nach vorn
   NSPoint vektornachvorn = NSMakePoint(cos(steigungunten) + cos(steigungsenkrecht), sin(steigungunten) + sin(steigungsenkrecht));
   
   // Vektor der Winkelhalbiernenden nach hinten
   //NSPoint vektornachhinten = NSMakePoint(-1*(cos(steigungunten) + cos(steigungsenkrecht)), sin(steigungunten) + sin(steigungsenkrecht));
   
   //NSLog(@"t0: %.4f t1: %.4f",vektortang.x,vektortang.y);
   //NSLog(@"s0: %.4f s1: %.4f",vektorsenkr.x,vektorsenkr.y);
   //NSLog(@"u0: %.4f v1: %.4f",vektornachvorn.x,vektornachvorn.y);
   
   float holm1lage=[[[ProfilArray objectAtIndex:holmpos]objectForKey:@"x"]floatValue]*Profiltiefe;
   //float winkelnachvorn = steigungunten + M_PI/4;
   //float winkelnachhinten = steigungunten + 3*M_PI/4;
   //NSLog(@"holm1lage: %.4f steigungunten: %.4f steigungsenkrecht: %.4f",holm1lage,steigungunten,steigungsenkrecht);
   
   float xnachvorn = 0;
   float ynachvorn = Startpunktnachvorn.y + vektornachvorn.y/vektornachvorn.x * (xnachvorn - Startpunktnachvorn.x);
   
   float zielsteigungnachvorn = 1-steigungunten; // Soll der Steigung des vorderen Teils
   float minvornfehler = FLT_MAX; // abweichung vom Soll
   int minvornpos =0; // index des des Fehlerminimums
   
   float zielsteigungnachhinten = -(1-steigungunten);
   float minhintenfehler = FLT_MAX;
   int minhintenpos =0;
   
   
   for (int k=0;k<[ProfilArray count]/2;k++) // nur Oberseite
   {
      NSPoint tempOberseitenpunkt = NSMakePoint([[[ProfilArray objectAtIndex:k]objectForKey:@"x"]floatValue], [[[ProfilArray objectAtIndex:k]objectForKey:@"y"]floatValue]);
      
      // Bildet der Punkt an pos k mit Endpunktnachvorn einen Winkel von 45°?
      float tempsteigungvorn = (tempOberseitenpunkt.y - Startpunktnachvorn.y)/(tempOberseitenpunkt.x - Startpunktnachvorn.x);
      //NSLog(@"k: %d tempsteigungvorn: %.3f fehler: %.3f",k,tempsteigungvorn,fabs(tempsteigungvorn - zielsteigungnachvorn));
      float tempfehler = fabs(tempsteigungvorn - zielsteigungnachvorn);
      if (tempfehler < minvornfehler)
      {
         minvornfehler = tempfehler;
         minvornpos = k ;
      }
      
      float tempsteigunghinten = (tempOberseitenpunkt.y - Startpunktnachhinten.y)/(tempOberseitenpunkt.x - Startpunktnachhinten.x);
      //NSLog(@"k: %d tempsteigunghinten: %.3f fehler: %.3f",k,tempsteigunghinten,fabs(tempsteigunghinten - zielsteigungnachhinten));
      
      tempfehler = fabs(tempsteigunghinten - zielsteigungnachhinten);
      if (tempfehler < minhintenfehler)
      {
         minhintenfehler = tempfehler;
         minhintenpos = k ;
      }
      
   }
   //NSLog(@"holmposvorn: %d minvornpos: %d steigungvorn ok minvornfehler: %.3f",holmposvorn,minvornpos,minvornfehler);
   //NSLog(@"holmposhinten: %d minhintenpos: %d steigunghinten ok minhintenfehler: %.3f",holmposhinten,minhintenpos,minhintenfehler);
   //NSLog(@"Startpunkt.x: %.3f Startpunkt.y: %.3f",Startpunkt.x,Startpunkt.y);
   NSMutableArray* HolmpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   //HolmpunktArray fuellen
   
   //Anfang setzen: Koord von Endpunktnachhinten - schritte
   int aktuellepos= minhintenpos-schritte;
   int aktuellerindex=0;
   
   //Steigung der Profillinie von minhintenpos bis 2 Schritte nach hinten:
   float deltaxh = [[[ProfilArray objectAtIndex:minhintenpos-2]objectForKey:@"x"]floatValue] - [[[ProfilArray objectAtIndex:minhintenpos]objectForKey:@"x"]floatValue];
   
   float deltayh = [[[ProfilArray objectAtIndex:minhintenpos-2]objectForKey:@"y"]floatValue] - [[[ProfilArray objectAtIndex:minhintenpos]objectForKey:@"y"]floatValue];
   float steigungh = deltayh/deltaxh;

   //Steigung der Profillinie von minvornpos bis 2 Schritte nach vorn:
   float deltaxv = [[[ProfilArray objectAtIndex:minvornpos+2]objectForKey:@"x"]floatValue] - [[[ProfilArray objectAtIndex:minvornpos]objectForKey:@"x"]floatValue];
   float deltayv = [[[ProfilArray objectAtIndex:minvornpos+2]objectForKey:@"y"]floatValue] - [[[ProfilArray objectAtIndex:minvornpos]objectForKey:@"y"]floatValue];
   float steigungv = deltayv/deltaxv;
   //NSLog(@"steigungh: %.3f steigungv: %.3f",steigungh,steigungv);

   
   //Breite des Streifens: 10mm
   int l0 = 10;

   // start bei minhintenpos
   float startX = [[[ProfilArray objectAtIndex:minhintenpos]objectForKey:@"x"]floatValue];
   startX *= Profiltiefe;
   float startY = [[[ProfilArray objectAtIndex:minhintenpos]objectForKey:@"y"]floatValue];
   startY *= Profiltiefe;
   
   //Koord des Anfangs des Streifens berechnen: 10 mm nach hinten
   startX -= l0;// Wert in mm
   startY -= l0*steigungh;
   
   // Offset in mm fuer alle Punkte: Position des ersten Punktes
   float offsetx = startX; 
   float offsety = startY;
   
   // Offset subtrahieren
   startX -= offsetx;
   startY -= offsety;
   
   // Koord des Startpunktes addieren
   startX += Startpunkt.x;
   startY += Startpunkt.y;	// offset in mm
   
    
   NSNumber* startNumberY=[NSNumber numberWithFloat:startY];
   NSNumber* startNumberX=[NSNumber numberWithFloat:startX];
   
    NSDictionary* startDic=[NSDictionary dictionaryWithObjectsAndKeys:startNumberX, @"x",startNumberY,@"y" ,[NSNumber numberWithInt:aktuellerindex],@"index",[NSNumber numberWithInt:0],@"seitenindex", nil];
   [HolmpunktArray addObject: startDic];
   
   //erster Knickpunkt oben setzen: Koord von Endpunktnachhinten
   
   aktuellepos= minhintenpos;
   aktuellerindex++;
   float tempX = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"x"]floatValue];
   
   tempX *= Profiltiefe;						// Wert in mm
   tempX -= offsetx;
   tempX += Startpunkt.x;	// offset in mm
   NSNumber* tempNumberX1=[NSNumber numberWithFloat:tempX];
   
   float tempY = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"y"]floatValue];
   
   tempY *= Profiltiefe;						// Wert in mm
   tempY -= offsety;
   tempY += Startpunkt.y;	// offset in mm
   NSNumber* tempNumberY1=[NSNumber numberWithFloat:tempY];
    
   NSDictionary* tempDic1=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX1, @"x",tempNumberY1,@"y" ,[NSNumber numberWithInt:aktuellerindex],@"index",[NSNumber numberWithInt:0],@"seitenindex", nil];
   [HolmpunktArray addObject: tempDic1];
   
   //zweiter Knickpunkt unten setzen: Koord von Startpunktnachhinten
   aktuellepos= holmposhinten;
   aktuellerindex++;
   tempX = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"x"]floatValue];
   
   // neu: Startpunktnachvorn aus Berechnung
   tempX = Startpunktnachhinten.x;
   
   tempX *= Profiltiefe;						// Wert in mm
   tempX -= offsetx;
   tempX += Startpunkt.x;	// offset in mm
   
   NSNumber* tempNumberX2=[NSNumber numberWithFloat:tempX];
   
   tempY = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"y"]floatValue];
   
   // neu: Startpunktnachvorn aus Berechnung
   tempY = Startpunktnachhinten.y;
   
   tempY *= Profiltiefe;						// Wert in mm
   tempY -= offsety;
   tempY += Startpunkt.y;	// offset in mm
   
   NSNumber* tempNumberY2=[NSNumber numberWithFloat:tempY];
   
   NSDictionary* tempDic2=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX2, @"x",tempNumberY2,@"y" ,[NSNumber numberWithInt:aktuellerindex],@"index",[NSNumber numberWithInt:0],@"seitenindex", nil];
   [HolmpunktArray addObject: tempDic2];
   
   //dritter Knickpunkt unten setzen: Koord von Startpunktnachvorn
   aktuellepos= holmposvorn;
   aktuellerindex++;
   tempX = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"x"]floatValue];
   
   // neu: Startpunktnachvorn aus Berechnung
   tempX = Startpunktnachvorn.x;
   
   tempX *= Profiltiefe;						// Wert in mm
   tempX -= offsetx;
   tempX += Startpunkt.x;	// offset in mm
   NSNumber* tempNumberX3=[NSNumber numberWithFloat:tempX];
   
   tempY = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"y"]floatValue];
   
   // neu: Startpunktnachvorn aus Berechnung
   tempY = Startpunktnachvorn.y;
   
   tempY *= Profiltiefe;						// Wert in mm
   tempY -= offsety;
   tempY += Startpunkt.y;	// offset in mm
   NSNumber* tempNumberY3=[NSNumber numberWithFloat:tempY];
   
   NSDictionary* tempDic3=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX3, @"x",tempNumberY3,@"y" ,[NSNumber numberWithInt:aktuellerindex],@"index",[NSNumber numberWithInt:0],@"seitenindex", nil];
   [HolmpunktArray addObject: tempDic3];
   
   
   //dritter Knickpunkt oben setzen: Koord von Endpunktnachvorn
   aktuellepos= minvornpos;
   aktuellerindex++;
   tempX = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"x"]floatValue];
   
   tempX *= Profiltiefe;						// Wert in mm
   tempX -= offsetx;
   tempX += Startpunkt.x;	// offset in mm
   NSNumber* tempNumberX4=[NSNumber numberWithFloat:tempX];
   
   tempY = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"y"]floatValue];
   
   tempY *= Profiltiefe;						// Wert in mm
   tempY -= offsety;
   tempY += Startpunkt.y;	// offset in mm
   NSNumber* tempNumberY4=[NSNumber numberWithFloat:tempY];
   
   NSDictionary* tempDic4=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX4, @"x",tempNumberY4,@"y" ,[NSNumber numberWithInt:aktuellerindex],@"index",[NSNumber numberWithInt:0],@"seitenindex", nil];
   [HolmpunktArray addObject: tempDic4];
   
   //Endpunkt oben setzen: Koord von Endpunktnachvorn+schritte
   aktuellepos= minvornpos+schritte;
   aktuellerindex++;
   tempX = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"x"]floatValue];
   
   tempX *= Profiltiefe;						// Wert in mm
   tempX -= offsetx;
   tempX += Startpunkt.x;	// offset in mm
   NSNumber* tempNumberX5=[NSNumber numberWithFloat:tempX];
   
   tempY = [[[ProfilArray objectAtIndex:aktuellepos]objectForKey:@"y"]floatValue];
   
   tempY *= Profiltiefe;						// Wert in mm
   tempY -= offsety;
   tempY += Startpunkt.y;	// offset in mm
   NSNumber* tempNumberY5=[NSNumber numberWithFloat:tempY];
   
   NSDictionary* tempDic5=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX5, @"x",tempNumberY5,@"y" ,[NSNumber numberWithInt:aktuellerindex],@"index",[NSNumber numberWithInt:0],@"seitenindex", nil];
   [HolmpunktArray addObject: tempDic5];
   
   //NSLog(@"HolmpunktArray %@",[HolmpunktArray description]);
   
   [HolmpunktDic setObject:HolmpunktArray forKey:@"holmpunktarray"];
   
   return HolmpunktDic;
   
}

- (float)gfkVonProfil:(NSArray*) profilarray
{
   float gfkX = 0;   // aktueller wert
   float lastgfkX = 0; // Wert aus vorheriger loop
   float gfkY = 0;
   float lastgfkY = 0;
   
   float gfkweg = 0;
   int neg = 0; // Oberseite, x-Werte zunehmend
   if (profilarray.count > 3 && ([[[profilarray objectAtIndex:3]objectForKey:@"x"]intValue] < [[[profilarray objectAtIndex:0]objectForKey:@"x"]intValue]))
   {
      neg = 1;
   }
   NSArray* arrayx = [profilarray valueForKey:@"x"];
  int max = [[arrayx valueForKeyPath:@"@max.floatValue"] floatValue];
   
   
   for (int i=0;i<[profilarray count];i++)
   {
      // Profildatenpaare aus Datei mit dem Offset des Profilnullpunktes versehen
      
      //NSLog(@"profilarray index: %d Data: %@",i,[[profilarray objectAtIndex:i]description]);
      // X-Achse, 
      gfkX = [[[profilarray objectAtIndex:i]objectForKey:@"x"]floatValue];
      
      //NSLog(@"tempX: %2.2f ",tempX);
      float gfkY = [[[profilarray objectAtIndex:i]objectForKey:@"y"]floatValue];
      
      
      float tempweg = hypotf((gfkY - lastgfkY),(gfkX - lastgfkX));
      gfkweg += tempweg;
      //fprintf(stderr, "%d \t %2.2f \t %2.2f \t %2.2f \t %2.2f \t  %2.2f \t  %2.2f \n",i,gfkX,lastgfkX,gfkY ,lastgfkY,tempweg,gfkweg);
      
      lastgfkX = gfkX;
      lastgfkY = gfkY;

      
   } // for i
   gfkweg -= neg;
   return gfkweg;
} // gfkVonProfil

- (NSDictionary*)interpolProfilDicVonPos:(int)Startpunkt mitProfil:(NSArray*)ProfilArray mitProfiltiefe:(int)Profiltiefe mitScale:(int)Scale mitmindist:(float) mindist
{
   NSMutableArray* ProfilpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* MittellinieArray=[[NSMutableArray alloc]initWithCapacity:0];

   float gfkX = 0;   // aktueller wert
   float lastgfkX = 0; // Wert aus vorheriger loop
   float gfkY = 0;
   float lastgfkY = 0;
   
   float gfkweg = 0;
   
   float lastx=0;
   float lasty=0;
   
   float endx = 0;
   
   float mindistq = mindist*mindist;
   
   
   
   int startindex = 0;
   int previndex = 0;
   int nowindex = 0;
   int nextindex = 0;
   int overnextindex = 0;
   int bereich = 4;
   
   int schrittcounter = 0; // index der interpolationsstellen
   
   int neg = 0; // Oberseite, x-Werte zunehmend
   if (ProfilArray.count > 3 && ([[[ProfilArray objectAtIndex:3]objectForKey:@"x"]intValue] < [[[ProfilArray objectAtIndex:0]objectForKey:@"x"]intValue]))
   {
      neg = Profiltiefe;
   }
   double startx=0;
   double prevx = 0;
   double prevy = 0;
   float nowx = 0;
   float nowy = 0;
   double nextx = 0;
   double nexty = 0;
   double overnextx = 0;
   double overnexty = 0;

   
   NSMutableDictionary* ProfilpunktDic=NSMutableDictionary.new;
   
   // erstes objekt laden
   //[ProfilpunktArray addObject:[ProfilArray objectAtIndex:0]];
   
   
   startx = [[[ProfilArray objectAtIndex:0]objectForKey:@"x"]doubleValue]; // startwert x
   
   // ausgangswerte fuer indices
   
   previndex = 10;
   nowindex = 11;
   nextindex = 12;
   overnextindex = 13;
    // profil:
   printf("\ninterpolProfilDicVonPos \n");
 //  double px[[ProfilArray count]];
 //  double py[[ProfilArray count]] ;
   float tempxabstand = 0;
   
   for (int i=0;i<[ProfilArray count];i++)
   
   {
     // printf("%d\t%lf\t%lf\n",i,[[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue],[[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue]);
 //     px[i] = [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
 //     py[i] = [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
      
   }
   //printf("\n");
   // array abarbeiten
   
   endx = [[[ProfilArray lastObject]objectForKey:@"x"]floatValue];
   //for (int i=0;i<[ProfilArray count]-2;i++)
      for (int i=0;i<20;i++)
   {
       //NSLog(@"ProfilArray index: %d Data: %@",i,[[ProfilArray objectAtIndex:i]description]);
      // X-Achse, 
      nowx = [[[ProfilArray objectAtIndex:i+1]objectForKey:@"x"]floatValue];
      
      //NSLog(@"tempX: %2.2f ",tempX);
      nowy = [[[ProfilArray objectAtIndex:i+1]objectForKey:@"y"]floatValue];
      
      if(i<[ProfilArray count]-1) // zweitletztes Element
      {
         nextx = [[[ProfilArray objectAtIndex:i+2]objectForKey:@"x"]doubleValue];
         nexty = [[[ProfilArray objectAtIndex:i+2]objectForKey:@"y"]doubleValue];
      }

      if(i<[ProfilArray count]-2) // drittletztes element
      {
         overnextx = [[[ProfilArray objectAtIndex:i+3]objectForKey:@"x"]doubleValue];
         overnexty = [[[ProfilArray objectAtIndex:i+3]objectForKey:@"y"]doubleValue];
      }
      double koeffarray[bereich];
      
      prevx = [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
      prevy = [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
    
       
 
      
      if(i==0) // erstes intervall: wertx im bereich zwischen prevx und nowx
      {
         /*
         i+1 ++;
         previndex ++;
         nextindex ++;
         overnextindex ++;
         > verschoben an ende
          start mit vorgegebenen Werte:
          previndex = 0;
          i+1 = 1;
          nextindex = 2;
          overnextindex = 3;
          fuer das intervall 0-1
          */
         double px[] = {prevx,nowx,nextx,overnextx};
         double py[]  = {prevy,nowy,nexty,overnexty};


         
         float dx = nowx - prevx;
         float dy = nowy - prevy;
         float prevdist = sqrt(pow(dx,2) + pow(dy,2));
         int anzschritte = round(prevdist/mindist);
         //printf("i: %d anzschritte: %d\n",i,anzschritte);
         if(anzschritte)
         {
            for (int schritte = 0;schritte < anzschritte;schritte++)
            {
               float tempx = startx + (schritte)* mindist;
               if(tempx > nextx)
               {
                  lastx = tempx;
                  printf("\t **** **** **** %d tempx > nextx\n",i); 
                  continue;

               } 
               else
               {
                  float tempy = lagrangewert(px,py,0,bereich,16,tempx); // bereich zwischen stuetzstelle 0, 1
                  printf("i: \t%d \tanzschritte: %d schritte: %d  tempx,y:\t %lf  \t%lf \t schrittcounter: \t%d\n",i,anzschritte,schritte, tempx, tempy, schrittcounter);
                  //[ProfilpunktArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:tempx],@"x",[NSNumber numberWithFloat:tempy],@"y", nil]];
                  [ProfilpunktArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:tempx],@"x",[NSNumber numberWithFloat:tempy],@"y",[NSNumber numberWithInt:i],@"index",[NSNumber numberWithInt:schrittcounter],@"schrittcounter", nil]];

                  lastx = tempx;
               }
               schrittcounter++;
            }
         }
         printf("\n");
         
      }// if(i==1)
      else // rest des profils bis 2 Elemente vor Ende: wertx zwischen nowx und nextx
      {
         //printf("\n"); 
        // printf("i: %d i: %d i+1: %d i+2: %d lastx: %lf\n",i,i,i+1,i+2,lastx);
         
         nowx = [[[ProfilArray objectAtIndex:i+1]objectForKey:@"x"]floatValue];
         
         //NSLog(@"tempX: %2.2f ",tempX);
         nowy = [[[ProfilArray objectAtIndex:i+1]objectForKey:@"y"]floatValue];
         
         double px[] = {prevx,nowx,nextx,overnextx};
         double py[]  = {prevy,nowy,nexty,overnexty};

         float dx = nextx - nowx; // ev lastx
         float dy = nexty - nowy;
         float nextdist = sqrt(pow(dx,2) + pow(dy,2));
         nextdist = dx;
         
         //nowx: \t%lf\t prefx: \t%lf \t nextdist: \t%lf \n",nowx,prevx,nextdist);
         int anzschritte = (nextdist/mindist);
         //printf("i: %d anzschritte: %d\n",i,anzschritte);
         
         float aktx = lastx + mindist;
         printf("i: %d i: %d i+1: %d i+2: %d lastx: %lf anzschritte: %d\n",i,i,i+1,i+2,lastx, anzschritte);

         // erste pos sichern
        //float tempx = aktx ;
        // float tempy = lagrangewert(px,py,i+1,bereich,16,tempx);
         //printf("\t\t schritte: %d i+1: %d px now: %lf px next: %lf\t\t tempx,y: \t%lf  \t%lf\t lastx: %lf \tschrittcounter: %d\t", schritte,i+1,px[i+1],px[i+2],tempx,tempy,lastx,schrittcounter);
 
         
         //printf("\t\t \ti+1: %d nowx: %lf nowy: %lf nextx: %lf nexty: %lf\t\t tempx,y: \t%lf  \t%lf\t lastx: %lf \tschrittcounter: %d\t",i+1,nowx,nowy,nextx,nexty,tempx,tempy,lastx,schrittcounter);

//         printf("\n");
         //printf("anzschritte: %d schritte: %d  tempx,y:\t %lf \t %lf \t prevabstandx: \t%lf\t nextabstandx: \t%lf\t schrittcounter: \t%d\n",anzschritte,schritte, tempx, tempy, prevabstandx,nextabstandx,schrittcounter);
         //[ProfilpunktArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:tempx],@"x",[NSNumber numberWithFloat:tempy],@"y",[NSNumber numberWithInt:i],@"index",[NSNumber numberWithInt:schrittcounter],@"schrittcounter", nil]];
         lastx =aktx;
         //tempx += mindist;
         schrittcounter++;
         
         if(anzschritte)
         {
            
            
            for (int schritte = 0;schritte < anzschritte; schritte++)
            {
               //float tempx = startx + (schrittcounter)* mindist;
               
               float tempx = aktx + schritte * mindist;
               
               tempxabstand = tempx - nowx;
               
  
               
               if(tempx > endx)
               {
                  printf("end  erreicht bei : %d",i);
                  continue;
               }
               //printf("\t\tschritte: %d i+1: %d nowx: %lf nowy: %lf nextx: %lf nexty: %lf\t\t tempx,y: \t%lf  \t%lf\t lastx: %lf \tschrittcounter: %d\t", schritte,i+1,nowx,nowy,nextx,nexty,tempx,tempy,lastx,schrittcounter);
               
               //float prevabstandx = tempx - px[i+1] ;
               
               if(tempx > nextx)
               {
                  lastx = tempx;
                  printf("\t **** *** %d tempx > nextx\n",i); 
                  continue;
               }
              else
               {                  
                  //float nextabstandx = px[i+2] - tempx;
                  
                  
                  float tempy = lagrangewert(px,py,1,bereich,16,tempx);
                  //printf("\t\t schritte: %d i+1: %d px now: %lf px next: %lf\t\t tempx,y: \t%lf  \t%lf\t lastx: %lf \tschrittcounter: %d\t", schritte,i+1,px[i+1],px[i+2],tempx,tempy,lastx,schrittcounter);
                 
                 // printf("\t\t schritte: %d i+1: %d nowx: %lf nowy: %lf nextx: %lf nexty: %lf\t\t tempx,y: \t%lf  \t%lf\t lastx: %lf \tschrittcounter: %d\t tempxabstand: %lf\t", schritte,i+1,nowx,nowy,nextx,nexty,tempx,tempy,lastx,schrittcounter,tempxabstand);

                  //printf("\n");
                  //printf("anzschritte: %d schritte: %d  tempx,y:\t %lf \t %lf \t prevabstandx: \t%lf\t nextabstandx: \t%lf\t schrittcounter: \t%d\n",anzschritte,schritte, tempx, tempy, prevabstandx,nextabstandx,schrittcounter);
                  [ProfilpunktArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:tempx],@"x",[NSNumber numberWithFloat:tempy],@"y",[NSNumber numberWithInt:i],@"index",[NSNumber numberWithInt:schrittcounter],@"schrittcounter", nil]];
                  lastx =tempx;
               }
               
               
               schrittcounter++;
            }
            
         }
         else
         {
            printf("keine schritte bei i: %d",i);
         }
         
          
       }
      if(i==ProfilArray.count-1)
      {
         continue;
      }

      
   }// for i
   
   for (int i=0;i<ProfilpunktArray.count;i++)
   {
      //printf("%d\t%lf\t%lf \t index: %d schrittcounter: %d\n",i,[[[ProfilpunktArray objectAtIndex:i]valueForKey:@"x"]floatValue] , [[[ProfilpunktArray objectAtIndex:i]valueForKey:@"y"]floatValue],[[[ProfilpunktArray objectAtIndex:i]valueForKey:@"index"]intValue],[[[ProfilpunktArray objectAtIndex:i]valueForKey:@"schrittcounter"]intValue]);
   }
   
   return ProfilpunktDic;
}

- (NSDictionary*)ProfilDicVonPunkt:(NSPoint)Startpunkt mitProfil:(NSArray*)ProfilArray mitProfiltiefe:(int)Profiltiefe mitScale:(int)Scale
{
   //NSLog(@"AVR ProfilDicVonPunkt");
   
    int i;
    float maxX=0;   // Startwert fuer Suche nach vordestem Punkt des Profils. Muss nicht 0.0 sein.
   int minIndex=0;   // Index des vordersten Punktes im Array
   
   NSMutableArray* ProfilpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* MittellinieArray=[[NSMutableArray alloc]initWithCapacity:0];

   float gfkX = 0;   // aktueller wert
   float lastgfkX = 0; // Wert aus vorheriger loop
   float gfkY = 0;
   float lastgfkY = 0;
   
   float gfkweg = 0;
   
   float lastX=0;
   float lastY=0;
   int neg = 0; // Oberseite, x-Werte zunehmend
   if (ProfilArray.count > 3 && ([[[ProfilArray objectAtIndex:3]objectForKey:@"x"]intValue] < [[[ProfilArray objectAtIndex:0]objectForKey:@"x"]intValue]))
   {
      neg = Profiltiefe;
   }
   NSMutableDictionary* ProfilpunktDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   
   for (i=0;i<[ProfilArray count];i++)
   {
      // Profildatenpaare aus Datei mit dem Offset des Profilnullpunktes versehen
      
      //NSLog(@"ProfilArray index: %d Data: %@",i,[[ProfilArray objectAtIndex:i]description]);
      // X-Achse, 
      float tempX = [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
      
       //NSLog(@"tempX: %2.2f ",tempX);
      float tempY = [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
     
      
       
      // Mittellinie
      if ((i<5)|| (i> [ProfilArray count]-5))
      {
         float mittelwinkel = atanf(tempY/tempX);
         
         NSDictionary* tempMittellinienDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:mittelwinkel],@"m",[NSNumber numberWithInt:i],@"index", nil];
         [MittellinieArray addObject:tempMittellinienDic];
      
      }
      
      
      //[ProfilpunktDic setObject:[NSNumber numberWithInt:minIndex] forKey:@"nase"];
      //NSLog(@"maxX: %2.2f ",maxX);
      tempX *= Profiltiefe;                  // Wert in mm 
      gfkX = tempX;
      
      // NSLog(@"tempX: %2.2f ",tempX);
      tempX += Startpunkt.x ;   // offset in mm
      
      
      NSNumber* tempNumberX=[NSNumber numberWithFloat:tempX];
      //NSLog(@"tempX: %2.2f tempNumberX: %@",tempX, tempNumberX);
      //Y-Achse
      
      tempY *= Profiltiefe;    // Wert in mm 
      gfkY = tempY;
      
      tempY += Startpunkt.y;   // Offset in mm
      
      // Weg berechnen
      if (i==0)
      {
         lastX = tempX;
         lastY = tempY;
      }
      else
      {
         //float tempweg = hypotf((tempY - lastY),(tempX - lastX));
         //gfk += tempweg;
      }
      
      float tempweg = hypotf((gfkY - lastgfkY),(gfkX - lastgfkX));
      gfkweg += tempweg;
      //fprintf(stderr, "%d \t %2.2f \t %2.2f \t %2.2f \t %2.2f \t  %2.2f \t  %2.2f \n",i,gfkX,lastgfkX,gfkY ,lastgfkY,tempweg,gfkweg);
      
      lastgfkX = gfkX;
      lastgfkY = gfkY;
      NSNumber* tempNumberY=[NSNumber numberWithFloat:tempY];
      
      //ProfilpunktArray fuellen
      
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX, @"x",tempNumberY,@"y" ,[NSNumber numberWithInt:i],@"index", nil];
      
      [ProfilpunktArray addObject: tempDic];
       
   } // for i
   NSLog(@" Profil end");
   //NSLog(@"minIndex: %d minX: %2.2f ",minIndex, minX);
   // Profillinie schliessen:
   
    //[ProfilpunktArray addObject: [ProfilpunktArray objectAtIndex:0]];
   
   [ProfilpunktDic setObject:ProfilpunktArray forKey:@"profilpunktarray"];
   [ProfilpunktDic setObject:MittellinieArray forKey:@"mittelliniearray"];
 //  [ProfilpunktDic setObject:ProfilOpunktArray forKey:@"profilopunktarray"];
   //NSLog(@"ProfilUpunktArray x: %@",[[ProfilUpunktArray valueForKey:@"x"]description]);
   //NSLog(@"ProfilOpunktArray x: %@",[[ProfilOpunktArray valueForKey:@"x"]description]);
   //NSLog(@"MittellinieArray x: %@",[MittellinieArray description]);

   //NSLog(@"ProfilpunktArray x: %@",[[ProfilpunktArray valueForKey:@"x"]description]);
   gfkweg -= neg;
   NSLog(@"ProfilArrayVonPunkt gfkweg: %2.2f", gfkweg);
   return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:gfkweg],@"gfkweg",ProfilpunktArray,@"profilpunktarray", nil] ;
}



- (NSArray*)ProfilArrayVonPunkt:(NSPoint)Startpunkt mitProfil:(NSArray*)ProfilArray mitProfiltiefe:(int)Profiltiefe mitScale:(int)Scale
{
   //NSLog(@"AVR ProfilDicVonPunkt");
   
    int i;
    float maxX=0;   // Startwert fuer Suche nach vordestem Punkt des Profils. Muss nicht 0.0 sein.
   int minIndex=0;   // Index des vordersten Punktes im Array
   
   NSMutableArray* ProfilpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* MittellinieArray=[[NSMutableArray alloc]initWithCapacity:0];

   float gfkX = 0;   // aktueller wert
   float lastgfkX = 0; // Wert aus vorheriger loop
   float gfkY = 0;
   float lastgfkY = 0;
   
   float gfkweg = 0;
   
   float lastX=0;
   float lastY=0;
   int neg = 0; // Oberseite, x-Werte zunehmend
   if (ProfilArray.count > 3 && ([[[ProfilArray objectAtIndex:3]objectForKey:@"x"]intValue] < [[[ProfilArray objectAtIndex:0]objectForKey:@"x"]intValue]))
   {
      neg = Profiltiefe;
   }
   NSMutableDictionary* ProfilpunktDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   
   for (i=0;i<[ProfilArray count];i++)
   {
      // Profildatenpaare aus Datei mit dem Offset des Profilnullpunktes versehen
      
      //NSLog(@"ProfilArray index: %d Data: %@",i,[[ProfilArray objectAtIndex:i]description]);
      // X-Achse, 
      float tempX = [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
      
       //NSLog(@"tempX: %2.2f ",tempX);
      float tempY = [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
     
      
       
      // Mittellinie
      if ((i<5)|| (i> [ProfilArray count]-5))
      {
         float mittelwinkel = atanf(tempY/tempX);
         
         NSDictionary* tempMittellinienDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:mittelwinkel],@"m",[NSNumber numberWithInt:i],@"index", nil];
         [MittellinieArray addObject:tempMittellinienDic];
      
      }
      
      
      //[ProfilpunktDic setObject:[NSNumber numberWithInt:minIndex] forKey:@"nase"];
      //NSLog(@"maxX: %2.2f ",maxX);
      tempX *= Profiltiefe;                  // Wert in mm 
      gfkX = tempX;
      
      // NSLog(@"tempX: %2.2f ",tempX);
      tempX += Startpunkt.x ;   // offset in mm
      
      
      NSNumber* tempNumberX=[NSNumber numberWithFloat:tempX];
      //NSLog(@"tempX: %2.2f tempNumberX: %@",tempX, tempNumberX);
      //Y-Achse
      
      tempY *= Profiltiefe;    // Wert in mm 
      gfkY = tempY;
      
      tempY += Startpunkt.y;   // Offset in mm
      
      // Weg berechnen
      if (i==0)
      {
         lastX = tempX;
         lastY = tempY;
      }
      else
      {
         //float tempweg = hypotf((tempY - lastY),(tempX - lastX));
         //gfk += tempweg;
      }
      
      float tempweg = hypotf((gfkY - lastgfkY),(gfkX - lastgfkX));
      gfkweg += tempweg;
      //fprintf(stderr, "%d \t %2.2f \t %2.2f \t %2.2f \t %2.2f \t  %2.2f \t  %2.2f \n",i,gfkX,lastgfkX,gfkY ,lastgfkY,tempweg,gfkweg);
      
      lastgfkX = gfkX;
      lastgfkY = gfkY;
      NSNumber* tempNumberY=[NSNumber numberWithFloat:tempY];
      
      //ProfilpunktArray fuellen
      
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX, @"x",tempNumberY,@"y" ,[NSNumber numberWithInt:i],@"index", nil];
      
      [ProfilpunktArray addObject: tempDic];
       
   } // for i
   NSLog(@" Profil end");
   //NSLog(@"minIndex: %d minX: %2.2f ",minIndex, minX);
   // Profillinie schliessen:
   
    //[ProfilpunktArray addObject: [ProfilpunktArray objectAtIndex:0]];
   
   [ProfilpunktDic setObject:ProfilpunktArray forKey:@"profilpunktarray"];
   [ProfilpunktDic setObject:MittellinieArray forKey:@"mittelliniearray"];
 //  [ProfilpunktDic setObject:ProfilOpunktArray forKey:@"profilopunktarray"];
   //NSLog(@"ProfilUpunktArray x: %@",[[ProfilUpunktArray valueForKey:@"x"]description]);
   //NSLog(@"ProfilOpunktArray x: %@",[[ProfilOpunktArray valueForKey:@"x"]description]);
   //NSLog(@"MittellinieArray x: %@",[MittellinieArray description]);

   //NSLog(@"ProfilpunktArray x: %@",[[ProfilpunktArray valueForKey:@"x"]description]);
   NSLog(@"ProfilArrayVonPunkt gfkweg: %2.2f", gfkweg - neg);
   return ProfilpunktArray;
}



- (NSDictionary*)ProfilDicVonPunkt_old:(NSPoint)Startpunkt mitProfil:(NSArray*)ProfilArray mitProfiltiefe:(int)Profiltiefe mitScale:(int)Scale
{
   //NSLog(@"AVR ProfilDicVonPunkt");
	int i;
   float maxX=0;	// Startwert fuer Suche nach vordestem Punkt des Profils. Muss nicht 0.0 sein.
	int minIndex=0;	// Index des vordersten Punktes im Array
	
   NSMutableArray* ProfilpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* ProfilOpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* ProfilUpunktArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSMutableArray* MittellinieArray=[[NSMutableArray alloc]initWithCapacity:0];

   float oberseiteweg=0;
   float unterseiteweg=0;
   
   float lastX=0;
   float lastY=0;
   NSMutableDictionary* ProfilpunktDic=[[NSMutableDictionary alloc]initWithCapacity:0];

   for (i=0;i<[ProfilArray count];i++)
	{
		
		// Profildatenpaare aus Datei mit dem Offset des Profilnullpunktes versehen
		
      //NSLog(@"ProfilArray index: %d Data: %@",i,[[ProfilArray objectAtIndex:i]description]);
		// X-Achse, 
		float tempX = [[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
      //NSLog(@"tempX: %2.2f ",tempX);
      float tempY = [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
     
      
       
      // Mittellinie
      if ((i<5)|| (i> [ProfilArray count]-5))
      {
         float mittelwinkel = atanf(tempY/tempX);
         
         NSDictionary* tempMittellinienDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:mittelwinkel],@"m",[NSNumber numberWithInt:i],@"index", nil];
         [MittellinieArray addObject:tempMittellinienDic];
      
      }
      
      // Maximum von x bestimmen: Nase
      int seitenindex=0;// Oberseite
      
		if (tempX > maxX) // Maximum noch nicht erreicht, Oberseite
      {
         maxX = tempX;
         minIndex=i;
      }
      else
      {
         seitenindex=1; // Unterseite
         // TODO: Ersten Punkt einfuegen
         
      }
      
      [ProfilpunktDic setObject:[NSNumber numberWithInt:minIndex] forKey:@"nase"];
      //NSLog(@"maxX: %2.2f ",maxX);
      tempX *= Profiltiefe;						// Wert in mm 
      // NSLog(@"tempX: %2.2f ",tempX);
		tempX += Startpunkt.x;	// offset in mm
      
		
		NSNumber* tempNumberX=[NSNumber numberWithFloat:tempX];
		//NSLog(@"tempX: %2.2f tempNumberX: %@",tempX, tempNumberX);
		//Y-Achse
		
		tempY *= Profiltiefe;						// Wert in mm 
		tempY += Startpunkt.y;	// Offset in mm
		
      // Weg berechnen
      if (i==0)
      {
         lastX = tempX;
         lastY = tempY;
      }
      else
      {
         float tempweg = hypotf((tempY - lastY),(tempX - lastX));
         
      }
		
      NSNumber* tempNumberY=[NSNumber numberWithFloat:tempY];
		
      //ProfilpunktArray fuellen
      
      NSDictionary* tempDic=[NSDictionary dictionaryWithObjectsAndKeys:tempNumberX, @"x",tempNumberY,@"y" ,[NSNumber numberWithInt:i],@"index",[NSNumber numberWithInt:seitenindex],@"seitenindex", nil];
      
      [ProfilpunktArray addObject: tempDic];
      if (seitenindex) // Unterseite
      {
         [ProfilUpunktArray addObject: tempDic];
         
      }
      else
      {
         [ProfilOpunktArray addObject: tempDic];
      }
      
   } // for i
   [ProfilUpunktArray insertObject: [ProfilOpunktArray lastObject] atIndex:0];
   
   //NSLog(@"minIndex: %d minX: %2.2f ",minIndex, minX);
   // Profillinie schliessen:
   
   // [ProfilpunktArray addObject: [ProfilpunktArray objectAtIndex:0]];
   
   [ProfilpunktDic setObject:ProfilpunktArray forKey:@"profilpunktarray"];
   [ProfilpunktDic setObject:ProfilUpunktArray forKey:@"profilupunktarray"];
   [ProfilpunktDic setObject:ProfilOpunktArray forKey:@"profilopunktarray"];
   //NSLog(@"ProfilUpunktArray x: %@",[[ProfilUpunktArray valueForKey:@"x"]description]);
   //NSLog(@"ProfilOpunktArray x: %@",[[ProfilOpunktArray valueForKey:@"x"]description]);
   //NSLog(@"MittellinieArray x: %@",[MittellinieArray description]);

   //NSLog(@"ProfilpunktArray x: %@",[[ProfilpunktArray valueForKey:@"x"]description]);
   return ProfilpunktDic;
}

- (float)EndleistenwinkelvonOberseite:(NSArray*)profil
{
   fprintf(stderr,"EndleistenwinkelvonOberseite begin\n");
   for (int i=0;i<10;i++)
   {
      float ax = [[[profil objectAtIndex:i]objectForKey:@"x"]floatValue];
      float ay = [[[profil objectAtIndex:i]objectForKey:@"y"]floatValue];
       
   //fprintf(stderr,"%d \t%2.4f \t  %2.4f \n",i,ax,ay);

   }
   float steigung=0;
   float deltay = 0;
   float deltax = 0;
 
   float arc=0;
   int anfangsindex=2;
   int endindex=6;
   
   float xA = [[[profil objectAtIndex:anfangsindex]objectForKey:@"x"]floatValue];
   float xB = [[[profil objectAtIndex:endindex]objectForKey:@"x"]floatValue];
   
   float yA = [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
   float yB = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue];
   
   deltax = xB - xA;
   
   if (deltax == 0)
   {
      NSLog(@"EndleistenwinkelvonProfil Oberseite deltax ist 0");
   }
   else
   {
      //deltay = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
      deltay = yB - yA;
      arc = deltay/deltax;
      steigung = atanf(deltay/deltax);
      //NSLog(@"O   %2.6f  \t %2.6f\t %2.6f \t %2.6f * \tdeltax:\t%2.6f \t deltay: %2.6f\t steigung: \t%2.6f \t arc: %2.6f",xA,yA,xB,yB,deltax,deltay,steigung, arc);

     //steigung *= -1; // Oberseitearray ist invertiert
     return steigung;
      
   }


   return 0;

}
- (float)EndleistenwinkelvonUnterseite:(NSArray*)profil
{
   fprintf(stderr,"\nEndleistenwinkelvonUnterseite begin\n");
  
   for (int i=0;i<10;i++)
   {
      int ii = (profil.count-1) - i;
      float ax = [[[profil objectAtIndex:ii]objectForKey:@"x"]floatValue];
      float ay = [[[profil objectAtIndex:ii]objectForKey:@"y"]floatValue];
       
   //fprintf(stderr,"%d \t %d \t %2.4f \t  %2.4f \n",ii,i,ax,ay);

   }
   float steigung=0;
   float deltay = 0;
   float deltax = 0;
 
   float arc=0;
   int anfangsindex=2;
   int endindex=4;
   
   float xA = [[[profil objectAtIndex:(profil.count-1)-anfangsindex]objectForKey:@"x"]floatValue];
   float xB = [[[profil objectAtIndex:(profil.count-1)-endindex]objectForKey:@"x"]floatValue];
   
   float yA = [[[profil objectAtIndex:(profil.count-1)-anfangsindex]objectForKey:@"y"]floatValue];
   float yB = [[[profil objectAtIndex:(profil.count-1)-endindex]objectForKey:@"y"]floatValue];
   
   deltax = xB - xA;
   
   if (deltax == 0)
   {
      NSLog(@"EndleistenwinkelvonProfil Oberseite deltax ist 0");
   }
   else
   {
      //deltay = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
      deltay = yB - yA;
      arc = deltay/deltax;
      steigung = atanf(deltay/deltax);
      //NSLog(@"O   %2.6f  \t %2.6f\t %2.6f \t %2.6f\tdeltax:\t%2.6f \t deltay:\t %2.6f\t steigung: \t%2.6f \t arc: %2.6f", xA,yA,xB,yB,deltax,deltay,steigung, arc);

     steigung *= -1; 
     return steigung;
      
   }


   return 0;

}

- (float) EndleistenwinkelvonProfil:(NSArray*)profil
{
   fprintf(stderr,"EndleistenwinkelvonProfil begin\n");
   for (int i=0;i<10;i++)
   {
      float ax = [[[profil objectAtIndex:i]objectForKey:@"x"]floatValue];
      float ay = [[[profil objectAtIndex:i]objectForKey:@"y"]floatValue];
       
   //fprintf(stderr,"%d \t%2.4f \t  %2.4f \n",i,ax,ay);

   }
   //fprintf(stderr,"EndleistenwinkelvonProfil End\n");

     
   float steigungo=0, steigungu=0;
   float arco=0, arcu=0;
 // Oberseite
   int anzWerteO=0;
   int anzWerteU=0;
   
   // Bereich der Berechnung festlegen

   int anfangsindex=2;
   int endindex=4;
   
   int h = 1; // halber Abstand fuer zentralen Differenzenquotienten
   int m = 3; // zentrum, > h
   /*
    Df (x0 , h) =( f (x0 + h/2 ) − f (x0 − h/2 ))/h
    
    */
   
   float a1 = [[[profil objectAtIndex:(m-h)]objectForKey:@"x"]floatValue];
   float a2 = [[[profil objectAtIndex:(m-h)]objectForKey:@"y"]floatValue];

   
   float e1 = [[[profil objectAtIndex:(m+h)]objectForKey:@"x"]floatValue];
   float e2 = [[[profil objectAtIndex:(m+h)]objectForKey:@"y"]floatValue];

   
   float d0 = (e2 - a2)/h;
   
   float sO = (e2 - a2)/(e1 - a1); // steigung
   
      
   //NSLog(@"O DiffQuot h: %d  \t m:  %d  \t a1: \t %2.6f  e1: \t  %2.6f \t a2: \t %2.6f e2: \t %2.6f \t s0:  \t%2.6f \n  ",h,m,a1,e1,a2,e2, sO);


   
   
   
   
   
   float steigung = 0;
   float deltay = 0;
   float deltax = 0;
   int oberseiteindex = anfangsindex+1;
   int unterseiteindex = anfangsindex+1;
   //for (i=anfangsindex;i<endindex;i++)
   NSLog(@"EndleistenwinkelvonProfil Oberseite:");
   
   //while (oberseiteindex < endindex)
   {
      float xA = [[[profil objectAtIndex:anfangsindex]objectForKey:@"x"]floatValue];
      float xB = [[[profil objectAtIndex:endindex]objectForKey:@"x"]floatValue];
      
      float yA = [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
      float yB = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue];

      
      //deltax = [[[profil objectAtIndex:endindex]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:anfangsindex]objectForKey:@"x"]floatValue];
      deltax = xB - xA;
      
      if (deltax == 0)
      {
         NSLog(@"EndleistenwinkelvonProfil Oberseite deltax ist 0");
      }
      else
      {
         //deltay = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
         deltay = yB - yA;
         arco = deltay/deltax;
         steigung = atanf(deltay/deltax);
         NSLog(@"O   %2.6f  \t %2.6f \t %2.6f  \t %2.6f \t \tdeltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung o:  \t %2.6f  \t arc: %2.6f",xA,yA,xB,yB,deltax,deltay,steigung, arco);

         //      steigung *= -1;
         steigungo=steigung;
         anzWerteO++;
      }
 
 //     NSLog(@"O oberseiteindex: %d \t  %2.6f  \t %2.6f \t deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t grad: %2.6f",oberseiteindex,xA,xB,deltax,deltay,steigung, steigung/M_PI*180);
      oberseiteindex++;
   }// while
   //NSLog(@"EndleistenwinkelvonProfil Oberseite end");

   
   
   // Unterseite
   
   m = [profil count]-1 - m;
   
   
   e1 = [[[profil objectAtIndex:(m+h)]objectForKey:@"x"]floatValue];
   e2 = [[[profil objectAtIndex:(m+h)]objectForKey:@"y"]floatValue];

   
   a1 = [[[profil objectAtIndex:(m-h)]objectForKey:@"x"]floatValue];
   a2 = [[[profil objectAtIndex:(m-h)]objectForKey:@"y"]floatValue];

   d0 = (e2 - a2)/h;
   float sU = (e2 - a2)/(e1 - a1); // steigung
   
      
   //NSLog(@"U DiffQuot  h: %d  \t m:  %d  \t a1: \t %2.6f  e1: \t  %2.6f \t a2: \t %2.6f e2: \t %2.6f \t s0:  \t%2.6f \n  ",h,m,a1,e1,a2,e2, sU);

   //for (i=anfangsindex;i<endindex;i++)
   NSLog(@"EndleistenwinkelvonProfil Unterseite:");
   //while (unterseiteindex < endindex)

   {
      float xA = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"x"]floatValue];
      float xB = [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"x"]floatValue];

      float yA = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"y"]floatValue];
      float yB = [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"y"]floatValue];

     // int endi=[profil count]-1-unterseiteindex;
      // float deltax = [[[profil objectAtIndex:[profil count]-1-i-1]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:[profil count]-1-i]objectForKey:@"x"]floatValue];
      
      deltax = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"x"]floatValue];
      if (deltax == 0)
      {
         NSLog(@"EndleistenwinkelvonProfil Unterseite deltax ist 0");
      }
      else
      {
         
         deltay = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"y"]floatValue];
         arcu = deltay/deltax;
         steigung = atanf(deltay/deltax);
         NSLog(@"U  %2.6f  \t %2.6f \t  \t %2.6f  \t %2.6f \t \t  deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t arc: %2.6f",xA,yA,xB,yB,deltax,deltay,steigung, arcu);

         //      steigung *= -1;
         steigungu= steigung;
         //NSLog(@"U unterseiteindex: %d  \t deltax:  \t %2.6f  \t deltay:  \t %2.6f   \t steigung u:  \t %2.6f  \t grad: %2.6f",unterseiteindex,deltax,deltay,steigung, steigung/M_PI*180);
      }
      
   }// while
   //NSLog(@"EndleistenwinkelvonProfil Unterseite end");
   /*
   if (anzWerteU == 0)
   {
      NSLog(@"EndleistenwinkelvonProfil anzwerte = 0");
      return 0;
   }
    */
   //steigungo /=anzWerteO;
   //steigungu /=anzWerteU;
   NSLog(@"Steigung raw steigungo: %2.4f steigungu: %2.4f arcO:  %2.4f  arcU:  %2.4f sO:  %2.4f  sU:  %2.4f ",steigungo,steigungu, arco, arcu,sO,sU);
   //NSLog(@"steigungo: %1.2f steigungu: %2.2f",steigungo*180/M_PI,steigungu*180/M_PI);
   float mittelwert = (steigungo+steigungu)/2; // Winkelhalbierende
   NSLog(@"steigung M: %1.2f arc M: %2.2f s M: %2.4f",(steigungo+steigungu)/2,(arcu + arco)/2, (sO+sU)/2);
   
   return (atanf(sO + sU)/2);
   
   //return atanf((arcu + arco)/2);
   //return mittelwert;
}
- (float) EndleistenwinkelvonProfil_old2:(NSArray*)profil
{
   fprintf(stderr,"EndleistenwinkelvonProfil begin\n");
   for (int i=0;i<10;i++)
   {
      float ax = [[[profil objectAtIndex:i]objectForKey:@"x"]floatValue];
      float ay = [[[profil objectAtIndex:i]objectForKey:@"y"]floatValue];
       
   fprintf(stderr,"%d \t%2.4f \t  %2.4f \n",i,ax,ay);

   }
   fprintf(stderr,"EndleistenwinkelvonProfil End\n");

     
   float steigungo=0, steigungu=0;
   float arco=0, arcu=0;
 // Oberseite
   int anzWerteO=0;
   int anzWerteU=0;
   int anfangsindex=3;
   // Bereich der Berechnung festlegen
   int endindex=5;
   
   int h = 1; // halber Abstand fuer zentralen Differenzenquotienten
   int m = 2; // zentrum, > h
   /*
    Df (x0 , h) =( f (x0 + h/2 ) − f (x0 − h/2 ))/h
    
    */
   
   float a1 = [[[profil objectAtIndex:(m-h)]objectForKey:@"x"]floatValue];
   float a2 = [[[profil objectAtIndex:(m-h)]objectForKey:@"y"]floatValue];

   
   float e1 = [[[profil objectAtIndex:(m+h)]objectForKey:@"x"]floatValue];
   float e2 = [[[profil objectAtIndex:(m+h)]objectForKey:@"y"]floatValue];

   float d0 = (e2 - a2)/h;
   float sO = (e2 - a2)/(e1 - a1); // steigung
   
      
   NSLog(@"O DiffQuot h: %d  \t a1: \t %2.6f  e1: \t  %2.6f \t a2: \t %2.6f e2: \t %2.6f \t d0:  \t%2.6f \ts0:  \t%2.6f \n  ",h,a1,e1,a2,e2,d0, sO);


   
   
   
   
   
   float steigung = 0;
   float deltay = 0;
   float deltax = 0;
   int oberseiteindex = anfangsindex+1;
   int unterseiteindex = anfangsindex+1;
   //for (i=anfangsindex;i<endindex;i++)
   NSLog(@"EndleistenwinkelvonProfil Oberseite:");
   
   //while (oberseiteindex < endindex)
   {
      float xA = [[[profil objectAtIndex:anfangsindex]objectForKey:@"x"]floatValue];
      float xB = [[[profil objectAtIndex:endindex]objectForKey:@"x"]floatValue];
      float yA = [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
      float yB = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue];

      deltax = xB - xA;
      deltax = [[[profil objectAtIndex:endindex]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:anfangsindex]objectForKey:@"x"]floatValue];
 
      if (deltax == 0)
      {
         NSLog(@"EndleistenwinkelvonProfil Oberseite deltax ist 0");
      }
      else
      {
         deltay = [[[profil objectAtIndex:endindex]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:anfangsindex]objectForKey:@"y"]floatValue];
         arco = deltay/deltax;
         steigung = atanf(deltay/deltax);
         NSLog(@"O index: %d \t  %2.6f  \t %2.6f \t %2.6f  \t %2.6f \t \tdeltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung o:  \t %2.6f  \t arc: %2.6f",oberseiteindex,xA,yA,xB,yB,deltax,deltay,steigung, arco);

         //      steigung *= -1;
         steigungo=steigung;
         anzWerteO++;
      }
 
 //     NSLog(@"O oberseiteindex: %d \t  %2.6f  \t %2.6f \t deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t grad: %2.6f",oberseiteindex,xA,xB,deltax,deltay,steigung, steigung/M_PI*180);
      oberseiteindex++;
   }// while
   //NSLog(@"EndleistenwinkelvonProfil Oberseite end");

   
   
   // Unterseite
   
   m = [profil count]-1 - 2;
   
   a1 = [[[profil objectAtIndex:(m+h)]objectForKey:@"x"]floatValue];
   a2 = [[[profil objectAtIndex:(m+h)]objectForKey:@"y"]floatValue];

   
   e1 = [[[profil objectAtIndex:(m-h)]objectForKey:@"x"]floatValue];
   e2 = [[[profil objectAtIndex:(m-h)]objectForKey:@"y"]floatValue];

   d0 = (e2 - a2)/h;
   float sU = (e2 - a2)/(e1 - a1); // steigung
   
      
   NSLog(@"U DiffQuot  h: %d  \t a1: \t %2.6f  e1: \t  %2.6f \t a2: \t %2.6f e2: \t %2.6f \t d0:  \t%2.6f \ts0:  \t%2.6f \n  ",h,a1,e1,a2,e2,d0, sU);

   //for (i=anfangsindex;i<endindex;i++)
   NSLog(@"EndleistenwinkelvonProfil Unterseite:");
   //while (unterseiteindex < endindex)

   {
      float xA = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"x"]floatValue];
      float xB = [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"x"]floatValue];

      float yA = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"y"]floatValue];
      float yB = [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"y"]floatValue];

     // int endi=[profil count]-1-unterseiteindex;
      // float deltax = [[[profil objectAtIndex:[profil count]-1-i-1]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:[profil count]-1-i]objectForKey:@"x"]floatValue];
      
      deltax = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"x"]floatValue] - [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"x"]floatValue];
      if (deltax == 0)
      {
         NSLog(@"EndleistenwinkelvonProfil Unterseite deltax ist 0");
      }
      else
      {
         
         deltay = [[[profil objectAtIndex:[profil count]-1-endindex]objectForKey:@"y"]floatValue] - [[[profil objectAtIndex:[profil count]-1-anfangsindex]objectForKey:@"y"]floatValue];
         arcu = deltay/deltax;
         steigung = atanf(deltay/deltax);
         NSLog(@"U index: %d  \t %2.6f  \t %2.6f \t  \t %2.6f  \t %2.6f \t \t  deltax:  \t %2.6f  \t deltay:  \t %2.6f  \t steigung u:  \t %2.6f  \t arc: %2.6f",unterseiteindex,xA,yA,xB,yB,deltax,deltay,steigung, arcu);

         //      steigung *= -1;
         steigungu= steigung;
         //NSLog(@"U unterseiteindex: %d  \t deltax:  \t %2.6f  \t deltay:  \t %2.6f   \t steigung u:  \t %2.6f  \t grad: %2.6f",unterseiteindex,deltax,deltay,steigung, steigung/M_PI*180);
      }
      
   }// while
   NSLog(@"EndleistenwinkelvonProfil Unterseite end");
   /*
   if (anzWerteU == 0)
   {
      NSLog(@"EndleistenwinkelvonProfil anzwerte = 0");
      return 0;
   }
    */
   //steigungo /=anzWerteO;
   //steigungu /=anzWerteU;
   NSLog(@"Steigung raw steigungo: %2.4f steigungu: %2.4f arcO:  %2.4f  arcU:  %2.4f sO:  %2.4f  sU:  %2.4f ",steigungo,steigungu, arco, arcu,sO,sU);
   //NSLog(@"steigungo: %1.2f steigungu: %2.2f",steigungo*180/M_PI,steigungu*180/M_PI);
   float mittelwert = (steigungo+steigungu)/2; // Winkelhalbierende
   NSLog(@"steigung M: %1.2f arc M: %2.2f s M: %2.4f",(steigungo+steigungu)/2,(arcu + arco)/2, (sO+sU)/2);
   
   //return ((sO + sU)/2);
   
   //return (arcu + arco)/2;
   return mittelwert;
}

- (NSArray*)EndleisteneinlaufMitWinkel:(float)winkel mitLaenge:(float)laenge mitTiefe:(float)tiefe 
{
   //float tiefe=10;// Schlitztiefe
   float dicke=0.5; // Schlitzbreite
   float full_pwm = 1;
   //red_pwm = 0.4;
   NSMutableArray* EinlaufpunkteArray=[[NSMutableArray alloc]initWithCapacity:0];

   NSPoint Startpunkt = NSMakePoint(0,0);
   NSPoint Endpunkt = NSMakePoint(0,0);
   NSArray* tempEinlaufArray0 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:full_pwm], nil];
   [EinlaufpunkteArray addObject:tempEinlaufArray0];
  
   // Einstich
   if(tiefe)
   {
       Endpunkt.x +=tiefe * sinf(winkel);
       Endpunkt.y -=tiefe * cosf(winkel);
       NSArray* tempEinlaufArray1 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:full_pwm], nil];
       [EinlaufpunkteArray addObject:tempEinlaufArray1];
       // Ausstich
       Endpunkt.x -=tiefe * sinf(winkel);
       Endpunkt.y +=tiefe * cosf(winkel);
       NSArray* tempEinlaufArray3 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:red_pwm], nil];
       [EinlaufpunkteArray addObject:tempEinlaufArray3];
       
       // Ueberschneiden oben:
       Endpunkt.y += 4;
       //Endpunkt.x +=10;
       NSArray* tempEinlaufArray4 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:red_pwm], nil];
       [EinlaufpunkteArray addObject:tempEinlaufArray4];
 
       Endpunkt.y -= 4;
       //Endpunkt.x -=10;
       NSArray* tempEinlaufArray5= [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:red_pwm], nil];
       [EinlaufpunkteArray addObject:tempEinlaufArray5];


    }
   else 
   {
      //[EinlaufpunkteArray addObject:tempEinlaufArray0];
   }
   
   // Einlauf
   if(laenge)
   {
      Endpunkt.x +=laenge * cosf(winkel);
      Endpunkt.y +=laenge * sinf(winkel);
      NSArray* tempEinlaufArray4 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:full_pwm], nil];
      [EinlaufpunkteArray addObject:tempEinlaufArray4];
  
   }
   else
   {
    //  [EinlaufpunkteArray addObject:tempEinlaufArray0];
   }
    
     
   NSLog(@"endleiste end");
    
    for (int i=0;i<EinlaufpunkteArray.count;i++)
    {
       float ax = [EinlaufpunkteArray[i][0]floatValue];
       float ay = [EinlaufpunkteArray[i][1]floatValue];
      
       
       fprintf(stderr,"%2.4f \t  %2.4f \t  \n",ax,ay);
    }

    
   return EinlaufpunkteArray;
}

- (NSArray*)NasenleistenauslaufMitLaenge:(float)laenge  mitTiefe:(float)tiefe
{
   //float tiefe=10;// Schlitztiefe
   float dicke=0.5; // Schlitzbreite
   float full_pwm = 1;
   

   NSMutableArray* AuslaufpunkteArray=[[NSMutableArray alloc]initWithCapacity:0];

   NSPoint Endpunkt = NSMakePoint(0,0);
   NSArray* tempEinlaufArray0 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y], [NSNumber numberWithFloat:full_pwm],nil];
   [AuslaufpunkteArray addObject:tempEinlaufArray0];
  
   // Ueberschneiden
   Endpunkt.y += 4;
   tempEinlaufArray0 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y], [NSNumber numberWithFloat:full_pwm],nil];
   [AuslaufpunkteArray addObject:tempEinlaufArray0];
   Endpunkt.y -= 4;
   tempEinlaufArray0 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y], [NSNumber numberWithFloat:red_pwm],nil];
   [AuslaufpunkteArray addObject:tempEinlaufArray0];
  
   
   // Auslauf
   if(laenge)
   {
      Endpunkt.x +=laenge;
      NSArray* tempEinlaufArray4 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y], [NSNumber numberWithFloat:full_pwm],nil];
      [AuslaufpunkteArray addObject:tempEinlaufArray4];
   }
   else  
   {
      [AuslaufpunkteArray addObject:tempEinlaufArray0];
   }
   
   // Einstich
   if(tiefe)
   {
      Endpunkt.y -=tiefe;
      NSArray* tempEinlaufArray1 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:full_pwm], nil];
      [AuslaufpunkteArray addObject:tempEinlaufArray1];
      
      /*
       // Boden
       Endpunkt.x +=dicke;
       NSArray* tempEinlaufArray2 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y], nil];
       [AuslaufpunkteArray addObject:tempEinlaufArray2];
       */
      // Ausstich
      Endpunkt.y +=tiefe;
      NSArray* tempEinlaufArray3 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:Endpunkt.x],[NSNumber numberWithFloat:Endpunkt.y],[NSNumber numberWithFloat:red_pwm], nil];
      [AuslaufpunkteArray addObject:tempEinlaufArray3];
   }
   
   return AuslaufpunkteArray;
}



- (NSMutableArray*)addAbbrandVonKoordinaten:(NSArray*)Koordinatentabelle mitAbbrandA:(float)abbrandmassa  mitAbbrandB:(float)abbrandmassb aufSeite:(int)seite von:(int)von bis:(int)bis
{
   /*
    seite = 0: abbrandmassa oben, Negativform
    seite = 1: abbrandmassa aussen, Positivform
    */
   //NSLog(@"addAbbrand MassA: %2.2f MassB: %2.2f von: %d bis: %d",abbrandmassa,abbrandmassb,von,bis);
   int i=0;
   NSMutableArray* AbbrandArray = [[NSMutableArray alloc]initWithCapacity:0];
   
   float lastwha[2] = {}; // WH des letzten berechneten Punktes. Wird fuer Check gebraucht, ob die Kruemmung gewechselt hat
   float lastwhb[2] = {}; // WH des letzten berechneten Punktes. Wird fuer Check gebraucht, ob die Kruemmung gewechselt hat
   
   
   float wegobena=0, weguntena=0;
   float wegobenb=0, weguntenb=0;
   
   int prevseitea=1;
   int prevseiteb=1;
   
   int prevseitenkorrektura=1;
   int prevseitenkorrekturb=1;

   float prevhypoa = 0;
   float nexthypoa= 0;
   
   //   NSLog(@"addAbbrandVonKoordinaten ax: %@",[Koordinatentabelle valueForKey:@"ax"]);
   //   NSLog(@"addAbbrandVonKoordinaten ay: %@",[Koordinatentabelle valueForKey:@"ay"]);
   //NSLog(@"addAbbrandVonKoordinaten start: %@",[Koordinatentabelle  description]);
   //NSLog(@"addAbbrandVonKoordinaten start: %@",[[Koordinatentabelle objectAtIndex:0] description]);
   
   //fprintf(stderr, "i \tprev x \tprev y \tnext x \tnexy \tprefhyp \tnexthyp \tprevnorm x \tprevnorm y \tnextnorm x  \tnextnorm y\n");
   
   /*
    Fuer jeden Punkt:
    -Winkelhalbierende zwischen vorherigem (prev) und naechstem (next) Stueck berechnen.
    -Mit Determinante Aussenseite bestimmen.
    -Winkelhalbierende mit Laenge 'abbrand' bestimmen. Wert ist fuer a und b verschieden, je nach Profiltiefe.
    -Neue Koordinaten in Dic einsetzen: abrax, abray, abrbx, abrby.
    
    */
   //fprintf(stderr,"i\t ax\tay\tpreva[0]\tpreva[1]\tnexta[0]\tnexta[1]\twha[0]\twha[1]\t prevnorma[0]\tprevnorma[1]\tnextnorma[0]\tnextnorma[1]\tcosphia\tlastwha[0]\tlastwha[1]\tprevhypoa\tnexthypoa\tcospsia\n");

   for (i=0; i<[Koordinatentabelle count];i++)
   {
      int seitenkorrektura = 1;
      int seitenkorrekturb = 1;
      NSMutableDictionary* tempDic=[NSMutableDictionary dictionaryWithDictionary:[Koordinatentabelle objectAtIndex:i]];
       float ax = [[[Koordinatentabelle objectAtIndex:i]objectForKey:@"ax"]floatValue];
       float ay = [[[Koordinatentabelle objectAtIndex:i]objectForKey:@"ay"]floatValue];
       float bx = [[[Koordinatentabelle objectAtIndex:i]objectForKey:@"bx"]floatValue];
       float by = [[[Koordinatentabelle objectAtIndex:i]objectForKey:@"by"]floatValue];

       
       
       if (i>von-1 && i<bis) // Abbrandbereich, von ist 1-basiert
      {
          
         float nextax = 0;
         float nextay = 0;
         float nextbx = 0;
         float nextby = 0;
         
         float prevax = 0;
         float prevay = 0;
         float prevbx = 0;
         float prevby = 0;
         
         float cosphia = 0; // cos des halben Winkels
         float cosphib = 0; // cos des halben Winkels
         float cosphi2a = 0; // cos des halben Winkels
         float cosphi2b = 0; // cos des halben Winkels
         float wha[2] = {}; // Vektor der Winkelhalbierenden a
         float whb[2] = {}; // Vektor der Winkelhalbierenden b
         
         if (i<bis-1) //  Noch im Abbrandbereich bis-1: naechsten Wert lesen
         {
            nextax = [[[Koordinatentabelle objectAtIndex:i+1]objectForKey:@"ax"]floatValue];
            nextay = [[[Koordinatentabelle objectAtIndex:i+1]objectForKey:@"ay"]floatValue];
            nextbx = [[[Koordinatentabelle objectAtIndex:i+1]objectForKey:@"bx"]floatValue];
            nextby = [[[Koordinatentabelle objectAtIndex:i+1]objectForKey:@"by"]floatValue];
         }
         
         
         if (i>von) // Schon im Abbrandbereich von: vorherigen Wert lesen
         {
            prevax = [[[Koordinatentabelle objectAtIndex:i-1]objectForKey:@"ax"]floatValue];
            prevay = [[[Koordinatentabelle objectAtIndex:i-1]objectForKey:@"ay"]floatValue];
            prevbx = [[[Koordinatentabelle objectAtIndex:i-1]objectForKey:@"bx"]floatValue];
            prevby = [[[Koordinatentabelle objectAtIndex:i-1]objectForKey:@"by"]floatValue];
         }
         
          
         if ((i<bis-1) && (i>von)) // Punkt im Abbrandbereich
         {
             // Kruemmungen berechnen
            if (i<bis && i>von+1)
            {
               float diffvor[2] = {ax-prevax, ay-prevay};
               float diffnach[2] = {nextax-ax, nextay-ay};
         //      fprintf(stderr,"Kruemmungen \t%d\tdiffvor %2.8f\tdiffnach %2.8f\n",i,diffvor[2],diffnach[2]);

               
               float mittevor[2] = {(ax+prevax)/2,(prevay+ay)/2};
               float mittenach[2] = {(ax+nextax)/2,(nextay+ay)/2};
          //     fprintf(stderr,"Kruemmungen \t%d\tmittevor %2.8f\tmittenach %2.8f\n",i,diffvor[2],diffnach[2]);

               //fprintf(stderr,"mittelpunkt \t%d\t%2.8f\t%2.8f\t%2.8f\t%2.8f\t%2.8f\n",i,mittevor[0],mittevor[1],mittenach[0],mittenach[1],1);

               // senkrechte:
               float steigungvor = 0;
               float steigungnach = 0;
               
               float senkrechtvor = 0;
               float senkrechtnach = 0;
               
               // vor
               if (diffvor[0]) // nicht senkrecht
               {
                  steigungvor = diffvor[1]/diffvor[0];
                 
               }
               if (diffvor[1])
               {
                  senkrechtvor = -diffvor[0]/diffvor[1];
               }

               // nach
               if (diffnach[0]) // nicht waagrecht
               {
                  steigungnach = diffnach[1]/diffnach[0];
                  
               }
               if (diffnach[1])
               {
                  senkrechtnach = -diffnach[0]/diffnach[1];
               }

               //fprintf(stderr,"kruemmung   \t%d\t%2.8f\t%2.8f\t%2.8f\t%2.8f\t%d\n",i,steigungvor,steigungnach,senkrechtvor,senkrechtnach,1);
               
               
               
               // Mittelsenkrechte vor:
               // y  = mittevor[0]+ x* senkrechtvor
               
               // Mittelsenkrechte nach:
               // y = mittenach[0]+ x* senkrechtvor
               // zweiten punkt mit dx=delta: http://de.wikipedia.org/wiki/Zweipunkteform
               float delta=10;
               float tempvor[2] = {mittevor[0]+delta,mittevor[1]+senkrechtvor*delta};
               
               // Gleichung fuer Senkrechte vor:
               // senkrechtevor*x   -1*y = (mittevor[0]*senkrechtvor - mittevor[1])
               // senkrechtenach*x  -1*y = (mittenach[0]*senkrechtenach - mittenach[1])
               
               
               float constvor= mittevor[0]*senkrechtvor - mittevor[1];
               float constnach= mittenach[0]*senkrechtnach - mittenach[1];
               
               // Gleichungssystem:
               // senkrechtevor  -1 constvor
               // senkrechtenach -1 constnach
               
               // konstante Determinante aus Koeffizienten links
               float consta[2] ={senkrechtvor,-1};
               float constb[2] ={senkrechtnach,-1};
               
               float detconst = determinante(consta,constb);
               
               // Unterdeterminaten fuer Variable x:
               
               float a[2] ={constvor,-1};
               float b[2] ={constnach,-1};
               float detvor = determinante(a,b);
               
               // Unterdet fuer Variable y
               
               float c[2] = {senkrechtvor,constvor};
               float d[2] = {senkrechtnach,constnach};
               float detnach = determinante(c,d);
               
               if (detconst)
               {
                  float mittelpunkt[2] = {detvor/detconst,detnach/detconst};
                  float radius = hypotf(mittelpunkt[0]-ax,mittelpunkt[1]-ay);
                  //
                  //
                  //
                  if (radius < abbrandmassa )
                  {
                     fprintf(stderr,"mittelpunkt \t%d\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\n",i,ax,ay,detvor,detnach,mittelpunkt[0],mittelpunkt[1],radius);
                  }
                  
               }
            }// end Kruemmung berechnen
            
            
            //NSLog(@" ");
            // ********
            // Seite 1
            // ********
            
            // Vektoren vorher, nachher
            //float preva[2] = {prevax-ax,prevay-ay};
            //float preva[2] = {prevax-ax,prevay-ay};
            
            float preva[2] = {ax-prevax,ay-prevay};
            float nexta[2] = {nextax-ax,nextay-ay};
            //NSLog(@"i: %d  preva[0]: %2.4f preva[1]: %2.4f nexta[0]: %1.4f nexta[1]: %2.4f",i,preva[0],preva[1],nexta[0],nexta[1]);
            
            /*
            float prevhypoa=hypot(preva[0],preva[1]); // Laenge des vorherigen Weges
            float nexthypoa=hypot(nexta[0],nexta[1]); // Laenge des naechsten Weges
            
            float prevnorma[2]= {(preva[0])/prevhypoa,(preva[1])/prevhypoa}; // vorheriger Normalenvektor
            float nextnorma[2]= {(nexta[0])/nexthypoa,(nexta[1])/nexthypoa}; // naechster Normalenvektor
            */
            
            
            
            /*
             
             
             // Rechteck auf Ueberschlagung testen: Determinante muss in allen Ecken gleiches VZ haben. Vektoren im Gegenuhrzeigersinn
             // Vektor 0: prev zu now
             float v0[2] = {nowax-prevax, noway-prevay};
             // Vektor 1: now zu nowabr
             float v1[2] = {nowabrax-nowax, nowabray-noway};
             // Vektor 2: nowabr zu prevabr
             float v2[2] = {prevabrax-nowabrax, prevabray-nowabray};
             // Vektor 3: prevabr zu prev
             float v3[2] = {nowax-prevabrax, noway-prevabray};
             
             int detvorzeichen=0;
             float det0 = determinante(v0,v1);
             if (det0 < 0)
             {
             detvorzeichen--;
             }
             else
             {
             detvorzeichen++;
             }
             float det1 = determinante(v1,v2);
             if (det1 < 0)
             {
             detvorzeichen--;
             }
             else
             {
             detvorzeichen++;
             }
             
             float det2 = determinante(v2,v3);
             if (det2 < 0)
             {
             detvorzeichen--;
             }
             else
             {
             detvorzeichen++;
             }
             
             float det3 = determinante(v3,v0);
             if (det3 < 0)
             {
             detvorzeichen--;
             }
             else
             {
             detvorzeichen++;
             }
             
             if (abs(detvorzeichen)<4)
             {
             fprintf(stderr,"determinanten   %d\t%2.8f\t%2.8f\t%2.8f\t%2.8f\t%d\n",i,det0,det1,det2,det3,detvorzeichen);
             }

             
             */
            
            // Laengen der Vektoren bestimmen
            
            
            if (preva[0] || preva[1])
            {
               prevhypoa=hypot(preva[0],preva[1]); // Laenge des vorherigen Weges
            }
            else
            {
               NSLog(@"%d kein prevhypoa",i);
               
            }
            
            if (nexta[0] || nexta[1])
            {
               nexthypoa = hypot(nexta[0],nexta[1]); // Laenge des naechsten Weges
            }
            else
            {
               NSLog(@"%d  kein nexthypoa",i);
            }

            
            //NSLog(@"i: %d  prevhypoa: %2.4f nexthypoa: %2.4f",i,prevhypoa,nexthypoa);
            
            float prevnorma[2] = {0.0,0.0};
            if (prevhypoa)
            {
               prevnorma[0]= -(preva[1])/prevhypoa;
               prevnorma[1] = (preva[0])/prevhypoa; // vorheriger Normalenvektor
            }
            else
            {
               NSLog(@"%d kein prevnorma",i);
            }
            
            
            
            float nextnorma[2] = {0.0,0.0};
            if (nexthypoa)
            {
               nextnorma[0]= -(nexta[1])/nexthypoa;
               nextnorma[1] = (nexta[0])/nexthypoa; // vorheriger Normalenvektor
            }
            else
            {
               NSLog(@"%d kein nextnorma",i);
            }
           

            
            
            // Winkel aus Skalarprodukt der Einheitsvektoren
            cosphia=prevnorma[0]*nextnorma[0]+ prevnorma[1]*nextnorma[1]; // cosinus des Zwischenwinkels
            
            
            // Halbwinkelsatz: cos(phi/2)=sqrt((1+cos(phi))/2)
            
            // Vorzeichen von cosphia
            if (cosphia >=0)
            {
               // kleine Winkelunterschiede eliminieren
               if (cosphia >0.999)
               {
                  //NSLog(@"cosphia korr+");
                  cosphia=1.0;
                  cosphi2a=1.0;
               }
               else
               {
                  cosphi2a=sqrtf((1+cosphia)/2);                       // cosinus des halben Zwischenwinkels
               }
            }
            
            else
            {
               // kleine Winkelunterschiede eliminieren
               if (cosphia < (-0.999))
               {
                  //NSLog(@"cosphia korr-");
                  cosphia=-1.0;
                  cosphi2a=-1.0;
               }
               else
               {
                  cosphi2a=-sqrtf((1+cosphia)/2);                       // cosinus des halben Zwischenwinkels
               }
               
            }
            
            
            
            
           
            
            //            NSLog(@"i: %d  prevhypoa: %2.4f nexthypoa: %2.4f cosphia: %1.8f",i,prevhypoa,nexthypoa,cosphia);
            
     //       cosphi2a=sqrtf((1-cosphia)/2);                       // cosinus des halben Zwischenwinkels
            //NSLog(@"i: %d cosphia: %2.4f",i,cosphia*1000);
            
            if (cosphia <0)
            {
               //NSLog(@"Wendepunkt bei: %d",i);
            }
            
            // Winkelhalbierende
          
            wha[0] = prevnorma[0]+ nextnorma[0];                // Winkelhalbierende als Vektorsumme der Normalenvektoren
            wha[1] = prevnorma[1]+ nextnorma[1];
            
            // Determinante. Vorzeichen gibt die Seite der WH an
            /*
             Determinante:
             Erste Gerade:
             preva[0] preva[1]
             zweite Gerade:
             wha[0] wha[1]
             determinante = preva[0]*wha[1]-preva[1]*wha[0]
             */
            
            float deta = preva[0]*wha[1]-preva[1]*wha[0];
            
            if (deta < 0)
            {
               seitenkorrektura *= -1;
            }
            //NSLog(@"i: %d deta: %2.4f cosphia: %2.4f seitenkorrektura: %d",i,deta,cosphia,seitenkorrektura);
            
            // Fehler: wenn winkel zwischen prevnorma und nextnorma = 180°: wha ist (0,0) > wha = (1,0)
            if (wha[0]==0 && wha[1]==0)
            {
               //NSLog(@"wha[0]==0 && wha[1]==0 wha[0]: %2.4f wha[1]: %2.4f",wha[0],wha[1]);
               //wha[0] = prevnorma[0]*seitenkorrektura;
               //wha[1] = prevnorma[1]*seitenkorrektura;
               
               wha[0] = lastwha[0]*seitenkorrektura;
               wha[1] = lastwha[1]*seitenkorrektura;
            }
            
            
            
            //           NSLog(@"i: %d  wha[0]: %2.4f wha[1]: %2.4f cosphi: %1.8f",i,wha[0],wha[1],cosphia);
            
            
            // *******
            // Seite 2
            // *******
            
            if (i==131)
            {
               int a=i;
            }
            float prevb[2]= {bx-prevbx,by-prevby};
            float nextb[2]= {nextbx-bx,nextby-by};
            
            /*
            float prevhypob=hypotf(prevb[0],prevb[1]);
            float nexthypob=hypotf(nextb[0],nextb[1]);
            
            float prevnormb[2]= {prevb[0]/prevhypob,prevb[1]/prevhypob};
            float nextnormb[2]= {nextb[0]/nexthypob,nextb[1]/nexthypob};
            */
            
            float prevhypob = 0;
            
            if (prevb[0] || prevb[1])
            {
               prevhypob=hypot(prevb[0],prevb[1]); // Laenge des vorherigen Weges
            }
            
            float nexthypob= 0;
            
            if (nextb[0] || nextb[1])
            {
               nexthypob = hypot(nextb[0],nextb[1]); // Laenge des naechsten Weges
            }
            
            float prevnormb[2] = {0.0,0.0};
            
            if (prevhypob)
            {
               prevnormb[0]= -(prevb[1])/prevhypob;
               prevnormb[1] = (prevb[0])/prevhypob; // vorheriger Normalenvektor
            }
            
            
            
            float nextnormb[2] = {0.0,0.0};
            if (nexthypob)
            {
               nextnormb[0]= -(nextb[1])/nexthypob;
               nextnormb[1] = (nextb[0])/nexthypob; // vorheriger Normalenvektor
            }

            // Winkel aus Skalarprodukt der Einheitsvektoren
            float cosphib=prevnormb[0]*nextnormb[0]+ prevnormb[1]*nextnormb[1];
            
            if (cosphib >=0)
            {
               // kleine Winkelunterschiede eliminieren
               if (cosphib >0.999)
               {
                  //NSLog(@"cosphia korr+");
                  cosphib=1.0;
                  cosphi2b=1.0;
               }
               else
               {
                  cosphi2b=sqrtf((1+cosphib)/2);                       // cosinus des halben Zwischenwinkels
               }
            }
            
            else
            {
               // kleine Winkelunterschiede eliminieren
               if (cosphib < (-0.999))
               {
                  //NSLog(@"cosphib korr-");
                  cosphib=-1.0;
                  cosphi2b=-1.0;
               }
               else
               {
                  cosphi2b=-sqrtf((1+cosphib)/2);                       // cosinus des halben Zwischenwinkels
               }
               
            }
            

            
            
            // Halbwinkelsatz: cos(phi/2)=sqrt((1+cos(phi))/2)
            //cosphi2b=sqrtf((1-cosphib)/2);
            
            // Winkelhalbierende
            whb[0] = prevnormb[0]+ nextnormb[0];
            whb[1] = prevnormb[1]+ nextnormb[1];
            
            float detb = prevb[0]*whb[1]-prevb[1]*whb[0];
            
            if (detb < 0)
            {
               seitenkorrekturb *= -1;
            }
            //NSLog(@"i: %d detb: %2.4f cosphib: %2.4f seitenkorrekturb: %d",i,detb,cosphib,seitenkorrekturb);
            
            if (whb[0]==0 && whb[1]==0)
            {
               //NSLog(@"whb[0]==0 && whb[1]==0 whb[0]: %2.4f whb[1]: %2.4f",whb[0],whb[1]);
               whb[0] = lastwhb[0]*seitenkorrekturb;
               whb[1] = lastwhb[1]*seitenkorrekturb;
               
            }
            
            
            // letzte wh : lastwha, lastwhb gespeichert in vorherigem Durchgang
            //  Seite A
            float lasthypoa = hypotf(lastwha[0],lastwha[1]);   // Laenge der vorherigen WH
            float currhypoa = hypotf(wha[0],wha[1]);           // Laenge der aktuellen WH
            
            // cosinussatz
            float cospsia = (wha[0]*lastwha[0]+wha[1]*lastwha[1])/(lasthypoa*currhypoa);
            
         if (i>[Koordinatentabelle count]-20)
         {
          //  fprintf(stderr,"%d\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.6f\t%1.4f\t%1.4f\t%1.4f\t%1.4f\t%1.6f\n",i, ax,ay,preva[0],preva[1],nexta[0],nexta[1],wha[0],wha[1], prevnorma[0],prevnorma[1],nextnorma[0],nextnorma[1],cosphia,lastwha[0],lastwha[1],prevhypoa,nexthypoa,cospsia);
         }
            //            NSLog(@"i: %d  lasthypoa: %2.4f currhypoa: %2.4f cospsia: %1.8f",i,lasthypoa,currhypoa,cospsia);
            
            if (cospsia < 0) // Winkel ist > 90°
            {
               //NSLog(@"Winkel ist > 90°");
               // Ersetzt duch Ermittlung der Determinante zur Bestimmung der richtigen Seite
               //              wha[0] *= -1;
               //              wha[1] *= -1;
               
            }
            //  Seite B
            float lasthypob = hypotf(lastwhb[0],lastwhb[1]);
            float currhypob = hypotf(whb[0],whb[1]);
            float cospsib = (whb[0]*lastwhb[0]+whb[1]*lastwhb[1])/(lasthypob*currhypob);
            //NSLog(@"lasthypob: %2.4f currhypob: %2.4f cospsib: %1.8f",lasthypob,currhypob,cospsib);
            
            if (cospsib<0)
            {
               //              whb[0] *= -1;
               //              whb[1] *= -1;
            }
         }
         
         
         
         
         
         
         
         if (i==von) // erster Punkt, Abbrandvektor soll senkrecht stehen
         {
            NSLog(@"i=von: %d",i);
            float deltaax=nextax-ax;
            float deltaay=nextay-ay;
            float normalenhypoa = hypotenuse(deltaax, deltaay);
            
            // Normalenvektor steht senkrecht
            wha[0] = deltaay/normalenhypoa*(-1);      // erster Punkt, wha speichern
            wha[1] = deltaax/normalenhypoa;
            cosphi2a=1;
            //NSLog(@"deltaax: %2.4f deltaay: %2.4f normalenhypoa: %2.4f wha[0]: %2.4f wha[1]: %2.4f cosphi2a: %2.4f",deltaax,deltaay,normalenhypoa,wha[0],wha[1],cosphi2a);
            
            float deltabx=nextbx-bx;
            float deltaby=nextby-by;
            float normalenhypob = hypotenuse(deltabx, deltaby);
            // Normalenvektor steht senkrecht
            whb[0] = deltaby/normalenhypob*(-1);
            whb[1] = deltabx/normalenhypob;
            cosphi2b=1;
            
            
            // test
            if (wha[1]<0 ) // falsche Richtung in Naehe von Wendepunkt
            {
               wha[0] *= -1;
               wha[1] *= -1;
            }
            if (whb[1]<0 ) // falsche Richtung in Naehe von Wendepunkt
            {
               whb[0] *= -1;
               whb[1] *= -1;
            }
            
            
         }
         
         if (i==bis-1) // letzter Punkt, Abbrandvektor soll senkrecht stehen
         {
            //NSLog(@"i=bis-1");
            float deltaax=prevax-ax;
            float deltaay=prevay-ay;
            float normalenhypoa = hypotenuse(deltaax, deltaay);
            // Normalenvektor steht senkrecht
            wha[0] = deltaay/normalenhypoa*(-1);
            wha[1] = deltaax/normalenhypoa;
            cosphi2a=1;
            
            float deltabx=prevbx-bx;
            float deltaby=prevby-by;
            float normalenhypob = hypotenuse(deltabx, deltaby);
            // Normalenvektor steht senkrecht
            whb[0] = deltaby/normalenhypob*(-1);
            whb[1] = deltabx/normalenhypob;
            cosphi2b=1;
            
            
            // test
            if (wha[1]<0 ) // falsche Richtung in Naehe von Wendepunkt
            {
               wha[0] *= -1;
               wha[1] *= -1;
            }
            
            if (whb[1]<0 ) // falsche Richtung in Naehe von Wendepunkt
            {
               whb[0] *= -1;
               whb[1] *= -1;
            }
            
         }
         
         // ++++++++++++++++++++++++++++++++++
         // wh speichern fuer naechsten Punkt
         
         lastwha[0] = wha[0]*seitenkorrektura;
         lastwha[1] = wha[1]*seitenkorrektura;
         
         lastwhb[0] = whb[0]*seitenkorrekturb;
         lastwhb[1] = whb[1]*seitenkorrekturb;
         // ++++++++++++++++++++++++++++++++++
         
         float whahypo = hypotenuse(wha[0],wha[1]);
          //fprintf(stderr,"i:\t %d \tprevhypoa \t%2.2f\t nexthypoa \t%2.2f \twhahypo: \t%2.4f \tcosphia: \t%2.4f\tcosphi2a: \t%2.4f\n",i,prevhypoa,nexthypoa,whahypo,cosphia,cosphi2a);
         
         float abbranda[2]={wha[0]*seitenkorrektura/whahypo*abbrandmassa/cosphi2a,wha[1]*seitenkorrektura/whahypo*abbrandmassa/cosphi2a};
         
         float profilabbrandbmass = abbrandmassa;
         if ((i<(bis-2)) &&  (i>(von+1)))
            //if (i>von+1)
            //if (i<bis-2)
         {
            
            profilabbrandbmass = abbrandmassb;
         }
         //NSLog(@"i: %d profilabbrandbmass: %2.2f",i,profilabbrandbmass);
         float whbhypo = hypotf(whb[0],whb[1]);
         //NSLog(@"whbhypo: %2.4f",whbhypo);
         float abbrandb[2]= {whb[0]*seitenkorrekturb/whbhypo*profilabbrandbmass/cosphi2b,whb[1]*seitenkorrekturb/whbhypo*profilabbrandbmass/cosphi2b};
         
 //        NSLog(@"i %d orig ax %2.2f ay %2.2f bx %2.2f by %2.2f",i,ax,ay,bx,by);
 //        NSLog(@"i %d abbranda[0] %2.4f abbranda[1] %2.4f ",i,abbranda[0], abbranda[1]);
         if (isnan(abbrandb[0]) || isnan(abbrandb[1]))
         {
            NSLog(@"i %d abbranda[0] , abbranda[1] ist nan ",i);
         }
         else
         {
         [tempDic setObject:[NSNumber numberWithFloat:ax+abbranda[0]] forKey:@"abrax"];
         [tempDic setObject:[NSNumber numberWithFloat:ay+abbranda[1]] forKey:@"abray"];
         [tempDic setObject:[NSNumber numberWithFloat:bx+abbrandb[0]] forKey:@"abrbx"];
         [tempDic setObject:[NSNumber numberWithFloat:by+abbrandb[1]] forKey:@"abrby"];
         }
  //       float hypa = hypotf(ax, ay);
  //       float hypb = hypotf(bx, by);
  //       float abrhypa = hypotf(ax+abbranda[0], ay+abbranda[1]);
  //       float abrhypb = hypotf(bx+abbrandb[0], by+abbrandb[1]);
         
         if (i<25)
         {
            // NSLog(@"i %d mod %2.2f %2.2f %2.2f %2.2f  %2.2f %2.2f %2.2f %f",i,ax,ay,bx,by,ax+abbranda[0],ay+abbranda[1],bx+abbrandb[0],by+abbrandb[1]);
            //fprintf(stderr,"i \t%d  \t%2.2f \t%2.2f \t%2.2f \t%2.2f\n",i,hypa,abrhypa,hypb,abrhypb);
         }
         
         if (((i>10)&&(i<18)) || (i> 40))
         {
            //NSLog(@"i: %d tempDic: %@",i,[tempDic description]);
            // fprintf(stderr,"i %d  \t%2.2f \t%2.2f \t%2.2f \t%2.2f\n",i,hypa,abrhypa,hypb,abrhypb);
            
         }
      } // i im Bereich
       else
       {
           [tempDic setObject:[NSNumber numberWithFloat:ax] forKey:@"abrax"];
           [tempDic setObject:[NSNumber numberWithFloat:ay] forKey:@"abray"];
           [tempDic setObject:[NSNumber numberWithFloat:bx] forKey:@"abrbx"];
           [tempDic setObject:[NSNumber numberWithFloat:by] forKey:@"abrby"];

       }

       
      
      [AbbrandArray addObject:tempDic];
      
   } // for i
   //NSLog(@"addAbbrandVonKoordinaten end: %@",[AbbrandArray  description]);
   //NSLog(@"addAbbrandVonKoordinaten end: %@",[[AbbrandArray  objectAtIndex:0] description]);
   return AbbrandArray;
   
}



@end
