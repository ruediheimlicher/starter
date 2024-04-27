//
//  ViewController.swift
//  Digital_Power_Interface
//
//  Created by Ruedi Heimlicher on 02.11.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//
// Bridging-Header: https://stackoverflow.com/questions/24146677/swift-bridging-header-import-issue/31717280#31717280

// https://stackoverflow.com/questions/46193109/hide-warnings-simultaneous-accesses-to-but-modification-requires-exclusive


import Cocoa


 public var lastDataRead = Data.init(count:BUFFER_SIZE)

var loadcounter = 0

var globalusbstatus = 0

func printhex(wert:UInt8)
{
   print(String(wert, radix:16, uppercase:true))
}

func hex(_ wert:UInt8)->String
{
   return String(wert, radix:16, uppercase:true) 
}

class rZeigerView:NSView
{
   var zeigerpfad: NSBezierPath = NSBezierPath()
   var feld = frame
   override init(frame frameRect: NSRect) 
   {
      super.init(frame:frameRect);
      self.wantsLayer = true
      //self.layer?.backgroundColor = NSColor.red.cgColor
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      let mittex:CGFloat = bounds.size.width / 2
      let mittey:CGFloat = bounds.size.height / 2
      zeigerpfad.move(to: NSMakePoint(mittex, 0)) // start point
      zeigerpfad.line(to: NSMakePoint(mittex, h))
//    zeigerpfad.rotateAroundCenter(angle: 10)
      //zeigerpfad.stroke()
   }
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
   }
   
   func setFeld(feld: NSRect)
   {
   //   self.setBoundsOrigin(feld.origin)
      self.setBoundsOrigin(feld.origin)
      self.setBoundsSize(feld.size)
      

   }
   
   override func draw(_ dirtyRect: NSRect)
   {
      let blackColor = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
      blackColor.set()
      //zeigerpfad.stroke()
    //  zeigerpfad.move(to: NSMakePoint(20, 75))
      /*
      var bPath: NSBezierPath = NSBezierPath(rect:dirtyRect)
      var lineDash:[CGFloat] = [20.0,5.0,5.0]
      bPath.move(to: NSMakePoint(20, 75))
      bPath.line(to: NSMakePoint(dirtyRect.size.width - 20, 75))
      bPath.lineWidth = 10.0
      bPath.setLineDash(lineDash, count: 3, phase: 0.0)
      bPath.stroke()
      
      
      var cPath: NSBezierPath = NSBezierPath(rect:dirtyRect)
      cPath.move(to: NSMakePoint(10, 10))
      cPath.curve(to: NSMakePoint(dirtyRect.size.width - 20, 25), controlPoint1: NSMakePoint(10, 10), controlPoint2: NSMakePoint(15, 20))
      cPath.lineWidth = 4.0
      
      cPath.stroke()
 */
   }
   
}


struct position
{
   var x:UInt16 = 0
   var y:UInt16 = 0
   var z:UInt16 = 0
   
}
//MARK: rServoPfad
class rServoPfad 
{
   var pfadarray = [position]()
   var delta = 1 // Abstand der Schritte
   required init?() 
   {
      //super.init()
      //Swift.print("servoPfad init")
      var startposition = position()
      startposition.x = 0
      startposition.y = 0
      startposition.z = 0
 //     pfadarray.append(startposition)
      
   }
   
   func setStartposition(x:UInt16, y:UInt16, z:UInt16)
   {
      let anz = pfadarray.count
      if (pfadarray.count > 0)
      {
         pfadarray[0].x = x
         pfadarray[0].y = y
         pfadarray[0].z = z
      }
      else
      {
         addPosition(newx: x, newy: y, newz: z)
      }
   }
   
   func addPosition(newx:UInt16, newy:UInt16, newz:UInt16)
   {
       let newposition = position(x:newx,y:newy,z:newz)
      pfadarray.append(newposition)
    }
 
   func clearPfadarray()
   {
      pfadarray.removeAll()
   }
   
   func anzahlPunkte() -> Int
   {
      return Int(pfadarray.count)
   }
   
}

//MARK: TABVIEW
class rDeviceTabViewController: NSTabViewController 
{
   
   override func viewDidLoad() {
      print("rDeviceTabViewController viewdidload")
      super.viewDidLoad()
      self.tabView.tabViewItem(at:1).color = NSColor.red
     // self.TabViewBorderType = 1;
   
   }
   override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) 
   {
     // 
      let identifier:String = tabViewItem?.identifier as! String
      //print("DeviceTab identifier: \(String(describing: identifier)) usbstatus: \(globalusbstatus)")
    // let sup = self.view.superview
     // print("DeviceTab superview: \(sup) ident: \(sup?.identifier)")
   //let supsup = self.view.superview?.superview
      //print("DeviceTab supsup: \(supsup) ident: \(supsup?.identifier)")
      //print("subviews: \(supsup?.subviews)")
      
      var userinformation:[String : Any]
      userinformation = ["message":"tabview",  "ident": identifier, ] as [String : Any]
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"tabview"),
              object: nil,
              userInfo: userinformation)
 
      userinformation = ["message":"usb"] as [String : Any]
      /*
      nc.post(name:Notification.Name(rawValue:"usb_status"),
              object: nil,
              userInfo: userinformation)
*/
   }
 
}

//MARK: ViewController
class rViewController: NSViewController, NSWindowDelegate
{
    var cncwritecounter = 0;
   let notokimage :NSImage = NSImage(named:NSImage.Name(rawValue: "notok_image"))!
   let okimage :NSImage = NSImage(named:NSImage.Name(rawValue: "ok_image"))!
    
    
   
    var AVR = rAVRview()
    
    @IBOutlet weak var steps_Feld: NSTextField!
    @IBOutlet weak var micro_Feld: NSTextField!


   @IBOutlet weak var USB_OK_Feld: NSImageView!
   
   // Robot
   var z0:Float = 30 // Hoehe Drehpunkt 0
   var l0:Float = 1// laenge Arm 0
   var l1:Float = 1 // laenge Arm 1
   var l2:Float = 1 // laenge Arm 2
   
   var phi0:Float = 0 // Winkel Arm 0 von Senkrechte
   var phi1:Float = 0 // Winkel Arm 1
   var phi2:Float = 0 // Winkel Arm 2
   // var  myUSBController:USBController
   // var usbzugang:
   var usbstatus: Int = 0
   
   var boardindex:Int = 0
    
    var viewdidloadcounter = 0
   
   var teensyboardarray:[[String:Any]] = []
   
   var teensy = usb_teensy()
   
   var servoPfad = rServoPfad()
   
   var selectedDevice:String = ""
   
   var hgfarbe  = NSColor()
   
   //var tsp_nn = rTSP_NN()
   
   var formatter = NumberFormatter()
   
  
   var achse0_start:UInt16  = ACHSE0_START;
   var achse0_max:UInt16   = ACHSE0_MAX;

   var robotPList = UserDefaults.standard 
   let defaults = UserDefaults.standard
    
    // von CNCViewC
    var mausistdown:Int = 0
     
    var Stepperposition:Int = 0
    
    var halt = 0
    var home = 0

    var pwm = 1
    
    var HomeAnschlagSet = IndexSet()
     // end IOWarriorWindowController

    //var KoordinatenTabelle = [[String:Double]]()
    var usb_schnittdatenarray = [[UInt8]]()
    
    var schnittdatenstring:String = ""
    
    var steps = 48
    var micro = 1

    //var Einstellungen = rEinstellungen()
    let USBATTACHED = 5
   let USBREMOVED  = 6
   // end von CNCViewC
    
   // https://learnappmaking.com/plist-property-list-swift-how-to/
   struct Preferences: Codable {
      var webserviceURL:String
      var itemsPerPage:Int
      var backupEnabled:Bool
      var robot1_offset:Int
   }
   
 
   func windowWillClose(_ aNotification: Notification) {
      print("windowWillClose ViewC")
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"beenden"),
              object: nil,
              userInfo: nil)
      
   }
   
    override var acceptsFirstResponder : Bool {
           return true
    }

   
   override func viewDidLoad()
   {
       if loadcounter > 0
       {
           return
       }
      super.viewDidLoad()
      self.view.wantsLayer = true
      self.view.superview?.wantsLayer = true

      view.window?.delegate = self // https://stackoverflow.com/questions/44685445/trying-to-know-when-a-window-closes-in-a-macos-document-based-application
      self.view.window?.acceptsMouseMovedEvents = true
 
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 2
      formatter.minimumIntegerDigits = 1
      //formatter.roundingMode = .down

      /*
       let TEENSY3_TITLE = "Teensy 3.x"
       let TEENSY3_VID = 0x16C0
       let TEENSY3_PID = 0x0486

       let TEENSY2_TITLE = "Teensy 2"
       let TEENSY2_VID = 0x16C0
       let TEENSY2_PID = 0x0480

       */
 
 
      //USB_OK.backgroundColor = NSColor.greenColor()
      // Do any additional setup after loading the view.
      let newdataname = Notification.Name("newdata")
  //    NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:newdataname,object:nil)
  //     NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "newdata"), object: nil)

       loadcounter += 1
           NotificationCenter.default.addObserver(self, selector:#selector(joystickAktion(_:)),name:NSNotification.Name(rawValue: "joystick"),object:nil)
           NotificationCenter.default.addObserver(self, selector:#selector(tabviewAktion(_:)),name:NSNotification.Name(rawValue: "tabview"),object:nil)
           
           //      NotificationCenter.default.addObserver(self, selector: #selector(usbsendAktion), name:NSNotification.Name(rawValue: "usbsend"), object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(beendenAktion), name:NSNotification.Name(rawValue: "beenden"), object: nil)

 
           // von CNCVIWC
           NotificationCenter.default.addObserver(self, selector: #selector(usbsendAktion), name:NSNotification.Name(rawValue: "usbsend"), object: nil)
           NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "usbschnittdaten"), object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(usbschnittdatenAktion), name:NSNotification.Name(rawValue: "usbschnittdaten"), object: nil)
       
           NotificationCenter.default.addObserver(self, selector:#selector(newDataAktion(_:)),name:NSNotification.Name(rawValue: "newdata"),object:nil)
       
           NotificationCenter.default.addObserver(self, selector:#selector(contDataAktion(_:)),name:NSNotification.Name(rawValue: "contdata"),object:nil)
           NotificationCenter.default.addObserver(self, selector:#selector(usbattachAktion(_:)),name:NSNotification.Name(rawValue: "usb_attach"),object:nil)
           NotificationCenter.default.addObserver(self, selector: #selector(slaveresetAktion), name:NSNotification.Name(rawValue: "slavereset"), object: nil)
       
           NotificationCenter.default.removeObserver(self, name: Notification.Name("steps"), object: nil)

       NotificationCenter.default.addObserver(self, selector: #selector(stepsAktion), name:NSNotification.Name(rawValue: "steps"), object: nil)
           
           NotificationCenter.default.removeObserver(self, name: Notification.Name("micro"), object: nil)

       NotificationCenter.default.addObserver(self, selector: #selector(microAktion), name:NSNotification.Name(rawValue: "micro"), object: nil)
 
           NotificationCenter.default.addObserver(self, selector: #selector(stoptimerAktion), name:NSNotification.Name(rawValue: "stoptimer"), object: nil)
           
           NotificationCenter.default.addObserver(self, selector: #selector(haltAktion), name:NSNotification.Name(rawValue: "halt"), object: nil)
           
           NotificationCenter.default.addObserver(self, selector: #selector(DCAktion), name:NSNotification.Name(rawValue: "dc_pwm"), object: nil)
       
       
       // end CNCViewC
      
      
      defaults.set(25, forKey: "Age")
      defaults.set(true, forKey: "UseTouchID")
      defaults.set(CGFloat.pi, forKey: "Pi")
      
      defaults.set("Paul Hudson", forKey: "Name")
      defaults.set(Date(), forKey: "LastRun")
      
      let name = "John Doe"
      let robot1 = 300
//      robotPList.set(name, forKey: "name")
      robotPList.set(robot1, forKey: "robot1")
      
      
      var preferences = Preferences(webserviceURL: "https://api.twitter.com", itemsPerPage: 12, backupEnabled: false,robot1_offset: 300)
      print("preferences: \(preferences)")
      preferences.robot1_offset = 400
 
      
      let encoder = PropertyListEncoder()
      encoder.outputFormat = .xml
      
      let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Robot/Preferences.plist")
      print("path: \(path)")
      do {
         let data = try encoder.encode(preferences)
         try data.write(to: path)
      } catch {
         print(error)
      }
     
      if  let path        = Bundle.main.path(forResource: "Preferences", ofType: "plist"),
         let xml         = FileManager.default.contents(atPath: path),
         let preferences = try? PropertyListDecoder().decode(Preferences.self, from: xml)
      {
         print(preferences.webserviceURL)
      }
      
    }
    
    @objc override func viewWillDisappear()
    {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("steps"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("micro"), object: nil)

    }
   
    // https://nabtron.com/quit-cocoa-app-window-close/
    override func viewDidAppear() 
    {
        USB_OK_Feld.image = notokimage
        
        teensyboardarray.append(["titel":TEENSY2_TITLE,"PID":TEENSY2_PID,"VID":TEENSY2_VID])
        teensyboardarray.append(["titel":TEENSY3_TITLE,"PID":TEENSY3_PID,"VID":TEENSY3_VID])
        
        print("teensyboardarray: \(teensyboardarray)")
        
        BoardPop.removeAllItems()
        var popindex = 0
        for boarditem in teensyboardarray
        {
            let temptitel = teensyboardarray[popindex]["titel"] as! String
            BoardPop.addItem(withTitle: teensyboardarray[popindex]["titel"] as! String)
            popindex += 1
        }
        
        print("viewDidAppear")
        self.view.window?.delegate = self as? NSWindowDelegate 
         
        //let boardarray:NSArray = BoardPop.itemTitles as NSArray
        
        let warnung = NSAlert.init()
        warnung.messageText = "Welches Board?"
        let boardarray = BoardPop.itemTitles
        for titel in boardarray
        {
            let buttonstring = titel
            warnung.addButton(withTitle: titel)
        }
        warnung.addButton(withTitle: "cancel")
        let devicereturn  = warnung.runModal().rawValue
        boardindex = devicereturn-1000
        
        print("boardindex: \(boardindex) devicereturn: \(devicereturn)")
        self.view.window?.makeKey()
        
        if boardindex < teensyboardarray.count
        {
            BoardPop.selectItem(at:devicereturn-1000)
            
            let teensycode = teensyboardarray[boardindex]
            
            let erfolg = teensy.USBOpen(code:teensycode, board: boardindex)
            usbstatus = Int(Int(erfolg))
            globalusbstatus = Int(erfolg)
            print("viewDidAppear erfolg: \(erfolg) usbstatus: \(usbstatus) rawhid_status: \(rawhid_status())")
            if usbstatus == 1
            {
                USB_OK_Feld.image = okimage
                var timerdic:[String:Any] = [String:Any]()
                 timerdic["home"] = 0
             
                 let result = teensy.start_read_USB(true, dic:timerdic)
                 print("teensy.read_OK ist \(result)")

            }
            else
            {
                USB_OK_Feld.image = notokimage
                
            }
            
        }
        
        var userinformation:[String : Int]
        userinformation = [ "usbstatus": usbstatus, "boardindex":boardindex] as [String : Int]
        print("userinformation: \(userinformation)")
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"usb_status"),
                object: nil,
                userInfo: userinformation)
        
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

    
   func openFile() -> URL? 
   { 
      let myFileDialog = NSOpenPanel() 
      myFileDialog.runModal() 
      return myFileDialog.url 
   }  
    
    @objc func writeCNCAbschnitt()
    {
        cncwritecounter += 1
        //print("swift rViewController writeCNCAbschnitt usb_schnittdatenarray: \(usb_schnittdatenarray) cncwritecounter: \(cncwritecounter)")
       let count = usb_schnittdatenarray.count
       //print("writeCNCAbschnitt  count: \(count) Stepperposition: \t",Stepperposition)
       
       if(Stepperposition < count)
       {
          //print("schnittdatenarray:\n",usb_schnittdatenarray[Stepperposition])
       }
       //print("writeCNCAbschnitt code: \(usb_schnittdatenarray[0][16]) Stepperposition: \(Stepperposition) count: \(count) ")
       
       if Stepperposition < count
       {
          //let motorstatus = usb_schnittdatenarray[Stepperposition][21]
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
             print("VC Stepperposition: \(Stepperposition) aktuellezeile: \(aktuellezeile) ")
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
             
              print("writeCNCAbschnitt")

             //print("writeCNCAbschnitt write_byteArray: \(teensy.write_byteArray)")
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
    
   
 /*
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
*/
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
         print("DCAktion writeCNCAbschnitt")
        writeCNCAbschnitt()
        teensy.clear_data()

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
      /*
        var i = 0
       while i < 10
       {
          print("i: \(i)  wert: \(lastDataRead[i])\t")
          i = i+1
       }
       */
        
       if let d = notification.userInfo!["contdata"]
        {
              
           //print("d: \(d)\n") // d: [0, 9, 56, 0, 0,...
           //let t = type(of:d)
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
     //print("viewcontroller usbschnittdatenAktion")
     
      
       
  //     guard let steps:Int32 = AVR?.motorsteps()  else {return}
       
     //print("viewcontroller usbschnittdatenAktion steps: \(steps)")
     usb_schnittdatenarray.removeAll()
     
     let info = notification.userInfo
     print("info: \(info)")
     //    let usb_pwm =  info?["pwm"] as! UInt8
     //    let usb_delayok =  info?["delayok"] as! UInt8
    
     guard let usb_home = info?["home"] as? Int else {
        print("Basis usbstatusAktion: kein home\n")
        return
     }
        
              
  //   let usb_home =  info?["home"] as! UInt8
     
     if usb_home == 1
     {
        //print("viewcontroller usbschnittdatenAktion usb_home: \(usb_home)")
        Stepperposition = 0
        
     }
     //    let usb_art =  info?["art"] as! UInt8
     //    let usb_cncposition =  info?["cncposition"]
     
     //print("usb_pwm: \(usb_pwm) usb_delayok: \(usb_delayok) usb_home: \(usb_home) usb_art: \(usb_art) usb_cncposition: \(usb_cncposition) ")
     //        let zeilenzahlarray = info?["schnittdatenarray"] as! [UInt8]
     // guard   let zeilenzahlarray = info?["schnittdatenarray"] as?[[UInt8]] else {return}

      guard   let zeilenzahlarray = info?["schnittdatenarray"] as?[[Int]] else 
      
      {
          print("usbschnittdatenaktion : kein zeilenzahlarray\n")
          return
      }
     
     //HomeAnschlagSet.removeAll()
     
     var zeilenindex = 0
     for zeile in   zeilenzahlarray
     {
        var wertarray = [UInt8]()
        var elementindex = 0
        for el in zeile
        {
           guard UInt8(el) != nil else { return  }
            wertarray.append(UInt8(el))
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
        let result = teensy.start_read_USB(true, dic:timerdic)
         print("teensy.read_OK status ist: \(result)")
     }
     else
     {
        print("teensy.read_OK ist true")
     }
      print("readOK vor writeCNCAbschnitt: \(teensy.read_OK.boolValue)\n usb_schnittdatenarray: \(usb_schnittdatenarray)")
      writeCNCAbschnitt()
    }
    
    @objc func usbattachAktion(_ note:Notification)
     {
        let info = note.userInfo
        let status = info?["attach"] as! Int
        print("ViewController usbattachAktion status: \(status)");
        
        if (status == USBREMOVED)
        {
     //      USB_OK_Feld.image = notokimage
           //USBKontrolle.stringValue="USB OFF"
           print("ViewController usbattachAktion USBREMOVED ")
        }
       else if (status == USBATTACHED)
        {
      //     USB_OK_Feld.image = okimage
          // [USBKontrolle setStringValue:@"USB ON"];
           
           print("ViewController usbattachAktion USBATTACHED")
        }
        
        
     }


    @objc func usbsendAktion(_ notification:Notification)
     {
        print("usbsendAktion: \(notification)")
     }

   
   @objc func beendenAktion(_ notification:Notification) 
    {
       
       print("beendenAktion")
        NSApplication.shared.terminate(self)
       
       
    }

   @objc @IBAction func showEinstellunge(_ sender: Any)
    {
       print("ViewController showEinstellungen")
    }

   @objc func tabviewAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let ident:String = info?["ident"] as! String  // 
      print("ViewController tabviewAktion:\t \(ident) usbstatus: \(usbstatus) globalusbstatus: \(globalusbstatus)")
      selectedDevice = ident
      usbstatus = Int(globalusbstatus)
      
   }

   
   
   @objc func joystickAktion(_ notification:Notification) 
   {
      let info = notification.userInfo
      let punkt:CGPoint = info?["punkt"] as! CGPoint
      let wegindex:Int = info?["index"] as! Int // 
      let first:Int = info?["first"] as! Int
      //print("xxx joystickAktion:\t \(punkt)")
      //print("x: \(punkt.x) y: \(punkt.y) index: \(wegindex) first: \(first)")
      
      /*
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
            print("joystickAktion cont achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(String(describing: anz)) wegindex: \(wegindex)")
            
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
            print("joystickAktion hyp: \(hyp) anzahlsteps: \(anzahlsteps) ")

            teensy.write_byteArray[HYP_BYTE_H] = UInt8((Int(hyp) & 0xFF00) >> 8) // hb
            teensy.write_byteArray[HYP_BYTE_L] = UInt8((Int(hyp) & 0x00FF) & 0xFF) // lb
       
            teensy.write_byteArray[STEPS_BYTE_H] = UInt8((Int(anzahlsteps) & 0xFF00) >> 8) // hb
            teensy.write_byteArray[STEPS_BYTE_L] = UInt8((Int(anzahlsteps) & 0x00FF) & 0xFF) // lb
            
            teensy.write_byteArray[INDEX_BYTE_H] = UInt8(((wegindex-1) & 0xFF00) >> 8) // hb // hb // Start, Index 0
            teensy.write_byteArray[INDEX_BYTE_L] = UInt8(((wegindex-1) & 0x00FF) & 0xFF) // lb

            print("joystickAktion hypx: \(hypx) hypy: \(hypy) hypz: \(hypz) hyp: \(hyp)")
            
         }
         else
         {
            print("joystickAktion start achse0: \(achse0) achse1: \(achse1)  achse2: \(achse2) anz: \(anz) wegindex: \(wegindex)")
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
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
      */
   }
 
 
   @objc func newDataAktion(_ notification:Notification) 
    {
       // Reaktion auf eingehende USB-Daten
       var lastData = teensy.getlastDataRead()
       let lastDataArray = [UInt8](lastData)
       print("VC newDataAktion notification: \n\(notification)\n lastData:\n \(lastData)")
       
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
             // https://useyourloaf.com/blog/swift-string-cheat-sheet/
             let home = Int(usbdata[13])
              
              print("newDataAktion abschnittfertig abschnittfertig: \(hex(abschnittfertig))")
               NotificationDic["abschnittfertig"] = Int(abschnittfertig)

              let abschnittnummer:Int = Int((usbdata[5] << 8) | usbdata[6])
              let ladeposition = usbdata[8]
              
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
                print("VC newDataAktion abschnittfertig > A0")
                let Abschnittnummer = Int(usbdata[5])
                NotificationDic["inposition"] = Int(Abschnittnummer)
                let ladePosition = Int(usbdata[6])
                NotificationDic["outposition"] = ladePosition
                NotificationDic["stepperposition"] = Stepperposition
                NotificationDic["mausistdown"] = mausistdown
                
                NotificationDic["home"] = Int(usbdata[13])
                NotificationDic["cncstatus"] = Int(usbdata[22])
                NotificationDic["anschlagstatus"] = Int(usbdata[19])
                 NotificationDic["abschnittfertig"] = Int(abschnittfertig)

                //print("newDataAktion cncstatus: \(usbdata[22])")
                var AnschlagSet = IndexSet()
                
                switch abschnittfertig
                {
                case 0xE1:// Antwort auf mouseup 0xE0 HALT
                   print("VC newDataAktion newDataAktion E1 mouseup")
                   usb_schnittdatenarray.removeAll()
                   
                   AVR?.setBusy(0)
                   teensy.read_OK = false
                   break
                   
                case 0xEA: // home
                   print("VC newDataAktion  EA home gemeldet")
                   break
                   
                // Anschlag first
                case 0xA5:
                   print("VC newDataAktion  Anschlag A0")
                   AnschlagSet.insert(0) // schritteax lb
                   AnschlagSet.insert(1) // schritteax hb
                   AnschlagSet.insert(4) // delayax lb
                   AnschlagSet.insert(5) // delayax lb
                   break;
                   
                case 0xA6:
                   print("VC newDataAktion  Anschlag B0")
                   AnschlagSet.insert(2) // schritteax lb
                   AnschlagSet.insert(3) // schritteax hb
                   AnschlagSet.insert(6) // delayax lb
                   AnschlagSet.insert(7) // delayax lb
                   break;
                   
                case 0xA7:
                   print("VC newDataAktion  Anschlag C0")
                   AnschlagSet.insert(8) // schrittebx lb
                   AnschlagSet.insert(9) // schrittebx hb
                   AnschlagSet.insert(12) // delayabx lb
                   AnschlagSet.insert(13) // delaybx lb
                   break;
                   
                case 0xA8:
                   print("VC newDataAktion  Anschlag D0")
                   AnschlagSet.insert(10) // schritteby lb
                   AnschlagSet.insert(11) // schritteby hb
                   AnschlagSet.insert(14) // delayby lb
                   AnschlagSet.insert(15) // delayby lb
                   break;
                   
                // Anschlag home first
                case 0xB5:
                   print("VC newDataAktion +++++++++  Anschlag A home first")
                   HomeAnschlagSet.insert(0xB5)
                   print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                   break
                case 0xB6:
                   print("VC newDataAktion +++++++++  Anschlag B home first")
                   HomeAnschlagSet.insert(0xB6)
                   print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                   break
                case 0xB7:
                   print("VC newDataAktion +++++++++  Anschlag C home first")
                   HomeAnschlagSet.insert(0xB7)
                   print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                   break
                case 0xB8:
                   print("VC newDataAktion +++++++++ VC Anschlag D home first")
                   HomeAnschlagSet.insert(0xB8)
                   print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                   break
                   
                // Anschlag Second
                case 0xC5:
                   print("VC newDataAktion Anschlag A home  second")
                   break
                case 0xC6:
                   print("VC newDataAktion Anschlag B home  second")
                   break
                case 0xC7:
                   print("VC newDataAktion Anschlag C home  second")
                   break
                case 0xC8:
                   print("VC newDataAktion Anschlag D home  second")
                   break
                   
                case 0xD0:
                   print("VC newDataAktion ***   ***   Letzter Abschnitt")
                   //print("VC newDataAktion  0xD0 Stepperposition: \(Stepperposition) \n\(schnittdatenstring)");
                   //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                   NotificationDic["abschnittfertig"] = Int(abschnittfertig)
                    /*
                   let nc = NotificationCenter.default
                   nc.post(name:Notification.Name(rawValue:"usbread"),
                           object: nil,
                           userInfo: NotificationDic)
                    */
                  // return
                     
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
                
                 /*
                 if Stepperposition > CNCPositionFeld.integerValue
                      {
                          PositionFeld.integerValue = stepperposition
                          ProfilFeld.stepperposition = stepperposition - 1
                          ProfilFeld.needsDisplay = true
                          
                      }
*/
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
                
                // Indexset mit relevanten Werten fuer Endanschlag
                var EndIndexSet = IndexSet(integersIn:0xAA...0xAD)  // End Abschnitt von A - D
                EndIndexSet.insert(integersIn:0xA5...0xA8)          // // Anschlag A0 - D0
                
                var HomeIndexSet = IndexSet(integersIn:0xAA...0xAD) // End Abschnitt von A - D
                EndIndexSet.insert(integersIn:0xB5...0xB8)          // Anschlag A0 home first
                
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
                         print("HomeAnschlagSet: \(HomeAnschlagSet)")
                      
                         writeCNCAbschnitt()
                         
                      }
                   }
                }
                   //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                   NotificationDic["homeanschlagset"] = Int(HomeAnschlagSet.count)
                   NotificationDic["home"] = Int(home)
                   NotificationDic["abschnittfertig"] = Int(abschnittfertig)
                   print("HotwireVC newDataAktion Notific: \(NotificationDic)")
                   
                    let nc = NotificationCenter.default
                    nc.post(name:Notification.Name(rawValue:"usbread"),
                    object: nil,
                    userInfo: NotificationDic)
                    
                
             } // if abschnittfertig > A0
             
             //writeCNCAbschnitt()
             //print("dic end\n")
              /*
              let nc = NotificationCenter.default
              nc.post(name:Notification.Name(rawValue:"usbread"),
                      object: nil,
                      userInfo: NotificationDic)
*/
          } // if count > 0
          
       } // if d
       else
       {
          print("*** newDataAktion if let d not ok")
       }
       //let dic = notification.userInfo as? [String:[UInt8]]
       //print("dic: \(dic ?? ["a":[123]])\n")
       
    }
    
    
   
   func tester(_ timer: Timer)
   {
      let theStringToPrint = timer.userInfo as! String
      print(theStringToPrint)
   }
   
   
   @IBAction func report_Slider0(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      //print("report_Slider0 IntVal: \(sender.intValue)")
      
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR0)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      print("report_Slider0 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
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
         //print("report_Slider0 senderfolg: \(senderfolg)")
      }
   }
   
   @IBAction func report_goto_0(_ sender: NSButton)
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

   func goto_0(x:Float, y:Float, z:Float)
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
   
    @IBAction func report_clear_Ring(_ sender: NSButton)
    {
      print("report_clear_Ring ")
      teensy.write_byteArray[0] = CLEAR_RING
      teensy.write_byteArray[ACHSE0_BYTE_H] = UInt8(((ACHSE0_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE0_BYTE_L] = UInt8(((ACHSE0_START) & 0x00FF) & 0xFF) // lb
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8(((ACHSE1_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8(((ACHSE1_START) & 0x00FF) & 0xFF) // lb

      teensy.write_byteArray[ACHSE2_BYTE_H] = UInt8(((ACHSE2_START) & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE2_BYTE_L] = UInt8(((ACHSE2_START) & 0x00FF) & 0xFF) // lb
 
       /*
      teensy.write_byteArray[HYP_BYTE_H] = 0 // hb
      teensy.write_byteArray[HYP_BYTE_L] = 0 // lb

      teensy.write_byteArray[INDEX_BYTE_H] = 0 // hb
      teensy.write_byteArray[INDEX_BYTE_L] = 0 // lb
        */
      Joystickfeld.clearWeg()
      servoPfad?.clearPfadarray()

      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }

   }
   
   @IBAction func report_goto_x_Stepper(_ sender: NSStepper)
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

   @IBAction func report_goto_y_Stepper(_ sender: NSStepper)
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
   
   @IBAction func report_Slider1(_ sender: NSSlider)
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

   @IBAction func report_Pot1_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot1_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_L_Feld.integerValue = intpos
      
      Pot1_Slider.minValue = sender.doubleValue 
      print("report_Pot1_Stepper_L Pot1_Slider.minValue: \(Pot1_Slider.minValue)")
      
   }
   
   @IBAction func report_Pot1_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot1_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot1_Stepper_H_Feld.integerValue = intpos
      
      Pot1_Slider.maxValue = sender.doubleValue 
      print("report_Pot1_Stepper_H Pot1_Slider.maxValue: \(Pot1_Slider.maxValue)")
      
   }

   @IBAction func report_I_Stepper(_ sender: NSStepper)
   {
      //teensy.write_byteArray[0] = SET_0 // Code 
      print("report_I_Stepper IntVal: \(sender.intValue)")
      let I = Pot1_Feld.floatValue
      let intpos = sender.intValue 
      
      let pos = sender.floatValue
      let Istring = formatter.string(from: NSNumber(value: intpos))
 //     print("report_U_Stepper u: \(u) Istring: \(Istring ?? "0")")
      Pot1_Feld.stringValue  = Istring!
      
      self.Pot1_Stepper_H.floatValue = sender.floatValue
      
      teensy.write_byteArray[ACHSE1_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE1_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
      }
   }

   @IBAction func report_StartSinus(_ sender: NSButton)
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
   @IBAction func report_StopSinus(_ sender: NSButton)
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
  
   @IBAction func report_Slider_sin(_ sender: NSSlider)
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
   
   @IBAction func report_Pot0_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot0_Stepper_L IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_L_Feld.integerValue = intpos
      
      Pot0_Slider.minValue = sender.doubleValue 
      print("report_Pot0_Stepper_L Pot0_Slider.minValue: \(Pot0_Slider.minValue)")
      
   }
   
   @IBAction func report_Pot0_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot0_Stepper_H IntVal: \(sender.integerValue)")
      
      let intpos = sender.integerValue 
      Pot0_Stepper_H_Feld.integerValue = intpos
      
      Pot0_Slider.maxValue = sender.doubleValue 
      print("report_Pot0_Stepper_H Pot0_Slider.maxValue: \(Pot0_Slider.maxValue)")
      
   }

   
   @IBAction func report_set_Pot0(_ sender: NSTextField)
   {
      teensy.write_byteArray[0] = SET_0 // Code 
      
      // senden mit faktor 1000
      //let u = Pot0_Feld.floatValue 
      let Pot0_wert = Pot0_Feld.floatValue * 100
      let Pot0_intwert = UInt(Pot0_wert)
      
      let Pot0_HI = (Pot0_intwert & 0xFF00) >> 8
      let Pot0_LO = Pot0_intwert & 0x00FF
      
      print("report_set_Pot0 Pot0_wert: \(Pot0_wert) Pot0 HI: \(Pot0_HI) Pot0 LO: \(Pot0_LO) ")
      let intpos = sender.intValue 
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
   
   
   @IBAction func report_Slider2(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      //print("report_Slider2 IntVal: \(sender.intValue)")
      let pos = sender.floatValue
      
      let intpos = UInt16(pos * FAKTOR3)
      let Ustring = formatter.string(from: NSNumber(value: intpos))
      
      //print("report_Slider2 pos: \(pos) intpos: \(intpos)  Ustring: \(Ustring ?? "0")")
      // Pot0_Feld.stringValue  = Ustring!
      Pot2_Feld.integerValue  = Int(intpos)
      Pot2_Stepper_L.integerValue  = Int(sender.minValue) // Stepper min setzen
      Pot2_Stepper_L_Feld.integerValue = Int(sender.minValue)
      Pot2_Stepper_H.integerValue  = Int(sender.maxValue) // Stepper max setzen
      Pot2_Stepper_H_Feld.integerValue = Int(sender.maxValue)
      
      teensy.write_byteArray[ACHSE3_BYTE_H] = UInt8((intpos & 0xFF00) >> 8) // hb
      teensy.write_byteArray[ACHSE3_BYTE_L] = UInt8((intpos & 0x00FF) & 0xFF) // lb
      
      if (usbstatus > 0)
      {
         let senderfolg = teensy.send_USB()
         //print("report_Slider2 senderfolg: \(senderfolg)")
      }
   }
   @IBAction  func report_Pot2_Stepper_H(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_H IntVal: \(sender.integerValue)")
   }
   @IBAction  func report_Pot2_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
      print("report_Pot2_Stepper_L IntVal: \(sender.integerValue)")

   }
   
   @IBAction  func report_Slider3(_ sender: NSSlider)
   {
      teensy.write_byteArray[0] = SET_3 // Code 
      print("report_Slider3 IntVal: \(sender.intValue)")
   }


   @IBAction func report_set_Pot1(_ sender: AnyObject)
   {
      
   }

   @IBAction  func report_Pot3_Stepper_L(_ sender: NSStepper) // untere Grenze
   {
   }
   @IBAction  func report_Pot3_Stepper_H(_ sender: NSStepper)// Obere Grenze
   {
      print("report_Pot3_Stepper_H IntVal: \(sender.integerValue)")
   }
   
   @IBAction func report_start_UDP(_ sender: AnyObject)
   {
      
      
   }
    
   @IBAction func report_start_read_USB(_ sender: AnyObject)
   {
      //myUSBController.startRead(1)
      if teensy.dev_present() > 0
      {
         var timerdic = [String:Any]()
         var start_read_USB_erfolg = teensy.start_read_USB(true,dic:timerdic)
         
          Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = true

      }
      else
      {
          
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "report_start_read_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
           
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false
      }
    }
   
   @IBAction func check_USB(_ sender: NSButton)
   {
      let present = teensy.dev_present()
      let hidstatus = teensy.status()
      let nc = NotificationCenter.default
      var userinformation:[String : Any]
      print("USBOpen usbstatus vor check: \(usbstatus) hidstatus: \(hidstatus) present: \(present)")
      if (hidstatus > 0) // already open
      {
         print("USB-Device ist schon da")
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "USB-Device ist schon da"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         USB_OK_Feld.image = okimage
         
         //   return
         
      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "Welches Board?"
         let boardarray = BoardPop.itemTitles 
         for titel in boardarray
         {
            let buttonstring = titel
            warnung.addButton(withTitle: titel)
         }
         warnung.addButton(withTitle: "cancel")
         let devicereturn:Int = warnung.runModal().rawValue
         boardindex = devicereturn-1000
         print("devicereturn: \(devicereturn)")
         if boardindex >= teensyboardarray.count
         {
            return;
         }
         let device = teensyboardarray[boardindex]
         let erfolg = teensy.USBOpen(code:device,  board: boardindex)
          usbstatus = Int(erfolg)
         globalusbstatus = Int(erfolg)
         //   print("USBOpen erfolg: \(erfolg) usbstatus: \(usbstatus)")
      }
      
      
      if (rawhid_status()==1)
      {
         print("status 1")
         USB_OK_Feld.image = okimage
         print("USB-Device da")
         /*
          let warnung = NSAlert.init()
          warnung.messageText = "USB"
          warnung.messageText = "USB-Device ist da"
          warnung.addButton(withTitle: "OK")
          //warnung.runModal()
          */
         let manu = get_manu()
         //println(manu) // ok, Zahl
         //         var manustring = UnsafePointer<CUnsignedChar>(manu)
         //println(manustring) // ok, Zahl
         
         let manufactorername = String(cString: UnsafePointer(manu!))
         //  print("str: ", manufactorername)
         manufactorer.stringValue = manufactorername
         
         //manufactorer.stringValue = "Manufactorer: " + teensy.manufactorer()!
         Start_Knopf.isEnabled = true
         Send_Knopf.isEnabled = true
         
         userinformation = ["message":"usb", "usbstatus": 1] as [String : Any]
         
      }
      else
      
      {
         print("status 0")
         // USB_OK.backgroundColor = NSColor.yellow
         // USB_OK.stringValue = "-"
         USB_OK_Feld.image = notokimage
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "check_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         userinformation = ["message":"usb", "usbstatus": 0] as [String : Any]
         nc.post(name:Notification.Name(rawValue:"usb_status"),
                 object: nil,
                 userInfo: userinformation)
         
         /*
          if let taste = USB_OK
          {
          //print("Taste USB_OK ist nicht nil")
          taste.backgroundColor = NSColor.red
          //USB_OK.backgroundColor = NSColor.redColor()
          
          }
          else
          {
          print("Taste USB_OK ist nil")
          }*/ 
         Start_Knopf.isEnabled = false
         Stop_Knopf.isEnabled = false
         Send_Knopf.isEnabled = false
         
         //return
      }
      nc.post(name:Notification.Name(rawValue:"usb_status"),
              object: nil,
              userInfo: userinformation)
      
      //print("antwort: \(teensy.status())")
   }
   
   @IBAction func report_stop_read_USB(_ sender: AnyObject)
   {
      if teensy.dev_present() > 0
      {
         teensy.read_OK = false
         if teensy.dev_present() > 0
         {
            Start_Knopf.isEnabled = true
            Send_Knopf.isEnabled = true
         }
         else
         {
            Start_Knopf.isEnabled = false
         }
         Stop_Knopf.isEnabled = false
      }
   }
   
   @IBAction func send_USB(_ sender: AnyObject)
   {
      //NSBeep()
      if teensy.dev_present() > 0
      {
         var senderfolg = teensy.send_USB()
      }
      else
      {
         let warnung = NSAlert.init()
         warnung.messageText = "USB"
         warnung.messageText = "send_USB: Kein USB-Device"
         warnung.addButton(withTitle: "OK")
         warnung.runModal()
         Send_Knopf.isEnabled = false

      }
      
      //println("send_USB senderfolg: \(senderfolg)")
      
      
      /*
      var USB_Zugang = USBController()
      USB_Zugang.setKontrollIndex(5)
      
      Counter.intValue = USB_Zugang.kontrollIndex()
      
      // var  out  = 0
      
      //USB_Zugang.Alert("Hoppla")
      
      var x = getX()
      Counter.intValue = x
      
      var    out = rawhid_open(1, 0x16C0, 0x0480, 0xFFAB, 0x0200)
      
      println("send_USB out: \(out)")
      
      if (out <= 0)
      {
      usbstatus = 0
      Anzeige.stringValue = "not OK"
      println("kein USB-Device")
      }
      else
      {
      usbstatus = 1
      println("USB-Device da")
      var manu = get_manu()
      //println(manu) // ok, Zahl
      var manustring = UnsafePointer<CUnsignedChar>(manu)
      //println(manustring) // ok, Zahl
      
      let manufactorername = String.fromCString(UnsafePointer(manu))
      println("str: %s", manufactorername!)
      manufactorer.stringValue = manufactorername!
      
      /*
      var strA = ""
      strA.append(Character("d"))
      strA.append(UnicodeScalar("e"))
      println(strA)
      
      let x = manu
      let s = "manufactorer"
      println("The \(s) is \(manu)")
      var pi = 3.14159
      NSLog("PI: %.7f", pi)
      let avgTemp = 66.844322156
      println(NSString(format:"AAA: %.2f", avgTemp))
      */
      }
      */
      
   }
   

   @IBAction func report_BoardPop(_ sender: NSPopUpButton) 
   {
      let board = sender.titleOfSelectedItem
      
      let boardtag = sender.selectedItem?.tag
      print("Board: \(board) boardtag: \(boardtag)")
      
   }
    
   
   @nonobjc  func windowShouldClose(_ sender: Any) 
   {
      print("windowShouldClose")
      NSApplication.shared.terminate(self)
   }
   
   override var representedObject: Any? 
      {
      didSet {
         // Update the view, if already loaded.
      }
   }
   
   func getPlist(withName name: String) -> [String]?
   {
      // https://learnappmaking.com/plist-property-list-swift-how-to/
      if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
         let xml = FileManager.default.contents(atPath: path)
      {
         return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String]
      }
      
      return nil
   }
   
   
   //MARK: Konstanten
   // const fuer USB
   let SET_0:UInt8 = 0xA1
   let SET_1:UInt8 = 0xB1
   
   let SET_2:UInt8 = 0xC1
   let SET_3:UInt8 = 0xD1
   
   let SET_ROB:UInt8 = 0xA2
   
   let SET_DRAW:UInt8 = 0xD2
   
   let SET_P:UInt8 = 0xA3
   let GET_P:UInt8 = 0xB3
   
   let SIN_START:UInt8 = 0xE0
   let SIN_END:UInt8 = 0xE1
   
   let U_DIVIDER:Float = 9.8
   let ADC_REF:Float = 3.26
   
   let ACHSE0_BYTE_H = 0
   let ACHSE0_BYTE_L = 1
   let ACHSE0_START_BYTE_H = 2
   let ACHSE0_START_BYTE_L = 3

   
   let ACHSE1_BYTE_H = 4
   let ACHSE1_BYTE_L = 5
   let ACHSE1_START_BYTE_H = 6
   let ACHSE1_START_BYTE_L = 7
  
   let ACHSE2_BYTE_H = 8
   let ACHSE2_BYTE_L = 9
   let ACHSE2_START_BYTE_H = 10
   let ACHSE2_START_BYTE_L = 11
   
   let ACHSE3_BYTE_H = 12
   let ACHSE3_BYTE_L = 13
   let ACHSE3_START_BYTE_H = 14
   let ACHSE3_START_BYTE_L = 15

   
   
   let HYP_BYTE_H = 32 // Hypotenuse
   let HYP_BYTE_L = 33
   
   let INDEX_BYTE_H = 18
   let INDEX_BYTE_L = 19
   
   let STEPS_BYTE_H = 36
   let STEPS_BYTE_L = 37
   
   
   
  
   
   //MARK:      Outlets 
   @IBOutlet weak var Device: NSTabView!
   @IBOutlet weak var manufactorer: NSTextField!
   @IBOutlet weak var Counter: NSTextField!
   
   @IBOutlet  var Start_Knopf: NSButton!
   @IBOutlet  var Stop_Knopf: NSButton!
   @IBOutlet weak var Send_Knopf: NSButton!
   @IBOutlet weak var Start_Read_Knopf: NSButton!
   
   @IBOutlet weak var Anzeige: NSTextField!
   
   //@IBOutlet weak var USB_OK: NSTextField!
  // @IBOutlet weak var USB_OK_Feld: NSImageView!
   
   @IBOutlet weak var check_USB_Knopf: NSButton!
   @IBOutlet weak var BoardPop:NSPopUpButton!
   
   //@IBOutlet weak var start_read_USB_Knopf: NSButtonCell!
   
   @IBOutlet weak var codeFeld: NSTextField!
   
   @IBOutlet weak var dataFeld: NSTextField!
   
   @IBOutlet weak var schrittweiteFeld: NSTextField!
   
   @IBOutlet weak var Pot0_Feld: NSTextField!
   @IBOutlet weak var Pot0_Slider: NSSlider!
   @IBOutlet weak var Pot0_Stepper_H: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L: NSStepper!
   @IBOutlet weak var Pot0_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot0_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot0_Inverse_Check: NSButton!
   
   @IBOutlet weak var joystick_x: NSTextField!
   @IBOutlet weak var joystick_y: NSTextField!
   
   @IBOutlet weak var goto_x: NSTextField!
   @IBOutlet weak var goto_x_Stepper: NSStepper!
   @IBOutlet weak var goto_y: NSTextField!
   @IBOutlet weak var goto_y_Stepper: NSStepper!
   
   @IBOutlet weak var Pot1_Feld_raw: NSTextField!
   @IBOutlet weak var Pot1_Feld: NSTextField!
   @IBOutlet weak var Pot1_Slider: NSSlider!
   @IBOutlet weak var Pot1_Stepper_H: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L: NSStepper!
   @IBOutlet weak var Pot1_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot1_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot1_Inverse_Check: NSButton!
   
   @IBOutlet weak var Pot2_Feld_raw: NSTextField!
   @IBOutlet weak var Pot2_Feld: NSTextField!
   @IBOutlet weak var Pot2_Slider: NSSlider!
   @IBOutlet weak var Pot2_Stepper: NSStepper!
   @IBOutlet weak var Pot2_Stepper_H: NSStepper!
   @IBOutlet weak var Pot2_Stepper_L: NSStepper!
   @IBOutlet weak var Pot2_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot2_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot2_Inverse_Check: NSButton!
   
   @IBOutlet weak var Pot3_Feld_raw: NSTextField!
   @IBOutlet weak var Pot3_Feld: NSTextField!
   @IBOutlet weak var Pot3_Slider: NSSlider!
   @IBOutlet weak var Pot3_Stepper: NSStepper!
   @IBOutlet weak var Pot3_Stepper_H: NSStepper!
   @IBOutlet weak var Pot3_Stepper_L: NSStepper!
   @IBOutlet weak var Pot3_Stepper_L_Feld: NSTextField!
   @IBOutlet weak var Pot3_Stepper_H_Feld: NSTextField!
   @IBOutlet weak var Pot3_Inverse_Check: NSButton!
   
   @IBOutlet weak var Joystickfeld: rJoystickView!
   
   @IBOutlet weak var clear_Ring: NSButton!
   
   @IBOutlet weak var ObjekteMenu: NSMenu!
   
}
protocol UIntToBytesConvertable {
    var toBytes: [UInt8] { get }
}

extension UIntToBytesConvertable {
    func toByteArr<T: BinaryInteger>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
}

extension UInt16: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
            return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt16>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                             count: MemoryLayout<UInt16>.size)
        }
    }
}

extension UInt32: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt32>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                             count: MemoryLayout<UInt32>.size)
        }
    }
}

extension UInt64: UIntToBytesConvertable {
    var toBytes: [UInt8] {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
        return toByteArr(endian: self.littleEndian,
                         count: MemoryLayout<UInt64>.size)
        } else {
            return toByteArr(endian: self.bigEndian,
                             count: MemoryLayout<UInt64>.size)
        }
    }
}
extension NSBezierPath
{
   func rotateAroundCenter(angle: CGFloat)
   {
      let midh = NSMidX(self.bounds)/2
      let midv = NSMidY(self.bounds)/2
      let center = NSMakePoint(midh, midv)
      var transform = NSAffineTransform()
      //     transform.rotate(byDegrees: angle)
      //     self.transform(using: transform as AffineTransform)
      
      let originBounds:NSRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y , self.bounds.size.width, self.bounds.size.height )
      Swift.print("rotateAround bounds vor rotate origin x: \(self.bounds.origin.x) y: \(self.bounds.origin.y) size h: \(self.bounds.height) w: \(self.bounds.width)")
      
      transform = NSAffineTransform()
      transform.translateX(by: +(NSWidth(originBounds) / 2 ), yBy: +(NSHeight(originBounds) / 2))
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -(NSWidth(originBounds) / 2 ), yBy: -(NSHeight(originBounds) / 2))
      
      //   transform = transform.rotated(by: angle)
      //   transform = transform.translatedBy(x: -center.x, y: -center.y)
      self.transform(using:transform as AffineTransform)
      
      Swift.print("rotateAround bounds nach rotate origin x: \(self.bounds.origin.x) y: \(self.bounds.origin.y) size h: \(self.bounds.height) w: \(self.bounds.width)")
      
   }
   
   // https://stackoverflow.com/questions/50012606/how-to-rotate-uibezierpath-around-center-of-its-own-bounds
   func rotateAroundCenterB(angle: CGFloat)
   {
      let midh = NSMidX(self.bounds)
      let midv = NSMidY(self.bounds)
      let center = NSMakePoint(midh, midv)

      var transform = NSAffineTransform()
      transform.translateX(by: center.x, yBy: center.y)
      transform.rotate(byDegrees: angle)
      transform.translateX(by: -center.x, yBy: -center.y)
      self.transform(using:transform as AffineTransform)
   }

}
