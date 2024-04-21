//
//  rCNCViewController.swift
//  CNC_Interface
//
//  Created by Ruedi Heimlicher on 27.02.2021.
//  Copyright © 2021 Ruedi Heimlicher. All rights reserved.
//

import Foundation
import Cocoa


@objc class rCNCViewController:rViewController
{
   // von IOWarriorWindowController
   
   @IBOutlet weak var steps_Feld: NSTextField!
   @IBOutlet weak var micro_Feld: NSTextField!
    var mausistdown:Int = 0
    
   var Stepperposition:Int = 0
   
   var halt = 0
   var home = 0

   var pwm = 0
   
   var HomeAnschlagSet = IndexSet()
    // end IOWarriorWindowController

   var usb_schnittdatenarray:[[UInt8]] = [[]]
   
   var schnittdatenstring:String = ""
   //var readTimer:Timer
   //var readtimer : Timer? = nil
   
   //var AVR = rAVRview()
   
   var Hotwire = rHotwireViewController()
   
   var steps = 0
   var micro = 0
   
   var Einstellungen = rEinstellungen()
   
   override var acceptsFirstResponder : Bool {
          return true
   }
   override  func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(beendenAktion), name:NSNotification.Name(rawValue: "beenden"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(usbsendAktion), name:NSNotification.Name(rawValue: "usbsend"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "usbschnittdaten"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(usbschnittdatenAktion), name:NSNotification.Name(rawValue: "usbschnittdaten"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:NSNotification.Name(rawValue: "newdata"),object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(contDataAktion(_:)),name:NSNotification.Name(rawValue: "contdata"),object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(usbattachAktion(_:)),name:NSNotification.Name(rawValue: "usb_attach"),object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(slaveresetAktion), name:NSNotification.Name(rawValue: "slavereset"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stepsAktion), name:NSNotification.Name(rawValue: "steps"), object: nil)
        //      NotificationCenter.default.addObserver(self, selector: #selector(microAktion), name:NSNotification.Name(rawValue: "micro"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stoptimerAktion), name:NSNotification.Name(rawValue: "stoptimer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(haltAktion), name:NSNotification.Name(rawValue: "halt"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DCAktion), name:NSNotification.Name(rawValue: "dc_pwm"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(microAktion), name:NSNotification.Name(rawValue: "micro"), object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(stepsAktion), name:NSNotification.Name(rawValue: "motorsteps"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsAktion), name:NSNotification.Name(rawValue: "settings"), object: nil)

         
  
  
        
    }
   
 
   override func keyDown(with theEvent: NSEvent)
   {
      //self.window.makeFirstResponder(AVR?.Profilfeld)
    //  super.keyDown(with: theEvent)
      Swift.print( "CNCView Key Pressed" )
     Swift.print(theEvent.keyCode)
      // Apple Mouse, keyboard and Trackpad
      let optionKeyPressed = theEvent.modifierFlags.contains(.option)
      var arrowstep:Int32 = 100
      
      if optionKeyPressed 
      {
          Swift.print("optionKeyPressed")
         arrowstep = 10
      }
      
      switch (theEvent.keyCode)
      {
         case 123:
            print("left arrowstep: \(arrowstep)")
 //        AVR?.ManRichtung(3, pfeilstep: arrowstep) // left
            break
         case 124:
            print("right arrowstep: \(arrowstep)")
 //            AVR?.ManRichtung(1, pfeilstep: arrowstep) // right
             break
         case 125:
            print("down arrowstep: \(arrowstep)")
  //           AVR?.ManRichtung(4, pfeilstep: arrowstep) // down
             break
         case 126:
            print("up arrowstep: \(arrowstep)")
 //            AVR?.ManRichtung(2, pfeilstep: arrowstep) // up
             break
         
         default:
            
            //print("default")
            return;
         //super.keyDown(with: theEvent)
      }// switch keycode
   
   }
   
   
   
/*
   - (void)keyDown:(NSEvent*)derEvent
   {
      //NSLog(@"keyDown: %@",[derEvent description]);
      NSMutableDictionary* NotificationDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
      [NotificationDic setObject:[NSNumber  numberWithInt:[derEvent keyCode]]forKey:@"pfeiltaste"];
      /*
      [NotificationDic setObject:[NSNumber  numberWithInt:Klickpunkt]forKey:@"klickpunkt"];
      [NotificationDic setObject:[NSNumber  numberWithInt:Klickseite]forKey:@"klickseite"];
      [NotificationDic setObject:[NSNumber numberWithInt:GraphOffset] forKey:@"graphoffset"];
      */
      
      NSLog(@"WC keyDown: %d",[derEvent keyCode]);
      
      switch ([derEvent keyCode]) 
      {
         case 123:
            NSLog(@"links");
            
            break;
            
         case 124:
            NSLog(@"rechts");
            break;
            
         case 125:
            NSLog(@"down");
            break;
            
         case 126:
            NSLog(@"up");
            break;
            
            
            
         default:
            break;
      }
      
      NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
      [nc postNotificationName:@"pfeiltaste" object:self userInfo:NotificationDic];
      
   }
 
 */
   
   @objc func usbattachAktion(_ note:Notification) 
   {
      let info = note.userInfo
      let status = info?["attach"] as! Int
      print("ViewController usbattachAktion status: \(status)");
      
      if (status == USBREMOVED)
      {
   //      USB_OK_Feld.image = notokimage
         //USBKontrolle.stringValue="USB OFF"
         print("CNCViewController usbattachAktion USBREMOVED ")
      }
     else if (status == USBATTACHED)
      {
    //     USB_OK_Feld.image = okimage
        // [USBKontrolle setStringValue:@"USB ON"];
         
         print("CNCViewController usbattachAktion USBATTACHED")
      }
      
      
   }
   
    @objc func settingsAktion(_ notification:Notification)
    {
       print("settingsAktion: \(notification)")
 
    }

   @objc func stepsAktion(_ notification:Notification)
   {
      print("stepsAktion: \(notification)")
      steps = notification.userInfo?["motorsteps"] as! Int
      print("stepsAktion steps: \(steps)")
      steps_Feld.integerValue = steps
   }

   @objc func microAktion(_ notification:Notification) 
   {
      print("microAktion: \(notification)")
      micro = notification.userInfo?["micro"] as! Int
      print("Aktion micro: \(micro)")
      micro_Feld.integerValue = micro
   }

   @objc func stoptimerAktion(_ notification:Notification) 
    {
       print("stoptimerAktion: \(notification)")
       teensy.stop_timer()
       
    
    }

   @objc func DCAktion(_ notification:Notification) 
    {
       usb_schnittdatenarray.removeAll()
       //print("DCAktion: \(notification)")
       let info = notification.userInfo
       guard let pwm = notification.userInfo?["pwm"] else 
       {
          print("DCAktion: kein pwm")
          return
       }
       print("DCAktion  pwm: \(pwm)")
       Stepperposition = 0;
       var wertarray = [UInt8](repeating: 0, count: Int(BufferSize()))  
       
       wertarray[16] = 0xE2
       wertarray[24] = 0xE2
       wertarray[18]=0; // indexh, indexl ergibt abschnittnummer
       wertarray[20]=pwm as! UInt8; // pwm
       
       usb_schnittdatenarray.append(wertarray)
       writeCNCAbschnitt()
       teensy.clear_data()

    }
   
   
   @objc func usbsendAktion(_ notification:Notification) 
    {
       print("usbsendAktion: \(notification)")
       
    
    }
    
    override func windowWillClose(_ aNotification: Notification) {
        print("windowWillClose cnc")
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"beenden"),
                object: nil,
                userInfo: nil)
        
     }
   
   @objc func haltAktion(_ notification:Notification) 
   {
      print("haltAktion ")
      usb_schnittdatenarray.removeAll()
      let info = notification.userInfo
      print("haltAktion info: \(info)")
      var wertarray = [UInt8](repeating: 0, count: Int(BufferSize()))  
      
      wertarray[16] = 0xE0
      wertarray[18]=0; // indexh, indexl ergibt abschnittnummer
      wertarray[20]=0; // pwm
      
      usb_schnittdatenarray.append(wertarray)
      writeCNCAbschnitt()
      teensy.clear_data()
   }

   
   @objc func slaveresetAktion(_ notification:Notification) 
   {
      print("slaveresetAktion")
      
      teensy.clear_data()
      let senderfolg = teensy.send_USB()
      print("slaveresetAktion senderfolg: \(senderfolg)")
   }

 /*
   @objc func AVR_steps()->Int32
   {
      guard let avrsteps:Int32 = AVR?.motorsteps()  else {return 0}
      return avrsteps
   }
*/
    
     @objc func usbschnittdatenAktion(_ notification:Notification) 
   {
      // N
      /*
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
       
       zoomfaktor  22
       steps 25
       micro 26
       
       */
      
      Stepperposition = 0
      //print("cncviewcontroller usbschnittdatenAktion")
      
       
        
   //     guard let steps:Int32 = AVR?.motorsteps()  else {return}
        
      //print("cncviewcontroller usbschnittdatenAktion steps: \(steps)")
      usb_schnittdatenarray.removeAll()
      
      let info = notification.userInfo
   //   print("info: \(info)")
      //    let usb_pwm =  info?["pwm"] as! UInt8
      //    let usb_delayok =  info?["delayok"] as! UInt8
     
      guard let usb_home = info?["home"] as? Int else {
         print("Basis usbstatusAktion: kein home\n")
         return
      }
         
               
               
 
               
   //   let usb_home =  info?["home"] as! UInt8
      
      if usb_home == 1
      {
         //print("cncviewcontroller usbschnittdatenAktion usb_home: \(usb_home)")
         Stepperposition = 0
         
      }
      //    let usb_art =  info?["art"] as! UInt8
      //    let usb_cncposition =  info?["cncposition"]
      
      //print("usb_pwm: \(usb_pwm) usb_delayok: \(usb_delayok) usb_home: \(usb_home) usb_art: \(usb_art) usb_cncposition: \(usb_cncposition) ")
      //        let zeilenzahlarray = info?["schnittdatenarray"] as! [UInt8]
      guard   let zeilenzahlarray = info?["schnittdatenarray"] as?[[UInt8]] else {return}
      
      //HomeAnschlagSet.removeAll()
      
      var zeilenindex = 0
      for zeile in   zeilenzahlarray
      {
         var wertarray = [UInt8]()
         var elementindex = 0
         for el in zeile
         {
            guard UInt8(el) != nil else { return  }
            wertarray.append(el)
            elementindex += 1
         }
         for anz in  elementindex..<Int(BufferSize())
         {
            wertarray.append(0)
            
         }
         wertarray[25] = UInt8(steps)
         wertarray[26] = UInt8(micro)
         
         /*
          print("usbschnittdatenAktion usb_schnittdatenarray 0-48");
         var zeile:Int=0
         for i in 0..<48
         {
            print("\(i)\t\(wertarray[i])")
            zeile += 1
         }
          */
         usb_schnittdatenarray.append(wertarray)
   
      }
      
      
      if (globalusbstatus == 0)
      {
         let warnung = NSAlert.init()
         
         warnung.informativeText = "USB_SchnittdatenAktion: USB ist noch nicht eingesteckt."
         warnung.messageText = "CNC Schnitt starten"
         warnung.addButton(withTitle: "Einstecken und einschalten")
         warnung.addButton(withTitle: "Zurück")
         
         var openerfolg = 0
         let devicereturn = warnung.runModal()
         switch (devicereturn)
         {
         case NSApplication.ModalResponse.alertFirstButtonReturn: // Einschalten
            let device = teensyboardarray[boardindex]
            openerfolg = Int(teensy.USBOpen(code: device, board: boardindex))
            break
            
         case NSApplication.ModalResponse.alertSecondButtonReturn:
            return
            break
         case NSApplication.ModalResponse.alertThirdButtonReturn:
            return
            break
         default:
            return
            break
         }
      }
      
      var timerdic:[String:Any] = [String:Any]()
      timerdic["home"] = usb_home
      
      if (teensy.read_OK.boolValue == false)
      {
         print("teensy.read_OK ist false")
         teensy.start_read_USB(true, dic:timerdic)
      }
      else
      {
         print("teensy.read_OK ist true")
      }
      
      writeCNCAbschnitt()
     }

    @objc func writeCNCAbschnitt()
   {
    print("writeCNCAbschnitt usb_schnittdatenarray: \(usb_schnittdatenarray)")
      let count = usb_schnittdatenarray.count
      //print("writeCNCAbschnitt  count: \(count) Stepperposition: \t",Stepperposition)
      
      if(Stepperposition < count)
      {
         print("schnittdatenarray:\t",usb_schnittdatenarray[Stepperposition])
      }
       print("\n")
      //print("writeCNCAbschnitt code: \(usb_schnittdatenarray[0][16]) Stepperposition: \(Stepperposition) count: \(count) ")
      
      if Stepperposition < count
      {
         let motorstatus = usb_schnittdatenarray[Stepperposition][21]
         //print("motorstatus: \(motorstatus)")
      }
 
      
      if Stepperposition == 0
      {
         schnittdatenstring = ""
        // print("writeCNCAbschnitt 19")
         
      }
      teensy.write_byteArray.removeAll()
      
      if Stepperposition < usb_schnittdatenarray.count
      {
         //print("Stepperposition < usb_schnittdatenarray.count")
         if halt > 0
         {
            /*
            if readtimer?.isValid ?? false 
            {
               print("writeCNCAbschnitt HALT readTimer inval")
               readtimer?.invalidate() 
            }
            */
         }
         else
         {
            let aktuellezeile:[UInt8] = usb_schnittdatenarray[Stepperposition]
            //print("aktuellezeile: \(aktuellezeile) 25: \(aktuellezeile[25])")
            let writecode = aktuellezeile[16]
            var string:String = ""
            var index=0
            //print("aktuellezeile:")
            for wert in aktuellezeile
            {
               teensy.write_byteArray.append(wert)
               if index < 24
               {
                  string.append(String(wert))
                  string.append("\t")
               }
               index += 1
            }
            //print("\(string) code: \(aktuellezeile[16]) pos: \(aktuellezeile[17]) index: \(aktuellezeile[19])");
            schnittdatenstring.append(string)
            schnittdatenstring.append("\n")
            
            //print("write_byteArray: \(teensy.write_byteArray)")
            if (globalusbstatus > 0)
            {
               let senderfolg = teensy.send_USB()
               print("writeCNCAbschnitt senderfolg: \(senderfolg)")
            }
            // print("Stepperposition: \(Stepperposition) \n\(schnittdatenstring)");
            var ausschlussindex:[UInt8] = [0xE2]
            if !(ausschlussindex.contains(writecode))
            {
               
               Stepperposition += 1
            }
            
         }// ! halt
      }
      else
      {
         print("writeCNCAbschnitt Fertig ")
     //    teensy.stop_read_USB()
         return
         
      }
      
      //print("writeCNCAbschnitt write_byteArray: \(teensy.write_byteArray)")
   }
   
  
   @objc override func newDataAktion(_ notification:Notification)  // entspricht readUSB
   {
      // Reaktion auf eingehende USB-Daten
      var lastData = teensy.getlastDataRead()
      let lastDataArray = [UInt8](lastData)
      //print("newDataAktion notification: \n\(notification)\n lastData:\n \(lastData)")       
 //     print("newDataAktion start")
/*
      var ii = 0
 //    while ii < 10
      {
 //        print("ii: \(ii)  wert: \(lastData[ii])\t")
         ii = ii+1
      }
 */     
      //let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
      //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
      let info = notification.userInfo
      
      //let data = "foo".data(using: .utf8)!      
      //print("info: \(String(describing: info))")
      //print("new Data")
      //let data = notification.userInfo?["data"]
      //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
      
      
      //print("lastDataRead: \(lastDataRead)   ")
      var i = 0
      while i < 10
      {
         //print("i: \(i)  wert: \(lastDataRead[i])\t")
         i = i+1
      }
      
      if let d = info!["contdata"] // Data vorhanden
      {
//         print("newDataAktion if let d ok")
         var usbdata = info!["data"] as! [UInt8]
         
         //      let stringFromByteArray = String(data: Data(bytes: usbdata), encoding: .utf8)         
         
         //      print("usbdata: \(usbdata)\n")
         
         //if  usbdata = info!["data"] as! [String] // Data vornanden
         if  usbdata.count > 0 // Data vorhanden
         {
            //print("usbdata: \(usbdata)\n") // d: [0, 9, 56, 0, 0,... 
            var NotificationDic = [String:Int]()
            
            let abschnittfertig:UInt8 =   usbdata[0] // code vom teensy
            //print("abschnittfertig wert: \(abschnittfertig)")
            // https://useyourloaf.com/blog/swift-string-cheat-sheet/
            let home = Int(usbdata[13])
            //print("abschnittfertig: \(String(abschnittfertig, radix:16, uppercase:true))\n")
           //print("newDataAktion abschnittfertig: \(hex(abschnittfertig)) cncstatus: \(usbdata[22]) home: \(home)\n")
            
            
            
            /*
            if usbdata != nil
            {
               //print("usbdata not nil\n")
               var i = 0
               while i < 10
               {
                  //print("i: \(i)  wert: \(usbdata[i])\t")
                  i = i+1
               }
               
            }
            */
            if abschnittfertig >= 0xA0 // Code fuer Fertig: AD
            {
               //print("abschnittfertig > A0")
               let Abschnittnummer = Int(usbdata[5])
               NotificationDic["inposition"] = Int(Abschnittnummer)
               let ladePosition = Int(usbdata[6])
               NotificationDic["outposition"] = ladePosition
               NotificationDic["stepperposition"] = Stepperposition
               NotificationDic["mausistdown"] = mausistdown
               
               NotificationDic["home"] = Int(usbdata[13])
               NotificationDic["cncstatus"] = Int(usbdata[22])
               NotificationDic["anschlagstatus"] = Int(usbdata[19])
               
               //print("newDataAktion cncstatus: \(usbdata[22])")
               var AnschlagSet = IndexSet()
               
               switch abschnittfertig
               {
               case 0xE1:// Antwort auf mouseup 0xE0 HALT
                  print("newDataAktion E1 mouseup")
                  usb_schnittdatenarray.removeAll()
                  
       //           AVR?.setBusy(0)
                  teensy.read_OK = false
                  break
                  
               case 0xEA: // home
                  print("newDataAktion EA home gemeldet")
                  break
                  
               // Anschlag first
               case 0xA5:
                  print("VC Anschlag A0")
                  AnschlagSet.insert(0) // schritteax lb
                  AnschlagSet.insert(1) // schritteax hb
                  AnschlagSet.insert(4) // delayax lb
                  AnschlagSet.insert(5) // delayax lb
                  break;
                  
               case 0xA6:
                  print("VC Anschlag B0")
                  AnschlagSet.insert(2) // schritteax lb
                  AnschlagSet.insert(3) // schritteax hb
                  AnschlagSet.insert(6) // delayax lb
                  AnschlagSet.insert(7) // delayax lb
                  break;
                  
               case 0xA7:
                  print("VC Anschlag C0")
                  AnschlagSet.insert(8) // schrittebx lb
                  AnschlagSet.insert(9) // schrittebx hb
                  AnschlagSet.insert(12) // delayabx lb
                  AnschlagSet.insert(13) // delaybx lb
                  break;
                  
               case 0xA8:
                  print("VC Anschlag D0")
                  AnschlagSet.insert(10) // schritteby lb
                  AnschlagSet.insert(11) // schritteby hb
                  AnschlagSet.insert(14) // delayby lb
                  AnschlagSet.insert(15) // delayby lb
                  break;
                  
               // Anschlag home first
               case 0xB5:
                  print("+++++++++ VC Anschlag A home first")
                  HomeAnschlagSet.insert(0xB5)
                  print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                  break
               case 0xB6:
                  print("+++++++++ VC Anschlag B home first")
                  HomeAnschlagSet.insert(0xB6)
                  print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                  break
               case 0xB7:
                  print("+++++++++ VC Anschlag C home first")
                  HomeAnschlagSet.insert(0xB7)
                  print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                  break
               case 0xB8:
                  print("+++++++++ VC Anschlag D home first")
                  HomeAnschlagSet.insert(0xB8)
                  print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                  break
                  
               // Anschlag Second  
               case 0xC5:
                  print("Anschlag A home  second")
                  break              
               case 0xC6:
                  print("Anschlag B home  second")
                  break
               case 0xC7:
                  print("Anschlag C home  second")
                  break
               case 0xC8:
                  print("Anschlag D home  second")
                  break
                  
               case 0xD0:
                  print("***   ***   Letzter Abschnitt")
                  //print("0xD0 Stepperposition: \(Stepperposition) \n\(schnittdatenstring)");
                  //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                  NotificationDic["abschnittfertig"] = Int(abschnittfertig)
                  let nc = NotificationCenter.default
                  nc.post(name:Notification.Name(rawValue:"usbread"),
                          object: nil,
                          userInfo: NotificationDic)
                  return
                  break
               
                  
               case 0xF1:
                  
                     print("F1 home ")
                  
                  break;
               case 0xF2:
                  
                     print("F2 ")
                  
                  break;
                  
               case 0xBD:
                  print("BD cncstatus: \(usbdata[22]) ")
                  
                  if Int(usbdata[63]) == 1
                     {
                        print("BD 63  ")
                         // return;
                     }
                  
                  break;
               default:
                  break
               }// switch abschnittfertig
               
               if AnschlagSet.count > 0
               {
                  print("AnschlagSet count 0")
                  //var i=0
                  for i in Stepperposition-1..<usb_schnittdatenarray.count
                  {
                     var tempZeilenArray = usb_schnittdatenarray[i]
                     for k in 0..<tempZeilenArray.count
                     {
                        if AnschlagSet.contains(k)
                        {
                           tempZeilenArray[k] = 0
                        }
                     }
                  }
               } // if AnschlagSet count
               
               if mausistdown == 2
               {
                  print("mausistdown = 2")
                  Stepperposition = 0
               }
               
               var EndIndexSet = IndexSet(integersIn:0xAA...0xAD)
               EndIndexSet.insert(integersIn:0xA5...0xA8)
               
               var HomeIndexSet = IndexSet(integersIn:0xAA...0xAD)
               EndIndexSet.insert(integersIn:0xB5...0xB8)
               
               //print("EndIndexSet: \(EndIndexSet)")
              //  print("HomeIndexSet: \(HomeIndexSet)")

               
               if EndIndexSet.contains(Int(abschnittfertig))
               {
                  print("EndIndexSet contains abschnittfertig")
                  //teensy.DC_pwm(0)
  //                AVR?.setBusy(0)
   //               teensy.read_OK = false
               }
               else
               {
                  if HomeIndexSet.contains(Int(abschnittfertig))
                  {
                     print("HomeIndexSet contains abschnittfertig")
                     if HomeAnschlagSet.count == 1
                     {
                        print("HomeAnschlagSet.count == 1")
                     }
                     else if HomeAnschlagSet.count == 4
                     {
                        print("HomeAnschlagSet.count == 4")
                     }
                     else if home == 2
                     {
                        print("home == 2")
                     }
                  }
                  else
                  {
                     //print("newDataAktion vor writeCNCAbschnitt count: \(usb_schnittdatenarray.count)")
                     if (usb_schnittdatenarray.count > 0) // nicht HALT
                     {
                     //if (Int(usbdata[10]) == 0)
                        //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                     
                        writeCNCAbschnitt()
                        
                     }
                  }
               }
                  //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                  NotificationDic["homeanschlagset"] = Int(HomeAnschlagSet.count)
                  NotificationDic["home"] = Int(home)
                  NotificationDic["abschnittfertig"] = Int(abschnittfertig)
                  
                  
                   let nc = NotificationCenter.default
                   nc.post(name:Notification.Name(rawValue:"usbread"),
                   object: nil,
                   userInfo: NotificationDic)
                   
               
            } // if abschnittfertig > A0
            
            //writeCNCAbschnitt()
            //print("dic end\n")
            
         } // if count > 0
         
      } // if d
      else
      {
         print("*** newDataAktion if let d not ok")
      }
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")
      
   }
   
    
   @objc func DC_pwm(_ dcpwm:Int)
    {
       print("DC_pwm pwm: \(dcpwm)")
    }

    @objc  func contDataAktion(_ notification:Notification) 
    {
       let lastData = teensy.getlastDataRead()
      print("contDataAktion notification: \n\(notification)\n lastData:\n \(lastData) ")       
      var ii = 0
       while ii < 10
       {
          //print("ii: \(ii)  wert: \(lastData[ii])\t")
          ii = ii+1
       }
       
       let u = ((Int32(lastData[1])<<8) + Int32(lastData[2]))
       //print("hb: \(lastData[1]) lb: \(lastData[2]) u: \(u)")
       let info = notification.userInfo
       
       //print("info: \(String(describing: info))")
       //print("new Data")
       let data = notification.userInfo?["data"]
       //print("data: \(String(describing: data)) \n") // data: Optional([0, 9, 51, 0,....
       
       
       //print("lastDataRead: \(lastDataRead)   ")
       var i = 0
       while i < 10
       {
          //print("i: \(i)  wert: \(lastDataRead[i])\t")
          i = i+1
       }
       
       if let d = notification.userInfo!["contdata"]
        {
              
           //print("d: \(d)\n") // d: [0, 9, 56, 0, 0,... 
           let t = type(of:d)
           //print("typ: \(t)\n") // typ: Array<UInt8>
           
           //print("element: \(d[1])\n")
           
           print("d as string: \(String(describing: d))\n")
           if d != nil
           {
              //print("d not nil\n")
              var i = 0
              while i < 10
              {
                 //print("i: \(i)  wert: \(d![i])\t")
                 i = i+1
              }
              
           }
          
           
           //print("dic end\n")
        }

            
          
          //print("dic end\n")
       }
       
       //let dic = notification.userInfo as? [String:[UInt8]]
       //print("dic: \(dic ?? ["a":[123]])\n")
       
   
   
   /*
   // MARK: joystick
     @objc override func joystickAktion(_ notification:Notification) 
     {
        print("CNCViewController joystickAktion usbstatus:\t \(usbstatus) selectedDevice: \(selectedDevice) ident: \(self.view.identifier)")
        let sel = NSUserInterfaceItemIdentifier.init(selectedDevice)

     }
    */
   @objc @IBAction  func showEinstellungen(_ sender: Any)
   {
      Swift.print("CNCView showEinstellungen")
 //     AVR?.showEinstellungen()
      
   }
  
   /*
   @objc @IBAction func print(sender:Any)
   {
      AVR?.printGraph()
   }
*/
    
   
   
   @objc @IBAction func printGraph(sender:Any)
   {
      Swift.print("print")
   // AVR?.printGraph()
   }

} // end rCNCViewController


