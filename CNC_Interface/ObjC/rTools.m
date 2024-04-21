//
//  Tools.m
//  CNC_Interface
//
//  Created by MacMini21 on 09.03.2024.
//  Copyright © 2024 Ruedi Heimlicher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "rAVRview.h"
@implementation rAVRview(rTools)

- (NSArray*)Tool_CNC_SchnittdatenArrayVonSteuerdaten:(NSDictionary*)derDatenDic
{
    NSDictionary* tempSteuerdatenDic = [self Tool_SteuerdatenVonDic:(derDatenDic)];
    NSArray* tempSteuerdatenArray = [self Tool_SchnittdatenVonDic:tempSteuerdatenDic ];
    return tempSteuerdatenArray;
}
- (NSArray*)Tool_SchnittdatenVonDic:(NSDictionary*)derDatenDic
{
    NSLog(@"****  Tool_SchnittdatenVonDic start  derDatenDic: %@",derDatenDic);

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
   
    // 21 motorstatus
   if ([derDatenDic objectForKey:@"motorstatus"])
   {
      //NSLog(@"Schnittdaten motorstatus: %d",[[derDatenDic objectForKey:@"motorstatus"]intValue]);
      
       
      [tempArray addObject:[derDatenDic objectForKey:@"motorstatus"]];

   }
   else
   {
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }

    // 22: zoom
    /*
   if ([derDatenDic objectForKey:@"zoomfaktor"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"zoomfaktor"]];
   }
   else
     */
   {
      [tempArray addObject:[NSNumber numberWithInt:1]];
   }
 
// 23 Steps einfuegen
   if ([derDatenDic objectForKey:@"steps"])
   {
      [tempArray addObject:[derDatenDic objectForKey:@"steps"]];
   }
   else
   {
      [tempArray addObject:[NSNumber numberWithInt:48]];
   }

   // 24 Faktor fuer microsteps einfuegen
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
   // 33, 34steigung einsetzen
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
  // NSLog(@"SchnittdatenVonDic tempArray: %@",[tempArray description]);
   //NSLog(@"SchnittdatenVonDic tempArray count: %d",[tempArray count]);
    //NSLog(@"****  Tool_SchnittdatenVonDic end  tempArray: %@",tempArray);

   
   return tempArray;
}

- (NSDictionary*)Tool_SteuerdatenVonDic:(NSDictionary*)derDatenDic
{
// Aufbereitung der Werte für die Uebergabe an Teensy, als uint8_t-Werte
   uint16_t dicindex = [[derDatenDic objectForKey:@"index"]intValue];
   NSLog(@"Tool_SteuerdatenVonDic start index: %d SteuerdatenVonDic: %@",dicindex, [derDatenDic description]);
    int  anzSchritte;
   int  anzaxplus=0;
   int  anzaxminus=0;
   int  anzayplus=0;
   int  anzayminus=0;

   int  anzbxplus=0;
   int  anzbxminus=0;
   int  anzbyplus=0;
   int  anzbyminus=0;
   
    int speed = 1;
    if ([derDatenDic objectForKey:@"speed"])
    {
        speed = [[derDatenDic objectForKey:@"speed"]intValue];
    }
    int steps = 48;
    if ([derDatenDic objectForKey:@"steps"])
    {
        steps = [[derDatenDic objectForKey:@"steps"]intValue];
    }


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

   
    float Distanz= sqrt(pow(DistanzX,2)+ pow(DistanzY,2));    // effektive Distanz
    float DistanzA= hypotf(DistanzAX,DistanzAY);    // effektive Distanz A
    float DistanzB= hypotf(DistanzBX,DistanzBY);    // effektive Distanz B
   
   

   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzA] forKey: @"distanza"];
   [tempDatenDic setObject:[NSNumber numberWithFloat:DistanzB] forKey: @"distanzb"];
   
   [tempDatenDic setObject:[NSNumber numberWithFloat:steigung] forKey:@"steigung"];

   if (DistanzA< 0.5 || DistanzB < 0.5)
   {
   //   NSLog(@"i:  DistanzA: %2.2f DistanzB: %2.2f",DistanzA,DistanzB);
   }
    
   float Zeit = Distanz/speed;                                                //    Schnittzeit für Distanz
   float ZeitA = DistanzA/speed;                                                //    Schnittzeit für Distanz A
   float ZeitB = DistanzB/speed;                                                //    Schnittzeit für Distanz B
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
    int SchritteX=steps*DistanzX;                                                    //    Schritte in X-Richtung
    int SchritteAX=steps*DistanzAX;                                                    //    Schritte in X-Richtung A
    int SchritteBX=steps*DistanzBX;                                                    //    Schritte in X-Richtung B
  
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
    
    int SchritteY=steps*DistanzY;    //    Schritte in Y-Richtung
    int SchritteAY=steps*DistanzAY;    //    Schritte in Y-Richtung A
    int SchritteBY=steps*DistanzBY;    //    Schritte in Y-Richtung B
   
    
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

   
    
   float delayX = 0;                            // Zeit fuer einen Schritt in 100us-Einheit
    float delayAX= 0;                            // Zeit fuer einen Schritt AX in 100us-Einheit
    float delayBX= 0;                            // Zeit fuer einen Schritt BX in 100us-Einheit
    
      
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
    //NSLog(@"Tool_SteuerdatenVonDic end index: %d tempDatenDic: %@",index,[tempDatenDic description]);
    return tempDatenDic;
}


@end
