//
//  rBasis.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 06.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//

import Cocoa

class rPCB: rViewController 
{
      
   var hintergrundfarbe:NSColor = NSColor()
   
   override func viewDidAppear() 
   {
      print ("PCB viewDidAppear ")
  
     }
   
  
   
   
   override func viewDidLoad() 
    {
        super.viewDidLoad()
        // Do view setup here.
      self.view.window?.acceptsMouseMovedEvents = true
      //let view = view[0] as! NSView
      self.view.wantsLayer = true
      
      hintergrundfarbe  = NSColor.init(red: 0.25, 
                                    green: 0.85, 
                                    blue: 0.85, 
                                    alpha: 0.25)
      
      self.view.layer?.backgroundColor = hintergrundfarbe.cgColor
      
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down
      

       
      //let sup = self.view.superview
      //print("DeviceTab superview: \(String(describing: sup)) ident: \(String(describing: sup?.identifier))")
      
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
  //    let newdataname = Notification.Name("newdata")
   //   NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
  //    NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
      NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)
      
      
      // servoPfad
      servoPfad?.setStartposition(x: 0x800, y: 0x800, z: 0)
      
      // Pot 0
      
      /*
      Pot0_Slider.integerValue = Int(ACHSE0_START)
      Pot0_Feld.integerValue = Int(ACHSE0_START)
      let intpos0 = UInt16(Float(ACHSE0_START) * FAKTOR0)
      Pot0_Feld.integerValue = Int(UInt16(Float(ACHSE0_START) * FAKTOR0))
      Pot0_Stepper_L.integerValue = 0
      Pot0_Stepper_L_Feld.integerValue = 0
      Pot0_Stepper_H.integerValue = Int(Pot0_Slider.maxValue)
      Pot0_Stepper_H_Feld.integerValue = Int(Pot0_Slider.maxValue)
      
      // Pot 1
      Pot1_Slider.integerValue = Int(ACHSE1_START)
      //Pot1_Feld.integerValue = Int(ACHSE1_START)
      let intpos1 = UInt16(Float(ACHSE1_START) * FAKTOR1)
      Pot1_Feld.integerValue = Int(UInt16(Float(ACHSE1_START) * FAKTOR1))
      //Pot1_Feld.integerValue = Int(intpos1)
      Pot1_Stepper_L.integerValue = 0
      Pot1_Stepper_L_Feld.integerValue = 0 
      Pot1_Stepper_H.integerValue = Int(Pot1_Slider.maxValue)
      Pot1_Stepper_H_Feld.integerValue = Int(Pot1_Slider.maxValue)
      //print("intpos0: \(intpos0) intpos1: \(intpos1)")
      
      // Pot 2
      Pot2_Slider.integerValue = Int(ACHSE2_START)
      Pot2_Feld.integerValue = Int(ACHSE2_START)
      Pot2_Stepper_L.integerValue = 0
      Pot2_Stepper_L_Feld.integerValue = 0 
      Pot2_Stepper_H.integerValue = Int(Pot2_Slider.maxValue)
      Pot2_Stepper_H_Feld.integerValue = Int(Pot2_Slider.maxValue)
      
      // Pot 3
      Pot3_Slider.integerValue = Int(ACHSE3_START)
      Pot3_Feld.integerValue = Int(ACHSE3_START)
      Pot3_Stepper_L.integerValue = 0
      Pot3_Stepper_L_Feld.integerValue = 0 
      Pot3_Stepper_H.integerValue = Int(Pot3_Slider.maxValue)
      Pot3_Stepper_H_Feld.integerValue = Int(Pot3_Slider.maxValue)
      */
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[0] = SET_0
  
   
   }
 
   @objc func usbstatusAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      guard let status = info?["usbstatus"] as? Int else 
      { 
         print("Basis usbstatusAktion: kein status\n")
         return  
         
      }// 
      //print("Basis usbstatusAktion:\t \(status)")
      usbstatus = Int(status)
   }

   
 // MARK: joystick
   @objc override func joystickAktion(_ notification:Notification) 
   {
      print("Basis joystickAktion usbstatus:\t \(usbstatus) selectedDevice: \(selectedDevice) ident: \(self.view.identifier)")
      let sel = NSUserInterfaceItemIdentifier.init(selectedDevice)
     // if (selectedDevice == self.view.identifier)
      if (sel == self.view.identifier)
      {
  //       print("Basis joystickAktion passt")
         
         let info = notification.userInfo
         let punkt:CGPoint = info?["punkt"] as! CGPoint
         let wegindex:Int = info?["index"] as! Int // 
         let first:Int = info?["first"] as! Int
  //       print("Basis joystickAktion:\t \(punkt)")
  //       print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first)")
         
         teensy.write_byteArray[0] = SET_ROB // Code 
         
         // Horizontal Pot0
         let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
         let faktorw:Double = (Pot0_Slider.maxValue - Pot0_Slider.minValue) / w
         //      print("w: \(w) faktorw: \(faktorw)")
         var x = Double(punkt.x)
         if (x > w)
         {
            x = w
         }
         goto_x.integerValue = Int(Float(x*faktorw))
         joystick_x.integerValue = Int(Float(x*faktorw))
         goto_x_Stepper.integerValue = Int(Float(x*faktorw))
         let achse0 = UInt16(Float(x*faktorw) * FAKTOR0)
         //print("x: \(x) achse0: \(achse0)")
         teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((achse0 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((achse0 & 0x00FF) & 0xFF) // lb
         
         
         let h = Double(Joystickfeld.bounds.size.height)
         let faktorh:Double = (Pot1_Slider.maxValue - Pot1_Slider.minValue) / h
         
         let faktorz = 1
         //     print("h: \(h) faktorh: \(faktorh)")
         var y = Double(punkt.y)
         if (y > h)
         {
            y = h
         }
         let z = 0
         goto_y.integerValue = Int(Float(y*faktorh))
         joystick_y.integerValue = Int(Float(y*faktorh))
         goto_y_Stepper.integerValue = Int(Float(y*faktorh))
         let achse1 = UInt16(Float(y*faktorh) * FAKTOR1)
         //print("y: \(y) achse1: \(achse1)")
         teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((achse1 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((achse1 & 0x00FF) & 0xFF) // lb
         let achse2 =  UInt16(Float(z*faktorz) * FAKTOR2)
         teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((achse2 & 0xFF00) >> 8) // hb
         teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((achse2 & 0x00FF) & 0xFF) // lb
         
         
         let message:String = info?["message"] as! String
         if ((message == "mousedown") && (first >= 0))// Polynom ohne mousedragged
         {
            teensy.write_byteArray[0] = SET_RING
            let anz = servoPfad?.anzahlPunkte()
            if (wegindex > 1)
            {
               print("")
               print("basis joystickAktion cont achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(String(describing: anz)) wegindex: \(wegindex)")
               
               let lastposition = servoPfad?.pfadarray.last
               
               let lastx:Int = Int(lastposition!.x)
               let nextx:Int = Int(achse0)
               let hypx:Int = (nextx - lastx) * (nextx - lastx)
               
               let lasty:Int = Int(lastposition!.y)
               let nexty:Int = Int(achse1)
               let hypy:Int = (nexty - lasty) * (nexty - lasty)
               
               let lastz:Int = Int(lastposition!.z)
               let nextz:Int = Int(achse2)
               let hypz:Int = (nextz - lastz) * (nextz - lastz)
               
               print("joystickAktion lastx: \(lastx) nextx: \(nextx) lasty: \(lasty) nexty: \(nexty)")
               
               let hyp:Float = (sqrt((Float(hypx + hypy + hypz))))
               
               let anzahlsteps = hyp/schrittweiteFeld.floatValue
               print("Basis joystickAktion hyp: \(hyp) anzahlsteps: \(anzahlsteps) ")
               
               teensy.write_byteArray[HYP_BYTE_H] = UInt8((Int(hyp) & 0xFF00) >> 8) // hb
               teensy.write_byteArray[HYP_BYTE_L] = UInt8((Int(hyp) & 0x00FF) & 0xFF) // lb
               
               teensy.write_byteArray[STEPS_BYTE_H] = UInt8((Int(anzahlsteps) & 0xFF00) >> 8) // hb
               teensy.write_byteArray[STEPS_BYTE_L] = UInt8((Int(anzahlsteps) & 0x00FF) & 0xFF) // lb
               
               teensy.write_byteArray[INDEX_BYTE_H] = UInt8(((wegindex-1) & 0xFF00) >> 8) // hb // hb // Start, Index 0
               teensy.write_byteArray[INDEX_BYTE_L] = UInt8(((wegindex-1) & 0x00FF) & 0xFF) // lb
               
               print("Basis joystickAktion hypx: \(hypx) hypy: \(hypy) hypz: \(hypz) hyp: \(hyp)")
               
            }
            else
            {
               print("basis joystickAktion start achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(anz) wegindex: \(wegindex)")
               teensy.write_byteArray[HYP_BYTE_H] = 0 // hb // Start, keine Hypo
               teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
               teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb // Start, Index 0
               teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
               
            }
            
            servoPfad?.addPosition(newx: achse0, newy: achse1, newz: 0)
         }
         
         if (usbstatus > 0)
         {
            let senderfolg = teensy.send_USB()
            print("joystickAktion senderfolg: \(senderfolg)")
         }
      }
      else
      {
 //        print("Basis joystickAktion passt nicht")
      }
      
   }
   
   
   @objc override func newDataAktion(_ notification:Notification) 
   {
      let lastData = teensy.getlastDataRead()
      print("lastData:\t \(lastData[1])\t\(lastData[2])   ")
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
      
      if let d = notification.userInfo!["usbdata"]
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
      
      //let dic = notification.userInfo as? [String:[UInt8]]
      //print("dic: \(dic ?? ["a":[123]])\n")
      
   }
   
   //MARK: Slider 0
   @IBAction override func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      print("report_Slider0 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot0_Feld.integerValue  = Int(intpos)
      Pot0_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot0_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot0_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot0_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("rBasis report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   @IBAction override func report_Pot0_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot0_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_L_Feld.integerValue = intpos
      
      Pot0_Slider.minValue = sender.doubleValue 
      print("report_Pot0_Stepper_L Pot0_Slider.minValue: \(Pot0_Slider.minValue)")
      
   }
   
   @IBAction override func report_Pot0_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot0_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_H_Feld.integerValue = intpos
      
      Pot0_Slider.maxValue = sender.doubleValue 
      print("report_Pot0_Stepper_H Pot0_Slider.maxValue: \(Pot0_Slider.maxValue)")
      
   }
   @IBAction override func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
      let 
      intpos = sender.intValue 
      self.Pot0_Slider.floatValue = Pot0_wert //sender.floatValue
      self.Pot0_Stepper_L.floatValue = Pot0_wert//sender.floatValue
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(Pot0_LO)
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(Pot0_HI)
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         if (senderfolg < BUFFER_SIZE)
         {
            print("report_set_Pot0 U: %d",senderfolg)
         }
      }
   }
   

   
   
   // MARK:Slider 1
   @IBAction override func report_Slider1(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_1 // Code
      print("report_Slider1 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      let intpos = UInt16(pos * FAKTOR0)
      let Istring = formatter.string(from: NSNumber(value: intpos))
      print("intpos: \(intpos) IString: \(Istring)") 
      Pot1_Feld.integerValue  = Int(intpos)
      
      Pot1_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot1_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot1_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot1_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction override func report_Pot1_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot1_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_L_Feld.integerValue = intpos
      
      Pot1_Slider.minValue = sender.doubleValue 
      print("report_Pot1_Stepper_L Pot1_Slider.minValue: \(Pot1_Slider.minValue)")
      
   }
   
   @IBAction override func report_Pot1_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot1_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_H_Feld.integerValue = intpos
      
      Pot1_Slider.maxValue = sender.doubleValue 
      print("report_Pot1_Stepper_H Pot1_Slider.maxValue: \(Pot1_Slider.maxValue)")
      
   }
// MARK:goto  
   @IBAction override func report_goto_0(_ sender: NSButton)
   {
      print("report_goto_0")
      var x = goto_x.integerValue
      if x > Int(Pot0_Slider.maxValue)
      {
         x = Int(Pot0_Slider.maxValue)
      }
      var y = goto_y.integerValue
      if y > Int(Pot1_Slider.maxValue)
      {
         y = Int(Pot1_Slider.maxValue)
      }
      
      print("report_goto_0  x: \(x) y: \(y)")
      self.goto_0(x:Float(x),y:Float(y),z: 0)
   }
   
   override func goto_0(x:Float, y:Float, z:Float)
   {
      teensy.write_byteArray[0] = GOTO_0
      print("goto_0 x: \(x) y: \(y)")
      // achse 0
      let intposx = UInt16(x * FAKTOR0)
      goto_x_Stepper.integerValue = Int(x) //Int(intposx)
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intposx & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intposx & 0x00FF) & 0xFF) // lb
      
      // Achse 1
      let intposy = UInt16(y * FAKTOR1)
      goto_y_Stepper.integerValue = Int(y)
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intposy & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intposy & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
      
      
   }
   @IBAction override func report_goto_x_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_goto_x_Stepper IntVal: \(sender.intValue)")
      let intpos = sender.integerValue 
      goto_x.integerValue = intpos
      let intposx = UInt16(Float(intpos ) * FAKTOR0)
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((intposx & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((intposx & 0x00FF) & 0xFF) // lb
      
      let w = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let invertfaktorw:Float = Float(w / (Pot0_Slider.maxValue - Pot0_Slider.minValue)) 
      
      var currpunkt:NSPoint = Joystickfeld.weg.currentPoint
      currpunkt.x = CGFloat(Float(intpos) * invertfaktorw)
      Joystickfeld.weg.line(to: currpunkt)
      Joystickfeld.needsDisplay = true 
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   @IBAction override func report_goto_y_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_goto_y_Stepper IntVal: \(sender.intValue)")
      let intpos = sender.integerValue 
      goto_y.integerValue = intpos
      let intposy = UInt16(Float(intpos ) * FAKTOR0)
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intposy & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intposy & 0x00FF) & 0xFF) // lb
      
      let h = Double(Joystickfeld.bounds.size.width) // Breite Joystickfeld
      let invertfaktorh:Float = Float(h / (Pot1_Slider.maxValue - Pot1_Slider.minValue)) 
      
      var currpunkt:NSPoint = Joystickfeld.weg.currentPoint
      currpunkt.y = CGFloat(Float(intpos) * invertfaktorh)
      Joystickfeld.weg.line(to: currpunkt)
      Joystickfeld.needsDisplay = true 
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }
   
   // MARK Sinus
   @IBAction override func report_StartSinus(_ sender: NSButton)
   {
      print("report_StartSinus ")
      let intpos0 = UInt16(Float(ACHSE0_START) * FAKTOR0)
      Pot0_Feld.integerValue = Int(UInt16(Float(ACHSE0_START) * FAKTOR0))
      
      teensy.write_byteArray[0] = SIN_START
      let intpos = UInt16(Float(ACHSE0_START) * FAKTOR0)
      let startwert = UInt16(Float(ACHSE0_START) * FAKTOR0)
      
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
   @IBAction override func report_StopSinus(_ sender: NSButton)
   {
      print("report_StopSinus ")
      teensy.write_byteArray[0] = SIN_END
      teensy.write_byteArray[1] = SIN_END
      let startwert = ACHSE0_START
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8((startwert & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8((startwert & 0x00FF) & 0xFF) // lb
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         print("report_sinus senderfolg: \(senderfolg) startwert: \(startwert)")
      }
      
      
   }
   
   @IBAction override func report_Slider_sin(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_2 // Code 
      //print("report_Slider:sin IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      Pot2_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
  
   
   
// MARK: Ring
   
   
   @IBAction override func report_clear_Ring(_ sender: NSButton)
   {
      print("report_clear_Ring ")
      teensy.write_byteArray[0] = CLEAR_RING
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8(((ACHSE2_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8(((ACHSE2_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[HYP_BYTE_H] = 0 // hb
      teensy.write_byteArray[HYP_BYTE_L] = 0 // lb
      
      teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb
      teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
      Joystickfeld.clearWeg()
      servoPfad?.clearPfadarray()
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
      
   }

   
   
   
    
} // rPCB
