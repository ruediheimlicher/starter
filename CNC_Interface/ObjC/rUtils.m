//
//  rUtils.m
//  USBInterface
//
//  Created by Sysadmin on 09.03.07.
//  Copyright 2007 Ruedi Heimlicher. All rights reserved.
//

#import "rUtils.h"
#include <stdio.h>
#include <stdlib.h>
#include "poly.h"

@implementation rUtils
- (void) logRect:(NSRect)r
{
NSLog(@"logRect: origin.x %2.2f origin.y %2.2f size.heigt %2.2f size.width %2.2f",r.origin.x, r.origin.y, r.size.height, r.size.width);
}

- (NSArray*)readProfil:(NSString*)profilname
{
	NSMutableArray* ProfilArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSOpenPanel* OpenPanel=[NSOpenPanel openPanel];
//	[OpenPanel setCanChooseFiles:YES];
//	[OpenPanel setCanChooseDirectories:NO];
//	[OpenPanel setAllowsMultipleSelection:NO];
 //  [OpenPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt",NULL]];
   NSLog(@"readProfil start");
	/*
	[OpenPanel beginSheetForDirectory:NSHomeDirectory() file:nil 
	 //types:nil 
							 modalForWindow:[self window] 
							  modalDelegate:self 
							 didEndSelector:@selector(ProfilPfadAktion:returnCode:contextInfo:)
								 contextInfo:nil];
	*/
	NSInteger antwort=[OpenPanel runModal];
	return NULL;
   NSURL* ProfilPfad=[OpenPanel URL];
	NSLog(@"readProfil: URL: %@",ProfilPfad);
	NSError* err=0;
	NSString* ProfilString=[NSString stringWithContentsOfURL:ProfilPfad encoding:NSMacOSRomanStringEncoding  error:&err]; // String des Speicherpfads
	//NSLog(@"Utils openProfil ProfilString: \n%@",ProfilString);
	
	NSArray* tempArray=[ProfilString componentsSeparatedByString:@"\r"];
	NSString* firstString = [tempArray objectAtIndex:0];
	NSLog(@"firstString: %@ Array:%@",firstString,[[firstString componentsSeparatedByString:@"\t"]description]);
	
	if (!([[firstString componentsSeparatedByString:@"\t"]count]==2)) // Titel
	{
		NSRange titelRange;
 
		titelRange.location = 1;
		titelRange.length = [tempArray count]-1;
 
		tempArray = [tempArray subarrayWithRange:titelRange];
	
	}
	NSLog(@"Utils openProfil tempArray: \n%@",[tempArray description]);
	//NSLog(@"Utils openProfil tempArray count: %d",[tempArray count]);
	int i=0;
	
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:6];
	[numberFormatter setFormat:@"##0.000000"];

	for (i=0;i<[tempArray count];i++)
	{
		NSString* tempZeilenString=[tempArray objectAtIndex:i];
		//NSLog(@"Utils tempZeilenString l: %d",[tempZeilenString length]);
		if ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))
		{
			continue;
		}
		//NSLog(@"char 0: %d",[tempZeilenString characterAtIndex:0]);
		if ([tempZeilenString characterAtIndex:0]==10)
		{
		//NSLog(@"char 0 weg");
		tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		
		while ([tempZeilenString characterAtIndex:0]==' ')
		{
		tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		//NSLog(@"tempZeilenString A: %@",tempZeilenString);
		NSRange LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
		//NSLog(@"LeerschlagRange start loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		while(LeerschlagRange.length )
		{
			//if (LeerschlagRange.length==1)
			{
				//tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
				
			}
			//else
			{
				tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
			}
			LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
			NSLog(@"LeerschlagRange loop loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		}
		//NSLog(@"tempZeilenString B: %@",tempZeilenString);
		tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
		//NSLog(@"tempZeilenString C: %@",tempZeilenString);
		
		NSArray* tempZeilenArray=[tempZeilenString componentsSeparatedByString:@"\t"];
		float wertx=[[tempZeilenArray objectAtIndex:0]floatValue];//*100;
		float werty=[[tempZeilenArray objectAtIndex:1]floatValue];//*100;
		NSString*tempX=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:wertx]]];
		NSString*tempY=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:werty]]];
		//NSLog(@"tempX: %@",tempX);
		//NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:wertx], @"x",
		//[NSNumber numberWithFloat:werty], @"y",NULL];
		NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:tempX, @"x",tempY, @"y",NULL];
		[ProfilArray addObject:tempDic];
		//[ProfilArray insertObject:tempDic atIndex:0];
	}
	
	NSLog(@"Utils openProfil ProfilArray: \n%@",[ProfilArray description]);
	return ProfilArray;
}

- (NSArray*)flipProfil:(NSArray*)profilArray
{
   NSMutableArray* flipProfilArray = [[NSMutableArray alloc]initWithCapacity:0];
   int i;
   
   
   for (i=0;i< [profilArray count];i++)
   {
      NSMutableDictionary* tempZeilenDic = [NSMutableDictionary dictionaryWithDictionary:[profilArray objectAtIndex:i]];
      float tempx=[[tempZeilenDic objectForKey:@"x"]floatValue];
      
      tempx *= -1;
      tempx += 1;
      float tempy=[[tempZeilenDic objectForKey:@"y"]floatValue];
      [tempZeilenDic setObject:[NSNumber numberWithFloat:tempx]forKey:@"x"];
      [tempZeilenDic setObject:[NSNumber numberWithFloat:tempy]forKey:@"y"];
      [flipProfilArray addObject:tempZeilenDic];
   }
   
   return flipProfilArray;
}


- (NSArray*)spiegelnProfilVertikal:(NSArray*)profilArray
{
   NSMutableArray* flipProfilArray = [[NSMutableArray alloc]initWithCapacity:0];
   int i;
   
   
   for (i=0;i< [profilArray count];i++)
   {
      NSMutableDictionary* tempZeilenDic = [NSMutableDictionary dictionaryWithDictionary:[profilArray objectAtIndex:i]];
      float tempy=[[tempZeilenDic objectForKey:@"y"]floatValue];
      
      tempy *= -1;
      //tempx += 1;
      float tempx=[[tempZeilenDic objectForKey:@"x"]floatValue];
      [tempZeilenDic setObject:[NSNumber numberWithFloat:tempx]forKey:@"x"];
      [tempZeilenDic setObject:[NSNumber numberWithFloat:tempy]forKey:@"y"];
      [flipProfilArray addObject:tempZeilenDic];
   }
   
   return flipProfilArray;
}


- (NSDictionary*)floatProfilDatenAnPfad:(NSString*)profilpfad
{
   NSMutableArray* ProfilArray=[NSMutableArray new];
   NSLog(@"ProfilDatenAnPfad: URL: %@",profilpfad);
   NSError* err=0;
   NSString* ProfilString=[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:profilpfad] encoding:NSUTF8StringEncoding error:&err]; // String des Speicherpfads
   //NSLog(@"Utils openProfil ProfilString: \n%@ err: %@",ProfilString, [err description]);
   if (ProfilString==NULL)
   {
      return NULL;
   }
   
   NSString* stringterm;
   if ([[ProfilString componentsSeparatedByString:@"\r"]count]==1)
   {
      stringterm = @"\n";
   }
   else {
      stringterm = @"\r";
   }
   
   NSArray* tempArray=[ProfilString componentsSeparatedByString:stringterm];
   NSString* firstString = [tempArray objectAtIndex:0];
   NSString* ProfilName=[NSString string];
   
   NSRange nameRange;
   nameRange=[firstString rangeOfString:@"\n"];
   //NSLog(@"nameRange start loc: %u l: %u",nameRange.location, nameRange.length);   
   
   if (nameRange.location < NSNotFound)
   {
      ProfilName = [firstString substringToIndex:nameRange.location];
      
      //NSLog(@"firstString mit n: %@ ProfilName:%@",firstString,ProfilName);
   }
   else if (!([[firstString componentsSeparatedByString:@"\t"]count]==2)) // Titel
   {
      ProfilName = firstString;
      NSRange titelRange;
      
      titelRange.location = 1;
      titelRange.length = [tempArray count]-1;
      
      tempArray = [tempArray subarrayWithRange:titelRange];
      
   }
   else
   {
      ProfilName =@"Profil";
   }

   // Nasenindex suchen
   float minx=NSNotFound;
   int Nasenindex=0;
   
   for (int i=0;i<[tempArray count];i++)
   {
      
      NSString* tempZeilenString=[tempArray objectAtIndex:i];
      nameRange=[tempZeilenString rangeOfString:@"\n"];
      //NSLog(@"nameRange start loc: %d l: %d",nameRange.location, nameRange.length);   
      
      if (nameRange.location < NSNotFound)
      {
         //NSLog(@"i: %d String mit n: %@ ",i,tempZeilenString);
         tempZeilenString = [tempZeilenString substringFromIndex:nameRange.location];
         
         //NSLog(@"i: %d String ohne n: %@ ",i,tempZeilenString);
      }
      
      //NSLog(@"i: %d Utils tempZeilenString l: %d",i,[tempZeilenString length]);
      
      if ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))
      {
         //NSLog(@"i: %d ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))",i);
         continue;
      }
      //NSLog(@"char 0: %d",[tempZeilenString characterAtIndex:0]);
      if ([tempZeilenString characterAtIndex:0]==10)
      {
         //NSLog(@"char 0 weg");
         tempZeilenString=[tempZeilenString substringFromIndex:1];
      }
      
      while ([tempZeilenString characterAtIndex:0]==' ')
      {
         tempZeilenString=[tempZeilenString substringFromIndex:1];
      }
      //NSLog(@"%d tempZeilenString A: %@",i,tempZeilenString);
      NSRange LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
      //NSLog(@"LeerschlagRange start loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
      while(LeerschlagRange.length )
      {
         //if (LeerschlagRange.length==1)
         {
            //tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
            
         }
         //else
         {
            tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
         }
         LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
         //NSLog(@"LeerschlagRange loop loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
      }
      //NSLog(@"tempZeilenString B: %@",tempZeilenString);
      tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
      //NSLog(@"i: %d tempZeilenString C: %@",i,tempZeilenString);
      
      NSArray* tempZeilenArray=[tempZeilenString componentsSeparatedByString:@"\t"];
      float wertx=[[tempZeilenArray objectAtIndex:0]floatValue];
      float werty=[[tempZeilenArray objectAtIndex:1]floatValue];
      
      if ((wertx == 0) && (Nasenindex == 0))
      {
         minx=wertx;
         Nasenindex=i;
         
      }
      NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:wertx], @"x",[NSNumber numberWithFloat:werty], @"y",[NSNumber numberWithFloat:1], @"data",NULL];
      [ProfilArray addObject:tempDic];
    
      
      
   }// for i
   
   
   // Profil umdrehen
   //ProfilArray = (NSMutableArray*)[self flipProfil:ProfilArray];
   //NSLog(@"Utils openProfil ProfilArray: \n%@",[ProfilArray description]);

   NSLog(@"OberseiteArray");
   NSArray* OberseiteArray=[ProfilArray subarrayWithRange:NSMakeRange(0, Nasenindex+1)];
   
   for (int i=0;i<OberseiteArray.count;i++)
   {
      fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[OberseiteArray objectAtIndex:i]objectForKey:@"x"] floatValue],[[[OberseiteArray objectAtIndex:i]objectForKey:@"y"] floatValue]);
   }

   NSLog(@"UnterseiteArray");
   NSArray* UnterseiteArray=[ProfilArray subarrayWithRange:NSMakeRange(Nasenindex, [ProfilArray count]-Nasenindex)];
   NSMutableArray * revUnterseiteArray = [NSMutableArray new];
   int i=0;
   for( i = 0; i < [UnterseiteArray count]; i++) 
   {
      [revUnterseiteArray addObject:[UnterseiteArray objectAtIndex:[UnterseiteArray count] - i - 1]];
   }

   for (int i=0;i<UnterseiteArray.count;i++)
   {
      fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[UnterseiteArray objectAtIndex:i]objectForKey:@"x"] floatValue],[[[UnterseiteArray objectAtIndex:i]objectForKey:@"y"] floatValue]);
   }

   NSDictionary* floatProfilDic=[NSDictionary dictionaryWithObjectsAndKeys:ProfilArray,@"profilarray", OberseiteArray,@"oberseitearray",UnterseiteArray, @"unterseitearray",ProfilName, @"profilname",NULL];


   return floatProfilDic;
   
   
}

- (NSDictionary*)ProfilDatenAnPfad:(NSString*)profilpfad
{
	NSMutableArray* ProfilArray=[[NSMutableArray alloc]initWithCapacity:0];
   NSLog(@"ProfilDatenAnPfad: URL: %@",profilpfad);
	NSError* err=0;
	NSString* ProfilString=[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:profilpfad] encoding:NSUTF8StringEncoding error:&err]; // String des Speicherpfads
	//NSLog(@"Utils openProfil ProfilString: \n%@ err: %@",ProfilString, [err description]);
	if (ProfilString==NULL)
	{
      return NULL;
	}
   
   NSString* stringterm;
   if ([[ProfilString componentsSeparatedByString:@"\r"]count]==1)
   {
      stringterm = @"\n";
   }
   else {
      stringterm = @"\r";
   }
   
   
	NSArray* tempArray=[ProfilString componentsSeparatedByString:stringterm];
   
   
	NSString* firstString = [tempArray objectAtIndex:0];
	//NSLog(@"firstString: %@",firstString );
   
	//NSLog(@"firstString desc: %@",[firstString description]);
	NSString* ProfilName=[NSString string];
   
   NSRange testRange;
	testRange=[firstString rangeOfString:@"\r"];
	//NSLog(@"testRange start loc: %u l: %u",testRange.location, testRange.length);	
   
   
   
	NSRange nameRange;
	nameRange=[firstString rangeOfString:@"\n"];
	//NSLog(@"nameRange start loc: %u l: %u",nameRange.location, nameRange.length);	
	
	if (nameRange.location < NSNotFound)
	{
		ProfilName = [firstString substringToIndex:nameRange.location];
		
		//NSLog(@"firstString mit n: %@ ProfilName:%@",firstString,ProfilName);
	}
	else if (!([[firstString componentsSeparatedByString:@"\t"]count]==2)) // Titel
	{
		ProfilName = firstString;
		NSRange titelRange;
		
		titelRange.location = 1;
		titelRange.length = [tempArray count]-1;
		
		tempArray = [tempArray subarrayWithRange:titelRange];
		
	}
	else
	{
		ProfilName =@"Profil";
	}
	//NSLog(@"Utils openProfil ProfilName: %@",ProfilName);
	//NSLog(@"Utils openProfil tempArray: \n%@",[tempArray description]);
	//NSLog(@"Utils openProfil tempArray count: %d",[tempArray count]);
	int i=0;
	
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:6];
	[numberFormatter setFormat:@"##0.0000"];
	
   // Nasenindex suchen
   float minx=NSNotFound;
   int Nasenindex=0;
   
   
   
	for (i=0;i<[tempArray count];i++)
	{
		
		NSString* tempZeilenString=[tempArray objectAtIndex:i];
  //    NSLog(@"%d tempZeilenString raw: %@",i,tempZeilenString);
		nameRange=[tempZeilenString rangeOfString:@"\n"];
		//NSLog(@"nameRange start loc: %d l: %d",nameRange.location, nameRange.length);	
		
		if (nameRange.location < NSNotFound)
		{
			//NSLog(@"i: %d String mit n: %@ ",i,tempZeilenString);
			tempZeilenString = [tempZeilenString substringFromIndex:nameRange.location];
			
			//NSLog(@"i: %d String ohne n: %@ ",i,tempZeilenString);
		}
		
		//NSLog(@"i: %d Utils tempZeilenString l: %d",i,[tempZeilenString length]);
		
		if ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))
		{
         //NSLog(@"i: %d ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))",i);
			continue;
		}
		//NSLog(@"char 0: %d",[tempZeilenString characterAtIndex:0]);
		if ([tempZeilenString characterAtIndex:0]==10)
		{
			//NSLog(@"char 0 weg");
			tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		
		while ([tempZeilenString characterAtIndex:0]==' ')
		{
			tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
//		NSLog(@"%d tempZeilenString A: %@",i,tempZeilenString);
		NSRange LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
		//NSLog(@"LeerschlagRange start loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		while(LeerschlagRange.length )
		{
			//if (LeerschlagRange.length==1)
			{
				//tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
				
			}
			//else
			{
				tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
			}
			LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
			//NSLog(@"LeerschlagRange loop loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		}
//		NSLog(@"tempZeilenString B: %@",tempZeilenString);
		tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
//		NSLog(@"i: %d tempZeilenString C: %@",i,tempZeilenString);
		
		NSArray* tempZeilenArray=[tempZeilenString componentsSeparatedByString:@"\t"];
		float wertx=[[tempZeilenArray objectAtIndex:0]floatValue];
		float werty=[[tempZeilenArray objectAtIndex:1]floatValue];
		NSString*tempX=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:wertx]]];
		NSString*tempY=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:werty]]];
		//NSLog(@"tempX: %@ tempY: %@",tempX,tempY);
		//NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:wertx], @"x",
		//[NSNumber numberWithFloat:werty], @"y",NULL];
      
      //if (wertx < minx)
      if ((wertx == 0) && (Nasenindex == 0))
      {
         minx=wertx;
         Nasenindex=i;
         
      }

      NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:tempX, @"x",tempY, @"y",[NSNumber numberWithFloat:1], @"data",NULL];
 //     NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[tempZeilenArray objectAtIndex:1], @"x",[tempZeilenArray objectAtIndex:0], @"y",[NSNumber numberWithFloat:1], @"data",NULL];
		
      
      [ProfilArray addObject:tempDic];
     
      
      //[ProfilArray insertObject:tempDic atIndex:0];
	} // for i
    
    
	
   Nasenindex = 0;
   for (int i=0;i<ProfilArray.count;i++)
   {
      float wertx=[[[ProfilArray objectAtIndex:i]objectForKey:@"x"] floatValue];
      float werty=[[[ProfilArray objectAtIndex:i]objectForKey:@"y"] floatValue];
      if ((wertx == 0) && (Nasenindex == 0))
      {
         minx=wertx;
         Nasenindex=i;
         
      }


   }
   
   if(ProfilArray.count > 200)
   {
      ProfilArray = [self anzahlPunktereduzierenVon:ProfilArray];
   }
   
   Nasenindex = 0;
   for (int i=0;i<ProfilArray.count;i++)
   {
      float wertx=[[[ProfilArray objectAtIndex:i]objectForKey:@"x"] floatValue];
      float werty=[[[ProfilArray objectAtIndex:i]objectForKey:@"y"] floatValue];
      if ((wertx == 0) && (Nasenindex == 0))
      {
         minx=wertx;
         Nasenindex=i;
         
      }


   }
   

      
   
   NSLog(@"Profilarray name: %@:",ProfilName);
   for (int i=0;i<ProfilArray.count;i++)
   {
      fprintf(stderr,"%d \t %2.6f \t %2.6f \n",i,[[[ProfilArray objectAtIndex:i]objectForKey:@"x"]floatValue], [[[ProfilArray objectAtIndex:i]objectForKey:@"y"]floatValue]);
   }

   // Profil umdrehen
   ProfilArray = (NSMutableArray*)[self flipProfil:ProfilArray];
	//NSLog(@"Utils openProfil ProfilArray: \n%@",[ProfilArray description]);
	
   // Test Spline
   
   //NSLog(@"count: %d Nasenindex: %d",[ProfilArray count],Nasenindex);
   
   NSLog(@"OberseiteArray");
   NSArray* OberseiteArray=[NSArray arrayWithArray:[ProfilArray subarrayWithRange:NSMakeRange(0, Nasenindex+1)]];
   NSLog(@"OberseiteArray count: %d",OberseiteArray.count);
   for (int i=0;i<OberseiteArray.count;i++)
   {
       fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[OberseiteArray objectAtIndex:i]objectForKey:@"x"] floatValue],[[[OberseiteArray objectAtIndex:i]objectForKey:@"y"] floatValue]);
       
   }
   // minimaldistanz
    for (int i=0;i<OberseiteArray.count;i++)
    {
        float x = [[[OberseiteArray objectAtIndex:i]objectForKey:@"x"]floatValue];
        float y = [[[OberseiteArray objectAtIndex:i]objectForKey:@"x"]floatValue];
        
    }
    
    
   NSLog(@"UnterseiteArray");
   NSArray* UnterseiteArray=[NSArray arrayWithArray:[ProfilArray subarrayWithRange:NSMakeRange(Nasenindex, [ProfilArray count]-Nasenindex)]];
   NSMutableArray * revUnterseiteArray = [NSMutableArray new];
   //int i=0;
    NSLog(@"UnterseiteArray count %d",UnterseiteArray.count);
   for( i = 0; i < [UnterseiteArray count]; i++)
   {
      fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[UnterseiteArray objectAtIndex:i]objectForKey:@"x"] floatValue],[[[UnterseiteArray objectAtIndex:i]objectForKey:@"y"] floatValue]);

      [revUnterseiteArray addObject:[UnterseiteArray objectAtIndex:[UnterseiteArray count] - i - 1]];
   }
   NSLog(@"revUnterseiteArray");
   
   //NSLog(@"Spline Unterseite");
   
   //   NSDictionary* UnterseiteSplineKoeffArray=[self SplinekoeffizientenVonArray:revUnterseiteArray];
   
   
   // End Spline
   
    
   NSDictionary* ProfilDic=[NSDictionary dictionaryWithObjectsAndKeys:ProfilArray,@"profilarray", OberseiteArray,@"oberseitearray",UnterseiteArray, @"unterseitearray",ProfilName, @"profilname",NULL];
   //NSLog(@"Utils openProfil ProfilDic: \n%@",[ProfilDic description]);
	return ProfilDic;
}

-  (NSDictionary*)readProfilMitName
{
	NSMutableArray* ProfilArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSOpenPanel* OpenPanel=[NSOpenPanel openPanel];
	[OpenPanel setCanChooseFiles:YES];
	[OpenPanel setCanChooseDirectories:NO];
	[OpenPanel setAllowsMultipleSelection:NO];
   [OpenPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt",NULL]];
   //NSButton *gleichesProfil = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 240, 24)];
   //[gleichesProfil setButtonType:NSSwitchButton];
   //[gleichesProfil setState:1];
   //[gleichesProfil setTitle:@"gleiches Profil fuer beide Seiten"];
   //[OpenPanel setAccessoryView:gleichesProfil];
	/*
	 [OpenPanel beginSheetForDirectory:NSHomeDirectory() file:nil 
	 //types:nil 
	 modalForWindow:[self window] 
	 modalDelegate:self 
	 didEndSelector:@selector(ProfilPfadAktion:returnCode:contextInfo:)
	 contextInfo:nil];
	 */
	int antwort=[OpenPanel runModal];
   return NULL;
   if (antwort == NSFileHandlingPanelCancelButton)
   {
      return NULL;
      
   }
   
	NSURL* ProfilPfad=[OpenPanel URL];
	NSLog(@"readProfilMitName: URL: %@",ProfilPfad);
	NSError* err=0;
	NSString* ProfilString=[NSString stringWithContentsOfURL:ProfilPfad encoding:NSUTF8StringEncoding error:&err]; // String des Speicherpfads
	//NSLog(@"Utils openProfil ProfilString: \n%@ err: %@",ProfilString, [err description]);
	if (ProfilString==NULL)
	{
	ProfilString=[NSString stringWithContentsOfURL:ProfilPfad encoding:NSMacOSRomanStringEncoding error:&err];
	
	}
	if (ProfilString==NULL)
	{
	ProfilString=[NSString stringWithContentsOfURL:ProfilPfad encoding:NSUnicodeStringEncoding error:&err];
	
	}

	NSArray* tempArray=[ProfilString componentsSeparatedByString:@"\r"];
	NSString* firstString = [tempArray objectAtIndex:0];
	NSLog(@"firstString: %@",firstString);
	NSString* ProfilName=[NSString string];
	
	NSRange nameRange;
	nameRange=[firstString rangeOfString:@"\n"];
	NSLog(@"nameRange start loc: %u l: %u",nameRange.location, nameRange.length);	
	
	if (nameRange.location < NSNotFound)
	{
		ProfilName = [firstString substringToIndex:nameRange.location];
		
		NSLog(@"firstString mit n: %@ ProfilName:%@",firstString,ProfilName);
	}
	else if (!([[firstString componentsSeparatedByString:@"\t"]count]==2)) // Titel
	{
		ProfilName = firstString;
		NSRange titelRange;
		
		titelRange.location = 1;
		titelRange.length = [tempArray count]-1;
		
		tempArray = [tempArray subarrayWithRange:titelRange];
		
	}
	else
	{
		ProfilName =@"Profil";
	}
	//NSLog(@"Utils openProfil ProfilName: %@",ProfilName);
	//NSLog(@"Utils openProfil tempArray: \n%@",[tempArray description]);
	//NSLog(@"Utils openProfil tempArray count: %d",[tempArray count]);
	int i=0;
	
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:4];
	[numberFormatter setFormat:@"##0.0000"];
	
	for (i=0;i<[tempArray count];i++)
	{
		
		NSString* tempZeilenString=[tempArray objectAtIndex:i];
		nameRange=[tempZeilenString rangeOfString:@"\n"];
		//NSLog(@"nameRange start loc: %d l: %d",nameRange.location, nameRange.length);	
		
		if (nameRange.location < NSNotFound)
		{
			//NSLog(@"i: %d String mit n: %@ ",i,tempZeilenString);
			tempZeilenString = [tempZeilenString substringFromIndex:nameRange.location];
			
			//NSLog(@"i: %d String ohne n: %@ ",i,tempZeilenString);
		}
		
		//NSLog(@"i: %d Utils tempZeilenString l: %d",i,[tempZeilenString length]);
		
		if ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))
		{
         //NSLog(@"i: %d ((tempZeilenString==NULL)|| ([tempZeilenString length]==1))",i);
			continue;
		}
		//NSLog(@"char 0: %d",[tempZeilenString characterAtIndex:0]);
		if ([tempZeilenString characterAtIndex:0]==10)
		{
			//NSLog(@"char 0 weg");
			tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		
		while ([tempZeilenString characterAtIndex:0]==' ')
		{
			tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		//NSLog(@"tempZeilenString A: %@",tempZeilenString);
		NSRange LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
		//NSLog(@"LeerschlagRange start loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		while(LeerschlagRange.length )
		{
			//if (LeerschlagRange.length==1)
			{
				//tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
				
			}
			//else
			{
				tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
			}
			LeerschlagRange=[tempZeilenString rangeOfString:@"  "];
			//NSLog(@"LeerschlagRange loop loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		}
		//NSLog(@"tempZeilenString B: %@",tempZeilenString);
		tempZeilenString=[tempZeilenString stringByReplacingOccurrencesOfString:@" " withString:@"\t"];
		//NSLog(@"i: %d tempZeilenString C: %@",i,tempZeilenString);
		
		NSArray* tempZeilenArray=[tempZeilenString componentsSeparatedByString:@"\t"];
		float wertx=[[tempZeilenArray objectAtIndex:0]floatValue];
		float werty=[[tempZeilenArray objectAtIndex:1]floatValue];
		NSString*tempX=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:wertx]]];
		NSString*tempY=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:werty]]];
		//NSLog(@"tempX: %@",tempX);
		//NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:wertx], @"x",
		//[NSNumber numberWithFloat:werty], @"y",NULL];
		NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:tempX, @"x",tempY, @"y",NULL];
		[ProfilArray addObject:tempDic];
	}
	
	//NSLog(@"Utils openProfil ProfilArray: \n%@",[ProfilArray description]);
	
	NSDictionary* ProfilDic=[NSDictionary dictionaryWithObjectsAndKeys:ProfilArray,@"profilarray",ProfilName, @"profilname",NULL];
   //NSLog(@"Utils openProfil ProfilDic: \n%@",[ProfilDic description]);
	return ProfilDic;
}

- (NSArray*)anzahlPunktereduzierenVon:(NSArray*) bigarray
{
   int even = (bigarray.count % 2 == 0);
   NSDictionary* last = [bigarray lastObject];
   
   NSMutableArray* returnarray = [NSMutableArray new];
   for(int i=0;i<bigarray.count;i++)
   {
      if([[[bigarray objectAtIndex:i]objectForKey:@"x"]floatValue] == 0)
      {
         [returnarray addObject:bigarray[i]];
      }
      else if(i%2 == 0)
      {
         [returnarray addObject:bigarray[i] ];
      }
         
   }
   
   if (even)
   {
      [returnarray addObject:last];
   }

   return returnarray;
}


- (NSArray*)werteanpassenUnterseiteVon:(NSArray*) syncarray
{
   //NSLog(@"werteanpassenUnterseiteVon start");
   NSMutableArray* returncarray = [NSMutableArray new];
   if([syncarray count] == 2)
   {
      NSArray* A = [syncarray objectAtIndex:0];
      long mincount = 0;
      NSArray* B = [syncarray objectAtIndex:1];
      long maxcount = 0;
    
      
      // profil Richtung rechts
      NSArray* soll = [NSArray array]; // zu erreichen
      NSArray* quelle = [NSArray array]; // 
      
      NSString* code = @"x";
      int changedarraypos = -1; // position von changedarray im returnarray
      if(A.count > B.count) // B ist soll und berechnet  Zwischenwerte von A durch Interpolation
      {
         code = @"soll:B quelle:A";
         changedarraypos = 0; 
         soll = B;
         maxcount = A.count;
         quelle = A; // liefert Werte fuer Interpolation
         mincount = B.count;
         
      }
      else // 
      {
         code = @"soll:A quelle:B";
         changedarraypos = 1; 
         soll = A;
         maxcount = B.count;
         quelle = B; // wird reduziert
         mincount = A.count;
      }
      //NSLog(@"A count: %d B count: %d \t code: %@ ",A.count, B.count, code );
      /*
      NSLog(@"soll:");
      for (int i=0;i<soll.count;i++)
      {
         fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[soll objectAtIndex:i]objectForKey:@"x"] floatValue],[[[soll objectAtIndex:i]objectForKey:@"y"] floatValue]);
      }
       
      NSLog(@"quelle:");
      for (int i=0;i<quelle.count;i++)
      {
         fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[quelle objectAtIndex:i]objectForKey:@"x" ] floatValue],[[[quelle objectAtIndex:i]objectForKey:@"y" ] floatValue]);
      }
      */
      //NSLog(@"UA");
      if ([[soll[0]objectForKey:@"x"] floatValue] > 0)
      {
         //NSLog(@"soll an 0 > 0");
      }
 
      float maxdiff = 0;
      int maxindex = 0;
      int insertindex = 0;
      NSMutableArray* changedarray =  [NSMutableArray new]; // soll mit Interpolationswerten aus quelle an positionen von soll aufgebaut werden
      int sollstart = 0; // aktuelle Pos der Interpolation
      NSDictionary* startdic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.0],@"x", [NSNumber numberWithFloat:0.0],@"y", nil];
  //    [changedarray addObject:startdic];
      for (int sollpos = 0;sollpos < soll.count; sollpos++)
      {
         //NSLog(@"sollpos: %d",sollpos);
         
         float sollx = [[soll[sollpos]objectForKey:@"x"] floatValue]; // fuer diese pos den Wert auf quelle bestimmen
         float quellposU = 0;
         float changexU, changexO = 0; // Pos auf quelle vor und nach sollx
         int quellestartpos = 1;
         int quellesucherfolg = 0;
         for (int quellepos = quellestartpos;quellepos < quelle.count; quellepos++)// Positionen auf quelle vor und nach sollx suchen, Beginn ab 1
         {
            float quellex = [[quelle[quellepos]objectForKey:@"x"] floatValue]; 
            if((quellex < sollx) && (quellesucherfolg == 0) ) // Wert gefunden quellx abnehmend
            {
               changexO = quellex;
               changexU = [[quelle[quellepos-1]objectForKey:@"x"] floatValue];
               float diffx = changexO - changexU;
               
               
               quellestartpos = quellepos;
               //NSLog(@"Wert gefunden quellepos bei %d: sollx: %2.6f changexO: %2.6f changexU: %2.6f",quellepos, sollx, changexO, changexU);
               float changeyO = [[quelle[quellepos]objectForKey:@"y"] floatValue];
               float changeyU = [[quelle[quellepos-1]objectForKey:@"y"] floatValue];
               float diffy = changeyO - changeyU;
               //NSLog(@"diffx: %2.6f diffy: %2.6f",diffx, diffy);
               float interpolY = changeyU + (diffy)/(diffx)*(sollx - changexU);
               //NSLog(@"changeyO: %2.6f changeyU: %2.6f  interpolY: %2.6f",changeyO,changeyU,interpolY);
               
               NSDictionary* tempdic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:sollx],@"x", [NSNumber numberWithFloat:interpolY],@"y", nil];
               [changedarray addObject:tempdic];
               
               quellesucherfolg = 1;
               continue;
            }
            
         } // Interpolationswerte finden
         
         
          //    sollstart = sollpos; // naechste loop beginnt hier
      }
      //NSLog(@"UB");
      // letztes El einfuegen
      NSDictionary* lastdic = [NSDictionary dictionaryWithObjectsAndKeys:[[quelle lastObject]objectForKey:@"x"],@"x", [[quelle lastObject]objectForKey:@"y"],@"y", nil];
     [changedarray addObject:lastdic];
/*
      NSLog(@"changedarray:");
      for (int i=0;i<changedarray.count;i++)
      {
         fprintf(stderr,"%d \t %2.6f \t %2.6f \n",i,[[[changedarray objectAtIndex:i]objectForKey:@"x"]floatValue], [[[changedarray objectAtIndex:i]objectForKey:@"y"]floatValue]);
      }
      NSLog(@"UC");
 */
      //NSLog(@"werteanpassenUnterseiteVon end");
      if (changedarraypos == 1) // pos 1 fuer changedarray
      {
         return [NSArray arrayWithObjects: soll, changedarray, nil];
      }
      else if (changedarraypos == 0)
      {
         return [NSArray arrayWithObjects: changedarray,soll, nil];
      }
      
   }
   
  
   return nil;
}

- (NSArray*)werteanpassenOberseiteVon:(NSArray*) syncarray
{
   //NSLog(@"werteanpassenOberseiteVon start");
   NSMutableArray* returncarray = [NSMutableArray new];
   if([syncarray count] == 2)
   {
      NSArray* A = [syncarray objectAtIndex:0];
      long mincount = 0;
      NSArray* B = [syncarray objectAtIndex:1];
      long maxcount = 0;
      
      
      
      // profil Richtung rechts
      NSArray* soll = [NSArray array]; // zu erreichen
      NSArray* quelle = [NSArray array]; // 
      
      NSString* code = @"x";
      int changedarraypos = -1; // position von changedarray im returnarray
      if(A.count > B.count) // B ist soll und berechnet  Zwischenwerte von A durch Interpolation
      {
         code = @"soll:B quelle:A";
         changedarraypos = 0; 
         soll = B;
         maxcount = A.count;
         quelle = A; // liefert Werte fuer Interpolation
         mincount = B.count;
         
      }
      else // 
      {
         code = @"soll:A quelle:B";
         changedarraypos = 1; 
         soll = A;
         maxcount = B.count;
         quelle = B; // wird reduziert
         mincount = A.count;
      }
      //NSLog(@"A count: %d B count: %d \t code: %@ ",A.count, B.count, code );
      
      
      /*
      NSLog(@"soll:");
      for (int i=0;i<soll.count;i++)
      {
         fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[soll objectAtIndex:i]objectForKey:@"x"] floatValue],[[[soll objectAtIndex:i]objectForKey:@"y"] floatValue]);
      }
      NSLog(@"quelle:");
      for (int i=0;i<quelle.count;i++)
      {
         fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[quelle objectAtIndex:i]objectForKey:@"x" ] floatValue],[[[quelle objectAtIndex:i]objectForKey:@"y" ] floatValue]);
      }
      */
      //NSLog(@"OA");
      NSMutableArray* changedarray =  [NSMutableArray new]; // soll mit Interpolationswerten aus quelle an positionen von soll aufgebaut werden

      if (A.count == B.count)
      {
         NSLog(@"count gleich");
         return [NSArray arrayWithObjects: soll, quelle, nil];
         
      }
         
       //  else
      {
         NSLog(@"count ungleich");
         float maxdiff = 0;
         int maxindex = 0;
         int insertindex = 0;
          int sollstart = 0; // aktuelle Pos der Interpolation
         NSDictionary* startdic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.0],@"x", [NSNumber numberWithFloat:0.0],@"y", nil];
         //    [changedarray addObject:startdic];
         for (int sollpos = 0;sollpos < soll.count; sollpos++)
         {
            //NSLog(@"sollpos: %d",sollpos);
            
            float sollx = [[soll[sollpos]objectForKey:@"x"] floatValue]; // fuer diese pos den Wert auf quelle bestimmen
            float quellposU = 0;
            float changexU, changexO = 0; // Pos auf quelle vor und nach sollx
            int quellestartpos = 1;
            int quellesucherfolg = 0;
            for (int quellepos = quellestartpos;quellepos < quelle.count; quellepos++)// Positionen auf quelle vor und nach sollx suchen, Beginn ab 1
            {
               float quellex = [[quelle[quellepos]objectForKey:@"x"] floatValue]; 
               if((quellex > sollx) && (quellesucherfolg == 0) ) // Wert gefunden
               {
                  changexO = quellex;
                  changexU = [[quelle[quellepos-1]objectForKey:@"x"] floatValue];
                  float diffx = changexO - changexU;
                  
                  
                  quellestartpos = quellepos;
                  //NSLog(@"Wert gefunden quellepos bei %d: sollx: %2.6f changexO: %2.6f changexU: %2.6f",quellepos, sollx, changexO, changexU);
                  float changeyO = [[quelle[quellepos]objectForKey:@"y"] floatValue];
                  float changeyU = [[quelle[quellepos-1]objectForKey:@"y"] floatValue];
                  float diffy = changeyO - changeyU;
                  //NSLog(@"diffx: %2.6f diffy: %2.6f",diffx, diffy);
                  float interpolY = changeyU + (diffy)/(diffx)*(sollx - changexU);
                  //NSLog(@"changeyO: %2.6f changeyU: %2.6f  interpolY: %2.6f",changeyO,changeyU,interpolY);
                  
                  NSDictionary* tempdic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:sollx],@"x", [NSNumber numberWithFloat:interpolY],@"y", nil];
                  [changedarray addObject:tempdic];
                  
                  
                  
                  quellesucherfolg = 1;
                  continue;
               }
               
            } // Interpolationswerte finden
            
            
            //    sollstart = sollpos; // naechste loop beginnt hier
         }
         //NSLog(@"OB");
         // letztes El einfuegen
         NSDictionary* lastdic = [NSDictionary dictionaryWithObjectsAndKeys:[[quelle lastObject]objectForKey:@"x"],@"x", [[quelle lastObject]objectForKey:@"y"],@"y", nil];
         [changedarray addObject:lastdic];
      } // if ungleich
      NSLog(@"changedarray:");
      for (int i=0;i<changedarray.count;i++)
      {
 //        fprintf(stderr,"%d \t %2.6f \t %2.6f \n",i,[[[changedarray objectAtIndex:i]objectForKey:@"x"]floatValue], [[[changedarray objectAtIndex:i]objectForKey:@"y"]floatValue]);
      }
      NSLog(@"OC");
      NSLog(@"werteanpassenOberseiteVon end");
      if (changedarraypos == 1) // pos 1 fuer changedarray
      {
         return [NSArray arrayWithObjects: soll, changedarray, nil];
      }
      else if (changedarraypos == 0)
      {
         return [NSArray arrayWithObjects: changedarray,soll, nil];
      }
      
   }// if count == 2
   
  
   return nil;
}
- (NSArray*)anzahlwerteanpassenVon:(NSArray*) syncarray
{
   NSMutableArray* returncarray = [NSMutableArray new];
   if([syncarray count] == 2)
   {
      NSArray* A = [syncarray objectAtIndex:0];
      long mincount = 0;
      NSArray* B = [syncarray objectAtIndex:1];
      long maxcount = 0;
      
      for (int i=0;i<A.count;i++)
      {
         fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[A objectAtIndex:i]objectForKey:@"x"] floatValue],[[[A objectAtIndex:i]objectForKey:@"y"] floatValue]);
      }

      for (int i=0;i<B.count;i++)
      {
         fprintf(stderr, "%d\t%2.6f\t%2.6f\n",i,[[[B objectAtIndex:i]objectForKey:@"x" ] floatValue],[[[B objectAtIndex:i]objectForKey:@"y" ] floatValue]);
      }
      
      
      
      // profil Richtung rechts
      NSArray* soll = [NSArray array]; // zu erreichen
      NSArray* quelle = [NSArray array]; // 
      
      NSString* code = @"x";
      int changedarraypos = -1; // position von changedarray im returnarray
      if(A.count > B.count) // A muss reduziert werden
      {
         code = @"soll:B quelle:A";
         changedarraypos = 0; 
         soll = B;
         maxcount = A.count;
         quelle = A; // wird reduziert
         mincount = B.count;
         
      }
      else // 
      {
         code = @"soll:A quelle:B";
         changedarraypos = 1; 
         soll = A;
         maxcount = B.count;
         quelle = B; // wird reduziert
         mincount = A.count;
      }
      NSLog(@"A count: %d B count: %d \t code: %@ ",A.count, B.count, code );
      
       
      float maxdiff = 0;
      int maxindex = 0;
      int insertindex = 0;
      NSMutableArray* changedarray =  [NSMutableArray arrayWithArray:soll]; // soll mit Interpolationswerten reduziert werden
      
      int missing = (float)maxcount - (int)mincount; // anzahl Einschiebungen
      NSLog(@"missing: %d",missing);
      
      // 
      for (int pos = 0;pos < missing;pos++)
      {
         maxindex = 0; // index am Ende des groessten Intervalls in quelle
         maxdiff = 0; // max Intervall x
         float now = 0;
         float prev = 0;
         // 
         for(int i=1;i<changedarray.count;i++) // index 0 ueberspringen
         {
            now = [[soll[i]objectForKey:@"x"] floatValue];
            prev = [[soll[i-1]objectForKey:@"x"] floatValue];
            
            float diff = fabsf(now - prev);
            //NSLog(@"%d now: %2.4f prev: %2.4f  diff: %2.4f ",i,now, prev, diff);
            if(diff > maxdiff)
            {
               maxdiff = diff;
               maxindex = i;
               //continue;
            }
         }
         
         // Groesstes Intevall in quelle liegt zwischen maxindex-1 und maxindex
         
         // Wert auf changedarray suchen, der nach x von maxindex-1 kommt
         // x-Intervall auf quelle
         float checkx0 = [[soll[maxindex-1]objectForKey:@"x"]floatValue];
         float checkx1 = [[soll[maxindex]objectForKey:@"x"]floatValue];
         NSLog(@"maxindex: %d checkx0: %2.4f checkx1: %2.4f",maxindex, checkx0, checkx1);
         int nextx = 0;
         
         for(int k=0;k<changedarray.count-1;k++) // letztes Element auslassen
         {
             fprintf(stderr,"%d \t%2.6f \t%2.6f\n",k,[[[changedarray objectAtIndex:k]objectForKey:@"x"]floatValue],[[[changedarray objectAtIndex:k]objectForKey:@"y"]floatValue]);
            if ([[[changedarray objectAtIndex:k]objectForKey:@"x"]floatValue] > checkx0) // x liegt ueber checkx0
            {
               // bingo
               nextx = k;
               // next x auf changedarray suchen
               if([[[changedarray objectAtIndex:k+1]objectForKey:@"x"]floatValue] < checkx1)
               {
                  NSLog(@"Punkt %d auf changedarray liegt innerhalb intervall", k);
               }
               
            }
         }
         
         
         // Mittelwert x
         float midx = ([[changedarray[maxindex]objectForKey:@"x"] floatValue] + [[changedarray[maxindex-1]objectForKey:@"x"] floatValue])/2;
         
         // Mittelwert y
         float midy = ([[changedarray[maxindex]objectForKey:@"y"] floatValue]  + [[changedarray[maxindex-1]objectForKey:@"y"] floatValue])/2;
         
         NSMutableDictionary* temp = (NSMutableDictionary*)changedarray[maxindex-1]; // vorhandener Wert am Beginn des grossen Intervalls als Muster
         temp[@"x"] = [NSNumber numberWithFloat: midx]; // x ersetzen mit Interpolation
         temp[@"y"] = [NSNumber numberWithFloat: midy]; // y ersetzen mit Interpolation
         [changedarray insertObject:temp atIndex:maxindex-1 ];
         
         NSLog(@"maxdiff: %2.4f \t maxindex: %d midx: %2.4f midy: %2.4f",maxdiff, maxindex, midx, midy);
       }
      NSLog(@"changedarray  count: %d", [changedarray count]);

      //NSLog(@"changedarray: %lu count: %@", (unsigned long)[changedarray count],changedarray);
      for (int i=0;i<changedarray.count;i++)
      {
         float x = [[[soll objectAtIndex:i]valueForKey:@"x"]floatValue];
         float y = [[[soll objectAtIndex:i]valueForKey:@"y"]floatValue];
         fprintf(stderr,"soll\t");
         fprintf(stderr,"%d\t %2.8f\t %2.8f \t\t",i,x,y);


         x = [[[changedarray objectAtIndex:i]valueForKey:@"x"]floatValue];
         y = [[[changedarray objectAtIndex:i]valueForKey:@"y"]floatValue];
         fprintf(stderr,"changedarray\t");
         fprintf(stderr,"%d\t %2.8f\t %2.8f \t\t",i,x,y);
         
         if (i<quelle.count)
         {
            x = [[[quelle objectAtIndex:i]valueForKey:@"x"]floatValue];
            y = [[[quelle objectAtIndex:i]valueForKey:@"y"]floatValue];
            fprintf(stderr,"quelle\t");
            fprintf(stderr,"%d\t %2.8f\t %2.8f ",i,x,y);

         }
         fprintf(stderr,"\n");
      }
      if (changedarraypos == 1) // pos 1 fuer changedarray
      {
         return [NSArray arrayWithObjects: soll, changedarray, nil];
      }
      else if (changedarraypos == 0)
      {
         return [NSArray arrayWithObjects: changedarray,soll, nil];
      }
      
   }
   
  
   return nil;
}


- (NSArray*)anzahlwertesynchronisierenVon:(NSArray*) syncarray
{
   NSMutableArray* returncarray = [NSMutableArray new];
   if([syncarray count] == 2)
   {
      NSArray* A = [syncarray objectAtIndex:0];
      long mincount = 0;
      NSArray* B = [syncarray objectAtIndex:1];
      long maxcount = 0;
      
      NSArray* soll = [NSArray array]; // zu erreichen
      NSArray* quelle = [NSArray array]; // 
      
      NSString* code = @"x";
      int changedarraypos = -1; // position von changedarray im returnarray
      if(A.count > B.count) // B muss ergaenzt werden
      {
         code = @"soll:A quelle:B";
         changedarraypos = 1; 
         soll = A;
         maxcount = A.count;
         quelle = B; // bekommt Interpolationswerte
         mincount = B.count;
         
      }
      else // 
      {
         code = @"soll:B quelle:A";
         changedarraypos = 0; 
         soll = B;
         maxcount = B.count;
         quelle = A; // bekommt Interpolationswerte
         mincount = A.count;
      }
      NSLog(@"A count: %d B count: %d \t code: %@ ",A.count, B.count, code );
      
      
      float maxdiff = 0;
      int maxindex = 0;
      int insertindex = 0;
      NSMutableArray* changedarray =  [NSMutableArray arrayWithArray:quelle]; // soll mit Interpolationswerten ergaenzt werden
      
      int missing = (float)maxcount - (int)mincount; // anzahl Einschiebungen
      NSLog(@"missing: %d",missing);
      
      for (int pos = 0;pos < missing;pos++)
      {
         maxindex = 0; // index am Ende des groessten Intervalls
         maxdiff = 0; // max Intervall x
         float now = 0;
         float last = 0;
         for(int i=1;i<changedarray.count;i++)
         {
            now = [[changedarray[i]objectForKey:@"x"] floatValue];
            last = [[changedarray[i-1]objectForKey:@"x"] floatValue];
            
            float diff = now - last;
            if(diff > maxdiff)
            {
               maxdiff = diff;
               maxindex = i;
            }
         }
         
         // Groesstes Intevall liegt zwischen maxindex-1 und maxindex
         // Mittelwert x
         float midx = ([[changedarray[maxindex]objectForKey:@"x"] floatValue] + [[changedarray[maxindex-1]objectForKey:@"x"] floatValue])/2;
         
         // Mittelwert y
         float midy = ([[changedarray[maxindex]objectForKey:@"y"] floatValue]  + [[changedarray[maxindex-1]objectForKey:@"y"] floatValue])/2;
         
         NSMutableDictionary* temp = (NSMutableDictionary*)changedarray[maxindex-1]; // vorhandener Wert am Beginn des grossen Intervalls als Muster
         temp[@"x"] = [NSNumber numberWithFloat: midx]; // x ersetzen mit Interpolation
         temp[@"y"] = [NSNumber numberWithFloat: midy]; // y ersetzen mit Interpolation
         [changedarray insertObject:temp atIndex:maxindex-1 ];
         
         NSLog(@"maxdiff: %2.4f \t maxindex: %d midx: %2.4f midy: %2.4f",maxdiff, maxindex, midx, midy);
       }
      NSLog(@"changedarray  count: %d", [changedarray count]);

      //NSLog(@"changedarray: %lu count: %@", (unsigned long)[changedarray count],changedarray);
      for (int i=0;i<changedarray.count;i++)
      {
         float x = [[[soll objectAtIndex:i]valueForKey:@"x"]floatValue];
         float y = [[[soll objectAtIndex:i]valueForKey:@"y"]floatValue];
         fprintf(stderr,"soll\t");
         fprintf(stderr,"%d\t %2.8f\t %2.8f \t\t",i,x,y);


         x = [[[changedarray objectAtIndex:i]valueForKey:@"x"]floatValue];
         y = [[[changedarray objectAtIndex:i]valueForKey:@"y"]floatValue];
         fprintf(stderr,"changedarray\t");
         fprintf(stderr,"%d\t %2.8f\t %2.8f \t\t",i,x,y);
         
         if (i<quelle.count)
         {
            x = [[[quelle objectAtIndex:i]valueForKey:@"x"]floatValue];
            y = [[[quelle objectAtIndex:i]valueForKey:@"y"]floatValue];
            fprintf(stderr,"quelle\t");
            fprintf(stderr,"%d\t %2.8f\t %2.8f ",i,x,y);

         }
         fprintf(stderr,"\n");
      }
      if (changedarraypos == 1) // pos 1 fuer changedarray
      {
         return [NSArray arrayWithObjects: soll, changedarray, nil];
      }
      else if (changedarraypos == 0)
      {
         return [NSArray arrayWithObjects: changedarray,soll, nil];
      }
      
   }
   
  
   return nil;
}


- (NSArray*)abstandcheckenVonarrayA:(NSArray*) profilarrayA arrayB:(NSArray*) profilarrayB teil: (int)teil abstand:(float) minimaldistanz
{
   NSLog(@"abstandcheckenVon start");
   NSMutableArray* rawarray = [NSMutableArray new];
   
    //startwerte setzen

   
   NSDictionary* tempPrevDicA=[profilarrayA objectAtIndex:0];
   NSDictionary* tempPrevDicB=[profilarrayB objectAtIndex:0];
   
   float prevax = [[tempPrevDicA objectForKey:@"x"]floatValue];
   float prevay = [[tempPrevDicA objectForKey:@"y"]floatValue];
   float prevbx = [[tempPrevDicB objectForKey:@"x"]floatValue];
   float prevby = [[tempPrevDicB objectForKey:@"y"]floatValue];
   
    NSMutableDictionary* tempZeilenDic = NSMutableDictionary.new;
    
    [tempZeilenDic setObject:[tempPrevDicA objectForKey:@"x"] forKey:@"ax"];
    [tempZeilenDic setObject:[tempPrevDicA objectForKey:@"y"] forKey:@"ay"];
    [tempZeilenDic setObject:[tempPrevDicB objectForKey:@"y"] forKey:@"bx"];
    [tempZeilenDic setObject:[tempPrevDicB objectForKey:@"y"] forKey:@"by"];
    [tempZeilenDic setObject:[NSNumber numberWithInt:teil] forKey:@"teil"]; // Kennzeichnung Profilseite
    [tempZeilenDic setObject:[NSNumber numberWithInt:0] forKey:@"datensatzok"];
    //NSLog(@"index: %d  distanz OK  distA: %2.2f distB: %2.2f",index,cncindex,distA,distB);
    [rawarray addObject:tempZeilenDic];

    NSLog(@"Werte des ersten Datensatzes: prevax: %2.2f prevay: %2.2f teil: %d",prevax,prevay, teil);

   
   float nowax = 0;
   float noway = 0;
   float nowbx = 0;
   float nowby = 0;
   
   int datenindex = 0; // fortlaufender Zaehler, ohne uebersprungene elemente
   
   // Anfang checken
   
   for (int index=1;index< profilarrayA.count;index++)
   {
      //NSLog(@"profilarray index: %d",index);
      NSDictionary* tempZeilenDicA = [profilarrayA objectAtIndex:index];
      NSDictionary* tempZeilenDicB = [profilarrayB objectAtIndex:index];
      NSMutableDictionary* tempZeilenDic =NSMutableDictionary.new;
      /*
      //if(index < profilarrayA.count-20+1)// Punkte am Anfang
       if(index < 10)// Punkte am Anfang

       {
          //NSLog(@"profilarray index<20: %d",index);
          // Distanz bestimmen
          nowax = [[tempZeilenDicA objectForKey:@"x"]floatValue];
          noway = [[tempZeilenDicA objectForKey:@"y"]floatValue];
          
          nowbx = [[tempZeilenDicB objectForKey:@"x"]floatValue];
          nowby = [[tempZeilenDicB objectForKey:@"y"]floatValue];
          
          // Soll der Datensatz geladen werden?
          int datensatzok = 0;
          
          // Distanzen zum vorherigen Punkt
          float distA = hypot(nowax-prevax,noway-prevay);
          float distB = hypot(nowbx-prevbx,nowby-prevby);
          //NSLog(@"profilarray index: %d distA: %2.2f distB: %2.2f",index ,distA,distB);
          if (((distA > minimaldistanz || distB > minimaldistanz)) ) // Eine der Distanzen ist genügend gross
          {
             datensatzok = 1;
             //NSMutableDictionary* tempZeilenDic =NSMutableDictionary.new;
             [tempZeilenDic setObject:[tempZeilenDicA objectForKey:@"x"] forKey:@"ax"];
             [tempZeilenDic setObject:[tempZeilenDicA objectForKey:@"y"] forKey:@"ay"];
             [tempZeilenDic setObject:[tempZeilenDicB objectForKey:@"x"] forKey:@"bx"];
             [tempZeilenDic setObject:[tempZeilenDicB objectForKey:@"y"] forKey:@"by"];
             [tempZeilenDic setObject:[NSNumber numberWithInt:teil] forKey:@"teil"]; // Kennzeichnung Profilseite
             [tempZeilenDic setObject:[NSNumber numberWithInt:1] forKey:@"datensatzok"];
             //NSLog(@"index: %d  distanz OK  distA: %2.2f distB: %2.2f",index,cncindex,distA,distB);
             [rawarray addObject:tempZeilenDic];
          }
          else
          {
             NSLog(@"abstandchecken index: %d  *** distanz zu kurz. distA: %2.2f distB: %2.2f",index,distA,distB);
             continue;
             
          }
       }
      */
//      else
       {
          [tempZeilenDic setObject:[tempZeilenDicA objectForKey:@"x"] forKey:@"ax"];
          [tempZeilenDic setObject:[tempZeilenDicA objectForKey:@"y"] forKey:@"ay"];
          [tempZeilenDic setObject:[tempZeilenDicB objectForKey:@"x"] forKey:@"bx"];
          [tempZeilenDic setObject:[tempZeilenDicB objectForKey:@"y"] forKey:@"by"];
          [tempZeilenDic setObject:[NSNumber numberWithInt:teil] forKey:@"teil"]; // Kennzeichnung Profilseite
          [tempZeilenDic setObject:[NSNumber numberWithInt:0] forKey:@"datensatzok"];
          //NSLog(@"index: %d  distanz OK  distA: %2.2f distB: %2.2f",index,cncindex,distA,distB);
          [rawarray addObject:tempZeilenDic];
          
       }
      /*
      prevax = nowax;
      prevay = noway;
      prevbx = nowbx;
      prevby = nowby;
      */
      
   } // for
   
   // Ende checken: letzter Datensatz
   /*
   tempPrevDicA=[profilarrayA objectAtIndex:rawarray.count-1];
   tempPrevDicB=[profilarrayB objectAtIndex:rawarray.count-1];
   
   prevax = [[tempPrevDicA objectForKey:@"x"]floatValue];
   prevay = [[tempPrevDicA objectForKey:@"y"]floatValue];
   prevbx = [[tempPrevDicB objectForKey:@"x"]floatValue];
   prevby = [[tempPrevDicB objectForKey:@"y"]floatValue];
   */
   prevax = [[[rawarray objectAtIndex:rawarray.count-1] objectForKey:@"ax"]floatValue];
   prevay = [[[rawarray objectAtIndex:rawarray.count-1] objectForKey:@"ay"]floatValue];
   prevbx = [[[rawarray objectAtIndex:rawarray.count-1] objectForKey:@"bx"]floatValue];
   prevby = [[[rawarray objectAtIndex:rawarray.count-1] objectForKey:@"by"]floatValue];

   
   NSLog(@"Werte des letzten Datensatzes: prevax: %2.2f prevay: %2.2f",prevax,prevay);
   
   nowax = 0;
   noway = 0;
   nowbx = 0;
   nowby = 0;
   
   // Datensaetze markieren
   //for (int index = rawarray.count-2;index > rawarray.count-20;index--)
    // Letzten Datensatz sicher laden
     
     [[rawarray lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"datensatzok"];

   int index = rawarray.count-2;
   //while(index > rawarray.count-20+1)
   while(index > 1)
      
   {
      // Distanz bestimmen
      //NSLog(@"Datensaetze markieren index: %d",index);
      /*
      NSDictionary* tempZeilenDicA = [profilarrayA objectAtIndex:index];
      NSDictionary* tempZeilenDicB = [profilarrayB objectAtIndex:index];
      
      nowax = [[tempZeilenDicA objectForKey:@"x"]floatValue];
      noway = [[tempZeilenDicA objectForKey:@"y"]floatValue];
      
      nowbx = [[tempZeilenDicB objectForKey:@"x"]floatValue];
      nowby = [[tempZeilenDicB objectForKey:@"y"]floatValue];
      */
      
      nowax = [[[rawarray objectAtIndex:index] objectForKey:@"ax"]floatValue];
      noway = [[[rawarray objectAtIndex:index] objectForKey:@"ay"]floatValue];
      nowbx = [[[rawarray objectAtIndex:index] objectForKey:@"bx"]floatValue];
      nowby = [[[rawarray objectAtIndex:index] objectForKey:@"by"]floatValue];

      
      // Soll der Datensatz geladen werden?
      int datensatzok = 0;
      
      // Distanzen zum vorherigen Punkt
      float distA = hypot(nowax-prevax,noway-prevay);
      float distB = hypot(nowbx-prevbx,nowby-prevby);
      //NSLog(@"profilarray index: %d distA: %2.2f distB: %2.2f",index ,distA,distB);
      if (((distA > minimaldistanz && distB > minimaldistanz)) ) // Eine der Distanzen ist genügend gross
      {
        
         //NSLog(@"Datensatz ok index: %d distA: %2.2f distB: %2.2f",index,distA,distB);
         [[rawarray objectAtIndex:index]setObject:[NSNumber numberWithInt:1] forKey:@"datensatzok"];
         [[rawarray objectAtIndex:index]setObject:[NSNumber numberWithFloat:distA] forKey:@"dista"] ;
         prevax = nowax;
         prevay = noway;
         prevbx = nowbx;
         prevby = nowby;
         

      }
      else
      {
         NSLog(@"Datensatz distanz zu kurz index: %d distA: %2.2f distB: %2.2f",index,distA,distB);
         [[rawarray objectAtIndex:index]setObject:[NSNumber numberWithInt:0] forKey:@"datensatzok"] ;
         [[rawarray objectAtIndex:index]setObject:[NSNumber numberWithFloat:distA] forKey:@"dista"] ;
         // next datensatz ueberspringen
         
         
      }
      index -= 1;
      
   }
   for(int index = 0;index < rawarray.count;index++)
   {
      
      //NSLog(@"index: %d datensatzok: %d dista: %2.2f",index,[[[rawarray objectAtIndex:index]objectForKey:@"datensatzok"]intValue],[[[rawarray objectAtIndex:index]objectForKey:@"dista"]floatValue]);
      
   }
   
   // Aufraeumen
   NSMutableArray* returnarray = [NSMutableArray new];
   
   NSMutableArray* returnarray1 = [NSMutableArray new];
   NSMutableArray* returnarray2 = [NSMutableArray new];
   int okcounter = 0;
   for(int index = 0;index < rawarray.count;index++)
   {
   
      //NSLog(@"index: %d %@",index,[[rawarray objectAtIndex:index]description]);
      
      if([[[rawarray objectAtIndex:index]objectForKey:@"datensatzok"]intValue])
      {
         [[rawarray objectAtIndex:index]setObject:[NSNumber numberWithInt:okcounter] forKey:@"index" ];
         
         //NSLog(@"Aufraeumen Datensatz ok index: %d",index);
         //[[rawarray objectAtIndex:index]setObject:[NSNumber numberWithInt:index]forKey:@"index"];
         fprintf(stderr,"%d\t %2.2f \t %2.2f \t %2.2f \t %2.2f \n",
                 index,
                 [[[rawarray objectAtIndex:index]objectForKey:@"ax"]floatValue],
                 [[[rawarray objectAtIndex:index]objectForKey:@"ay"]floatValue],
                 [[[rawarray objectAtIndex:index]objectForKey:@"bx"]floatValue],
                 [[[rawarray objectAtIndex:index]objectForKey:@"by"]floatValue]);
          
         NSMutableDictionary* seiteaDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[rawarray objectAtIndex:index]objectForKey:@"ax"],@"ax",[[rawarray objectAtIndex:index]objectForKey:@"ay"],@"ay", [NSNumber numberWithInt:okcounter],@"index",nil ];
         [returnarray1 addObject:seiteaDic];
         
         NSMutableDictionary* seitebDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[rawarray objectAtIndex:index]objectForKey:@"bx"],@"ax",[[rawarray objectAtIndex:index]objectForKey:@"by"],@"ay", [NSNumber numberWithInt:okcounter],@"index",nil ];

         [returnarray2 addObject:seitebDic];

         
         okcounter++;
         [returnarray addObject:[rawarray objectAtIndex:index]];
      }
      else
      {
         NSLog(@"Aufraeumen Datensatz not ok index: %d",index);
      }
      
   }
   //[returnarray addObject:returnarray1];
   //[returnarray addObject:returnarray2];
   return returnarray;
}

- (NSDictionary*)SplinekoeffizientenVonArray:(NSArray*)dataArray
{
  // NSLog(@"SplinekoeffizientenVonArray l: %d dataArray: %@",[dataArray count],[dataArray description]);
   NSMutableDictionary* splineKoeffDic = [[NSMutableDictionary alloc]initWithCapacity:0];
   unsigned long l=[dataArray count];
   double* a=malloc(l*sizeof(double));
   double* b=malloc(l*sizeof(double));
   double* c=malloc(l*sizeof(double));
   double* d=malloc(l*sizeof(double));
   double* x=malloc(l*sizeof(double));
   double* y=malloc(l*sizeof(double));
   
   double* h=malloc(l*sizeof(double));
   double* e=malloc(l*sizeof(double));
   double* r=malloc(l*sizeof(double));
   double* u=malloc(l*sizeof(double));
   double* kappa=malloc(l*sizeof(double));
   int i;
   for(i=0;i<l;i++)
   {
      x[i] = [[[dataArray objectAtIndex:i] objectForKey:@"x"]floatValue];
      y[i] = [[[dataArray objectAtIndex:i] objectForKey:@"y"]floatValue];
      
   }
   // Differenzen der x-Werte: x(i+1) - x(i)
   for(i=0;i<(l-1);i++)
   {
      NSDictionary* tempZeilenDic = [dataArray objectAtIndex:i];
      //NSLog(@"i: %d tempZeilenDic: %@",i,[tempZeilenDic description]);
      //float temp=[[[dataArray objectAtIndex:i+1] objectForKey:@"x"]floatValue] - [[[dataArray objectAtIndex:i] objectForKey:@"x"]floatValue];
      
      h[i]= [[[dataArray objectAtIndex:i+1] objectForKey:@"x"]floatValue] - [[[dataArray objectAtIndex:i] objectForKey:@"x"]floatValue];
//      NSLog(@"i: %d  h[i]:%f temp: %f",i,h[i],temp);
      //NSLog(@"i: %d  h[i]:%f ",i,h[i]);
     // fprintf(stderr, "h: %f\n", h[i]);
   }
  // NSLog(@"\n\n");
   // Koeff e: 6/h(i) * (y(i+1)-y(i))
   for(i=0;i<(l-1);i++)
   {
      //NSArray* tempZeilenArray = [dataArray objectAtIndex:i];
      e[i]= 6/h[i] * ([[[dataArray objectAtIndex:i+1]objectForKey:@"y"]floatValue] - [[[dataArray objectAtIndex:i]objectForKey:@"y"]floatValue]);
//      fprintf(stderr, "i: %d e: %f\n",i, e[i]);
      //NSLog(@"i: %d  e[i]:%f ",i,e[i]);
   }
   //NSLog(@"\n\n");
   // Koeff u: 2*(h(i]+h[i-1]) - h[i-1]^2/ u[i-1]
   for(i=1;i<l;i++)
   {
      if (i==1)
      {
         u[i] = 2*(h[i] + h[i-1]);
      }
      else
      {
         u[i] = 2*(h[i] + h[i-1]) - h[i-1]*h[i-1]/u[i-1];
      }
     // fprintf(stderr, "i: %d u: %f\n",i, u[i]);
     //NSLog(@"i: %d  u[i]:%f ",i,u[i]);
   }
   //NSLog(@"\n\n");
   // Koeff r: e(i]-e[i-1) - r[i-1] * h[i-1] / u[i-1]
   for(i=1;i<l-1;i++)
   {
      if (i==1)
      {
         r[i] = e[i] - e[i-1];
      }
      else
      {
         r[i] = (e[i] - e[i-1]) - r[i-1] * h[i-1] / u[i-1] ;
      }
   //NSLog(@"i: %d  r[i]:%f ",i,r[i]);
   //fprintf(stderr, "i: %d r: %f\n",i, r[i]);

   }
   //NSLog(@"\n\n");
   // Koeff kappa: e(i]-e[i-1) - r[i-1] * h[i-1] / u[i-1] rueckwaerts einsetzen
   
   for(i=l-1;i>=0;i--)
   {
      if (i==0 || i==l-1) // Randwerte sind 0
      {
         kappa[i] = 0;
      }
      else
      {
         kappa[i] = (r[i] - h[i]*kappa[i+1])/u[i];
      }
 //     NSLog(@"i: %d  kappa[i]:%f ",i,kappa[i]);
 //     fprintf(stderr, "i: %d kappa: %f\n",i, kappa[i]);
   }
   
   NSLog(@"\n\n");
//   fprintf(stderr, "i:\tx:\ty:\tkappa:\ta:\tb:\tc:\td:\t\n");
   for(i=0;i<l;i++)
   {
     if (i<l-1)
     {
      a[i] = (kappa[i+1]-kappa[i])/(6*h[i]);
     }
      else
      {
         a[i]=0;
      }
      b[i] = kappa[i]/2;
      if (i<l-1)
      {
      c[i] = (y[i+1]-y[i])/h[i] - h[i]/6*(2*kappa[i] + kappa[i+1]);
      }
      else
      {
         c[i]=0;
      }
      d[i] = y[i];
      
  //    fprintf(stderr, "%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n",i, x[i], y[i], kappa[i], a[i], b[i], c[i], d[i]);
   } 
   
   free(a);
    free(b);
    free(c);
    free(d);
    free(x);
    free(y);
   free(h);
   free(e);
   free(r);
   free(u);
   free(kappa);
   
   return splineKoeffDic;
}

- (NSArray*)lagrangeinterpolation:(NSArray*)profilArray minimalabstand: (double)mindiff
{
   printf("lagrangeinterpolation start\n");
   NSMutableArray* lagrangeArray=NSMutableArray.new;
   int l = profilArray.count;
   int lagrangeindex = 0;
   int von = 0;
   int bereich = 4;
   int startindex = 0;
   double koeff[bereich];
   
   int okindex = 0; // index des zu lesenden next elements
   int nextindex = 0; // 
   
   
   for(int index=0;index < (l-1); index++)
   {
      NSDictionary* zeilendic = [profilArray objectAtIndex:index];
      double nowx = [[[profilArray objectAtIndex:index]objectForKey:@"x"]doubleValue];
      double nextx = [[[profilArray objectAtIndex:index+1]objectForKey:@"x"]doubleValue];
      

      double nowy = [[[profilArray objectAtIndex:index]objectForKey:@"y"]doubleValue];
      double nexty = [[[profilArray objectAtIndex:index+1]objectForKey:@"y"]doubleValue];
      
      double diff = nextx - nowx;
      

      double polykoeffarray[bereich];
      
      NSDictionary* nextzeilendic = [profilArray objectAtIndex:index+1];
      
      //printf("\n%d diff: %lf\n",index,diff);
      if(diff < mindiff)
      {
         
         if(diff > mindiff/4*3)
         {
            printf("diff zu klein index: %d diff: %lf nowx: %lf > einsetzen\n",index,diff, nowx);
            [lagrangeArray addObject:[profilArray objectAtIndex:index]]; // element einsetzen
            
         }
         else
         {
            printf("diff zu klein index: %d diff: %lf > Ueberspringen\n",index,diff);
            
         }
      }
      else
      {
         [lagrangeArray addObject:[profilArray objectAtIndex:index]]; // erstes Element im In tervall einsetzen
         if(index>1) // mindestens ein Intervall vorher, 4 werte erforderlich
         {
            
            
            double prevx = [[[profilArray objectAtIndex:index-1]objectForKey:@"x"]doubleValue];
            double prevy = [[[profilArray objectAtIndex:index-1]objectForKey:@"y"]doubleValue];
            
            if(index < (l-2))
            {
               double overnextx = [[[profilArray objectAtIndex:index+2]objectForKey:@"x"]doubleValue];
               double overnexty = [[[profilArray objectAtIndex:index+2]objectForKey:@"y"]doubleValue];
               double px[] = {prevx,nowx, nextx, overnextx};
               double py[] = {prevy,nowy, nexty, overnexty};
               
               double wertx = nowx + (nextx - nowx)/2;
               //printf("index: %d prevx: %lf nowx: %lf nextx: %lf overnextx: %lf\t",index,prevx,nowx,nextx, overnextx);
               double interpolwerty = lagrangewert(px, py, von, bereich,l,  wertx);
   //            printf("index: %d  prevx: %lf nowx: %lf nextx: %lf overnextx: %lf \tinterpolwerty: %lf\n",index,prevx,nowx,nextx, overnextx,interpolwerty);
               
               NSDictionary* interpoldic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:wertx],@"x",[NSNumber numberWithDouble:interpolwerty],@"y",[NSNumber numberWithInt:2],@"data",nil];
               [lagrangeArray addObject:interpoldic];
            }
            else
            {
               
            }
            
         }
      }
      
      
   }// for index
   
   [lagrangeArray addObject:[profilArray lastObject]];
   
   printf("lagrangeinterpolation end\n");
   
   return lagrangeArray;
}


- (NSArray*)wrenchProfil:(NSArray*)profilArray mitWrench:(float)wrench
{
   NSMutableArray* wrenchArray=[[NSMutableArray alloc]initWithCapacity:0];
   int i=0;
   /*
    x2 = x1 * cos(phi) - y1 * sin(phi)
    y2 = x1 * sin(phi) + y1 * cos(phi)
    */
   // winkel in rad:
   float phi=wrench/180*M_PI;
   // offset x infolge wrench:
   float offsetx= 1-cosf(phi);
   // offset y infolge wrench:
   float offsety= sinf(phi);
   
   //NSLog(@"offsetx: %2.5f offsety: %2.5f count: %d",offsetx,offsety,[profilArray count]);
   // NSLog(@"profilArray: %@",[profilArray description]);
   for(i=0;i<[profilArray count];i++)
   {
      
      float x1=[[[profilArray objectAtIndex:i]objectForKey:@"x"]floatValue];
      float y1=[[[profilArray objectAtIndex:i]objectForKey:@"y"]floatValue];
      float x2=x1*cosf(phi)-y1*sinf(phi);
      float y2=x1*sinf(phi)+y1*cosf(phi);
      y2 -= offsety;
      [wrenchArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x2],@"x",[NSNumber numberWithFloat:y2],@"y", nil]];
      
   }
   
   //NSLog(@"wrenchArray: %@",[wrenchArray description]);
   return wrenchArray;
}

- (NSMutableArray*)wrenchProfilschnittlinie:(NSArray*)linienArray mitWrench:(float)wrench
{
   NSMutableArray* wrenchArray=[[NSMutableArray alloc]initWithCapacity:0];
   int i=0;
   /*
    x2 = x1 * cos(phi) - y1 * sin(phi)
    y2 = x1 * sin(phi) + y1 * cos(phi)
    */
   // winkel in rad:
   float phi=wrench/180*M_PI;
   // offset x infolge wrench:
   float offsetx= 1-cosf(phi);
   // offset y infolge wrench:
   float offsety= sinf(phi);
   
   //NSLog(@"offsetx: %2.5f offsety: %2.5f count: %d",offsetx,offsety,[profilArray count]);
   //NSLog(@"linienArray: %@",[linienArray description]);
//   NSLog(@"linienArray: %@",[linienArray valueForKey:@"teil"]);
 
   // anfangspunkt und Endpunkt der Profillinie feststellen. Einlauf: 10. Auslauf: 40
   int profilanfangindex=0;
   int profilendeindex=0;
   int pos=10; // Auslauf oder Einlauf erkennen
   
   // Werte ohne Ein- und Auslauf
   float x0=[[[linienArray objectAtIndex:0]objectForKey:@"bx"]floatValue];
   float y0=[[[linienArray objectAtIndex:[linienArray count]-1]objectForKey:@"by"]floatValue];

   for(i=0;i<[linienArray count];i++)
   {
      
      if ([[[linienArray objectAtIndex:i]objectForKey:@"teil"]intValue] > pos) // Einlauf ist 10
      {
         if (profilanfangindex == 0) // noch nicht gesetzt
         {
         profilanfangindex = i; // Anfang gefunden
         pos=30;
         }
         else if (profilendeindex == 0)// Ende gefunden
         {
            profilendeindex = i; // Anfang gefunden
            pos=50;
           
         }
         
      }
      
   }
   if (pos>10)
   {
      if (profilendeindex)
      {
         profilendeindex -=1;
      }
   //NSLog(@"profilanfangindex: %d profilendeindex: %d",profilanfangindex,profilendeindex);
   x0=[[[linienArray objectAtIndex:profilendeindex]objectForKey:@"bx"]floatValue];
   y0=[[[linienArray objectAtIndex:profilendeindex]objectForKey:@"by"]floatValue];
   }
      //NSLog(@"x0: %2.2f y0: %2.2f",x0,y0);

   //Koordinaten drehen
   for(i=0;i<[linienArray count];i++)
   {
   
      float x1=[[[linienArray objectAtIndex:i]objectForKey:@"bx"]floatValue];
      float y1=[[[linienArray objectAtIndex:i]objectForKey:@"by"]floatValue];
      float x2=(x1-x0)*cosf(phi)-(y1-y0)*sinf(phi) +x0;
      float y2=(x1-x0)*sinf(phi)+(y1-y0)*cosf(phi) +y0;
      
 //     y2 -= offsety;
      
//      NSMutableDictionary* tempDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
      NSMutableDictionary* tempZeilenDic=[[NSMutableDictionary alloc]initWithDictionary:[linienArray objectAtIndex:i]];
      [tempZeilenDic setObject:[NSNumber numberWithFloat:x2] forKey:@"bx"];
      [tempZeilenDic setObject:[NSNumber numberWithFloat:y2] forKey:@"by"];
      [wrenchArray addObject: tempZeilenDic];
     // [wrenchArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x2],@"x",[NSNumber numberWithFloat:y2],@"y", nil]];
      
   }
   
   //NSLog(@"wrenchArray: %@",[wrenchArray description]);
   return wrenchArray;
}

- (NSArray*)readFigur
{
	NSMutableArray* FigurArray=[[NSMutableArray alloc]initWithCapacity:0];
	/*
    NSOpenPanel* ProfilOpenPanel=[[NSOpenPanel alloc ]init];
	[ProfilOpenPanel setCanChooseFiles:YES];
	[ProfilOpenPanel setCanChooseDirectories:NO];
	[ProfilOpenPanel setAllowsMultipleSelection:NO];
   [ProfilOpenPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt",NULL]];
   */
   NSLog(@"Utils readFigur start");
   NSOpenPanel *ProfilOpenPanel = [NSOpenPanel openPanel];
   NSLog(@"readFigur ProfilOpenPanel: %@",[ProfilOpenPanel description]);
   // Configure your panel the way you want it
   [ProfilOpenPanel setCanChooseFiles:YES];
   [ProfilOpenPanel setCanChooseDirectories:NO];
   [ProfilOpenPanel setAllowsMultipleSelection:NO];
   [ProfilOpenPanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
   NSLog(@"readFigur A");
   /*
   [ProfilOpenPanel beginWithCompletionHandler:^(NSInteger result)
   {
      NSLog(@"readFigur B");
      if (result == NSFileHandlingPanelOKButton)
      {
         NSLog(@"readFigur C");
         for (NSURL *fileURL in [ProfilOpenPanel URLs])
         {
            NSLog(@"readFigur C");
            NSLog(@"URLs: %@",[[ProfilOpenPanel URLs] description]);
            // Do what you want with fileURL
            // ...
         }
      }
      NSLog(@"readFigur D");
      [ProfilOpenPanel release];
      
   }];
    */
	/*
    [OpenPanel beginSheetForDirectory:NSHomeDirectory() file:nil 
	 //types:nil 
    modalForWindow:[self window] 
    modalDelegate:self 
    didEndSelector:@selector(ProfilPfadAktion:returnCode:contextInfo:)
    contextInfo:nil];
    */
   
   if (ProfilOpenPanel)
   {
      int antwort=[ProfilOpenPanel runModal];
      NSLog(@"ProfilOpenPanel antwort: %d",antwort);
   }
   else{
      NSLog(@"kein Panel");
      return FigurArray;
   }
    
//    return;
	NSURL* FigurPfad=[ProfilOpenPanel URL];
    
	NSLog(@"readFigur: URL: %@",FigurPfad);
	NSError* err=0;
	NSString* FigurString=[NSString stringWithContentsOfURL:FigurPfad encoding:NSUTF8StringEncoding error:&err]; // String des Speicherpfads
	
   //NSLog(@"Utils openProfil FigurString: \n%@",FigurString);
	
   NSArray* tempArray = [NSArray array];
   
	//NSArray* tempArray=[FigurString componentsSeparatedByString:@"\r"];
   
   //NSArray* temp_n_Array=[FigurString componentsSeparatedByString:@"\n"];
   //NSLog(@"Utils openProfil anz: %d temp_n_Array: %@",[temp_n_Array count],temp_n_Array);
   if ([[FigurString componentsSeparatedByString:@"\n"]count] == 1) // separator \r
   {
   tempArray=[FigurString componentsSeparatedByString:@"\r"];   
   
   }
   else 
   {
     tempArray=[FigurString componentsSeparatedByString:@"\n"]; 
   }
   
   //NSArray* temp_r_Array=[FigurString componentsSeparatedByString:@"\r"];
	
   
  // NSLog(@"Utils openProfil anz: %d temp_r_Array: \n%@",[temp_r_Array count],temp_r_Array);
   
   NSString* firstString = [tempArray objectAtIndex:0];
	//NSLog(@"firstString Titel: %@ ",firstString);
	if (([[firstString componentsSeparatedByString:@"\t"]count]==1)) // Titel
	{
      NSLog(@"Titel gefunden: %@ ",firstString);   
		NSRange titelRange;
      
		titelRange.location = 1;
		titelRange.length = [tempArray count]-1;
      
		tempArray = [tempArray subarrayWithRange:titelRange];
      
	}
	//NSLog(@"Utils openFigur tempArray nach Titel: \n%@",[tempArray description]);
	//NSLog(@"Utils openFigur tempArray count: %d",[tempArray count]);
	int i=0;
	
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	[numberFormatter setMaximumFractionDigits:4];
	[numberFormatter setFormat:@"##0.0000"];
   
	for (i=0;i<[tempArray count];i++)
	{
		NSString* tempZeilenString=[tempArray objectAtIndex:i];
		//NSLog(@"Utils tempZeilenString l: %d",[tempZeilenString length]);
		if ((tempZeilenString==NULL)|| ([tempZeilenString length]<=1))
		{
			continue;
		}
		//NSLog(@"char 0: %d",[tempZeilenString characterAtIndex:0]);
		
      if ([tempZeilenString characterAtIndex:0]==10)
		{
         NSLog(@"char 0 weg");
         tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		
      //leerschlag weg
		while ([tempZeilenString characterAtIndex:0]==' ')
		{
         tempZeilenString=[tempZeilenString substringFromIndex:1];
		}
		//NSLog(@"i: %d tempZeilenString: %@",i,tempZeilenString);
		//NSLog(@"LeerschlagRange start loc: %d l: %d",LeerschlagRange.location, LeerschlagRange.length);
		
		NSArray* tempZeilenArray=[tempZeilenString componentsSeparatedByString:@"\t"];
		if ([tempZeilenArray count])
      {
      // object 0 ist index
      float wertx=[[tempZeilenArray objectAtIndex:1]floatValue];//*100;
		float werty=[[tempZeilenArray objectAtIndex:2]floatValue];//*100;
		NSString*tempX=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:wertx]]];
		NSString*tempY=[NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:werty]]];
		//NSLog(@"tempX: %@",tempX);
		//NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:wertx], @"x",
		//[NSNumber numberWithFloat:werty], @"y",NULL];
         NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i],@"index",tempX, @"x",tempY, @"y",NULL];
		[FigurArray addObject:tempDic];
      }
		//[ProfilArray insertObject:tempDic atIndex:0];
	}
	
	//NSLog(@"Utils openProfil FigurArray: \n%@",[FigurArray description]);
	return FigurArray;
}



- (IBAction)ok:(id)sender
{
NSLog(@"ok");
}
@end
