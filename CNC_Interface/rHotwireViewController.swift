//
//  rHotwire.swift
//  CNC_Interface
//
//  Created by Ruedi Heimlicher on 01.07.2022.
//  Copyright © 2022 Ruedi Heimlicher. All rights reserved.
//

import Cocoa
import Foundation

var outletdaten:[String:AnyObject] = [:]

@objc class rPfeil_Feld:NSImageView
{
    var releasediconarray:[NSImage] = []
    var pressediconarray:[NSImage] = []
    /*
      richtung:
      right: 1
      up: 2
      left: 3
      down: 4
      */

    
    var pfeilrechtsreleased :NSImage = NSImage(named:NSImage.Name(rawValue: "pfeil_rechts_grau"))!
    var pfeilrechtspressed :NSImage = NSImage(named:NSImage.Name(rawValue: "pfeil_rechts"))!
    
    
    
    var feldklickcounter = 0;
    
     
    func acceptsFirstResponder() -> ObjCBool {return true}
    func canBecomeKeyView ()->ObjCBool {return true}
    required init?(coder  aDecoder : NSCoder)
    {
        //print("rPfeil_Taste required init")
        super.init(coder: aDecoder)
        
        releasediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_rechts_grau"))!)
        releasediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_up_grau"))!)
        releasediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_links_grau"))!)
        releasediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_down_grau"))!)

        pressediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_rechts"))!)
        pressediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_up"))!)
        pressediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_links"))!)
        pressediconarray.append(NSImage(named:NSImage.Name(rawValue: "pfeil_down"))!)

        /*
        var imageView = NSImageView(frame: CGRect(origin: .zero, size: pfeilrechtspressed.size))
        imageView.image = pfeilrechtsreleased
        imageView.alphaValue = 1.0
        pfeilrechtspressed = imageView.image!
        imageView = NSImageView(frame: CGRect(origin: .zero, size: pfeilrechtsreleased.size))
        imageView.image = pfeilrechtsreleased
        imageView.alphaValue = 0.1
        pfeilrechtsreleased = imageView.image!
         */
        self.image = releasediconarray[self.tag-1]
    }
    override func mouseDown(with theEvent: NSEvent)
    {
        super.mouseDown(with: theEvent)
        let startPoint = theEvent.locationInWindow
            print(startPoint) //for top left it prints (0, 900)
        feldklickcounter += 1
        print("swift Pfeil_Feld mouseDown  feldklickcounter: \(feldklickcounter)")
        let pfeiltag:Int = self.tag
        self.image = pressediconarray[self.tag-1]
        
        var userinformation:[String : Any]
        userinformation = ["richtung":pfeiltag,  "push": 1 ] as [String : Any]

        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"pfeilfeld" ),
                 object: nil,
                 userInfo: userinformation)

        
    }
    
    override func mouseUp(with theEvent: NSEvent)
    {
        super.mouseUp(with: theEvent)
        let startPoint = theEvent.locationInWindow
            print(startPoint) //for top left it prints (0, 900)
        feldklickcounter += 1
        print("swift Pfeil_Feld mouseUp  feldklickcounter: \(feldklickcounter)")
        let pfeiltag:Int = self.tag
        self.image = releasediconarray[self.tag-1]
        var userinformation:[String : Any]
        userinformation = ["richtung":pfeiltag,  "push": 0 , ] as [String : Any]

        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"pfeilfeld"),
                 object: nil,
                 userInfo: userinformation)

    }

    
} //rPfeil_Feld



@objc class rPfeil_Taste:NSButton
{
    var mousedowncounter = 0;
    
    
    
    required init?(coder  aDecoder : NSCoder)
    {
        //print("rPfeil_Taste required init")
        super.init(coder: aDecoder)
        
    }
    
    override func mouseDown(with theEvent: NSEvent)
    {
        super.mouseDown(with: theEvent)
        //mousedowncounter += 1
        print("swift Pfeil_Taste mouseDown  mousedowncounter: \(mousedowncounter)")
        let pfeiltag:Int = self.tag
        
        
        var userinformation:[String : Any]
        userinformation = ["richtung":pfeiltag,  "push": 1 , "mousedowncounter":mousedowncounter] as [String : Any]

        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"pfeil" ),
                 object: nil,
                 userInfo: userinformation)

        self.mouseUp(with:theEvent)
        
    }
    
    @objc override func mouseUp(with theEvent: NSEvent)
    {
        super.mouseUp(with: theEvent)
        print("swift Pfeiltaste mouseup")
        let pfeiltag:Int = self.tag
        
        /*
          richtung:
          right: 1
          up: 2
          left: 3
          down: 4
          */
        var userinformation:[String : Any]
        userinformation = ["richtung":pfeiltag,  "push": 0 , "mousedowncounter":mousedowncounter] as [String : Any]

        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"pfeil"),
                 object: nil,
                 userInfo: userinformation)

        
    }

    
    @objc func reportPfeiltaste(pfeiltag:Int)
    {
        print("reportPfeiltaste")
    }
}


@objc class rHotwireViewController: rViewController, NSTableViewDataSource, NSTableViewDelegate
{
      
   var hintergrundfarbe:NSColor = NSColor()
   //rTSP_NN* nn;
   var nn:rTSP_NN!
   // var micro:Int!
    //var AVR = rAVRview()
    
   var CNC_PList:NSMutableDictionary!
   
   //var ProfilTable: NSTableView!
   //var ProfilDaten: NSMutableArray!
   
    var motorsteps = 47
    var speed = 6
    var quelle:Int = 0
    
    let  FIRST_BIT = 0 // in 'position' von reportStopKnopf: Abschnitt ist first
    let  LAST_BIT = 1 // in 'position' von reportStopKnopf: Abschnitt ist last

   var  oldMauspunkt :  NSPoint  = NSZeroPoint
   /*
   var ProfilDatenOA: NSArray
   var ProfilDatenUA: NSArray
    var ProfilDatenOB: NSArray
   var ProfilDatenUB: NSArray
*/
   
   //var   Scale: Double!;
   var   cncposition: Int!
   //var   cncstatus: Double!

   var GraphEnd: Int!
   
   var   CNC_busy: Int!
   var   ProfilTiefe: Int!
   var   ProfilZoom: Double!
   var   mitOberseite: Int!
   var   mitUnterseite: Int!
   var   mitEinlauf: Int!
   var   mitAuslauf: Int!
   var   flipH: Int!
   var   flipV: Int!
   var   reverse: Int!
   var   einlauflaenge: Int!
   var   einlauftiefe: Int!
   var   einlaufrand: Int!
   var   auslauflaenge: Int!
   var   auslauftiefe: Int!
   var   auslaufrand: Int!

   struct RumpfDaten
   {
      var breitea = 30
      var breiteb = 16
      var einstichtiefe = 16
      var elementlaenge = 560
      var hoehea = 15
      var hoeheb = 8
      var portalabstand = 690
      var radiusa = 8
      var radiusb = 4
      var rand = 10
      var rumpfabstand = 50
      var rumpfauslauf = 15
      var rumpfblockbreite = 80
      var rumpfblockhoehe = 40
      var rumpfeinlauf = 15
      var rumpfmicro = 1
      var rumpfoffsetx = 8.5
      var rumpfoffsety = 0.0
      var rumpfportalabstand = 690
      var rumpfpwm = 92
      var rumpfspeed = 7
    var   motorsteps = 48
       var speed = 7
   }
    
    var hotwireplist:[String:AnyObject] = [:]
   var RahmenDic:[String:Double] = [:]
   
   var KoordinatenTabelle = [[String:Double]]()
    var  BlockKoordinatenTabelle = [[String:Double]]()
    var  BlockrahmenArray = [String]()
    var CNC_DatenArray = [String:Double]()
    var SchnittdatenArray = [[Int]]()
    var KoordinatenFormatter = NumberFormatter()
    
    var RumpfdatenArray = [[String:Double]]()
    var taskfertig = 0
    
    var CNC_Eingabe = rEinstellungen()
    
    @IBOutlet weak var  PfeilfeldLinks: rPfeil_Feld!
   @IBOutlet weak var intpos0Feld: NSStepper!
   //@IBOutlet weak var StepperTab: rTabview!
    
   //@IBOutlet weak var TaskTab: rTabview!
   //@IBOutlet weak var  ProfilFeld: NSTextField!
    
    @IBOutlet weak var  CNC_Tabview:  rDeviceTabViewController!
    
   @IBOutlet weak var  GFKFeldA: NSTextField!
   @IBOutlet weak var  GFKFeldB: NSTextField!

    
   @IBOutlet weak var  ProfilTiefeFeldA: NSTextField!
   @IBOutlet weak var  ProfilTiefeFeldB: NSTextField!

   @IBOutlet weak var  Einlauflaenge: NSTextField!
   @IBOutlet weak var  Einlauftiefe: NSTextField!

   @IBOutlet weak var  Auslauflaenge: NSTextField!
   @IBOutlet weak var  Auslauftiefe: NSTextField!

   @IBOutlet weak var  ProfilBOffsetYFeld: NSTextField!
   @IBOutlet weak var  ProfilBOffsetXFeld: NSTextField!
    
   @IBOutlet weak var  ProfilWrenchFeld: NSTextField! // Schränkung
   @IBOutlet weak var  ProfilWrenchEinheitRadio: NSMatrix!
   @IBOutlet weak var  HorizontalSchieberFeld: NSTextField!
   @IBOutlet weak var  VertikalSchieberFeld: NSTextField!
   @IBOutlet weak var  HorizontalSchieber: NSTextField!
   @IBOutlet weak var  VertikalSchieber: NSTextField!
    
   @IBOutlet weak var  SpeedStepper: NSStepper!
   @IBOutlet weak var  SpeedFeld: NSTextField!

   @IBOutlet weak var  ProfilNameFeldA: NSTextField!
   @IBOutlet weak var  ProfilNameFeldB: NSTextField!

   @IBOutlet weak var  StopKoordinate: NSTextField!
   @IBOutlet weak var  StartKoordinate: NSTextField!
   @IBOutlet weak var  Adresse: NSTextField!
   @IBOutlet weak var  Cmd: NSTextField!
   @IBOutlet weak var  CNCKnopf: NSTextField!
   @IBOutlet weak var  OberseiteCheckbox: NSButton!
   @IBOutlet weak var  UnterseiteCheckbox: NSButton!
   @IBOutlet weak var  OberseiteTaste: NSButton!
   @IBOutlet weak var  UnterseiteTaste: NSButton!
    
    @IBOutlet weak var  AndereSeiteTaste: NSButton!
   
   @IBOutlet weak var  EinlaufCheckbox: NSButton!
   @IBOutlet weak var  AuslaufCheckbox: NSButton!
   
   @IBOutlet  var  AbbrandCheckbox: NSButton!
   
   @IBOutlet weak var  ScalePop: NSPopUpButton!
   @IBOutlet weak var  Profil1Pop: NSPopUpButton!
   @IBOutlet weak var  Profil2Pop: NSPopUpButton!
   
   @IBOutlet  var  CNC_Table: NSTableView!
   @IBOutlet  weak var  CNC_Scroller: NSScrollView!
    @IBOutlet  weak var  TaskTab: NSTabView!
   // CNC
   @IBOutlet weak var CNC_Preparetaste: NSButton!
   @IBOutlet weak var CNC_Starttaste: NSButton!
   @IBOutlet weak var CNC_Stoptaste: NSButton!
   @IBOutlet weak var CNC_Sendtaste: NSButton!
   @IBOutlet weak var CNC_Terminatetaste: NSButton!
   @IBOutlet weak var CNC_Neutaste: NSButton!
   @IBOutlet weak var CNC_Halttaste: NSButton!
   @IBOutlet weak var DC_Taste: NSButton!
   @IBOutlet weak var DC_Stepper: NSStepper!
   @IBOutlet weak var DC_Slider: NSSlider!
   @IBOutlet weak var DC_PWM: NSTextField!
   @IBOutlet weak var CNC_StepsSegControl: NSSegmentedControl!
   @IBOutlet weak var CNC_microPop: NSPopUpButton!

   @IBOutlet weak var CNC_Uptaste: NSButton!
   @IBOutlet weak var CNC_Downtaste: NSButton!
   @IBOutlet weak var CNC_Lefttaste: NSButton!
   @IBOutlet weak var CNC_busySpinner: NSProgressIndicator!
    
   @IBOutlet weak var CNC_Linkstaste: NSButton!
    
   @IBOutlet weak var CNC_Righttaste: NSButton!
    
   @IBOutlet weak var CNC_Seite1Check: NSButton!
    @objc var  cnc_seite1check:Int = 0
   @IBOutlet weak var CNC_Seite2Check: NSButton!
    @objc var  cnc_seite2check:Int = 0
   @IBOutlet weak var CNC_BlockKonfigurierenTaste: NSButton!
   @IBOutlet weak var CNC_BlockAnfuegenTaste: NSButton!

    
   @IBOutlet weak var  Pfeiltaste: rPfeil_Taste!
    
   @IBOutlet  var IndexFeld: NSTextField!
   @IBOutlet  var IndexStepper: NSStepper!

   @IBOutlet  var WertAXFeld: NSTextField!
   @IBOutlet  var WertAXStepper: NSStepper!
   @IBOutlet  var WertAYFeld: NSTextField!
   @IBOutlet weak var WertAYStepper: NSStepper!
    
   @IBOutlet  var WertBXFeld: NSTextField!
   @IBOutlet weak var WertBXStepper: NSStepper!
   @IBOutlet  var WertBYFeld: NSTextField!
   @IBOutlet weak var WertBYStepper: NSStepper!
    
   @IBOutlet weak var ABBindCheck: NSButton!

   @IBOutlet weak var LagePop: NSPopUpButton!
   @IBOutlet weak var WinkelFeld: NSTextField!
   @IBOutlet weak var WinkelStepper: NSStepper!

 //  @IBOutlet weak var PWMFeld: NSTextField!
 //  @IBOutlet weak var PWMStepper: NSStepper!

   @IBOutlet weak var AbbrandFeld: NSTextField!

   @IBOutlet weak var GleichesProfilRadioKnopf: NSButton!
   @IBOutlet weak var WertFeld: NSTextField!
    
   @IBOutlet weak var PositionFeld: NSTextField!
   @IBOutlet weak var AnzahlFeld: NSTextField!
   @IBOutlet weak var PositionXFeld: NSTextField!
   @IBOutlet weak var PositionYFeld: NSTextField!
    
   @IBOutlet weak var SaveChangeTaste: NSButton!
   @IBOutlet weak var ShiftAllTaste: NSButton!
    
   @IBOutlet weak var Blockoberkante: NSTextField!
   @IBOutlet weak var OberkantenStepper: NSStepper!
   @IBOutlet weak var Blockbreite: NSTextField!
   @IBOutlet weak var Blockdicke: NSTextField!
    
   @IBOutlet weak var RumpfBlockbreite: NSTextField!
   @IBOutlet weak var RumpfBlockhoehe: NSTextField!

    
   @IBOutlet weak var Einlaufrand: NSTextField!
   @IBOutlet weak var Auslaufrand: NSTextField!
   @IBOutlet weak var AnschlagLinksIndikator: NSBox!
   @IBOutlet weak var AnschlagUntenIndikator: NSBox!
    
   @IBOutlet weak var Basisabstand: NSTextField!  // Abstand CNC zu Block
   @IBOutlet weak var Portalabstand: NSTextField!
   @IBOutlet weak var Spannweite: NSTextField!  //
    
   @IBOutlet weak var startdelayFeld: NSTextField!  //
    
   //@IBOutlet weak var USBKontrolle!
    
   @IBOutlet weak var HomeTaste: NSButton!

   @IBOutlet weak var SeitenVertauschenTaste: NSButton!
   @IBOutlet weak var NeuesElementTaste: NSButton!
    
   @IBOutlet weak var AbmessungX: NSTextField!
   @IBOutlet weak var AbmessungY: NSTextField!
    
   @IBOutlet weak var red_pwmFeld: NSTextField!

   @IBOutlet weak var LinkeRechteSeite: NSButton!
    
   @IBOutlet weak var VersionFeld: NSTextField!
   @IBOutlet weak var DatumFeld: NSTextField!
   @IBOutlet weak var SlaveVersionFeld: NSTextField!


   @IBOutlet weak var ManufactorerFeld:  NSTextField!
    @IBOutlet weak var ProductFeld:  NSTextField!
    @IBOutlet weak var MinimaldistanzFeld:  NSTextField!
    
    @IBOutlet weak var BlockbreiteFeld:  NSTextField!
    @IBOutlet weak var BlockbreiteStepper:  NSTextField!
    
    @IBOutlet weak var  ProfilFeld: rProfilfeldView!
    
    // Rumpf
    @IBOutlet weak var RandFeld:  NSTextField!
    @IBOutlet weak var EinlaufFeld:  NSTextField!
    @IBOutlet weak var BreiteAFeld:  NSTextField!
    @IBOutlet  var HoeheAFeld:  NSTextField!
    @IBOutlet  var RadiusAFeld:  NSTextField!
    @IBOutlet  var AuslaufFeld:  NSTextField!
    @IBOutlet  var BreiteBFeld:  NSTextField!
    @IBOutlet  var HoeheBFeld:  NSTextField!
    @IBOutlet  var RadiusBFeld:  NSTextField!
    @IBOutlet weak var EinstichtiefeFeld:  NSTextField!
    //@IBOutlet weak var RumpfblockhoeheFeld:  NSTextField!
    @IBOutlet weak var RumpfabstandFeld:  NSTextField! // Abstand CNC zu Block
    @IBOutlet weak var ElementlaengeFeld:  NSTextField! // Laenge des Rumpfabschnittes
    @IBOutlet weak var RumpfOffsetXFeld:  NSTextField!
    @IBOutlet weak var RumpfOffsetYFeld:  NSTextField!
    @IBOutlet weak var RumpfportalabstandFeld:  NSTextField!
    
    @IBOutlet weak var Schalendickefeld:  NSTextField!
    @IBOutlet weak var NutCheckbox:  NSButton!
    

    @IBOutlet weak var  RumpfteilTaste:  NSSegmentedControl!
    
    let MANRIGHT    = 1
    let MANUP       = 2
    let MANLEFT     = 3
    let MANDOWN     = 4

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
   //       micro_Feld.integerValue = micro
       }
*/
    @objc func vertikalspiegelnVonProfil(profilarray:[[String:Double]]) -> [[String:Double]]
    {
        var fliparray = [[String:Double]]()
        if profilarray.count == 0
        {
            return fliparray
        }
        for i in 0..<profilarray.count
        {
            var tempzeile = profilarray[i]
            let flip = tempzeile["y"]
            tempzeile["y"] = flip! * -1
            
            fliparray.append(tempzeile)
        }
        return fliparray
    }
    
    @objc func LibElementeingabeAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        print("swift LibElementeingabeAktion: \(info)")
        var infoDic = notification.userInfo as? [String:Any]
        
        
        print("LibElementeingabeAktion KoordinatenTabelle Start: \(KoordinatenTabelle)")

        var ax:Double = 0
        var ay:Double = 0
        var bx:Double = 0
        var by:Double = 0

        var StartpunktA:NSPoint
        var StartpunktB:NSPoint
 
        // letztes Element der Koordinatentabelle
        if KoordinatenTabelle.count > 0
        {
            ax = (KoordinatenTabelle.last?["ax"])!
            ay = (KoordinatenTabelle.last?["ay"])!
            bx = (KoordinatenTabelle.last?["bx"])!
            by = (KoordinatenTabelle.last?["by"])!
            
            StartpunktA = NSMakePoint(ax,ay)
            StartpunktB = NSMakePoint(bx,by)
        }
        else
        {
            ax = 25
            ay = 55
            bx = 25
            by = 55
            StartpunktA = NSMakePoint(ax,ay)
            StartpunktB = NSMakePoint(bx,by)
        }
        let offsetx:Double = ProfilBOffsetXFeld.doubleValue
        let offsety:Double = ProfilBOffsetYFeld.doubleValue
        var startx:Double = 0
        var starty:Double = 0
        
        if let tempstartx = infoDic?["startx"]
        {
            startx = tempstartx as! Double
        }
        else
        {
        }
 
        if let tempstarty = infoDic?["starty"]
        {
            starty = tempstarty as! Double
        }
        else
        {
        }
        
        
        var pwm:Double = 0
        if let tempwert = infoDic?["pwm"]
        {
            pwm = tempwert as! Double
        }
        else
        {
        }

        
        
        var oldax:Double? = 0
        var olday:Double? = 0
        var oldbx:Double? = offsetx
        var oldby:Double? = offsety
        
        
        if KoordinatenTabelle.count > 0
        {
            oldax = (KoordinatenTabelle.last?["ax"] ?? 0) - startx
            olday = (KoordinatenTabelle.last?["ay"] ?? 0) - starty
            oldbx = (KoordinatenTabelle.last?["bx"] ?? 0) - startx
            oldby = (KoordinatenTabelle.last?["by"] ?? 0) - starty
        }

        var tempElementKoordinatenArray = infoDic?["koordinatentabelle"] as? [[Double]]
        let anz:Int = tempElementKoordinatenArray!.count
        for i in 0..<anz
        {
            let zeile = tempElementKoordinatenArray?[i]
        //    let dx:Double = tempElementKoordinatenArray?[i][0] ?? 0
        //    let dy:Double = tempElementKoordinatenArray?[i][1] ?? 0
            let ax:Double = tempElementKoordinatenArray?[i][0] ?? 0
            let ay:Double = tempElementKoordinatenArray?[i][1] ?? 0

            
            var tempDic = [String:Double]()
            tempDic["ax"] = (oldax ?? 0) + ax
            tempDic["ay"] = (olday ?? 0) + ay
            tempDic["bx"] = (oldbx ?? 0) + ax
            tempDic["by"] = (oldby ?? 0) + ay
            tempDic["index"] = Double(i)
            tempDic["pwm"] = pwm
            tempDic["teil"] = 60

            KoordinatenTabelle.append(tempDic)
        } // for i
        
        CNC_Table.reloadData()
        CNC_Table.scrollRowToVisible(KoordinatenTabelle.count - 1)
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true
        CNC_Stoptaste.isEnabled = true
    } // LibElementeingabeAktion
    
    
    @objc func LibProfileingabeAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        print("LibProfileingabeAktion: \(info)")
        var infodic = notification.userInfo as? [String:Any]
        
        
        
        // chat
        /*
        if let userInfo = notification.userInfo as? [String: Any] {
            var arrayOfDictionaries: [[String: Any]] = []

            for (_, value) in userInfo {
                if let dictionary = value as? [String: Any] {
                    arrayOfDictionaries.append(dictionary)
                }
            }

            print("arrayOfDictionaries: \(arrayOfDictionaries)")
            // Now arrayOfDictionaries contains your converted data
        }
         */
        // chat
        
        print("LibProfileingabeAktion KoordinatenTabelle Start: \(KoordinatenTabelle)")
        if KoordinatenTabelle.count == 1
        {
            let firstzeile = KoordinatenTabelle.first
            if firstzeile?["ax"] == 0 && firstzeile?["ay"] == 0 && firstzeile?["bx"] == 0 && firstzeile!["by"] == 0
            {
                KoordinatenTabelle.removeAll()
            }
            
        }
        infodic!["koordinatentabelle"] = KoordinatenTabelle
        infodic!["offsetx"] = ProfilBOffsetXFeld.doubleValue
        infodic!["offsety"] = ProfilBOffsetYFeld.doubleValue
        infodic!["profiltiefea"] = ProfilTiefeFeldA.doubleValue
        infodic!["profiltiefeb"] = ProfilTiefeFeldB.doubleValue
        infodic!["spannweite"] = Spannweite.doubleValue
        infodic!["portalabstand"] = Portalabstand.integerValue
        infodic!["basisabstand"] = Basisabstand.integerValue
        
        infodic!["profilwrench"] = ProfilWrenchFeld.doubleValue
        
        let r = ProfilWrenchEinheitRadio.selectedRow
        infodic!["wrenchradio"] = ProfilWrenchEinheitRadio.selectedRow

        infodic!["minimaldistanz"] = MinimaldistanzFeld.floatValue

        

        
        infodic!["wertax"] = 35
        infodic!["wertay"] = 25
        
        infodic!["pwm"] = DC_PWM.floatValue
        infodic!["abbrand"] = AbbrandFeld.floatValue
        
        if AbbrandCheckbox.state == NSControl.StateValue.on
        {
            infodic!["mitabbrand"] = 1
        }
        else
        {
            infodic!["mitabbrand"] = 0
        }

        infodic!["offsetx"] = ProfilBOffsetXFeld.doubleValue
        infodic!["offsety"] = ProfilBOffsetYFeld.doubleValue

        infodic!["minimaldistanz"] = MinimaldistanzFeld.floatValue
        
        let popindex:Int = ScalePop.indexOfSelectedItem
        let a = ScalePop.selectedTag()
        let popitem:NSMenuItem = ScalePop.item(at: popindex)!
        let scalefaktor = popitem.tag
        infodic!["scale"] = scalefaktor
        
        
        
   //     let eingabedic = info! as NSDictionary
        
        
        KoordinatenTabelle = AVR?.libProfileingabeFunktion(infodic) as! [[String : Double]]
        
        /*
          Werte fuer "teil":
          10:  Endleisteneinlauf
          20:  Oberseite
          30:  Unterseite, rueckwaerts eingesetzt
          40:  Nasenleisteauslauf
          50: Sicherheitsschnitt nach oben
          */
           
        if WertAXFeld.doubleValue == 0
        {
            WertAXFeld.doubleValue = 35.0
            WertBXFeld.doubleValue = 35.0
        }
        
        if WertAYFeld.doubleValue == 0
        {
            WertAYFeld.doubleValue = 55.0
            WertBYFeld.doubleValue = 55.0
        }
                  
 
        
        ProfilFeld.setScale(derScalefaktor:CGFloat(scalefaktor))
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true
        
        
        let startindexoffset = KoordinatenTabelle.count - 1
        print("LibProfileingabeAktion startindexoffset: \(startindexoffset)")
        var von:Int = 0
        var bis:Int = KoordinatenTabelle.count
        var ProfilNameA = ""
        var ProfilNameB = ""


        var origpwm:Double = DC_PWM.doubleValue
        
 return

        
        
    }// LibProfileingabeAktion
    
    
    @objc func FormeingabeAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        print("FormeingabeAktion: \(info)")
        var infoDic = notification.userInfo as? [String:Any]
  
        print("LibElementeingabeAktion KoordinatenTabelle Start: \(KoordinatenTabelle)")

        var ax:Double = 0
        var ay:Double = 0
        var bx:Double = 0
        var by:Double = 0
        
        var StartpunktA:NSPoint
        var StartpunktB:NSPoint
 

        // letztes Element der Koordinatentabelle
        if KoordinatenTabelle.count > 0
        {
            ax = (KoordinatenTabelle.last?["ax"])!
            ay = (KoordinatenTabelle.last?["ay"])!
            bx = (KoordinatenTabelle.last?["bx"])!
            by = (KoordinatenTabelle.last?["by"])!
            
            StartpunktA = NSMakePoint(ax,ay)
            StartpunktB = NSMakePoint(bx,by)
        }
        else
        {
            ax = 25
            ay = 25
            bx = 25
            by = 25
            StartpunktA = NSMakePoint(ax,ay)
            StartpunktB = NSMakePoint(bx,by)
            var tempDic = [String:Double]()
            tempDic["ax"] = ax
            tempDic["ay"] = ay
            tempDic["bx"] = bx
            tempDic["by"] = by
            tempDic["index"] = 0
            tempDic["pwm"] = Double(pwm)
            
            tempDic["teil"] = 60
            KoordinatenTabelle.append(tempDic)

        }
        
        
        let offsetx:Double = ProfilBOffsetXFeld.doubleValue
        let offsety:Double = ProfilBOffsetYFeld.doubleValue
        var startx:Double = 0
        var starty:Double = 0

        if let tempstartx = infoDic?["startx"]
        {
            startx = tempstartx as! Double
        }
        else
        {
        }
 
        if let tempstarty = infoDic?["starty"]
        {
            starty = tempstarty as! Double
        }
        else
        {
        }
        var pwm:Double = 90
        if let tempwert = infoDic?["pwm"]
        {
            pwm = tempwert as! Double
        }
        else
        {
        }

        var oldax:Double? = 0
        var olday:Double? = 0
        var oldbx:Double? = offsetx
        var oldby:Double? = offsety
        
        
        if KoordinatenTabelle.count > 0
        {
            oldax = (KoordinatenTabelle.last?["ax"] ?? 0) - startx
            olday = (KoordinatenTabelle.last?["ay"] ?? 0) - starty
            oldbx = (KoordinatenTabelle.last?["bx"] ?? 0) - startx
            oldby = (KoordinatenTabelle.last?["by"] ?? 0) - starty
        }
        var tempElementKoordinatenArray = infoDic?["koordinatentabelle"] as? [[Double]]
        let anz:Int = tempElementKoordinatenArray!.count
 
        for i in 0..<anz
        {
            let zeile = tempElementKoordinatenArray?[i]
            let ax:Double = tempElementKoordinatenArray?[i][0] ?? 0
            let ay:Double = tempElementKoordinatenArray?[i][1] ?? 0
            let bx:Double = tempElementKoordinatenArray?[i][2] ?? ax // beide Formen gleich
            let by:Double = tempElementKoordinatenArray?[i][3] ?? ay

            
            var tempDic = [String:Double]()
            tempDic["ax"] = (oldax ?? 0) + ax
            tempDic["ay"] = (olday ?? 0) + ay
            tempDic["bx"] = (oldbx ?? 0) + bx
            tempDic["by"] = (oldby ?? 0) + by
            tempDic["index"] = Double(i)
            tempDic["pwm"] = pwm
            
            tempDic["teil"] = 60
            KoordinatenTabelle.append(tempDic)
        } // for i
        
        CNC_Table.reloadData()
        CNC_Table.scrollRowToVisible(KoordinatenTabelle.count - 1)
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true
        CNC_Stoptaste.isEnabled = true

        
        
        
    }// end FormeingabeAktion
    
    @objc func neuesElementSichernAktion(_ notification:Notification) -> Bool
    {
        if KoordinatenTabelle.count == 0
        {
            NSSound.beep()
            return false
        }
        print("reportElementSichern  KoordinatenTabelle Start: \(KoordinatenTabelle)")
         
        var startax:Double = 0
        var startay:Double = 0
        var startbx:Double = 0
        var startby:Double = 0

        let startline = KoordinatenTabelle[0]
        if let wert = startline["ax"]
        {
            startax = wert
        }
        if let wert = startline["ay"]
        {
            startay = wert
        }
        if let wert = startline["bx"]
        {
            startbx = wert
        }
        if let wert = startline["by"]
        {
            startby = wert
        }
        var startDic = [String:Double]()
        startDic["ax"] = startax
        startDic["ay"] = startay
        startDic["index"] = 0
        var ElementArray = [[String:Double]]()
        //ElementArray.append(startDic)
        let anz = KoordinatenTabelle.count
        for i in 0..<anz
        {
            var tempDic = [String:Double]()
            let templine = KoordinatenTabelle[i]
            tempDic["x"] = templine["ax"]! - startax
            tempDic["y"] = templine["ay"]! - startay
            tempDic["index"] = Double(i)
            ElementArray.append(tempDic)
        }
        print("Hotwire reportElementSichern ElementArray:")
        for i in 0..<ElementArray.count
        {
            let zeile = ElementArray[i]
            let ax = zeile["x"] ?? 0
            let ay = zeile["y"] ?? 0
           // print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f ",i,ax,ay))
        }
 
        // Name holen
         let NameDialog = NSAlert.init()
        NameDialog.messageText = "Name fuer das neue Element:"
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        NameDialog.accessoryView = textField

        
        NameDialog.addButton(withTitle: "OK")
        NameDialog.addButton(withTitle: "cancel")
        let response = NameDialog.runModal()
        
        var erfolg = 0
        var LibOK = false
        var istOrdner = false
        var error:NSError
        
        var Elementname = ""
        let fileManager = FileManager.default
        var LibPfad = NSHomeDirectory() + "/Documents" + "/CNCDaten" + "/ElementLib"
        var isDirectory: ObjCBool = false
        var saveElementArray = [[String:Any]]()
        if response == .alertFirstButtonReturn
        {
            Elementname = textField.stringValue
            print("Entered text: \(Elementname)")
            
            if ( fileManager.fileExists(atPath: LibPfad , isDirectory: &isDirectory)) == true && isDirectory.boolValue == true
            {
                LibOK = true
            }
         }
        else
        {
               print("Cancelled")
            return false
           }
        
        if LibOK == true
        {
            print("ElementLib da")
           
            // bestehende Element.plist lesen
            var elementPfad = LibPfad + "/" + "Element.plist"
            
            print("neuesElementSichernAktion Pfad: \(elementPfad)")
            
            var neuesElementDic = [String:Any]()
            neuesElementDic["name"] = Elementname
            neuesElementDic["elementarray"] = ElementArray
            
            if fileManager.fileExists(atPath: elementPfad)
            {
                print("fileExists an \(elementPfad)")
                if let elementarray = NSArray(contentsOfFile: elementPfad)
                {
                    print("elementarray: \(elementarray)")
                    
                    // Keys lesen
                    saveElementArray = NSMutableArray(contentsOfFile: elementPfad) as! [[String : Any]]
                    let elementnamenarray = saveElementArray.map { $0["name"] }
                   // print("elementnamenarray: \(elementnamenarray)")
                    
                     // auf duplikate pruefen
                    if let dupindex = elementnamenarray.firstIndex(where: { $0 as! String == Elementname })
                    {
                        print("dupindex: \(dupindex) Elementname schon da")
                        let warnung = NSAlert.init()
                        warnung.messageText = "Element mit Name \(Elementname) ist schon vorhanden"
                        warnung.addButton(withTitle: "Ersetzen")
                        warnung.addButton(withTitle: "neu eingeben")
                        warnung.addButton(withTitle: "Abbrechen")
                        let antwort = warnung.runModal()
                        switch (antwort)
                        {
                        case .alertFirstButtonReturn: // first button
                            print("first")
                            saveElementArray[dupindex] = neuesElementDic
                            
                        case .alertSecondButtonReturn:
                            print("second")
                        case .alertThirdButtonReturn:
                            print("third")
                            return false
                        default:
                            break
                        }

                    }
                    else
                    {
                        print("Elementname noch nicht da")
                        // neues Element anfuegen
                        saveElementArray.append(neuesElementDic)
                    }
                    
                }
                else
                {
                    print("Failed to load array from file")
                    
                }
                
            }
            
            
        }
        else
        {
            print("keine ElementLib")
            
        }
         
        // Create an XML string representation of the array
        var xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<array>\n"
        for item in saveElementArray {
            xmlString += "    <dict>\(item)</dict>\n"
        }
        xmlString += "</array>"
        print("xmlString: \(xmlString)")
        
        // Write the XML string to the file
        var saveURL = NSURL.fileURL(withPath: LibPfad + "/" + "Rumpf.plist")
        
        /*
        do {
            try xmlString.write(to: saveURL, atomically: true, encoding: .utf8)
            print("Array saved as XML at: \(saveURL)")
        } catch {
            print("Error saving array as XML: \(error)")
        }

        
        var aaa:[String:AnyObject] = [:]
        aaa["rumpfteildic"] = self.rumpfteilDic() as AnyObject
        */
  //      var error: NSError?
     //   var saveURL = NSURL.fileURL(withPath: LibPfad + "/" + "Element.plist")
        /*
        do
        {
            let data = try JSONSerialization.data(withJSONObject: saveElementArray, options: JSONSerialization.WritingOptions.prettyPrinted )
            print("data: \(data)")
            guard let jsonString = String(data: data, encoding: .utf8) else {
                 print("Something is wrong while converting JSON data to JSON string.")
                
                 return false
              }
           
            try data.write(to:saveURL)
            print("nach write data")
        } catch {
            fatalError("Failed to write array data to disk: \(error)")
        }
*/

        do {
           
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            
            // vorhandene Datei Element.plist neu schreiben
            saveURL = NSURL.fileURL(withPath:LibPfad + "/" + "Element.plist")
           // let data = try JSONSerialization.data(withJSONObject: saveElementArray, options: []) as? NSData
            try (saveElementArray as NSArray).write(to: saveURL)
            return true
        }  catch {
            print(error)
            return false
        }
        

        

    }
    
    /*
    @objc override func writeCNCAbschnitt()
    {
        cncwritecounter += 1
        print("swift override writeCNCAbschnitt usb_schnittdatenarray: \(usb_schnittdatenarray) cncwritecounter: \(cncwritecounter)")
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
             print("HW Stepperposition: \(Stepperposition) aktuellezeile: \(aktuellezeile) ")
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
     
    */
    @objc func DC_Funktion(pwm:UInt8 )
     {
        usb_schnittdatenarray.removeAll()
        //print("DCAktion: \(notification)")
         print("DCAktion  pwm: \(pwm)")
        Stepperposition = 0;
        var wertarray = [UInt8](repeating: 0, count: Int(BufferSize()))
        
        wertarray[16] = 0xE2
        wertarray[24] = 0xE2
        wertarray[18]=0; // indexh, indexl ergibt abschnittnummer
        wertarray[20]=pwm; // pwm
        
        usb_schnittdatenarray.append(wertarray)
         print("DC_Funktion writeCNCAbschnitt")
        writeCNCAbschnitt()
        teensy.clear_data()

     }

    
    @objc func MausGraphAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        //print("Hotwire mausGraphAktion:\t \(String(describing: info))")
        self.view.window?.makeFirstResponder(self.ProfilFeld)
        CNC_Table.deselectAll(nil)
        
        //   [[[self view]window]makeFirstResponder: ProfilGraph];
        let mauspunktstring = notification.userInfo?["mauspunkt"] as! String
        let MausPunkt:NSPoint = NSPointFromString(mauspunktstring);
        print("Hotwire mausGraphAktion MausPunkt:\t \(MausPunkt)")
        
        WertAXFeld.doubleValue = MausPunkt.x
        WertAYFeld.doubleValue = MausPunkt.y
        
        WertAXStepper.doubleValue = MausPunkt.x
        WertAYStepper.doubleValue = MausPunkt.y
        
        WertBXFeld.doubleValue = MausPunkt.x
        WertBYFeld.doubleValue = MausPunkt.y
        
        WertBXStepper.doubleValue = MausPunkt.x
        WertBYStepper.doubleValue = MausPunkt.y
        
        
        
        
        let offsetx:Double = ProfilBOffsetXFeld.doubleValue
        let offsety:Double = ProfilBOffsetYFeld.doubleValue
        
        //print("mausgraphaktion offsetx: \(offsetx) offsety: \(offsety)")
        
        var oldPosDic:[String:Double] = [:]
        
        var oldax:Double = MausPunkt.x;
        var olday:Double = MausPunkt.y;
        print("mausgraphaktion oldax: \(oldax) olday: \(olday)")
        var  oldbx:Double = oldax + offsetx;
        var  oldby:Double = olday + offsety;
        print("mausgraphaktion oldbx: \(oldbx) oldby: \(oldby)")
        var  oldpwm :Double =  DC_PWM.doubleValue
        //print("KoordinatenTabelle: \(KoordinatenTabelle) count: \(KoordinatenTabelle.count)")
        
        let c = KoordinatenTabelle.isEmpty
        
        print("Mausgraphaktion start KoordinatenTabelle: \(KoordinatenTabelle) ")
        
        if (KoordinatenTabelle.isEmpty == false)
        {
            oldPosDic = KoordinatenTabelle.last!
            oldax = oldPosDic["ax"] ?? 0
            olday = oldPosDic["ay"] ?? 0
            oldbx = oldPosDic["bx"] ?? 0
            oldby = oldPosDic["by"] ?? 0
            
            print("mausgraphaktion oldax a: \(oldax) olday: \(olday)")
            print("mausgraphaktion oldbx b: \(oldbx) oldby: \(oldby)")
            
            if (oldPosDic["pwm"]! > 0)
            {
                //NSLog(@"oldpwm VOR: %d",oldpwm);
                var  temppwm = oldPosDic["pwm"]
                if (temppwm == oldpwm)
                {
                    oldpwm = temppwm!;
                }
                //NSLog(@"oldpwm: %d temppwm: %d",oldpwm,temppwm);
            }
            CNC_Stoptaste.isEnabled = true
        }
        else // Start
        {
            // oldbx += offsetx;
            //oldby += offsety;
        }
        
        DC_Stepper.doubleValue = oldpwm
        DC_PWM.doubleValue = oldpwm
        
        //NSLog(@"oldax: %1.1f olday: %1.1f",oldax,olday);
        
        var deltax = MausPunkt.x-oldax;
        var deltay = MausPunkt.y-olday;
        
        //NSLog(@"deltax: %1.1f deltay: %1.1f",deltax, deltay);
        
        var neueZeileDic = [String:Double]()
        
        neueZeileDic["ax"] = MausPunkt.x
        neueZeileDic["ay"] = MausPunkt.y
        neueZeileDic["bx"] = oldbx + deltax
        neueZeileDic["by"] = oldby + deltay
        
        neueZeileDic["index"] = Double(KoordinatenTabelle.count)
        neueZeileDic["pwm"] = oldpwm
        print("neueZeileDic: \(neueZeileDic)")
        
        if (CNC_Starttaste.state.rawValue > 0)
        {
            oldMauspunkt = MausPunkt
            
            var tempDic:[String:Double] = [:]
            tempDic["ax"] = MausPunkt.x
            tempDic["ay"] = MausPunkt.y
            tempDic["bx"] = MausPunkt.x + offsetx
            tempDic["by"] = MausPunkt.y + offsety
            tempDic["index"] = Double(KoordinatenTabelle.count)
            tempDic["pwm"] = oldpwm
            print("tempDic: \(tempDic)")
            /*
             NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithFloat:MausPunkt.x], @"ax",
             [NSNumber numberWithFloat:MausPunkt.y], @"ay",
             [NSNumber numberWithFloat:MausPunkt.x + offsetx], @"bx",
             [NSNumber numberWithFloat:MausPunkt.y + offsety],@"by",
             [NSNumber numberWithInt:[KoordinatenTabelle count]],@"index",
             [NSNumber numberWithInt:oldpwm],@"pwm",NULL];
             */
            //NSLog(@"tempDic: %@",[tempDic description]);
            
            switch (KoordinatenTabelle.count)
            {
            case 0:
                IndexFeld.integerValue = KoordinatenTabelle.count
                IndexStepper.integerValue = KoordinatenTabelle.count
                IndexStepper.maxValue = Double(KoordinatenTabelle.count)
                //      [KoordinatenTabelle addObject:tempDic];
                KoordinatenTabelle.append(neueZeileDic)
                break;
                
            default:
                print("tempDic 2: \(tempDic)")
                KoordinatenTabelle.remove(at: 0)
                KoordinatenTabelle.insert(tempDic, at:0)
                //KoordinatenTabelle.replaceSubrange(0 ... 0, with: tempDic)
                
                IndexFeld.integerValue = 0
                IndexStepper.integerValue = 0
                break;
                
            }//switch
            
        }
        else if (CNC_Stoptaste.state.rawValue > 0)
        {
            
            var tempDic:[String:Double] = [:]
            tempDic["ax"] = MausPunkt.x
            tempDic["ay"] = MausPunkt.y
            tempDic["bx"] = MausPunkt.x + offsetx
            tempDic["by"] = MausPunkt.y + offsety
            tempDic["index"] = Double(KoordinatenTabelle.count)
            tempDic["pwm"] = oldpwm
            
            print("if CNC_Stoptaste state > 0 tempDic: \(tempDic)")
            /*
             NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithFloat:MausPunkt.x], @"ax",
             [NSNumber numberWithFloat:MausPunkt.y], @"ay",
             [NSNumber numberWithFloat:MausPunkt.x + offsetx], @"bx",
             [NSNumber numberWithFloat:MausPunkt.y + offsety], @"by",
             [NSNumber numberWithInt:[KoordinatenTabelle count]],@"index",
             [NSNumber numberWithInt:oldpwm],@"pwm",NULL];
             */
            //NSLog(@"if CNC_Stoptaste state tempDic: %@",[tempDic description]);
            
            
            if (KoordinatenTabelle.count > 1)
            {
                //[KoordinatenTabelle replaceObjectAtIndex:[KoordinatenTabelle count]-1 withObject:tempDic];
                //if (GraphEnd)
                
                IndexFeld.integerValue = KoordinatenTabelle.count
                IndexStepper.integerValue = KoordinatenTabelle.count
                IndexStepper.maxValue = Double(KoordinatenTabelle.count)
                /*
                 [IndexFeld setIntValue:[KoordinatenTabelle count]];
                 [IndexStepper setIntValue:[IndexFeld intValue]];
                 [IndexStepper setMaxValue:[IndexFeld intValue]];
                 */
                //   [KoordinatenTabelle addObject:tempDic];
                KoordinatenTabelle.append(neueZeileDic)
                
                //[KoordinatenTabelle replaceObjectAtIndex:[KoordinatenTabelle count]-1 withObject:tempDic];
                
            }
            else
            {
                
                IndexFeld.integerValue = KoordinatenTabelle.count
                IndexStepper.integerValue = KoordinatenTabelle.count
                IndexStepper.maxValue = Double(KoordinatenTabelle.count)
                KoordinatenTabelle.append(neueZeileDic)
                
                /*
                 [IndexFeld setIntValue:[KoordinatenTabelle count]];
                 [IndexStepper setIntValue:[IndexFeld intValue]];
                 [IndexStepper setMaxValue:[IndexFeld intValue]];
                 //[KoordinatenTabelle addObject:tempDic];
                 [KoordinatenTabelle addObject:neueZeileDic];
                 */
            }
            
            
        }
        else
        {
            
            /*
             if (fabs(MausPunkt.x - oldMauspunkt.x) > [CNC steps]*0x7F) // Groesser als int16_t
             {
             NSLog(@"zu grosser Schritt X");
             
             }
             */
            
            var tempDic:[String:Double] = [:]
            tempDic["ax"] = MausPunkt.x
            tempDic["ay"] = MausPunkt.y
            tempDic["bx"] = MausPunkt.x + offsetx
            tempDic["by"] = MausPunkt.y + offsety
            tempDic["index"] = Double(KoordinatenTabelle.count)
            tempDic["pwm"] = oldpwm
            print("tempDic 3: \(tempDic)")
            /*
             NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithFloat:MausPunkt.x], @"ax",
             [NSNumber numberWithFloat:MausPunkt.y], @"ay",
             [NSNumber numberWithFloat:MausPunkt.x + offsetx], @"bx",
             [NSNumber numberWithFloat:MausPunkt.y + offsety], @"by",
             [NSNumber numberWithInt:[KoordinatenTabelle count]],@"index",
             [NSNumber numberWithInt:oldpwm],@"pwm",
             NULL];
             */
            
            print("if CNC_Stoptaste state == 0 tempDic: \(tempDic)")
            IndexFeld.integerValue = KoordinatenTabelle.count
            IndexStepper.integerValue = KoordinatenTabelle.count
            IndexStepper.maxValue = Double(KoordinatenTabelle.count)
            KoordinatenTabelle.append(neueZeileDic)
            /*
             [IndexFeld setIntValue:[KoordinatenTabelle count]];
             [IndexStepper setIntValue:[IndexFeld intValue]];
             [IndexStepper setMaxValue:[IndexFeld intValue]];
             //[KoordinatenTabelle addObject:tempDic];
             [KoordinatenTabelle addObject:neueZeileDic];
             */
        }
        oldMauspunkt=MausPunkt;
        //NSLog(@"Mausklicktabelle: %@",[KoordinatenTabelle description]);
        
        //NSDictionary* RahmenDic = [self RahmenDic];
        let maxX:Double = RahmenDic["maxx"] ?? 100
        var minX:Double = RahmenDic["minx"] ?? 10
        
        let maxY:Double = RahmenDic["maxy"] ?? 100
        var minY:Double = RahmenDic["miny"] ?? 10
        
        
        //      float maxY=[[RahmenDic objectForKey:@"maxy"]floatValue];
        //      float minY=[[RahmenDic objectForKey:@"miny"]floatValue];
        //   NSLog(@"maxX: %2.2f minX: %2.2f * maxY: %2.2f minY: %2.2f",maxX,minX,maxY,minY);
        
        //  [AbmessungX setIntValue:maxX - minX];
        //  [AbmessungY setIntValue:maxY - minY];
        
        ProfilFeld.DatenArray = KoordinatenTabelle as NSArray
        //[ProfilGraph setDatenArray:KoordinatenTabelle];
        //ProfilFeld.needsDisplay = true
        ProfilFeld.setNeedsDisplay(ProfilFeld.frame)
        //[Profilfeld setNeedsDisplay:YES];
        
        print("Mausgraphaktion end KoordinatenTabelle: \(KoordinatenTabelle) ")

        CNC_Table.reloadData()
        
        if (KoordinatenTabelle.count > 0)
        {
            let rowindexset =  IndexSet(integer: KoordinatenTabelle.count)
            CNC_Table.selectRowIndexes(rowindexset, byExtendingSelection: false)
            //          CNCTable.scrollRowToVisible(KoordinatenTabelle.count - 1)
        }
        
        
        
    }
    
   @objc func MausDragAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        //print("Hotwire MausDragAktion")
        //print("Hotwire MausDragAktion:\t \(String(describing: info))")
        let mauspunktstring = notification.userInfo?["mauspunkt"] as! String
       let MausPunkt:NSPoint = NSPointFromString(mauspunktstring);
        let Graphoffset:Int = notification.userInfo?["graphoffset"] as! Int
        let Klickseite:Int = notification.userInfo?["klickseite"] as! Int
        let Klickindex:Int = notification.userInfo?["klickpunkt"] as! Int
        
        print("Hotwire MausDragAktion klickseite: \(Klickseite)")
        
        let oldDic = KoordinatenTabelle[Klickindex]
        
        let offsetx = ProfilBOffsetXFeld.doubleValue
        let offsety = ProfilBOffsetYFeld.doubleValue
        
        let oldax = oldDic["ax"]!
        let olday = oldDic["ay"]!
        let oldbx = oldDic["bx"]!
        let oldby = oldDic["by"]!
        
        var deltaAX = 0.0
        var deltaAY = 0.0
        var deltaBX = 0.0
        var deltaBY = 0.0
        
        var tempDic = [String:Double]()
        
        if Klickseite == 1
        {
            deltaAX = WertAXFeld.doubleValue - oldax
            deltaAY = WertAYFeld.doubleValue - olday
            tempDic["ax"] = oldax+deltaAX
            tempDic["ay"] = olday+deltaAY

            tempDic["bx"] = oldbx
            tempDic["by"] = oldby
            
            WertAXFeld.doubleValue = MausPunkt.x
            WertAYFeld.doubleValue = MausPunkt.y
            
            WertAXStepper.doubleValue = MausPunkt.x
            WertAYStepper.doubleValue = MausPunkt.y

            if ABBindCheck.state == NSControl.StateValue.on
            {
                deltaBX = WertBXFeld.doubleValue - oldbx
                deltaBY = WertBYFeld.doubleValue - oldby
                tempDic["bx"] = oldbx+deltaBX
                tempDic["by"] = oldby+deltaBY
                
                WertBXFeld.doubleValue = MausPunkt.x + offsetx
                WertBYFeld.doubleValue = MausPunkt.y + offsety
                
                WertBXStepper.doubleValue = MausPunkt.x  + offsetx
                WertBYStepper.doubleValue = MausPunkt.y + offsety
            }

          }
        if Klickseite == 2
        {
            deltaBX = WertBXFeld.doubleValue - oldbx
            deltaBY = WertBYFeld.doubleValue - oldby
            tempDic["bx"] = oldbx+deltaBX
            tempDic["by"] = oldby+deltaBY
            tempDic["ax"] = oldax
            tempDic["ay"] = olday

            WertBXFeld.doubleValue = MausPunkt.x// + offsetx
            WertBYFeld.doubleValue = MausPunkt.y// + offsety
            
            WertBXStepper.doubleValue = MausPunkt.x//  + offsetx
            WertBYStepper.doubleValue = MausPunkt.y // + offsety

            if ABBindCheck.state == NSControl.StateValue.on
            {
                deltaAX = WertAXFeld.doubleValue - oldax
                deltaAY = WertAYFeld.doubleValue - olday
                tempDic["ax"] = oldax+deltaAX
                tempDic["ay"] = olday+deltaAY
                
                WertAXFeld.doubleValue = MausPunkt.x - offsetx
                WertAYFeld.doubleValue = MausPunkt.y - offsety
                
                WertAXStepper.doubleValue = MausPunkt.x + offsetx
                WertAYStepper.doubleValue = MausPunkt.y + offsety


            }
 
          }

        
        /*
        if ABBindCheck.state == NSControl.StateValue.on && Klickseite == 1
        {
            deltaAX = WertAXFeld.doubleValue - oldax
            deltaAY = WertAYFeld.doubleValue - olday
        }

        if ABBindCheck.state == NSControl.StateValue.on && Klickseite == 2
        {
            deltaBX = WertBXFeld.doubleValue - oldbx
            deltaBY = WertBYFeld.doubleValue - oldby
        }
        */
        
        
       
   //     tempDic["ax"] = oldax+deltaAX
   //     tempDic["ay"] = olday+deltaAY
  //      tempDic["bx"] = oldbx+deltaBX
   //     tempDic["by"] = oldby+deltaBY
        
        // Abbrand
        var oldabrax = 0.0
        var oldabray = 0.0
        var oldabrbx = 0.0
        var oldabrby = 0.0
        
        if let wert = oldDic["abrax"]
        {
            oldabrax = oldDic["abrax"] ?? 0
        }
        if let wert = oldDic["abray"]
        {
            oldabray = oldDic["abray"] ?? 0
        }
        if let wert = oldDic["abrbx"]
        {
            oldabrbx = oldDic["abrbx"] ?? 0
        }
        if let wert = oldDic["abrby"]
        {
            oldabrby = oldDic["abrby"] ?? 0
        }

        /*
        tempDic["abrax"] = oldabrax+deltaAX
        tempDic["abray"] = oldabray+deltaAY
        tempDic["abrbx"] = oldabrbx+deltaBX
        tempDic["abrby"] = oldabrby+deltaBY
*/
        if let wert = oldDic["pwm"]
        {
            tempDic["pwm"] = oldDic["pwm"]
        }
        else
        {
            tempDic["pwm"] = 92.0
        }
        if let wert = oldDic["index"]
        {
            tempDic["index"] = oldDic["index"]
        }
 
     //   print("Hotwire MausDragAktion tempDic: \(tempDic)")
        KoordinatenTabelle[Klickindex] = tempDic
        
        IndexFeld.integerValue = Klickindex
        IndexStepper.integerValue = Klickindex
        
       
        /*
        WertAXFeld.doubleValue = MausPunkt.x
        WertAYFeld.doubleValue = MausPunkt.y
        
        WertAXStepper.doubleValue = MausPunkt.x
        WertAYStepper.doubleValue = MausPunkt.y
        
        WertBXFeld.doubleValue = MausPunkt.x// + offsetx
        WertBYFeld.doubleValue = MausPunkt.y// + offsety
        
        WertBXStepper.doubleValue = MausPunkt.x//  + offsetx
        WertBYStepper.doubleValue = MausPunkt.y // + offsety
        */
        //CNC_Table.reloadData()
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.setNeedsDisplay(ProfilFeld.frame)
        CNC_Table.reloadData()
        
    }

   @objc func MausKlickAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        print("Hotwire MausKlickAktion:\t \(String(describing: info))")
        
        //   self.view.window?.addObserver(self, forKeyPath: "firstResponder", options: [.initial, .new], context: nil)
        var klickIndex = 0
        self.view.window?.makeFirstResponder(self.ProfilFeld)
        if let checkindex =  info?["klickpunkt"]
        {
            klickIndex = checkindex as! Int
        }
        else
        {
            
        }
        
        
        if klickIndex > 0x0FFF
        {
            klickIndex -= 0xF000
        }
        var NotificationDic = [String:Any]()
        var tempZeilenDic = KoordinatenTabelle[klickIndex]
        
        IndexFeld.integerValue = klickIndex
        IndexStepper.integerValue = klickIndex
        
        WertAXFeld.doubleValue = tempZeilenDic["ax"] ?? 0
        WertAYFeld.doubleValue = tempZeilenDic["ay"] ?? 0
        
        WertAXStepper.doubleValue = tempZeilenDic["ax"] ?? 0
        WertAYStepper.doubleValue = tempZeilenDic["ay"] ?? 0
        
        WertBXFeld.doubleValue = tempZeilenDic["bx"] ?? 0
        WertBYFeld.doubleValue = tempZeilenDic["by"] ?? 0
        
        WertBXStepper.doubleValue = tempZeilenDic["bx"] ?? 0
        WertBYStepper.doubleValue = tempZeilenDic["by"] ?? 0
        
        self.ProfilFeld.needsDisplay = true
        var rowIndexSet = NSIndexSet.init(index: klickIndex)
        
        CNC_Table.selectRowIndexes(IndexSet.init(rowIndexSet), byExtendingSelection: false)
        
        
    } // MausKlickAktion

    @objc class func cncoutletdaten() -> NSDictionary
    {
        return outletdaten as NSDictionary
    }
    
   // @objc func reportPfeiltaste
    
    /*
      richtung:
      right: 1
      up: 2
      left: 3
      down: 4
      */

    /*
    @objc func updateSteps()
     {
        print("stepsAktion: \()")
        steps = notification.userInfo?["motorsteps"] as! Int
        print("stepsAktion steps: \(steps)")
        //steps_Feld.integerValue = steps
     }

     @objc func updateMicro()
     {
   //     print("stepsAktion: \(notification)")
        micro = notification.userInfo?["micro"] as! Int
        print("Aktion micro: \(micro)")
        //micro_Feld.integerValue = micro
     }
*/
   // MARK: NEU-Taste
    @IBAction func reportNeuTaste(_ sender: NSButton)
    {
        print("swift reportNeuTaste")
        CNC_busySpinner.stopAnimation(nil)
        CNC_Halttaste.state = NSControl.StateValue(rawValue: 0)
        CNC_Halttaste.isEnabled = false
        CNC_Sendtaste.isEnabled = false
        CNC_Starttaste.isEnabled = true
        CNC_Starttaste.state = NSControl.StateValue(rawValue: 0)
        CNC_Stoptaste.isEnabled = false
        NeuesElementTaste.isEnabled = true
        PositionFeld.stringValue = ""
        //ProfilFeld.viewWithTag(1001).stringValue = ""
        DC_Taste.isEnabled = false
        HomeTaste.state = NSControl.StateValue(rawValue: 0)
        KoordinatenTabelle.removeAll()
        CNC_Table.reloadData()
        CNC_Table.needsDisplay = true
        
        IndexFeld.stringValue = ""
        IndexStepper.integerValue = 0
        WertAXFeld.stringValue = ""
        WertAXStepper.integerValue = 0
        
        WertAYFeld.stringValue = ""
        WertAYStepper.integerValue = 0

        WertBXFeld.stringValue = ""
        WertBXStepper.integerValue = 0

        WertBYFeld.stringValue = ""
        WertBYStepper.integerValue = 0

        if (BlockrahmenArray != nil && BlockrahmenArray.count > 0)
        {
            BlockrahmenArray.removeAll()
            ProfilFeld.setRahmenArray(derRahmenArray: BlockrahmenArray as NSArray)
        }
        BlockKoordinatenTabelle.removeAll()
        CNC_DatenArray.removeAll()
        SchnittdatenArray.removeAll()
        
        ProfilFeld.stepperposition = -1
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true
        
        var HomeSchnittdatenArray = [String:Any]()
        var ManArray = [String:Double]()
        var PositionA = NSMakePoint(0, 0)
        var PositionB = NSMakePoint(0, 0)
        
        ManArray["ax"] = PositionA.x
        ManArray["ay"] = PositionA.y
        ManArray["bx"] = PositionB.x
        ManArray["by"] = PositionB.y
        
        let neucode:UInt8  = 0xF1
        var tempDic = [String:Int]()
        tempDic["code"] = Int(neucode)
        tempDic["position"] = 3
        tempDic["cncposition"] = 0
        tempDic["home"] = 0
     //   var tempSteuerdatenDic = [String:Any]()
      // tempSteuerdatenDic = AVR?.tool_SteuerdatenVonDic(tempDic) as! [String : Double]
        
        var tempSchnittdatenArray:[Int] = ((AVR?.tool_CNC_SchnittdatenArrayVonSteuerdaten(tempDic))) as! [Int]
        let nc = NotificationCenter.default
        var NotificationDic = [String:Any]()
        
        NotificationDic["cncposition"] = 0
        NotificationDic["home"] = 0
        
        NotificationDic["schnittdatenarray"] = tempSchnittdatenArray
        
        print("swift reportNeuTaste NotificationDic: \(NotificationDic)")

        nc.post(name:Notification.Name(rawValue:"usbschnittdaten"),
        object: nil,
        userInfo: NotificationDic)

        print("swift reportNeuTaste")
 
        
        
        //       KoordinatenTabelle.append(AVR?.schnittdatenVonDic(tempSteuerdatenDic) as! [String : Double]  )
    }
    
    @objc func NeuTastefunktion()
    {
        print("swift reportNeuTaste")
        CNC_Halttaste.state = NSControl.StateValue(rawValue: 0)
        CNC_Halttaste.isEnabled = false
        CNC_Sendtaste.isEnabled = false
        CNC_Starttaste.isEnabled = true
        CNC_Starttaste.state = NSControl.StateValue(rawValue: 0)
        CNC_Stoptaste.isEnabled = false
        NeuesElementTaste.isEnabled = false
        PositionFeld.stringValue = ""
        //ProfilFeld.viewWithTag(1001).stringValue = ""
        DC_Taste.isEnabled = false
        HomeTaste.state = NSControl.StateValue(rawValue: 0)
        KoordinatenTabelle.removeAll()
        CNC_Table.reloadData()
        CNC_Table.needsDisplay = true
        
        IndexFeld.stringValue = ""
        IndexStepper.integerValue = 0
        WertAXFeld.stringValue = ""
        WertAXStepper.integerValue = 0
        
        WertAYFeld.stringValue = ""
        WertAYStepper.integerValue = 0

        WertBXFeld.stringValue = ""
        WertBXStepper.integerValue = 0

        WertBYFeld.stringValue = ""
        WertBYStepper.integerValue = 0

        if (BlockrahmenArray != nil && BlockrahmenArray.count > 0)
        {
            BlockrahmenArray.removeAll()
            ProfilFeld.setRahmenArray(derRahmenArray: BlockrahmenArray as NSArray)
        }
        BlockKoordinatenTabelle.removeAll()
        CNC_DatenArray.removeAll()
        SchnittdatenArray.removeAll()
        
        ProfilFeld.stepperposition = -1
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true
        
        var HomeSchnittdatenArray = [String:Any]()
        var ManArray = [String:Double]()
        var PositionA = NSMakePoint(0, 0)
        var PositionB = NSMakePoint(0, 0)
        
        ManArray["ax"] = PositionA.x
        ManArray["ay"] = PositionA.y
        ManArray["bx"] = PositionB.x
        ManArray["by"] = PositionB.y
        
        let neucode:UInt8  = 0xF1
        var tempDic = [String:Int]()
        tempDic["code"] = Int(neucode)
        tempDic["position"] = 3
        tempDic["cncposition"] = 0
        tempDic["home"] = 0
     //   var tempSteuerdatenDic = [String:Any]()
      // tempSteuerdatenDic = AVR?.tool_SteuerdatenVonDic(tempDic) as! [String : Double]
        
        var tempSchnittdatenArray:[Int] = ((AVR?.tool_CNC_SchnittdatenArrayVonSteuerdaten(tempDic))) as! [Int]
        let nc = NotificationCenter.default
        var NotificationDic = [String:Any]()
        
        NotificationDic["cncposition"] = 0
        NotificationDic["home"] = 0
        
        NotificationDic["schnittdatenarray"] = tempSchnittdatenArray
        
        print("swift NeuTasteFunktion NotificationDic: \(NotificationDic)")

        nc.post(name:Notification.Name(rawValue:"usbschnittdaten"),
        object: nil,
        userInfo: NotificationDic)

        print("swift reportNeuTaste")
 
        
        
        //       KoordinatenTabelle.append(AVR?.schnittdatenVonDic(tempSteuerdatenDic) as! [String : Double]  )
    }
    
    
    @objc  @IBAction func reportStopTaste(_ sender: NSButton)
    {
        print("swift reportStopTaste")
        if CNC_Starttaste.state == NSControl.StateValue.on
        {
            CNC_Starttaste.state = NSControl.StateValue.off
        }
        let stepsindex = CNC_StepsSegControl.selectedSegment
        motorsteps = CNC_StepsSegControl.tag(forSegment:stepsindex)
        outletdaten["motorsteps"] = CNC_StepsSegControl.tag(forSegment:stepsindex)  as AnyObject
        micro = CNC_microPop.selectedItem?.tag ?? 1
        speed = SpeedFeld.integerValue
        pwm = DC_PWM.integerValue
        CNC_busySpinner.stopAnimation(nil)
        cnc_seite1check = CNC_Seite1Check.state.rawValue as Int
        cnc_seite2check = CNC_Seite2Check.state.rawValue as Int
        outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
        outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
        outletdaten["speed"] = speed as AnyObject
        outletdaten["micro"] = micro as AnyObject
        outletdaten["boardindex"] = boardindex as AnyObject
        outletdaten["pwm"] = pwm as AnyObject
        var zoomfaktor = ProfilTiefeFeldA.doubleValue / 1000
        outletdaten["zoom"] = zoomfaktor as AnyObject
        // Daten leeren
        CNC_DatenArray.removeAll()
        SchnittdatenArray.removeAll()
        HomeTaste.state = NSControl.StateValue.off
        DC_Taste.state = NSControl.StateValue.off
        cncposition = 0
        
        
        
        if KoordinatenTabelle.count <= 1
        {
            let warnung = NSAlert.init()
            warnung.messageText = "Zuwenig Elemente in KoordinatenTabelle"
            warnung.addButton(withTitle: "OK")
            let antwort = warnung.runModal()
            CNC_Stoptaste.state = NSControl.StateValue.off
        }
        ProfilFeld.setgraphstatus(status: 1)
        
        let tempSchnittdatenArray = AVR?.stopFunktion(KoordinatenTabelle, outletdaten: outletdaten)
        
      //  print("tempSchnittdatenArray: \(tempSchnittdatenArray)")
        
        for i in 0..<tempSchnittdatenArray!.count
        {
            let temparray = tempSchnittdatenArray![i] as! [Int]
            print("i: \(i) temparray: \(temparray)")
          SchnittdatenArray.append(temparray)
        }
     print("reportStopTaste SchnittdatenArray: \(SchnittdatenArray)")
        // code am Anfang und Schluss einfuegen
        var lastposition:Int = 0
        lastposition |= (1<<LAST_BIT)
        let anzdaten = SchnittdatenArray.count
        SchnittdatenArray[anzdaten-1][17] = lastposition
        
        AnzahlFeld.integerValue = SchnittdatenArray.count
        PositionFeld.integerValue = 0
        
        IndexFeld.integerValue = anzdaten
        IndexStepper.integerValue = anzdaten
        
        CNC_Sendtaste.isEnabled = true
        DC_Taste.state = NSControl.StateValue.off
    }
    
    @objc func StopTastefunktion()
    {
        print("swift StopTastefunktion Koordinatentabelle: \(KoordinatenTabelle)")
        if CNC_Starttaste.state == NSControl.StateValue.on
        {
            CNC_Starttaste.state = NSControl.StateValue.off
        }
        let stepsindex = CNC_StepsSegControl.selectedSegment
        motorsteps = CNC_StepsSegControl.tag(forSegment:stepsindex)
        outletdaten["motorsteps"] = CNC_StepsSegControl.tag(forSegment:stepsindex)  as AnyObject
        micro = CNC_microPop.selectedItem?.tag ?? 1
        speed = SpeedFeld.integerValue
        pwm = DC_PWM.integerValue
        
        cnc_seite1check = CNC_Seite1Check.state.rawValue as Int
        cnc_seite2check = CNC_Seite2Check.state.rawValue as Int
        outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
        outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
        outletdaten["speed"] = speed as AnyObject
        outletdaten["micro"] = micro as AnyObject
        outletdaten["boardindex"] = boardindex as AnyObject
        outletdaten["pwm"] = pwm as AnyObject
        var zoomfaktor = ProfilTiefeFeldA.doubleValue / 1000
        outletdaten["zoom"] = zoomfaktor as AnyObject
        // Daten leeren
        CNC_DatenArray.removeAll()
        SchnittdatenArray.removeAll()
        HomeTaste.state = NSControl.StateValue.off
        DC_Taste.state = NSControl.StateValue.off
        cncposition = 0
        
        
        
        if KoordinatenTabelle.count <= 1
        {
            let warnung = NSAlert.init()
            warnung.messageText = "Zuwenig Elemente in KoordinatenTabelle"
            warnung.addButton(withTitle: "OK")
            let antwort = warnung.runModal()
            CNC_Stoptaste.state = NSControl.StateValue.off
        }
        ProfilFeld.setgraphstatus(status: 1)
        
        let tempSchnittdatenArray = AVR?.stopFunktion(KoordinatenTabelle, outletdaten: outletdaten)
        
      //  print("tempSchnittdatenArray: \(tempSchnittdatenArray)")
        
        for i in 0..<tempSchnittdatenArray!.count
        {
            let temparray = tempSchnittdatenArray![i] as! [Int]
            print("i: \(i) temparray: \(temparray)")
          SchnittdatenArray.append(temparray)
        }
     print("reportStopTaste SchnittdatenArray: \(SchnittdatenArray)")
        // code am Anfang und Schluss einfuegen
        var lastposition:Int = 0
        lastposition |= (1<<LAST_BIT)
        let anzdaten = SchnittdatenArray.count
        SchnittdatenArray[anzdaten-1][17] = lastposition
        
        AnzahlFeld.integerValue = SchnittdatenArray.count
        PositionFeld.integerValue = 0
        
        IndexFeld.integerValue = anzdaten
        IndexStepper.integerValue = anzdaten
        
        CNC_Sendtaste.isEnabled = true
        DC_Taste.state = NSControl.StateValue.off
    }

    @IBAction func reportUSB_sendArray(_ sender:NSButton)
    {
        print("reportUSB_sendArray")
        if SchnittdatenArray.count == 0
        {
            let warnung = NSAlert.init()
            warnung.messageText = "reportUSB_sendArray SchnittdatenArray ist leer"
            warnung.addButton(withTitle: "OK")
            let antwort = warnung.runModal()
            //CNC_Stoptaste.state = NSControl.StateValue.off
            return
        }// leer
        
        if SpeedFeld.integerValue == 0
        {
            let warnung = NSAlert.init()
            warnung.messageText = "hor reportUSB_sendArray speed ist 0"
            warnung.addButton(withTitle: "OK")
            let antwort = warnung.runModal()
            //CNC_Stoptaste.state = NSControl.StateValue.off
            return
        }
 //       usbstatus = 1
        var delayok = 0
        if usbstatus > 0
        {
            if (SchnittdatenArray[0][1] <= 0x7F) || (SchnittdatenArray[0][9] <= 0x7F)
            {
                AnschlagLinksIndikator.fillColor = NSColor.green
            }
            
            if (SchnittdatenArray[0][3] <= 0x7F) || (SchnittdatenArray[0][11] <= 0x7F)
            {
                AnschlagUntenIndikator.fillColor = NSColor.green
            }

            var a:NSApplication.ModalResponse
            var delayok = 0
            if DC_Taste.state == NSControl.StateValue.off
            {
                
                let warnung = NSAlert.init()
                warnung.messageText = "Hot reportUSB_sendArray DC ist 0"
                warnung.addButton(withTitle: "Einschalten")
                warnung.addButton(withTitle: "Ignorieren")
                warnung.addButton(withTitle: "Abbrechen")
                let s1 = "Der Heizdraht ist noch nicht eingeschaltet."
                let s2 = "Nach dem Einschalten den Vorgang erneut starten."
                let informationString = ("\(s1)\n\(s2)")
                warnung.informativeText = informationString
                let antwort = warnung.runModal()
                //CNC_Stoptaste.state = NSControl.StateValue.off
                switch (antwort)
                {
                case .alertFirstButtonReturn: // first button
                        DC_Taste.state = NSControl.StateValue.on
                    let dc_pwm = UInt8(DC_Taste.intValue)
                    self.DC_Funktion(pwm: dc_pwm)
                    delayok = 1
                case .alertSecondButtonReturn:
                    print("second Button")
                    // pwm entfernen
                    for i in 0..<SchnittdatenArray.count
                    {
                        SchnittdatenArray[i][20] = 0
                    }
                case .alertThirdButtonReturn:
                    print("third")
                    return
                default:
                    break
                }

            }
          }// if usbstatus
        else
        {
            let warnung = NSAlert.init()
            warnung.messageText = "CNC Schnit starten"
            warnung.addButton(withTitle: "Einstecken und einschalten")
            warnung.addButton(withTitle: "Zurück")
            //warnung.addButton(withTitle: "Abbrechen")
            let s1 = "Der Heizdraht ist noch nicht eingeschaltet."
            let s2 = "Nach dem Einschalten den Vorgang erneut starten."
            let informationString = ("\(s1)\n\(s2)")
            warnung.informativeText = informationString
            let antwort = warnung.runModal()

        }
        
        print("reportUSB_sendArray cncposition: \(cncposition) \nschnittdatenarray 0: \(SchnittdatenArray[0])")
        CNC_Halttaste.isEnabled = true
        CNC_Stoptaste.state = NSControl.StateValue.off
        PositionFeld.integerValue = 0
        ProfilFeld.stepperposition = 0
        ProfilFeld.needsDisplay = true
        
        let nc = NotificationCenter.default
        var SchnittdatenDic = [String:Any]()
        
        SchnittdatenDic["pwm"] = pwm
        SchnittdatenDic["schnittdatenarray"] = SchnittdatenArray
        
        
        SchnittdatenDic["cncposition"] = 0
        if HomeTaste.state == NSControl.StateValue.off
        {
            SchnittdatenDic["home"] = 1
        }
        else
        {
            SchnittdatenDic["home"] = 0
        }
        SchnittdatenDic["art"] = 0
        SchnittdatenDic["delayok"] = delayok
        
        if delayok > 0
        {
            print("swift reportUSB_sendArray mit delay")
            let sel = #selector(sendDelayedArrayWithDic(schnittdatendic:))
            self.perform(#selector(sendDelayedArrayWithDic(schnittdatendic: )), with: SchnittdatenDic, afterDelay: 6)
           
        }
        else
        {
            taskfertig = 1
            print("swift reportUSB_sendArray ohne delay")
            nc.post(name:Notification.Name(rawValue:"usbschnittdaten"),
            object: nil,
            userInfo: SchnittdatenDic)
            CNC_busySpinner.startAnimation(nil)

        }
        
        print("swift reportUSB_sendArray NotificationDic: \(SchnittdatenDic)")
/*
        nc.post(name:Notification.Name(rawValue:"usbschnittdaten"),
        object: nil,
        userInfo: NotificationDic)
*/
        
        
        
    }//reportUSB_sendArray
    
    @objc func sendDelayedArrayWithDic(schnittdatendic:[String:Any])
    {
        print("sendDelayedAction")
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"usbschnittdaten"),
        object: nil,
        userInfo: schnittdatendic)
        CNC_busySpinner.startAnimation(nil)
        taskfertig = 1
    }
    
    @objc  func newHotwireDataAktion(_ notification:Notification)  // entspricht readUSB
    {
       // Reaktion auf eingehende USB-Daten
       var lastData = teensy.getlastDataRead()
       let lastDataArray = [UInt8](lastData)
       print("rHotwireController newDataAktion notification: \n\(notification)\n lastData:\n \(lastData)")
       
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
             print("newDataAktion abschnittfertig wert: \(abschnittfertig)")
             // https://useyourloaf.com/blog/swift-string-cheat-sheet/
             let home = Int(usbdata[13])
              
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
                print("abschnittfertig > A0")
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
                    CNC_busySpinner.stopAnimation(nil)
                   AVR?.setBusy(0)
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
                   print("HotWireVC newDataAktion 0xD0 Stepperposition: \(Stepperposition) \n\(schnittdatenstring)");
                   //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                   NotificationDic["abschnittfertig"] = Int(abschnittfertig)
                   let nc = NotificationCenter.default
                   nc.post(name:Notification.Name(rawValue:"usbread"),
                           object: nil,
                           userInfo: NotificationDic)
                   //return
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
             
          } // if count > 0
          
       } // if d
       else
       {
          print("*** newDataAktion if let d not ok")
       }
       //let dic = notification.userInfo as? [String:[UInt8]]
       //print("dic: \(dic ?? ["a":[123]])\n")
       
    }
    @objc override func newDataAktion(_ notification:Notification)
     {
        // Reaktion auf eingehende USB-Daten
        var lastData = teensy.getlastDataRead()
        let lastDataArray = [UInt8](lastData)
        print("HW newDataAktion notification: \n\(notification)\n lastData:\n \(lastData)")
        
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
                 print("HW  newDataAktion abschnittfertig > A0")
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
                    print("HW  newDataAktion newDataAktion E1 mouseup")
                    usb_schnittdatenarray.removeAll()
                    
                    AVR?.setBusy(0)
                    teensy.read_OK = false
                    break
                    
                 case 0xEA: // home
                    print("HW  newDataAktion  EA home gemeldet")
                    break
                    
                 // Anschlag first
                 case 0xA5:
                    print("HW  newDataAktion  Anschlag A0")
                    AnschlagSet.insert(0) // schritteax lb
                    AnschlagSet.insert(1) // schritteax hb
                    AnschlagSet.insert(4) // delayax lb
                    AnschlagSet.insert(5) // delayax lb
                    break;
                    
                 case 0xA6:
                    print("HW  newDataAktion  Anschlag B0")
                    AnschlagSet.insert(2) // schritteax lb
                    AnschlagSet.insert(3) // schritteax hb
                    AnschlagSet.insert(6) // delayax lb
                    AnschlagSet.insert(7) // delayax lb
                    break;
                    
                 case 0xA7:
                    print("HW  newDataAktion  Anschlag C0")
                    AnschlagSet.insert(8) // schrittebx lb
                    AnschlagSet.insert(9) // schrittebx hb
                    AnschlagSet.insert(12) // delayabx lb
                    AnschlagSet.insert(13) // delaybx lb
                    break;
                    
                 case 0xA8:
                    print("HW  newDataAktion  Anschlag D0")
                    AnschlagSet.insert(10) // schritteby lb
                    AnschlagSet.insert(11) // schritteby hb
                    AnschlagSet.insert(14) // delayby lb
                    AnschlagSet.insert(15) // delayby lb
                    break;
                    
                 // Anschlag home first
                 case 0xB5:
                    print("HW  newDataAktion +++++++++  Anschlag A home first")
                    HomeAnschlagSet.insert(0xB5)
                    print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                    break
                 case 0xB6:
                    print("HW  newDataAktion +++++++++  Anschlag B home first")
                    HomeAnschlagSet.insert(0xB6)
                    print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                    break
                 case 0xB7:
                    print("HW  newDataAktion +++++++++  Anschlag C home first")
                    HomeAnschlagSet.insert(0xB7)
                    print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                    break
                 case 0xB8:
                    print("HW  newDataAktion +++++++++ HW  Anschlag D home first")
                    HomeAnschlagSet.insert(0xB8)
                    print("HomeAnschlagSet count: \(HomeAnschlagSet.count)")
                    break
                    
                 // Anschlag Second
                 case 0xC5:
                    print("HW  newDataAktion Anschlag A home  second")
                    break
                 case 0xC6:
                    print("HW  newDataAktion Anschlag B home  second")
                    break
                 case 0xC7:
                    print("HW  newDataAktion Anschlag C home  second")
                    break
                 case 0xC8:
                    print("HW  newDataAktion Anschlag D home  second")
                    break
                    
                 case 0xD0:
                    print("HW  newDataAktion ***   ***   Letzter Abschnitt")
                    print("HW  newDataAktion  0xD0 Stepperposition: \(Stepperposition) \n\(schnittdatenstring)");
                    //print("HomeAnschlagSet: \(HomeAnschlagSet)")
                    NotificationDic["abschnittfertig"] = Int(abschnittfertig)
                     /*
                    let nc = NotificationCenter.default
                    nc.post(name:Notification.Name(rawValue:"usbread"),
                            object: nil,
                            userInfo: NotificationDic)
                    return
                      */
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
                    print("HotwireHW  newDataAktion Notific: \(NotificationDic)")
                    
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

    @objc func USBReadAktion(_ notification:Notification)
    {
        let note = notification.userInfo as![String:Any]
        let abschnittfertig = note["abschnittfertig"]  as! Int
        let outposition = note["outposition"] as! Int
        Stepperposition = note["stepperposition"] as! Int
        
        var homeanschlagCount = 0
           if let wert = note["homeanschlagset"]
           {
               homeanschlagCount = wert as! Int
           }

        if outposition > PositionFeld.integerValue
         {
             PositionFeld.integerValue = outposition
             ProfilFeld.stepperposition = outposition
             ProfilFeld.needsDisplay = true
             
         }

        switch abschnittfertig
        {
        case 0xBD:
            PositionFeld.integerValue = Stepperposition
            ProfilFeld.stepperposition = Stepperposition
            ProfilFeld.needsDisplay = true
            if taskfertig > 0
            {
                let warnung = NSAlert.init()
                warnung.messageText = "Task fertig"
                warnung.addButton(withTitle: "OK")
                warnung.runModal()
                taskfertig = 0
            }


        default:
            break
            
        } // switch abschnittfertig
        
    }
    
    @objc func USBReadFunktion(dataDic:[String:Int])
    {
        if let outposition = dataDic["outposition"]
        {
            if outposition > PositionFeld.integerValue
            {
                PositionFeld.integerValue = outposition
                ProfilFeld.stepperposition = outposition - 1
                ProfilFeld.needsDisplay = true
                
            }
        }
        else
        {
            return
        }
        /*
        if let stepperposition = dataDic["stepperposition"]
        {
            if stepperposition > CNCPositionFeld.integerValue
            {
                PositionFeld.integerValue = stepperposition
                ProfilFeld.stepperposition = stepperposition - 1
                ProfilFeld.needsDisplay = true
                
            }
        }
        else
        {
            return
        }
         */
        var homeanschlagCount = 0
        if let wert = dataDic["homeanschlagset"]
        {
            homeanschlagCount = dataDic["homeanschlagset"]!
        }

        
        
    }
    
    
    
    @IBAction func reportAndereSeiteAnfahren(_ sender: NSButton)
    {
        print("swift reportAndereSeiteAnfahren")
          
        
    }
// MARK:  *** *** ***  reportProfilOberseiteTask
    @IBAction func reportProfilOberseiteTask(_ sender: NSButton)
    {
        print("reportProfilOberseiteTask")
        var eingabeDic = [String:Any]()
        if KoordinatenTabelle.count == 0
        {
            var zeilenDic = ["index": 0, "ax":  25, "ay": 35, "bx": 25, "by": 35, "pwm": 0.8]
            KoordinatenTabelle.append(zeilenDic)
        }
        print("KoordinatenTabelle: \(KoordinatenTabelle)")
        CNC_Stoptaste.state = NSControl.StateValue.off
        //self.NeuTastefunktion()
        CNC_Starttaste.state = NSControl.StateValue.on
        print("KoordinatenTabelle: \(KoordinatenTabelle)")
        //self.StopTastefunktion()
        
        var profil1popindex = 0
        var profil2popindex = 0
        
        let offsetx = ProfilBOffsetXFeld.doubleValue
        let offsety = ProfilBOffsetYFeld.doubleValue
        
        
        var datenDic = [String:Any]()
        
        
        datenDic["element"] = "Linie"
        datenDic["startx"] = WertAXFeld.doubleValue
        datenDic["starty"] = WertAYFeld.doubleValue
        datenDic["einlaufrand"] = Einlaufrand.integerValue
        datenDic["auslaufrand"] = Auslaufrand.integerValue
        
        datenDic["einlauflaenge"] = Einlauflaenge.integerValue
        datenDic["einlauftiefe"] = Einlauftiefe.integerValue
        datenDic["auslauflaenge"] = Auslauflaenge.integerValue
        datenDic["auslauftiefe"] = Auslauftiefe.integerValue
        
        datenDic["abbrand"] = AbbrandFeld.doubleValue
        
        datenDic["mitoberseite"] = 1
        datenDic["mitunterseite"] = 0
        
        datenDic["pwm"] = pwm
        
        let redpwm = red_pwmFeld.doubleValue
        datenDic["redpwm"] = redpwm

        datenDic["minimaldistanz"] = MinimaldistanzFeld.floatValue
        
        if Profil1Pop.indexOfSelectedItem > 0
        {
            let profil1name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            datenDic["profil1"] = profil1name
            profil1popindex = Profil1Pop.indexOfSelectedItem
            datenDic["profil1popindex"] = profil1popindex
        }
        else if ProfilNameFeldA.stringValue.count > 0
        {
            datenDic["profil1"] = ProfilNameFeldA.stringValue
            datenDic["profil1popindex"] = 1
        }
        
        
        if Profil2Pop.indexOfSelectedItem > 0
        {
            let profil2name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            datenDic["profil2"] = profil2name
            profil2popindex = Profil2Pop.indexOfSelectedItem
            datenDic["profil2popindex"] = profil2popindex
        }
        else if ProfilNameFeldB.stringValue.count > 0
        {
            datenDic["profil2"] = ProfilNameFeldB.stringValue
            datenDic["profil2popindex"] = 1
        }

        
        OberseiteCheckbox.state = NSControl.StateValue.on
        UnterseiteCheckbox.state = NSControl.StateValue.off

        print("Hotwire reportProfilOberseiteTask VOR doProfil: KoordinatenTabelle")
        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"] ?? 0
            let ay = zeile["ay"] ?? 0
            let bx = zeile["bx"] ?? 0
            let by = zeile["by"] ?? 0
           // print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t  %2.4f \t %2.4f ",i,ax,ay,bx,by))
        }
        datenDic["koordinatentabelle"] = KoordinatenTabelle;
        
        CNC_Eingabe.setPList(CNC_PList as? [AnyHashable : Any])
        
        CNC_Eingabe.setDaten(datenDic)
        
        print("reportProfilOberseiteTask datenDic: \(datenDic)")
        CNC_Eingabe.profilPopTask(datenDic);
        
        print("HotWire reportProfilOberseiteTask NACH profilPopTask: KoordinatenTabelle")
        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"] ?? 30
            let ay = zeile["ay"] ?? 30
            let bx = zeile["bx"] ?? 30
            let by = zeile["by"] ?? 30
            //print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t  %2.4f \t %2.4f ",i,ax,ay,bx,by))
        }
        datenDic["koordinatentabelle"] = KoordinatenTabelle;
        
        //print("datendic vor blockanfuegenFunktion: \(datenDic)")
       
        KoordinatenTabelle.removeAll()
        KoordinatenTabelle = AVR?.blockanfuegenFunktion(datenDic) as! [[String : Double]];
        print("reportProfilOberseiteTask KoordinatenTabelle: ")
        // Abmessungen block
        var minX:Double = 1000
        var minY:Double = 1000
        var maxX:Double = 0
        var maxY:Double = 0
        var maxabrX:Double = 0
        var maxabrY:Double = 0
        // https://forums.swift.org/t/array-of-dictionaries-get-the-values-of-a-specific-key/29001
        let axarray = KoordinatenTabelle.compactMap { $0["ax"] }
        let ayarray = KoordinatenTabelle.compactMap { $0["ay"] }
        minX = axarray.min() ?? 10000
        minY = ayarray.min() ?? 1000
        maxX = axarray.max() ?? 0
        maxY = ayarray.max() ?? 0
 
        let abraxarray = KoordinatenTabelle.compactMap { $0["abrax"] }
        let abrayarray = KoordinatenTabelle.compactMap { $0["abray"] }
        maxabrX = (abraxarray.max() ?? 0)
        maxabrY = (abrayarray.max() ?? 0)
        
        maxX = max(maxX,maxabrX) + offsetx
        maxY = max(maxY,maxabrY) + offsety
        
        
        print("minX: \(minX) minY: \(minY) maxX: \(maxX) maxY: \(maxY)")
        
        print("reportProfilOberseiteTask Koordinatentabelle:")
        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"]
            let ay = zeile["ay"]
            let bx = zeile["bx"]
            let by = zeile["by"]
  
            let abrax = (zeile["abrax"] ?? ax)!
            let abray = (zeile["abray"] ?? ay)!
            let abrbx = (zeile["abrbx"] ?? bx)!
            let abrby = (zeile["abrby"] ?? by)!
             
            //print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t  %2.4f \t %2.4f \t\t%2.4f \t  %2.4f \t  %2.4f \t %2.4f ",i,ax!,ay!,abrax,abray,bx!,by!,abrbx,abrby))
        }
        
        let rahmenrect = NSMakeRect(minX, minY, maxX - minX, maxY - minY)
        //let rahmenarray = [[minX,maxY],[maxX,maxY],[maxX,minY],[minX,minY]]
        
        let rahmenarray = [NSMakePoint(minX, maxY) ,NSMakePoint(maxX,maxY),NSMakePoint(maxX,minY),NSMakePoint(minX,minY)]
        //BlockrahmenArray = rahmenarray
        CNC_Table.reloadData()
        //let r = rahmenarray as NSArray
        ProfilFeld.setRahmenArray(derRahmenArray: rahmenarray as NSArray)
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true

        CNC_Stoptaste.isEnabled = true
        

        print("reportProfilOberseiteTask end")
    }
    
    
    // MARK:  *** *** ***  reportProfilUnterseiteTask
        @IBAction func reportProfilUnterseiteTask(_ sender: NSButton)
    {
        print("reportProfilUnterseiteTask")
        var eingabeDic = [String:Any]()
        if KoordinatenTabelle.count == 0
        {
            var zeilenDic = ["index": 0, "ax":  25, "ay": 35, "bx": 25, "by": 35, "pwm": 0.8]
            KoordinatenTabelle.append(zeilenDic)
        }
        print("KoordinatenTabelle: \(KoordinatenTabelle)")
        CNC_Stoptaste.state = NSControl.StateValue.off
        //self.NeuTastefunktion()
        CNC_Starttaste.state = NSControl.StateValue.on
        print("KoordinatenTabelle: \(KoordinatenTabelle)")
        //self.StopTastefunktion()
        
        var profil1popindex = 0
        var profil2popindex = 0
        
        let offsetx = ProfilBOffsetXFeld.doubleValue
        let offsety = ProfilBOffsetYFeld.doubleValue
        
        
        var datenDic = [String:Any]()
        
        
        datenDic["element"] = "Linie"
        datenDic["startx"] = WertAXFeld.doubleValue
        datenDic["starty"] = WertAYFeld.doubleValue
        datenDic["einlaufrand"] = Einlaufrand.integerValue
        datenDic["auslaufrand"] = Auslaufrand.integerValue
        
        datenDic["einlauflaenge"] = Einlauflaenge.integerValue
        datenDic["einlauftiefe"] = Einlauftiefe.integerValue
        datenDic["auslauflaenge"] = Auslauflaenge.integerValue
        datenDic["auslauftiefe"] = Auslauftiefe.integerValue
        
        datenDic["abbrand"] = AbbrandFeld.doubleValue
        
        datenDic["mitoberseite"] = 0
        datenDic["mitunterseite"] = 1
        
        datenDic["pwm"] = pwm
        
        let redpwm = red_pwmFeld.doubleValue
        datenDic["redpwm"] = redpwm

        datenDic["minimaldistanz"] = MinimaldistanzFeld.floatValue
        
        if Profil1Pop.indexOfSelectedItem > 0
        {
            let profil1name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            datenDic["profil1"] = profil1name
            profil1popindex = Profil1Pop.indexOfSelectedItem
            datenDic["profil1popindex"] = profil1popindex
        }
        else if ProfilNameFeldA.stringValue.count > 0
        {
            datenDic["profil1"] = ProfilNameFeldA.stringValue
            datenDic["profil1popindex"] = 1
        }
        
        
        if Profil2Pop.indexOfSelectedItem > 0
        {
            let profil2name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            datenDic["profil2"] = profil2name
            profil2popindex = Profil2Pop.indexOfSelectedItem
            datenDic["profil2popindex"] = profil2popindex
        }
        else if ProfilNameFeldB.stringValue.count > 0
        {
            datenDic["profil2"] = ProfilNameFeldB.stringValue
            datenDic["profil2popindex"] = 1
        }

        
        OberseiteCheckbox.state = NSControl.StateValue.off
        UnterseiteCheckbox.state = NSControl.StateValue.on

        print("Hotwire reportProfilUnterseiteTask VOR doProfil: KoordinatenTabelle")
        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"] ?? 0
            let ay = zeile["ay"] ?? 0
            let bx = zeile["bx"] ?? 0
            let by = zeile["by"] ?? 0
           // print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t  %2.4f \t %2.4f ",i,ax,ay,bx,by))
        }
        datenDic["koordinatentabelle"] = KoordinatenTabelle;
        
        CNC_Eingabe.setPList(CNC_PList as? [AnyHashable : Any])
        
        CNC_Eingabe.setDaten(datenDic)
        
        print("reportProfilUnterseiteTask datenDic: \(datenDic)")
        CNC_Eingabe.profilPopTask(datenDic);
        
        print("HotWire reportProfilUnterseiteTask NACH profilPopTask: KoordinatenTabelle")
        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"] ?? 30
            let ay = zeile["ay"] ?? 30
            let bx = zeile["bx"] ?? 30
            let by = zeile["by"] ?? 30
            //print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t  %2.4f \t %2.4f ",i,ax,ay,bx,by))
        }
        datenDic["koordinatentabelle"] = KoordinatenTabelle;
        
        //print("datendic vor blockanfuegenFunktion: \(datenDic)")
        
        KoordinatenTabelle.removeAll()
        KoordinatenTabelle = AVR?.blockanfuegenFunktion(datenDic) as! [[String : Double]];
        print("reportProfilOberseiteTask KoordinatenTabelle: ")
        // Abmessungen block
        var minX:Double = 1000
        var minY:Double = 1000
        var maxX:Double = 0
        var maxY:Double = 0
        var maxabrX:Double = 0
        var maxabrY:Double = 0
        // https://forums.swift.org/t/array-of-dictionaries-get-the-values-of-a-specific-key/29001
        let axarray = KoordinatenTabelle.compactMap { $0["ax"] }
        let ayarray = KoordinatenTabelle.compactMap { $0["ay"] }
        minX = axarray.min() ?? 10000
        minY = ayarray.min() ?? 1000
        maxX = axarray.max() ?? 0
        maxY = ayarray.max() ?? 0
 
        let abraxarray = KoordinatenTabelle.compactMap { $0["abrax"] }
        let abrayarray = KoordinatenTabelle.compactMap { $0["abray"] }
        maxabrX = (abraxarray.max() ?? 0)
        maxabrY = (abrayarray.max() ?? 0)
        
        maxX = max(maxX,maxabrX) + offsetx
        maxY = max(maxY,maxabrY) + offsety
        
        
        print("minX: \(minX) minY: \(minY) maxX: \(maxX) maxY: \(maxY)")
        
        
        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"]
            let ay = zeile["ay"]
            let bx = zeile["bx"]
            let by = zeile["by"]
  
            let abrax = (zeile["abrax"] ?? ax)!
            let abray = (zeile["abray"] ?? ay)!
            let abrbx = (zeile["abrbx"] ?? bx)!
            let abrby = (zeile["abrby"] ?? by)!
             
            //print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t  %2.4f \t %2.4f \t\t%2.4f \t  %2.4f \t  %2.4f \t %2.4f ",i,ax!,ay!,abrax,abray,bx!,by!,abrbx,abrby))
        }
        
        let rahmenrect = NSMakeRect(minX, minY, maxX - minX, maxY - minY)
        //let rahmenarray = [[minX,maxY],[maxX,maxY],[maxX,minY],[minX,minY]]
        let rahmenarray = [NSMakePoint(minX, maxY) ,NSMakePoint(maxX,maxY),NSMakePoint(maxX,minY),NSMakePoint(minX,minY)]

        CNC_Table.reloadData()
        ProfilFeld.setRahmenArray(derRahmenArray: rahmenarray as NSArray)
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true

        CNC_Stoptaste.isEnabled = true
        

        print("reportProfilOberseiteTask end")
    }

    @IBAction func reportNeuesElement(_ sender:NSButton)
    {
        // Sicherheitshalber: letzten Punkt der bisherigen Datentabelle auswählen und Werte in Felder fuellen. Sonst wird neues Element nicht mit Endpunkt verbunden
        let rowindexset =  IndexSet(integer: KoordinatenTabelle.count)
        CNC_Table.selectRowIndexes(rowindexset, byExtendingSelection: false)   //
        
        
        
        
        var datenDic = [String:Any]()
        
        
        datenDic["element"] = "Linie"
        datenDic["startx"] = WertAXFeld.doubleValue
        datenDic["starty"] = WertAYFeld.doubleValue
        datenDic["einlaufrand"] = Einlaufrand.integerValue
        datenDic["auslaufrand"] = Auslaufrand.integerValue
        
        datenDic["einlauflaenge"] = Einlauflaenge.integerValue
        datenDic["einlauftiefe"] = Einlauftiefe.integerValue
        datenDic["auslauflaenge"] = Auslauflaenge.integerValue
        datenDic["auslauftiefe"] = Auslauftiefe.integerValue
        
        datenDic["abbrand"] = AbbrandFeld.doubleValue
        
        datenDic["mitoberseite"] = 1
        datenDic["mitunterseite"] = 1
        
        OberseiteCheckbox.state = NSControl.StateValue.on
        UnterseiteCheckbox.state = NSControl.StateValue.on
        
        
        if Profil1Pop.indexOfSelectedItem > 0
        {
            let profil1name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            datenDic["profil1"] = profil1name
        }
        else if ProfilNameFeldA.stringValue.count > 0
        {
            datenDic["profil1"] = ProfilNameFeldA.stringValue
        }
        
        
        if Profil2Pop.indexOfSelectedItem > 0
        {
            let profil2name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            datenDic["profil2"] = profil2name
        }
        else if ProfilNameFeldB.stringValue.count > 0
        {
            datenDic["profil2"] = ProfilNameFeldB.stringValue
        }
        
        AVR?.neueLinieFunktion(datenDic)
        
        /*
         var modalSession =  NSApp.beginModalSession(for:CNC_Eingabe.window!)
         //NSLog(@"runModalForWindow A");
         
         CNC_Eingabe.setPList(CNC_PList as? [AnyHashable : Any])
         //NSLog(@"runModalForWindow B");
         CNC_Eingabe.setDaten(datenDic)
         
         CNC_Eingabe.clearProfilGraphDaten()
         
         var modalResponse = NSApp.runModalSession(modalSession)
         */
        
        /*
         while ([NSApp runModalSession:session] != NSModalResponseContinue)
         {
         //NSLog(@"Modal break");
         break;
         }
         //[CNC_Eingabe showWindow:NULL];
         //[self doSomeWork];
         
         //[[CNC_Eingabe window]orderOut:NULL];
         [NSApp endModalSession:session];
         */
        
        // [NSApp runModalForWindow:CNC_Eingabe];
        
        //[NSApp beginSheet:CNC_Eingabe modalForWindow:[self window] modalDelegate:self didEndSelector:NULL contextInfo:nil];
        
    }
    
   @IBAction func reportManRight(_ sender: rPfeil_Taste)
   {
      //print("swift reportManRight: \(sender.tag)")
       
       AnschlagLinksIndikator.layer?.backgroundColor = NSColor.green.cgColor
       
       cnc_seite1check = CNC_Seite1Check.state.rawValue as Int
       cnc_seite2check = CNC_Seite2Check.state.rawValue as Int
       outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
       outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
       outletdaten["speed"] = SpeedFeld.integerValue as AnyObject
       outletdaten["micro"] = micro as AnyObject
       outletdaten["boardindex"] = boardindex as AnyObject
       print("outletdaten: \(outletdaten)")
       var pfeildaten:[String:Int] = [:]
       pfeildaten["cnc_seite1check"] = (CNC_Seite1Check.state.rawValue)
       pfeildaten["cnc_seite2check"] = (CNC_Seite2Check.state.rawValue)
       pfeildaten["speed"] = SpeedFeld.integerValue
       pfeildaten["micro"] = micro
       pfeildaten["motorsteps"] = motorsteps
       pfeildaten["boardindex"] = boardindex
       print("pfeildaten: \(pfeildaten)")
       
       
       
       AVR?.manRichtung(1, mousestatus:1, pfeilstep:100)
   }
    
    @IBAction func reportManUp(_ sender: rPfeil_Taste)
    {
       print("swift reportManUp: \(sender.tag)")
        cnc_seite1check = CNC_Seite1Check.state.rawValue as Int
        cnc_seite2check = CNC_Seite2Check.state.rawValue as Int
        outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
        outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
        outletdaten["speed"] = SpeedFeld.integerValue as AnyObject
        outletdaten["micro"] = micro as AnyObject


        AVR?.manRichtung(2, mousestatus:1, pfeilstep:100)
    }

    @IBAction func reportManLeft(_ sender: rPfeil_Taste)
    {
       print("swift reportManLeft: \(sender.tag)")
        cnc_seite1check = CNC_Seite1Check.state.rawValue as Int
        cnc_seite2check = CNC_Seite2Check.state.rawValue as Int
        outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
        outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
        outletdaten["speed"] = SpeedFeld.integerValue as AnyObject
        outletdaten["micro"] = micro as AnyObject


        AVR?.manRichtung(3, mousestatus:1, pfeilstep:100)
    }

    @IBAction func reportManDown(_ sender: rPfeil_Taste)
    {
       print("swift reportManDown: \(sender.tag)")
        cnc_seite1check = CNC_Seite1Check.state.rawValue as Int
        cnc_seite2check = CNC_Seite2Check.state.rawValue as Int
        outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
        outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
        outletdaten["speed"] = SpeedFeld.integerValue as AnyObject
        outletdaten["micro"] = micro as AnyObject


        AVR?.manRichtung(4, mousestatus:1, pfeilstep:100)
    }
    @IBAction  func reportIndexStepper(_ sender: NSStepper) //
    {
       print("reportIndexStepper IntVal: \(sender.integerValue)")
        IndexFeld.integerValue = sender.integerValue
        
        self.setDatenVonZeile(zeile: sender.integerValue)
        let StepperIndexSet = IndexSet(integer: sender.integerValue)
        
        CNC_Table.scrollRowToVisible(sender.integerValue)

        
        CNC_Table.reloadData()
        CNC_Table.selectRowIndexes(StepperIndexSet, byExtendingSelection: false)
    }

    @IBAction  func reportWertStepper(_ sender: NSStepper) //
    {
        print("reportWertStepper IntVal: \(sender.integerValue) wert: \(sender.doubleValue)")
        let steppertag = sender.tag
        let stepperwert = sender.doubleValue
        
         if CNC_Table.numberOfSelectedRows == 0
         {
             NSSound.beep()
         return
         }
         
        //let wertfeld = self.view.superview.viewWithTag
        let index = IndexFeld.integerValue
//        print("wertax vor replace: \(KoordinatenTabelle[IndexFeld.integerValue]["ax"])")
        var tempzeile:[String:Double] = KoordinatenTabelle[IndexFeld.integerValue]
        var wertax = tempzeile["ax"]!
        var wertay = tempzeile["ay"]!
        var wertbx = tempzeile["bx"]!
        var wertby = tempzeile["by"]!
        var wertpwm = DC_PWM.integerValue
        if let temp = tempzeile["pwm"]
        {
            wertpwm = Int(temp)
        }
        let bind = ABBindCheck.state == NSControl.StateValue.on
        
        switch steppertag
        {
        case 8100: // ax
            if bind == true
            {
                tempzeile["bx"] = wertbx - wertax + stepperwert
            }
            tempzeile["ax"] = stepperwert
        case 8101: // ay
            if bind == true
            {
                tempzeile["by"] = wertby - wertay + stepperwert
            }
            tempzeile["ay"] = stepperwert

        case 8102: // bx
            if bind == true
            {
                tempzeile["ax"] = wertax - wertbx + stepperwert
            }
            tempzeile["bx"] = stepperwert
        
        
        case 8103: // by
            if bind == true
            {
                tempzeile["ay"] = wertay - wertby + stepperwert
            }
            tempzeile["by"] = stepperwert
         
        default:
            break
        }
         
        KoordinatenTabelle[IndexFeld.integerValue] = tempzeile
  //      print("wertax nach replace: \(KoordinatenTabelle[IndexFeld.integerValue]["ax"])")
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        
        ProfilFeld.needsDisplay = true
        let StepperIndexSet = IndexSet(integer: index)
        //CNC_Table.scrollRowToVisible(index)
        CNC_Table.reloadData()
        CNC_Table.selectRowIndexes(StepperIndexSet, byExtendingSelection: false)

    }
    @IBAction  func reportWertAXStepper(_ sender: NSStepper) //
    {
        print("reportWertAXStepper IntVal: \(sender.integerValue) wert: \(sender.doubleValue)")
        /*
         if CNC_Table.numberOfSelectedRows == 0
         {
         return
         }
         */
        //let wertfeld = self.view.superview.viewWithTag
        let index = IndexFeld.integerValue
        print("wertax vor replace: \(KoordinatenTabelle[IndexFeld.integerValue]["ax"])")
        var tempzeile:[String:Double] = KoordinatenTabelle[IndexFeld.integerValue]
        var wertax = tempzeile["ax"]!
        var wertay = tempzeile["ay"]
        var wertbx = tempzeile["bx"]!
        var wertby = tempzeile["by"]
        var wertpwm = DC_PWM.integerValue
        if let temp = tempzeile["pwm"]
        {
            wertpwm = Int(temp)
        }
        let delta = sender.doubleValue - wertax
        wertax = sender.doubleValue
        if ABBindCheck.state == NSControl.StateValue.on
        {
            wertbx = wertbx + delta
        }
        var tempDic = [String:Double]()
        tempzeile["ax"] = wertax
        tempzeile["bx"] = wertbx
        tempzeile["pwm"] = Double(wertpwm)
        
        KoordinatenTabelle[IndexFeld.integerValue] = tempzeile
        print("wertax nach replace: \(KoordinatenTabelle[IndexFeld.integerValue]["ax"])")
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        
        ProfilFeld.needsDisplay = true
        let StepperIndexSet = IndexSet(integer: index)
        //CNC_Table.scrollRowToVisible(index)
        CNC_Table.reloadData()
        CNC_Table.selectRowIndexes(StepperIndexSet, byExtendingSelection: false)

    }

    @IBAction  func reportWertAYStepper(_ sender: NSStepper) //
    {
       print("reportWertAYStepper IntVal: \(sender.integerValue)")
    }

    @IBAction  func reportWertBXStepper(_ sender: NSStepper) //
    {
       print("reportWertBXStepper IntVal: \(sender.integerValue)")
    }

    @IBAction  func reportWertBYStepper(_ sender: NSStepper) //
    {
       print("reportWertBYStepper IntVal: \(sender.integerValue)")
    }
    
    
    @IBAction  func reportRump(_ sender: NSButton) //
    {
        print("reportRumpf")
        print("reportRumpf KoordinatenTabelle Start: \(KoordinatenTabelle)")

        var ax:Double = 0
        var ay:Double = 0
        var bx:Double = 0
        var by:Double = 0

        var StartpunktA:NSPoint
        var StartpunktB:NSPoint
 
        // letztes Element der Koordinatentabelle
        if KoordinatenTabelle.count > 0
        {
            ax = (KoordinatenTabelle.last?["ax"])!
            ay = (KoordinatenTabelle.last?["ay"])!
            bx = (KoordinatenTabelle.last?["bx"])!
            by = (KoordinatenTabelle.last?["by"])!
            
            StartpunktA = NSMakePoint(ax,ay)
            StartpunktB = NSMakePoint(bx,by)
        }
        else
        {
            ax = 25
            ay = 55
            bx = 25
            by = 55
            StartpunktA = NSMakePoint(ax,ay)
            StartpunktB = NSMakePoint(bx,by)
        }
        let offsetx:Double = ProfilBOffsetXFeld.doubleValue
        let offsety:Double = ProfilBOffsetYFeld.doubleValue
        var startx:Double = 0
        var starty:Double = 0
    
        var breiteAraw = BreiteAFeld.doubleValue;
       var hoeheAraw = HoeheAFeld.doubleValue ;
        var  radiusAraw = RadiusAFeld.doubleValue;
        var  breiteBraw = BreiteBFeld.doubleValue;
        var  hoeheBraw = HoeheBFeld.doubleValue;
        var  radiusBraw = RadiusBFeld.doubleValue;
        print("1 radiusAraw: \(radiusAraw) radiusBraw: \(radiusBraw)")
         //  Double elementlaenge = ElementlaengeFeld intValue;
        var  portalabstand = RumpfportalabstandFeld.doubleValue;
        var  elementlaenge = ElementlaengeFeld.doubleValue;
        var  rumpfbasisabstand = RumpfabstandFeld .doubleValue;
           // Horizontal
        var  pfeilungH = (breiteAraw - breiteBraw)/elementlaenge;
        var  arc=atan(pfeilungH);
            
        var  breiteA =  breiteAraw + rumpfbasisabstand * pfeilungH;
        var  breiteB = breiteA - portalabstand * pfeilungH;
        print("pfeilung W: \(pfeilungH) breiteA:  \(breiteA)  breiteB: \(breiteB)")

        // Vertikal
           var pfeilungV = (hoeheAraw - hoeheBraw)/elementlaenge
          
          var hoeheA = hoeheAraw + rumpfbasisabstand * pfeilungV
          var hoeheB = hoeheA  - portalabstand * pfeilungV
          //float hoeheB = hoeheBraw - (portalabstand- rumpfbasisabstand - elementlaenge) * pfeilungV;
          var faktorV = hoeheA/hoeheAraw
        // Startpunkt fixieren
        WertAXFeld.doubleValue = 20.0
        WertAYFeld.doubleValue = 20.0
        //  [RumpfOffsetXFeld setIntValue:(breiteAraw - breiteBraw)/2*(-1)];
        
        var gfkbreiteA = 0.0; // Breite der GFK-Lage
         gfkbreiteA += 2 * (hoeheAraw - radiusAraw) // senkrechte teile
        gfkbreiteA += radiusAraw * Double.pi // beide Viertelkreise
         gfkbreiteA += (breiteAraw - 2 * radiusAraw); // waagrechter Teil
        var gfkbreiteB = 0.0;
           gfkbreiteB += 2 * (hoeheBraw - radiusBraw) // senkrechte teile
           gfkbreiteB += radiusBraw * Double.pi // beide Viertelkreise
           gfkbreiteB += (breiteBraw - 2 * radiusBraw) // waagrechter Teil

        GFKFeldA.integerValue = Int(ceil(gfkbreiteA))
        GFKFeldA.integerValue = Int(ceil(gfkbreiteB))

        var RumpfelementDic = [String:Double]()
        RumpfelementDic["rumpfblockbreite"] = RumpfBlockbreite.doubleValue
        RumpfelementDic["rumpfblockhoehe"] = RumpfBlockhoehe.doubleValue
        RumpfelementDic["rumpfbreitea"] = breiteA
        RumpfelementDic["rumpfbreiteb"] = breiteB
        
        RumpfelementDic["rumpfhoehea"] = hoeheA
        RumpfelementDic["rumpfhoeheb"] = hoeheB
print("2 radiusAraw: \(radiusAraw) radiusBraw: \(radiusBraw)")
        RumpfelementDic["rumpfradiusa"] = radiusAraw
        RumpfelementDic["rumpfradiusb"] = radiusBraw

        
        RumpfelementDic["rumpfportalabstand"] = RumpfabstandFeld.doubleValue

        RumpfelementDic["rumpfelementlaenge"] = ElementlaengeFeld.doubleValue

        RumpfelementDic["rumpfoffsetx"] = RumpfOffsetXFeld.doubleValue
        RumpfelementDic["rumpfoffsety"] = RumpfOffsetYFeld.doubleValue
        
        RumpfelementDic["rumpfeinlauf"] = EinlaufFeld.doubleValue
        RumpfelementDic["rumpfauslauf"] = AuslaufFeld.doubleValue
        
        RumpfelementDic["rumpfrand"] = RandFeld.doubleValue
        RumpfelementDic["rumpfeinstichtiefe"] = EinstichtiefeFeld.doubleValue
        
        RumpfelementDic["pwm"] = DC_PWM.doubleValue
        RumpfelementDic["redpwm"] = red_pwmFeld.doubleValue
        
        
        print("reportRumpf RumpfelementDic:\n \(RumpfelementDic)")
        
        
        KoordinatenTabelle = AVR?.rumpfelementmitDic(RumpfelementDic) as! [[String : Double]]
    //print("Rumpfarray: \(Rumpfarray)")
        var minX:Double = 1000
        var minY:Double = 1000
        var maxX:Double = 0
        var maxY:Double = 0

        let axarray = KoordinatenTabelle.compactMap { $0["ax"] }
        let ayarray = KoordinatenTabelle.compactMap { $0["ay"] }
        minX = axarray.min() ?? 10000
        minY = ayarray.min() ?? 1000
        maxX = axarray.max() ?? 0
        maxY = ayarray.max() ?? 0

        for i in 0..<KoordinatenTabelle.count
        {
            let zeile = KoordinatenTabelle[i]
            let ax = zeile["ax"]
            let ay = zeile["ay"]
            let bx = zeile["bx"]
            let by = zeile["by"]
            let pwm = zeile["pwm"]
            let index = zeile["index"] ?? Double(i)
  
                
            //print(String(format: "a float number: %.2f", 1.0321))
            print(String(format:"%d \t%2.4f \t  %2.4f \t\t%2.4f \t  %2.4f \t  %2.4f  ",index,ax!,ay!,bx!,by!,pwm!))
        }
        let rahmenrect = NSMakeRect(minX, minY, maxX - minX, maxY - minY)
        //let rahmenarray = [[minX,maxY],[maxX,maxY],[maxX,minY],[minX,minY]]
        let rahmenarray = [NSMakePoint(minX, maxY) ,NSMakePoint(maxX,maxY),NSMakePoint(maxX,minY),NSMakePoint(minX,minY)]
        CNC_Table.reloadData()
        ProfilFeld.setRahmenArray(derRahmenArray: rahmenarray as NSArray)
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true

        CNC_Stoptaste.isEnabled = true
        
        
    //reiteA:breiteA mitHoeheA:hoeheA , mitRadiusA:radiusAraw mitBreiteB:breiteB mitHoeheB:hoeheB mitRadiusB:radiusBraw)
        
    }
    
    
    @IBAction  func reportRumpfteilTaste(_ sender: NSSegmentedControl) //
    {
        print("reportRumpfteilTaste index: \(sender.indexOfSelectedItem)")
        let rumpfteilindex = sender.indexOfSelectedItem
        let temprumpfteildic = self.rumpfteilDic()
        //self.NeuTastefunktion()
       // print("reportRumpfteilTaste rumpfteilDic: \(temprumpfteildic)")
        print("reportRumpfteilTaste rumpfteilDic")
        let teilkeys = temprumpfteildic.keys
        var  n:Int = 0
        for k in teilkeys
         {
            //let tempzey = zeilenkeys[i]
            let data = temprumpfteildic[k]
//            print("i:\t \(n) \tkey: \(k) \twert: \t\(data ?? 8888)")
            n += 1
        }

        
        print("reportRumpfteilTaste rumpfteilDic")
        let zeile = RumpfdatenArray[rumpfteilindex] as [String:Double]
        print("index: \(rumpfteilindex) breitea: \(zeile["breitea"])")
        let zeilenkeys = zeile.keys
        var i=0
        for k in zeilenkeys
         {
            //let tempzey = zeilenkeys[i]
            let data = zeile[k]
            print("i:\t \(i) \tkey:\t \(k) \tdata:\t \(data ?? 7777)")
            i += 1
        }

        BreiteAFeld.integerValue = Int(zeile["breitea"]!)
        BreiteBFeld.integerValue = Int(zeile["breiteb"]!)
        HoeheAFeld.integerValue = Int(zeile["hoehea"]!)
        HoeheBFeld.integerValue = Int(zeile["hoeheb"]!)
        RadiusAFeld.integerValue = Int(zeile["radiusa"]!)
        RadiusBFeld.integerValue = Int(zeile["radiusb"]!)
        RumpfabstandFeld.integerValue = Int(zeile["rumpfabstand"]!)
        ElementlaengeFeld.integerValue = Int(zeile["elementlaenge"]!)
        RumpfportalabstandFeld.integerValue = Int(zeile["rumpfportalabstand"]!)
        EinstichtiefeFeld.integerValue = Int(zeile["einstichtiefe"]!)
        EinlaufFeld.integerValue = Int(zeile["rumpfeinlauf"]!)
        AuslaufFeld.integerValue = Int(zeile["rumpfauslauf"]!)
        RandFeld.integerValue = Int(zeile["rand"]!)
        RumpfOffsetXFeld.integerValue = Int(zeile["rumpfoffsetx"]!)
        RumpfOffsetYFeld.integerValue = Int(zeile["rumpfoffsety"]!)
        RumpfBlockhoehe.integerValue = Int(zeile["rumpfblockhoehe"]!)
        RumpfBlockbreite.integerValue = Int(zeile["rumpfblockbreite"]!)

        
   //     print("reportRumpfteilTaste Rumpfdatenarray: \(RumpfdatenArray[rumpfteilindex])")
        
   //     print("reportRumpfteilTaste breiteA:\(temprumpfteildic["rumpfbreitea"])")
 //       var rumpfteilDic = AVR?.rumpfteilTasteFunktion(self.rumpfteilDic()  as [String: Double]);
   //     print("reportRumpfteilTaste rumpfteilDic von AVR:\(self.rumpfteilDic() as NSDictionary)")
        
    }

    @objc func rumpfteilDic() -> [String:Double]
    {
        var teildic =  [String:Double]()
        teildic["rumpfteil"] = Double(RumpfteilTaste.indexOfSelectedItem)
        teildic["rumpfportalabstand"] = RumpfportalabstandFeld.doubleValue
        teildic["rumpfrand"] = RandFeld.doubleValue
        teildic["rumpfeinlauf"] = EinlaufFeld.doubleValue
        teildic["rumpbreitea"] = BreiteAFeld.doubleValue
        teildic["rumphoehea"] = HoeheAFeld.doubleValue
        teildic["rumpradiusa"] = RadiusAFeld.doubleValue
        teildic["rumpbreiteb"] = BreiteBFeld.doubleValue
        teildic["rumphoeheb"] = HoeheBFeld.doubleValue
        teildic["rumpradiusb"] = RadiusBFeld.doubleValue
        teildic["rumpeinstichtiefe"] = EinstichtiefeFeld.doubleValue
        teildic["rumpfabstand"] = RumpfabstandFeld.doubleValue
        teildic["rumpelementlaenge"] = ElementlaengeFeld.doubleValue

        teildic["rumpfblockbreite"] = RumpfBlockbreite.doubleValue
        teildic["rumpfblockhoehe"] = RumpfBlockhoehe.doubleValue
        teildic["rumpfauslauf"] = AuslaufFeld.doubleValue
           
        teildic["rumpfoffsetx"] = RumpfOffsetXFeld.doubleValue
        teildic["rumpfoffsety"] = RumpfOffsetYFeld.doubleValue
        
        teildic["rumpfpwm"] = DC_PWM.doubleValue
        teildic["rumpfspeed"] = SpeedFeld.doubleValue
        let microitem:NSMenuItem = (CNC_microPop.selectedItem!)
        
        let micropoptag:Double = Double(microitem.tag)
        
        teildic["rumpfmicro"] = micropoptag
        
         
           

        return teildic
    }



    @objc func setDatenVonZeile(zeile:Int)
    {
        if (zeile < 0 || zeile > KoordinatenTabelle.count - 1 )
        {
            print("setDatenVonZeile ausserhalb")
            NSSound.beep()
            return
        }

        var tempzeile:[String:Double] = KoordinatenTabelle[zeile]
        IndexFeld.integerValue = Int(tempzeile["index"]!)
        IndexStepper.integerValue = IndexFeld.integerValue
        
        WertAXFeld.doubleValue = tempzeile["ax"]!
        WertAXStepper.doubleValue = tempzeile["ax"]!

        WertAYFeld.doubleValue = tempzeile["ay"]!
        WertAYStepper.doubleValue = tempzeile["ay"]!

        WertBXFeld.doubleValue = tempzeile["bx"]!
        WertBXStepper.doubleValue = tempzeile["bx"]!

        WertBYFeld.doubleValue = tempzeile["by"]!
        WertBYStepper.doubleValue = tempzeile["by"]!
        
        ProfilFeld.setKlickpunkt(derPunkt: IndexFeld.integerValue)
        ProfilFeld.needsDisplay = true
    }
    

    
    @IBAction func report_Shift(_ sender: NSButton)
    {
        print("swift report_Shift: \(sender.tag)")
        let knopftag = sender.tag
        var dx:Double = 0
        var dy:Double = 0
        let shiftschritt = 4
        
        switch knopftag
        {
        case 1:// rechts
            print("right")
            dx = Double(shiftschritt)
            dy = 0
        case 2: // up
            print("up")
            dx = 0
            dy = Double(shiftschritt)
        case 3: // left
            print("left")
            dx = Double(shiftschritt) * -1
            dy = 0
        case 4: // down
            print("down")
            dx = 0
            dy = Double(shiftschritt) * -1

            
            
        default:
            return
        }// switch tag

        
        var rahmenarray = [String:Double]()
        
        if KoordinatenTabelle.count > 0
        {
            for i in 0..<KoordinatenTabelle.count
            {
                var tempzeilendic = KoordinatenTabelle[i]
                KoordinatenTabelle[i]["ax"]! += dx
                KoordinatenTabelle[i]["ay"]! += dy
                KoordinatenTabelle[i]["bx"]! += dx
                KoordinatenTabelle[i]["by"]! += dy

                if  tempzeilendic["abrax"] == nil // kein abbran
                {
                    //print("kein abbrand")
                    continue
                }
                else
                {
                    KoordinatenTabelle[i]["abrax"]! += dx
                    KoordinatenTabelle[i]["abray"]! += dy
                    KoordinatenTabelle[i]["abrbx"]! += dx
                    KoordinatenTabelle[i]["abrby"]! += dy

                }
                
            }// for i
        }// if KoordinatenTabelle.count > 0
        
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
          
        if BlockKoordinatenTabelle.count > 0
        {
            for i in 0..<BlockKoordinatenTabelle.count
            {
                let tempzeilendic = BlockKoordinatenTabelle[i]
                BlockKoordinatenTabelle[i]["ax"]! += dx
                BlockKoordinatenTabelle[i]["ay"]! += dy
                BlockKoordinatenTabelle[i]["bx"]! += dx
                BlockKoordinatenTabelle[i]["by"]! += dy
            }
            
            
        }// if BlockKoordinatenTabelle.count > 0
        
 
        if BlockrahmenArray.count > 0
        {
            for i in 0..<BlockrahmenArray.count
            {
                var  temppunkt = NSPointFromString(BlockrahmenArray[i])
                temppunkt.x += dx
                temppunkt.y += dy
                BlockrahmenArray[i] = NSStringFromPoint(temppunkt)
            }
            
            ProfilFeld.setRahmenArray(derRahmenArray: BlockrahmenArray as NSArray)
        }// if BlockrahmenArray.count > 0
        

        
        CNC_Table.reloadData()
        ProfilFeld.needsDisplay = true
        
    }
    
   
    

    @IBAction func report_Home(_ sender: NSButton)
    {
        print("swift report_Home: \(sender.tag)")
        let nc = NotificationCenter.default
        var NotificationDic = [String:Int]()

        var AnfahrtArray = [[String:Double]]()
       
        // Startpunkt ist aktuelle Position. Lage: 3
        var PositionA:NSPoint = NSMakePoint(CGFloat(0), CGFloat(0))
        var PositionB:NSPoint = NSMakePoint(CGFloat(0), CGFloat(0))
        var index:Int = 0
        let zeilendicA:[String:Double] = ["ax": PositionA.x, "ay":PositionA.y, "bx": PositionB.x, "by":PositionB.y, "index":Double(index), "lage":3]
        AnfahrtArray.append(zeilendicA)
        
        PositionA.x -= 500
        PositionB.x -= 500
        index += 1
        let zeilendicB:[String:Double] = ["ax": PositionA.x, "ay":PositionA.y, "bx": PositionB.x, "by":PositionB.y, "index":Double(index), "lage":3]
        AnfahrtArray.append(zeilendicB)
        
        let zoomfaktor = 1
        
        var HomeSchnittdatenArray = [[String:Double]]()
        
        AVR?.homeSenkrechtSchicken()
        
    }
    
    /*******************************************************************/
    // CNC
    /*******************************************************************/
    @IBAction func report_Motorsteps(_ sender: NSSegmentedControl)
    {
        print("report_Motorsteps")
       let stepsindex = sender.selectedSegment
        motorsteps = sender.tag(forSegment: stepsindex)
        var NotificationDic = [String:Int]()
        let view = self.view.superview
        
       
        NotificationDic["motorsteps"] = motorsteps
        
        
        let nc = NotificationCenter.default
        /*
        nc.post(name:Notification.Name(rawValue:"motorsteps"),
        object: nil,
        userInfo: NotificationDic)
         */
        nc.post(name:Notification.Name(rawValue:"steps"),
        object: nil,
        userInfo: NotificationDic)

    }

    @IBAction func report_Microsteps(_ sender: NSPopUpButton)
    {
        print("report_Microsteps")
       let stepsindex = sender.indexOfSelectedItem
        micro = sender.selectedTag()
        var NotificationDic = [String:Int]()
        
       
        NotificationDic["micro"] = micro
        
        
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"micro"),
        object: nil,
        userInfo: NotificationDic)

    }

    

   @objc func HWManRichtung(richtung: Int,mousestatus: Int,pfeilstep: Int)
   {
      print("ManRichtung richtung:m\(richtung) mousestatus: \(mousestatus) pfeilstep: \(pfeilstep)")
   }

   
   override func viewDidAppear()
   {
      print ("Hotwire viewDidAppear new")
      // AndereSeiteTaste.target = self
      // AndereSeiteTaste.action = #selector(AVR?.reportAndereSeiteAnfahren(_ :))

     }
    
    // MARK: VIEWDIDLOAD
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
      
       AnschlagLinksIndikator.wantsLayer = true
       AnschlagLinksIndikator?.layer?.backgroundColor = NSColor.green.cgColor
 
       AnschlagUntenIndikator.wantsLayer = true
       AnschlagUntenIndikator?.layer?.backgroundColor = NSColor.green.cgColor

       // CNC_Table
       CNC_Table.dataSource = self
       CNC_Table.delegate = self
       CNC_Table.rowHeight = 13
       CNC_Table.gridStyleMask = .solidVerticalGridLineMask
       CNC_Table.usesAlternatingRowBackgroundColors = true
       
       CNC_busy = 0
       // https://www.swiftbysundell.com/articles/formatting-numbers-in-swift/
       
       //          let cx = formater.string(from: NSNumber(value: Double(zeilendaten[1])))// /INTEGERFAKTOR))
        // von CNC_Mill
       //         let cx = formater.string(from: NSNumber(value: Double(zeilendaten[1])))// /INTEGERFAKTOR))

       /*
        var zeilendic = [String:String]()
          zeilendic["ind"] = String(Int(zeilendaten[0]))
          zeilendic["X"] = cx
          zeilendic["Y"] = cy
          zeilendic["Z"] = cz
          //cx: Optional("3.985") cy: Optional("26.298")
          //      print("zeilendic: \(zeilendic)")
          CNC_DatendicArray.append(zeilendic)

        
        */
       
       KoordinatenFormatter.numberStyle = .decimal
       KoordinatenFormatter.maximumFractionDigits = 2
       KoordinatenFormatter.groupingSeparator = "."
       KoordinatenFormatter.minimumFractionDigits = 2
       
       let objCInstance = AVR

       AndereSeiteTaste.target = objCInstance
       AndereSeiteTaste.action = #selector(AVR?.reportAndereSeiteAnfahren(_ :))
       
       let ProfilnamenArray = AVR?.readProfilLib() as! [String]
       print("ProfilnamenArray: \(ProfilnamenArray[0])")
       Profil1Pop.removeAllItems()
       Profil1Pop.addItem(withTitle: "Profil wählen")
       Profil1Pop.addItems(withTitles: ProfilnamenArray)

       Profil2Pop.removeAllItems()
       Profil2Pop.addItem(withTitle: "Profil wählen")
       Profil2Pop.addItems(withTitles: ProfilnamenArray)
       
       self.setStartRumpfteilDic()

       

       NotificationCenter.default.addObserver(self, selector:#selector(usbstatusAktion(_:)),name:NSNotification.Name(rawValue: "usb_status"),object:nil)

       NotificationCenter.default.addObserver(self, selector:#selector(PfeilAktion(_:)),name:NSNotification.Name(rawValue: "pfeil"),object:nil)

       NotificationCenter.default.addObserver(self, selector:#selector(PfeilFeldAktion(_:)),name:NSNotification.Name(rawValue: "pfeilfeld"),object:nil)

       NotificationCenter.default.addObserver(self, selector:#selector(MausKlickAktion(_:)),name:NSNotification.Name(rawValue: "mausklick"),object:nil)
       NotificationCenter.default.addObserver(self, selector:#selector(MausGraphAktion(_:)),name:NSNotification.Name(rawValue: "mauspunkt"),object:nil)
       NotificationCenter.default.addObserver(self, selector:#selector(MausDragAktion(_:)),name:NSNotification.Name(rawValue: "mausdrag"),object:nil)

       NotificationCenter.default.addObserver(self, selector:#selector(PfeilFeldAktion(_:)),name:NSNotification.Name(rawValue: "pfeilfeld"),object:nil)

       NotificationCenter.default.addObserver(self, selector:#selector(LibProfileingabeAktion(_:)),name:NSNotification.Name(rawValue: "libprofileingabe"),object:nil)
       
       NotificationCenter.default.addObserver(self, selector:#selector(LibElementeingabeAktion(_:)),name:NSNotification.Name(rawValue: "libelementeingabe"),object:nil)

       NotificationCenter.default.addObserver(self, selector:#selector(FormeingabeAktion(_:)),name:NSNotification.Name(rawValue: "formeingabe"),object:nil)

       
       NotificationCenter.default.addObserver(self, selector: #selector(hotwirebeendenAktion), name:NSNotification.Name(rawValue: "beenden"), object: nil)

       // UI-Aktionen von VC setzen
       NotificationCenter.default.addObserver(self, selector: #selector(USBReadAktion), name:NSNotification.Name(rawValue: "usbread"), object: nil)


       NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "newdata"), object: nil)

      // neuesElementSichernAktion
       NotificationCenter.default.addObserver(self, selector: #selector(neuesElementSichernAktion), name:NSNotification.Name(rawValue: "elementsichern"), object: nil)

        
  //     NotificationCenter.default.addObserver(self, selector:#selector(neuesElementSichernAktion(_:)),name:NSNotification.Name(rawValue: "newdata"),object:nil)

      Auslauftiefe.integerValue = 10
      
       hotwireplist =  readHotwire_PList()
      
       outletdaten["cnc_seite1check"] = CNC_Seite1Check.state.rawValue as Int as AnyObject
       outletdaten["cnc_seite2check"] = CNC_Seite2Check.state.rawValue as Int as AnyObject
       
       var stepsindex = CNC_StepsSegControl.selectedSegment
       motorsteps = CNC_StepsSegControl.tag(forSegment:stepsindex)
       outletdaten["motorsteps"] = CNC_StepsSegControl.tag(forSegment:stepsindex)  as AnyObject

       micro = CNC_microPop.selectedItem?.tag ?? 1
       
       if let rumpfteildic = hotwireplist["rumpfteildic"]
       {
           RumpfDaten()
       }
       
       if let einlaufrand = hotwireplist["einlaufrand"]
       {
           Einlaufrand.integerValue = einlaufrand as! Int
       }
       else
       {
           Einlaufrand.integerValue = 15
       }
 
       if let auslaufrand = hotwireplist["auslaufrand"]
       {
           Auslaufrand.integerValue = auslaufrand as! Int
       }
       else
       {
           Auslaufrand.integerValue = 16
       }
       if let blockdicke = hotwireplist["blockdicke"]
       {
           Blockdicke.integerValue = blockdicke as! Int
       }
       else
       {
           Blockdicke.integerValue = 50
       }

       if let blockbreite = hotwireplist["blockbreite"]
       {
           Blockbreite.integerValue = blockbreite as! Int
       }
       else
       {
           Blockbreite.integerValue = 180
       }


       
      if (hotwireplist["koordinatentabelle"] != nil)
      {
         print("PList koordinatentabelle: \(hotwireplist["koordinatentabelle"] )")
      }
       
      if (hotwireplist["pwm"] != nil)
      {
         let plistpwm = hotwireplist["pwm"] as! Int
         print("plistpwm: \(plistpwm)")
         DC_PWM.integerValue = hotwireplist["pwm"] as! Int
         DC_Slider.integerValue = hotwireplist["pwm"] as! Int
         DC_Stepper.integerValue = hotwireplist["pwm"] as! Int
         pwm = plistpwm
      }
      else
      {
         DC_PWM.integerValue = 10
         DC_Slider.integerValue = 10
         DC_Stepper.integerValue = 10
         pwm  = 10

      }
      if (hotwireplist["speed"] != nil)
      {
         let plistspeed = hotwireplist["speed"]  as! Int
         print("speed: \(plistspeed )")
         SpeedFeld.integerValue = plistspeed
         SpeedStepper.integerValue = plistspeed
      }
      else
      {
         SpeedFeld.integerValue = 7
         SpeedStepper.integerValue = 7
      }
 
      if (hotwireplist["abbrand"] != nil)
      {
         let plistabbranda = hotwireplist["abbrand"]  as! Double
         print("speed: \(plistabbranda )")
         AbbrandFeld.doubleValue = plistabbranda
      }
      else
      {
         AbbrandFeld.doubleValue = 1.7
      }
       
       if (hotwireplist["minimaldistanz"] != nil)
       {
          let minimaldistanz = hotwireplist["minimaldistanz"]  as! Double
          print("minimaldistanz: \(minimaldistanz )")
          MinimaldistanzFeld.doubleValue = minimaldistanz
           
       }
       else
       {
           MinimaldistanzFeld.doubleValue = 1.9
       }

      if (hotwireplist["profilnamea"] != nil)
      {
         let plistprofilnamea = hotwireplist["profilnamea"]  as! String
         print("plistprofilnamea: \(plistprofilnamea )")
         ProfilNameFeldA.stringValue = plistprofilnamea
      }
      else
      {
        
         ProfilNameFeldA.stringValue = "Clark_Y"
      }

      if (hotwireplist["profilnameb"] != nil)
      {
         let plistprofilnameb = hotwireplist["profilnameb"]  as! String
         print("plistprofilnamea: \(plistprofilnameb )")
         ProfilNameFeldB.stringValue = plistprofilnameb
      }
      else
      {
         ProfilNameFeldB.stringValue = "Clark_Y"
      }

      if (hotwireplist["profiltiefea"] != nil)
      {
         let plistwert = hotwireplist["profiltiefea"]  as! Int
         ProfilTiefeFeldA.integerValue = plistwert
      }
      else
      {
         ProfilTiefeFeldA.integerValue = 101
      }

      if (hotwireplist["profiltiefeb"] != nil)
      {
         let plistwert = hotwireplist["profiltiefeb"]  as! Int
         ProfilTiefeFeldB.integerValue = plistwert
      }
      else
      {
         ProfilTiefeFeldB.integerValue = 141
      }

      if (hotwireplist["profilboffsetx"] != nil)
      {
         let plistwert = hotwireplist["profilboffsetx"]  as! Int
         ProfilBOffsetXFeld.integerValue = plistwert
      }
      else
      {
         ProfilBOffsetXFeld.integerValue = 1
      }

      if (hotwireplist["profilboffsety"] != nil)
      {
         let plistwert = hotwireplist["profilboffsety"]  as! Int
         ProfilBOffsetYFeld.integerValue = plistwert
      }
      else
      {
         ProfilBOffsetYFeld.integerValue = 1
      }

      // Wrench Profil B
      if (hotwireplist["profilwrench"] != nil)
      {
         let plistwert = hotwireplist["profilwrench"]  as! Int
         ProfilWrenchFeld.integerValue = plistwert
      }
      else
      {
         ProfilWrenchFeld.integerValue = 1
      }
      
       if (hotwireplist["einlaufrand"] != nil)
       {
          let plistwert = hotwireplist["einlaufrand"]  as! Int
          Einlaufrand.integerValue = plistwert
       }
       else
       {
           Einlaufrand.integerValue = 11
       }

       if (hotwireplist["auslaufrand"] != nil)
       {
          let plistwert = hotwireplist["auslaufrand"]  as! Int
          Auslaufrand.integerValue = plistwert
       }
       else
       {
           Auslaufrand.integerValue = 11
       }

      if (hotwireplist["einlauflaenge"] != nil)
      {
         let plistwert = hotwireplist["einlauflaenge"]  as! Int
         Einlauflaenge.integerValue = plistwert
      }
      else
      {
         Einlauflaenge.integerValue = 1
      }

      if (hotwireplist["einlauftiefe"] != nil)
      {
         let plistwert = hotwireplist["einlauftiefe"]  as! Int
         Einlauftiefe.integerValue = plistwert
      }
      else
      {
         Einlauftiefe.integerValue = 1
      }

      if (hotwireplist["auslauflaenge"] != nil)
      {
         let plistwert = hotwireplist["auslauflaenge"]  as! Int
         Auslauflaenge.integerValue = plistwert
      }
      else
      {
         Auslauflaenge.integerValue = 1
      }

      if (hotwireplist["auslauftiefe"] != nil)
      {
         let plistwert = hotwireplist["auslauflaenge"]  as! Int
         Auslauftiefe.integerValue = plistwert
      }
      else
      {
         Auslauftiefe.integerValue = 1
      }

      if (hotwireplist["basisabstand"] != nil)
      {
         let plistwert = hotwireplist["basisabstand"]  as! Int
         Basisabstand.integerValue = plistwert
      }
      else
      {
         Basisabstand.integerValue = 1
      }

      if (hotwireplist["portalabstand"] != nil)
      {
         let plistwert = hotwireplist["portalabstand"]  as! Int
         Portalabstand.integerValue = plistwert
      }
      else
      {
         PositionFeld.integerValue = 1
      }
     
      if (hotwireplist["spannweite"] != nil)
      {
         let plistwert = hotwireplist["spannweite"]  as! Int
         Spannweite.integerValue = plistwert
      }
      else
      {
         Spannweite.integerValue = 500
      }

      if (hotwireplist["auslauf"] != nil)
      {
         let plistwert = hotwireplist["auslauf"]  as! Int
         AuslaufFeld.integerValue = plistwert
      }
      else
      {
         AuslaufFeld.integerValue = 1
      }
       if let rumpfdatenarray = hotwireplist["rumpfdatenarray"]
       {
           print("rumpfdatenarray da")
           RumpfdatenArray = hotwireplist["rumpfdatenarray"] as! [[String : Double]]
           if RumpfdatenArray.count > 0
           {
               AVR?.setRumpfteilDic(RumpfdatenArray[0], forPart: 0)
           }
           let zeile = RumpfdatenArray[1] as [String:Double]
           
           let zeilenkeys = zeile.keys
           print("zeilenkeys: \(zeilenkeys)")
           var i=0
           for k in zeilenkeys
            {
               //let tempzey = zeilenkeys[i]
               let data = zeile[k]
              print("i: \(i) key: \(k) data: \(data)")
               i += 1
           }
           
           
           
       }
       else
           
       {
           print("rumpfdatenarray nicht da")
       }

       outletdaten["speed"] = SpeedFeld.integerValue as AnyObject
       //outletdaten["steps"] = steps_Feld.integerValue as AnyObject
       var NotificationDic = [String:Int]()
       
       NotificationDic["micro"] = micro
       NotificationDic["motorsteps"] = motorsteps
       
       
       let nc = NotificationCenter.default
       nc.post(name:Notification.Name(rawValue:"micro"),
       object: nil,
       userInfo: NotificationDic)

       nc.post(name:Notification.Name(rawValue:"motorsteps"),
       object: nil,
       userInfo: NotificationDic)
       
       
       var settingsNotificationDic = [String:AnyObject]()
       
       settingsNotificationDic["schnittsettings"] = hotwireplist as AnyObject
       
       nc.post(name:Notification.Name(rawValue:"settings"),
       object: nil,
        userInfo: settingsNotificationDic)


       
       
      
   }//viewDidLoad
    
   
    // TODO: *** *** *** *** *** *** reportHome
   // @objc IBAction reportHome:(id)sender
    
    @IBAction func reportHome(_ sender: NSButton)
    {
        
        
        print("reportHome")
        //AVR!.reportHome(nil)
        AVR!.goHome()
   

    }
    
    @IBAction func reportDC_Stepper(_ sender: NSStepper)
    {
        print("reportDC_Stepper wert: \(sender.integerValue)")
        DC_PWM.integerValue = sender.integerValue
        DC_Slider.integerValue = sender.integerValue
        outletdaten["pwm"] = sender.integerValue as AnyObject
        if CNC_busy > 0
        {
            if DC_Taste.state == NSControl.StateValue.on
            {
                let dataDic = ["pwm":sender.integerValue]
                self.DCAktion(datadic:dataDic)
            }
            else
            {
                let dataDic = ["pwm":0]
                self.DCAktion(datadic:dataDic)
            }
        }
   }
    
    @IBAction func reportSpeed_Stepper(_ sender: NSStepper)
    {
        print("reportSpeed_Stepper wert: \(sender.integerValue)")
        SpeedFeld.integerValue = sender.integerValue
        
        outletdaten["speed"] = sender.integerValue as AnyObject
        
    } // reportSpeed_Stepper
    
    @IBAction func reportDC_Taste(_ sender: NSButton)
    {
        
       print("reportDC_Taste state");
      
        if sender.state ==  NSControl.StateValue.on
       {
            let dataDic = ["pwm":DC_PWM.integerValue]
            self.DCAktion(datadic:dataDic)

       }
       else
       {
           let dataDic = ["pwm":0]
           self.DCAktion(datadic:dataDic)
       }

    }
    
    @IBAction func reportNeueFigur(_ sender: NSButton)
    {
        print("reportNeueFigur")
        if CNC_Eingabe == nil
        {
            
        }
        CNC_Eingabe.window?.title = "Einstellungen"
        CNC_Eingabe.window?.makeKeyAndOrderFront(nil)
        CNC_Eingabe.window?.isReleasedWhenClosed = true
        let rowindexset = IndexSet(integer:CNC_Table.numberOfRows-1)
        
        CNC_Table.selectRowIndexes(rowindexset, byExtendingSelection: false)
        CNC_Table.scrollRowToVisible(CNC_Table.numberOfRows-1)
        
        var datenDic = [String:Any]()
        datenDic["startx"] = WertAXFeld.doubleValue
        datenDic["starty"] = WertAYFeld.doubleValue
        datenDic["einlaufrand"] = Einlaufrand.integerValue
        datenDic["auslaufrand"] = Auslaufrand.integerValue
        
        datenDic["einlauflaenge"] = Einlauflaenge.integerValue
        datenDic["einlauftiefe"] = Einlauftiefe.integerValue
        datenDic["auslauflaenge"] = Auslauflaenge.integerValue
        datenDic["auslauftiefe"] = Auslauftiefe.integerValue
        
        datenDic["abbrand"] = AbbrandFeld.doubleValue
        datenDic["mitoberseite"] = 1
        datenDic["mitunterseite"] = 1
        datenDic["profilwrench"] = ProfilWrenchFeld.doubleValue
        
        if Profil1Pop.indexOfSelectedItem > 0
        {
            let profil1name = Profil1Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            print("profil1name: \(profil1name)")
            datenDic["profil1"] = profil1name
        }
        else
        {
            datenDic["profil1"] = ProfilNameFeldA.stringValue
        }

        if Profil2Pop.indexOfSelectedItem > 0
        {
            let profil2name = Profil2Pop.titleOfSelectedItem?.components(separatedBy: ".")[0]
            print("profil2name: \(profil2name)")
            datenDic["profil2"] = profil2name
        }
        else
        {
            datenDic["profil2"] = ProfilNameFeldB.stringValue
        }
        CNC_Eingabe.setDaten(datenDic)
        
        NSApp.runModal(for: (CNC_Eingabe.window)!)
        
        
       // NSModalSession session = [NSApp beginModalSessionForWindow:[CNC_Eingabe window]];
    }
    
    
    @IBAction func reportLinkeRechteSeite(_ sender: NSButton)
    {
        print("reportLinkeRechteSeite")
        if KoordinatenTabelle.count == 0
        {
            return
        }
    //stackoverflow.com/questions/55560035/how-to-retrieve-value-from-all-keys-with-the-same-name-from-an-array-of-dictiona
    let valuesx = KoordinatenTabelle.compactMap{$0["ax"]} as [Double]
    //print("reportLinkeRechteSeite valuesx: \(valuesx)")
    let minX = valuesx.min()
    let maxX = valuesx.max()
    print("reportLinkeRechteSeite min: \(minX) max: \(maxX)")

        let itemlabel = TaskTab.selectedTabViewItem?.label
        if ((itemlabel?.isEqual("Profil")) != nil)
        {
            print("Profil")
            for i in 0..<KoordinatenTabelle.count
            {
                let wertaX = KoordinatenTabelle[i]["ax"]
                KoordinatenTabelle[i]["ax"] = maxX! - (wertaX! - minX!)
                if let wertabraX = KoordinatenTabelle[i]["abrax"]
                {
                    KoordinatenTabelle[i]["abrax"] =  maxX! - (wertabraX - minX!)
                }
                
                let wertbX = KoordinatenTabelle[i]["bx"]
                KoordinatenTabelle[i]["bx"] = maxX! - (wertbX! - minX!)
                if let wertabrbX = KoordinatenTabelle[i]["abrbx"]
                {
                    KoordinatenTabelle[i]["abrbx"] =  maxX! - (wertabrbX - minX!)
                }

                
                
            }
            CNC_Table.reloadData()
            ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
            ProfilFeld.needsDisplay = true
        }
        else if (((itemlabel?.isEqual("Rumpf"))) != nil)
        {
            print("Rumpf")
        }
        //
    }

    @objc func DCAktion(datadic:[String:Any])
    {
        usb_schnittdatenarray.removeAll()
        //print("DCAktion: \(notification)")
        //let info = notification.userInfo
        guard let pwm = datadic["pwm"] else
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
    @objc func readHotwire_PList() -> [String:AnyObject]
    {
        var dateiname = ""
        var dateisuffix = ""
        var urlstring:String = ""
        var hotwireplist:[String] = []
        var USBPfad = NSHomeDirectory() + "/Documents" + "/CNCDaten"
        var PListName:String = "/CNC.plist"
        USBPfad += PListName
        print("readHotwire_PList: \(USBPfad)")
        var USB_URL = NSURL.fileURL(withPath:USBPfad)
        
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:] //Our data

      if FileManager.default.fileExists(atPath: USBPfad)
      {
         print("PList da")
      }
      // https://stackoverflow.com/questions/24045570/how-do-i-get-a-plist-as-a-dictionary-in-swift
      if let plistXML = FileManager.default.contents(atPath: USBPfad)
      {
         do
         {//convert the data to a dictionary and handle errors.
              plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]

          } catch {
              print("Error reading plist: \(error), format: \(propertyListFormat)")
          }
         
         //print("xml: \(plistXML) anz: \(plistXML.count)")
         for zeile in plistData
         {
     //       print("zeile: \(zeile)")
         }
     //    print("0: \(plistData["0"])")
       }
      
      
      // von CNC_Mill
      
    
      
      
      /*
      do
      {
         guard let fileURL = openFile() else { return  }
         
         urlstring = fileURL.absoluteString
         dateiname = urlstring.components(separatedBy: "/").last ?? "-"
         print("report_readSVG fileURL: \(fileURL)")
         
         dateiname = dateiname.components(separatedBy: ".").first ?? "-"
         
         //USBPfad.stringValue = dateiname

      }
      catch
      {
         print("readCNC_PList  error: \(error)")
         
         /* error handling here */
         return
      }
*/
      return plistData
   }
    
    
    // MARK: Rumpf
    @objc func setStartRumpfteilDic()
    {
        Portalabstand.intValue = 660    //
        RandFeld.intValue = 10//
        EinlaufFeld.intValue = 10//
        BreiteAFeld.intValue =  38//
        HoeheAFeld.intValue = 18//
        RadiusAFeld.intValue = 10//
        BreiteBFeld.intValue = 18//
        HoeheBFeld.intValue = 9//
        RadiusBFeld.intValue = 5//
        EinstichtiefeFeld.intValue = 15//
        RumpfabstandFeld.intValue = 50//
        ElementlaengeFeld.intValue = 520//
        
        RumpfBlockbreite.intValue = 100//
        RumpfBlockhoehe.intValue = 50//
        AuslaufFeld.intValue = 10//
        
        RumpfOffsetXFeld.doubleValue = 0.0
        RumpfOffsetYFeld.doubleValue = 0.0
        RumpfportalabstandFeld.doubleValue = 660
        
        CNC_microPop.selectItem(withTag: 1)
    }

    @objc func setRumpfteilDic(rumpfteildic:([String:Double]) , rumpfteil:(Int))
    {
     }

   

   
   @objc func MauspunktAktion(_ notification:Notification)
   {
       let info = notification.userInfo
      print("MauspunktAktion : info: \(notification.userInfo) \(info)")

   }
    
   @objc func usbstatusAktion(_ notification:Notification)
   {
       //        userinformation = ["message":"usbstart", "usbstatus": usbstatus, "boardindex":boardindex] as [String : Any]
       
       let info = notification.userInfo
       print(" usbstatusAktion: info: \(notification.userInfo) \(info)")
      guard let status = info?["usbstatus"] as? Int else
      {
         print(" usbstatusAktion: kein status\n")
         return
         
      }//
       guard let rawboardindex = info?["boardindex"] as? Int else
       {
          print("Basis rawboardindex: kein rawboardindex\n")
          return
          
       }//

      print("Hotwire usbstatusAktion:\t \(status)")
      usbstatus = Int(status)
      boardindex = rawboardindex
      
       
   }
    
    @IBAction func reportSeiteVertauschen(_ sender:NSButton)
    {
        print("reportSeiteVertauschen")
        if KoordinatenTabelle.count==0
       {
          return
       }
       var i = 0
        for i in 0..<KoordinatenTabelle.count
        {
            var neuerZeilenDic = KoordinatenTabelle[i] //[String:Double]()
            
            var tempax = neuerZeilenDic["ax"]
            var tempay = neuerZeilenDic["ay"]
            var tempbx = neuerZeilenDic["bx"]
            var tempby = neuerZeilenDic["by"]
            
            // keys vertauschen
            neuerZeilenDic["ax"] = tempbx
            neuerZeilenDic["ay"] = tempby
            neuerZeilenDic["bx"] = tempax
            neuerZeilenDic["by"] = tempay
            
            var abrax:Double = 0
            var abray:Double = 0
            var abrbx:Double = 0
            var abrby:Double = 0
            
            
            if let tempabrax = neuerZeilenDic["abrax"]
            {
                abrax = tempabrax
            }
            if let tempabray = neuerZeilenDic["abray"]
            {
                abray =  tempabray
            }
            if let tempabrbx = neuerZeilenDic["abrbx"]
            {
                abrbx = tempabrbx
            }
            if let tempabrby = neuerZeilenDic["abrby"]
            {
                abrby = tempabrby
            }
            // key vertauschen
            
            if abrax > 0
            {
                neuerZeilenDic["abrbx"] = abrax
            }
            if abray > 0
            {
                neuerZeilenDic["abrby"] = abray
            }

            if abrbx > 0
            {
                neuerZeilenDic["abrax"] = abrbx
            }
            if abrby > 0
            {
                neuerZeilenDic["abray"] = abrby
            }

            KoordinatenTabelle[i] = neuerZeilenDic
        }
        ProfilFeld.setDatenArray(derDatenArray: KoordinatenTabelle as NSArray)
        ProfilFeld.needsDisplay = true
        CNC_Table.reloadData()

    }
    
    @objc func saveHotwire_PList()
    {
        var USBPfad = NSHomeDirectory() + "/Documents" + "/CNCDaten"
        var PListName:String = "/CNC.plist"
        USBPfad += PListName
        print("readHotwire_PList: \(USBPfad)")
        var USB_URL = NSURL.fileURL(withPath:USBPfad)
        
        hotwireplist["einlaufrand"] = Einlaufrand.integerValue as AnyObject
        hotwireplist["auslaufrand"] = Auslaufrand.integerValue as AnyObject
        hotwireplist["blockdicke"] = Blockdicke.integerValue as AnyObject
        hotwireplist["blockbreite"] = Blockbreite.integerValue as AnyObject
        hotwireplist["pwm"] = DC_PWM.integerValue as AnyObject
        hotwireplist["redpwm"] = red_pwmFeld.doubleValue as AnyObject

        hotwireplist["speed"] = SpeedFeld.integerValue as AnyObject
        
 //       hotwireplist["steps"] = steps_Feld.integerValue as AnyObject

        hotwireplist["abbrand"] = AbbrandFeld.doubleValue as AnyObject
        hotwireplist["minimaldistanz"] = MinimaldistanzFeld.doubleValue as AnyObject
        hotwireplist["profilnamea"] =  ProfilNameFeldA.stringValue as AnyObject
        hotwireplist["profilnameb"] =  ProfilNameFeldB.stringValue as AnyObject
        hotwireplist["profiltiefea"] = ProfilTiefeFeldA.integerValue as AnyObject
        hotwireplist["profiltiefeb"] = ProfilTiefeFeldB.integerValue as AnyObject
        hotwireplist["profilboffsetx"] = ProfilBOffsetXFeld.integerValue as AnyObject
        hotwireplist["profilboffsety"] = ProfilBOffsetYFeld.integerValue as AnyObject
        
        hotwireplist["einlauflaenge"] = Einlauflaenge.integerValue as AnyObject
        hotwireplist["einlauftiefe"] = Einlauftiefe.integerValue as AnyObject
        hotwireplist["auslauflaenge"] = Auslauflaenge.integerValue as AnyObject
        hotwireplist["ausauftiefe"] = Auslauftiefe.integerValue as AnyObject
        
        
        hotwireplist["basisabstand"] = Basisabstand.integerValue as AnyObject
        hotwireplist["portalabstand"] = Portalabstand.integerValue as AnyObject
        
        hotwireplist["spannweite"] = Spannweite.integerValue as AnyObject
        
        hotwireplist["profilwrench"] = ProfilWrenchFeld.integerValue as AnyObject
        hotwireplist["spannweite"] = Spannweite.integerValue as AnyObject
        
        // Profil
        if Profil1Pop.indexOfSelectedItem > 0
        {
            hotwireplist["profil1popindex"] = Profil1Pop.indexOfSelectedItem as AnyObject
        }
        else
        {
            hotwireplist["profil1popindex"] = 1 as AnyObject
        }

        if Profil2Pop.indexOfSelectedItem > 0
        {
            hotwireplist["profil2popindex"] = Profil2Pop.indexOfSelectedItem as AnyObject
        }
        else
        {
            hotwireplist["profil2popindex"] = 1 as AnyObject
        }
        
        let rumpfteildic = self.rumpfteilDic()
        hotwireplist["rumpfteildic"] = self.rumpfteilDic() as AnyObject


        
    }

    
    @objc  func hotwirebeendenAktion(_ notification:Notification) -> Bool
     {
        
        print("Hotwire beendenAktion")
         
         self.saveHotwire_PList()
         var USBPfad = NSHomeDirectory() + "/Documents" + "/CNCDaten"
         let PListName:String = "/CNC.plist"
         USBPfad += PListName
         print("saveHotwire_PList: \(USBPfad)")
         var USB_URL = NSURL.fileURL(withPath:USBPfad)
         
         do {
             let data = try PropertyListSerialization.data(fromPropertyList: hotwireplist, format: .xml, options: 0)
             try data.write(to: USB_URL)
             return true
         }  catch {
             print(error)
             return false
         }
         
         
         
         
         let cc = NSMutableDictionary(dictionary:hotwireplist)
         let success = cc.write(to: USB_URL, atomically: true)
              print("write: ", success)

           NSApplication.shared.terminate(self)
        
        
     }


  
    @objc func PfeilFeldAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        print(" PfeilFeldAktion: info: \(notification.userInfo) \(info)")
        if (info?["richtung"] != nil)
        {
            quelle = info?["richtung"] as! Int
            
            if info?["push"] != nil
            {
                mausistdown = info?["push"] as!Int
            } // if push
        }// if richtung
        else
        {
            NSSound.beep()
            quelle = 0
            mausistdown = 0
            return
        }
        if mausistdown > 0
        {
            switch quelle
            {
            case MANDOWN:
                print("PfeilFeldAktion MANDOWN")
            case MANUP:
                print("PfeilFeldAktion MANUP")
                AnschlagUntenIndikator.layer?.backgroundColor = NSColor.green.cgColor
            case MANLEFT:
                print("PfeilFeldAktion MANLEFT")
            case MANRIGHT:
                print("PfeilFeldAktion MANRIGHT")
                AnschlagLinksIndikator.layer?.backgroundColor = NSColor.green.cgColor
                
                
            default:
                break
            }// switch quelle
            //AVR?.homeSenkrechtSchicken()
            AVR?.manFeldRichtung(Int32(quelle), mousestatus:Int32(mausistdown), pfeilstep:700)
        } // mausistdown > 0
        else // Button released
        {
            print("swift PfeilFeldAktion Button released quelle: \(quelle)")
            AVR?.manFeldRichtung(Int32(quelle), mousestatus:Int32(mausistdown), pfeilstep:80)
        }
        
        
    }
    
    @objc func PfeilAktion(_ notification:Notification)
    {
        let info = notification.userInfo
        print(" PfeilAktion: info: \(notification.userInfo) \(info)")
        if  let mauscounter = info?["mousedownconter"]
        {
            let mc = mauscounter as! Int
            print(" PfeilAktion: mauscounter: \(mc)")
        }
        else
        {
            
        }
        
        if (info?["richtung"] != nil)
        {
            quelle = info?["richtung"] as! Int
            
            if info?["push"] != nil
            {
                mausistdown = info?["push"] as!Int
            } // if push
        }// if richtung
        else
        {
            NSSound.beep()
            quelle = 0
            mausistdown = 0
            return
        }
        
        if mausistdown > 0
        {
            switch quelle
            {
            case MANDOWN:
                print("PfeilAktion MANDOWN")
            case MANUP:
                print("PfeilAktion MANUP")
                AnschlagUntenIndikator.layer?.backgroundColor = NSColor.green.cgColor
            case MANLEFT:
                print("PfeilAktion MANLEFT")
            case MANRIGHT:
                print("PfeilAktion MANRIGHT")
                AnschlagLinksIndikator.layer?.backgroundColor = NSColor.green.cgColor
                
                
            default:
                break
            }// switch quelle
            AVR?.manRichtung(Int32(quelle), mousestatus:Int32(mausistdown), pfeilstep:700)
            
        } // mausistdown > 0
        else // Button released
        {
            print("swift Pfeilaktion Button released quelle: \(quelle)")
            AVR?.manRichtung(Int32(quelle), mousestatus:Int32(mausistdown), pfeilstep:80)
        }
        
        
    }// Pfeilaktion


    func numberOfRows(in tableView: NSTableView) -> Int {
        
       return (KoordinatenTabelle.count)
       
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
       let zeile = KoordinatenTabelle[row]
       //print("p: \(zeile)")
        let key = NSUserInterfaceItemIdentifier(tableColumn!.identifier.rawValue)
       let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(tableColumn!.identifier.rawValue), owner: self) as? NSTableCellView
        if key.rawValue == "index" || key.rawValue == "pwm"
        {
            cell?.textField?.intValue = Int32(zeile[key.rawValue]!)
       }
        else
        {
            let keystring = KoordinatenFormatter.string(from:zeile[key.rawValue]! as NSNumber)
            //cell?.textField?.doubleValue = zeile[key.rawValue]! // ohne formatter
            cell?.textField?.stringValue = keystring!
        }
       
       return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
        let tableView = notification.object as! NSTableView
        self.setDatenVonZeile(zeile: tableView.selectedRow)
        
    }

} // end Hotwire

/*
//MARK: dataTable
extension rHotwireViewController
{
   func numberOfRows(in tableView: NSTableView) -> Int {
      return (KoordinatenTabelle.count)
      
   }
   
   func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
      let zeile = KoordinatenTabelle[row]
      //print("p: \(person)")
       let key = tableColumn!.identifier.rawValue
      let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
       cell?.textField?.doubleValue = zeile[key]!
      
      return cell
   }
}
*/
