//
//  Utils.h
//  USBInterface
//
//  Created by Sysadmin on 09.03.07.
//  Copyright 2007 Ruedi Heimlicher. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface rUtils : NSObject {

}
- (void) logRect:(NSRect)r;
- (NSDictionary*)ProfilDatenAnPfad:(NSString*)profilpfad;
- (NSDictionary*)floatProfilDatenAnPfad:(NSString*)profilpfad;
- (NSArray*)readProfil:(NSString*)profilname;
- (NSDictionary*)readProfilMitName;
- (NSArray*)anzahlPunktereduzierenVon:(NSArray*) bigarray;
- (NSArray*)anzahlwertesynchronisierenVon:(NSArray*) syncarray;
- (NSArray*)abstandcheckenVonarrayA:(NSArray*) profilarrayA arrayB:(NSArray*) profilarrayB teil: (int)teil abstand:(float) minimaldistanz;
- (NSArray*)anzahlwerteanpassenVon:(NSArray*) syncarray;
- (NSArray*)werteanpassenUnterseiteVon:(NSArray*) syncarray;
- (NSArray*)werteanpassenOberseiteVon:(NSArray*) syncarray;
- (NSDictionary*)SplinekoeffizientenVonArray:(NSArray*)dataArray;
- (NSArray*)lagrangeinterpolation:(NSArray*)profilArray minimalabstand: (double)mindiff;

- (NSArray*)spiegelnProfilVertikal:(NSArray*)profilArray;
- (NSArray*)wrenchProfil:(NSArray*)profilArray mitWrench:(float)wrench;
- (NSMutableArray*)wrenchProfilschnittlinie:(NSArray*)profilArray mitWrench:(float)wrench;
- (NSArray*)readFigur;
@end
