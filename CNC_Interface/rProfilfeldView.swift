//
//  rDrehknopf.swift
//  Robot_Interface
//
//  Created by Ruedi Heimlicher on 18.08.2019.
//  Copyright © 2019 Ruedi Heimlicher. All rights reserved.
//
import Cocoa
import Foundation




class rProfilfeldView: NSView
{
    // von Profilgrah
    var  DatenArray :  NSArray  = NSArray()
    var  RahmenArray :  NSArray  = NSArray()
    var  StartPunktA :  NSPoint  = NSZeroPoint
    var  EndPunktA :  NSPoint  = NSZeroPoint
    var  StartPunktB :  NSPoint  = NSZeroPoint
    var  EndPunktB :  NSPoint  = NSZeroPoint
    var  oldMauspunkt :  NSPoint  = NSZeroPoint
    var  scale  :  Double  = 4
    var  mausistdown :  Int  = 0
    var  Klickpunkt :  Int  = -1
    var  Klickseite :  Int  = -1
    var  klickrange :  NSRange  = NSRange()
    var  KlicksetA :  NSMutableIndexSet  = NSMutableIndexSet()
    var  startklickpunkt :  Int  = -1
    var  stepperposition :  Int  = -1
    var  anzahlmaschen :  Int  = 0
    var  graphstatus :  Int  = 0
    var  screen  :  Int  = 0
    var  GraphOffset :  Int  = 0
    
    
 
    func setDatenArray(derDatenArray:NSArray) 
    {
        DatenArray=derDatenArray
    }
    func setRahmenArray(derRahmenArray:NSArray)
    {
        RahmenArray=derRahmenArray
    }
    func setScale(derScalefaktor : CGFloat ) 
    {
        scale = derScalefaktor
    }
    
    func setKlickpunkt(derPunkt:Int)
    {
        print("setKlickpunkt punkt: \(derPunkt)")
        Klickpunkt = derPunkt
        startklickpunkt = derPunkt
    }
    
    
    func setStepperposition(pos : Int )
    {
       stepperposition = pos
       if (DatenArray.count > 0) && (pos > DatenArray.count)
       {
           var line = DatenArray[Klickpunkt] as! [String:Any]
          var ax = line["ax"] as! Double
          var ay = line["ay"] as! Double

          var PunktA:NSPoint = NSMakePoint(ax  * scale, ay * scale)
         // var PunktB:NSPoint = NSMakePoint(x: ax  * scale, y: ay * scale)
          var tempMarkARect:NSRect = NSMakeRect(PunktA.x-4.1, PunktA.y-4.1, 8.2, 8.2)
          self.setNeedsDisplay(tempMarkARect)
          
       }// if DatenArray.count > 0
     }// setStepperposition
   
   func clickedPunktvonMaus(derPunkt:NSPoint) -> Int
   {
      var delta:Double  = 4
      var KlickFeld = NSMakeRect(derPunkt.x-delta/2, derPunkt.y-delta/2, delta, delta);
       print("clickedPunktvonMaus KlickFeld: \(KlickFeld)")
      for i in 0..<DatenArray.count
      {
         var line = DatenArray[i] as! [String:Any]
         var ax = line["ax"] as! Double
         var ay = line["ay"] as! Double
         
         var bx = line["bx"] as! Double
         var by = line["by"] as! Double
         
         var tempPunktA:NSPoint = NSMakePoint(ax,ay)
         var tempPunktB:NSPoint = NSMakePoint(bx, by)
         
        print("clickedPunktvonMaus tempPunktA: \(tempPunktA) tempPunktB: \(tempPunktB)")
         if self.mouse(tempPunktA, in: KlickFeld)
         {
             print("clickedPunktvonMaus  Seite A")
            return i
         }
         if self.mouse(tempPunktB, in: KlickFeld)
         {
            return i+0xF000
             print("clickedPunktvonMaus Seite B")
         }
      }// for i
      
      
      return -1
   }
   
   func clickedAbschnittvonMaus(derPunkt:NSPoint) -> Int
   {
      print("clickedAbschnittvonMaus Punkt: x: \(derPunkt.x) y: \(derPunkt.y)")
      var index:Int = -1
      var delta:Double = 4
      
      for i in 0..<DatenArray.count - 1
      {
         var line = DatenArray[i] as! [String:Any]
         var ax = line["ax"] as! Double
         var ay = line["ay"] as! Double
         
         var tempPunktA:NSPoint = NSMakePoint(ax  ,ay)
         var tempPunktB:NSPoint = NSMakePoint(ax , ay)
         
         let dist = sqrt(pow((tempPunktA.y-tempPunktB.y),2) + pow((tempPunktA.x-tempPunktB.x),2))
         
         if dist == 0
         {
            continue
         }
         
         var sinphi:Double = (tempPunktB.y-tempPunktA.y)/dist
         var cosphi:Double = (tempPunktB.x-tempPunktA.x)/dist;
         var deltax:Double = delta*sinphi;
         var deltay:Double = delta*cosphi;
         
         var clickPfad:NSBezierPath = NSBezierPath()
         clickPfad.move(to: NSMakePoint(tempPunktA.x+deltax,tempPunktA.y-deltay))
         clickPfad.line(to: NSMakePoint(tempPunktB.x+deltax,tempPunktB.y-deltay))
         clickPfad.line(to: NSMakePoint(tempPunktB.x-deltax,tempPunktB.y+deltay))
         clickPfad.line(to: NSMakePoint(tempPunktA.x-deltax,tempPunktA.y+deltay))
         
         var hit = clickPfad.contains(derPunkt)
         
         if hit == true
         {
            print("hit in Punkt \(tempPunktA.x) \(tempPunktA.y)")
            print("clickPfad: \(clickPfad)")
            index = i
         }// if hit
         
         

      }// for i
      
      return index
   }// clickedAbschnittvonMaus
   
    func setAnzahlMaschen (anzahl : Int )
    {
        anzahlmaschen = anzahl
    }
    func getDatenArray() -> NSArray
    {
        return DatenArray
    }
    func acceptsFirstResponder() -> ObjCBool {return true}
    func canBecomeKeyView ()->ObjCBool {return true}
    
    func keyDown (derEvent : NSEvent ) 
   {
      let nc = NotificationCenter.default
      var arrowstep:Int32 = 100
      var NotificationDic:[String:Any] = [:]
     // NotificationDic["ax"] = Int(lokalpunkt.x)
    //  NotificationDic["ay"] = Int(lokalpunkt.y)
      NotificationDic["pfeiltaste"] = Int(derEvent.keyCode)
      NotificationDic["klickpunkt"] = Klickpunkt
      NotificationDic["klickseite"] = Klickseite
      NotificationDic["graphoffset"] = GraphOffset
      
      switch (derEvent.keyCode)
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

      nc.post(name: NSNotification.Name(rawValue: "pfeilfeldtaste") , object: nil, userInfo: NotificationDic)

   }
    
     
    func mausistDown() -> Int
   {
      return mausistdown
   }
    
     func setKlickrange (derRange : NSRange )
    {
        klickrange = derRange
    }
    func setGraphOffset (offset : Int )
    {
        GraphOffset = offset
    }
    func setgraphstatus (status : Int ) 
    {
        graphstatus = status
    }
    func GitterZeichnenMitMaschen (anzahl : Int ) {}
    
    func GitterZeichnen ()
    {
        
        var Gittermass:Double  = scale*10;
        
        var breite:CGFloat = bounds.size.width;
        let w:CGFloat = bounds.size.width
        let h:CGFloat = bounds.size.height
        //print("w: \(w) h: \(h) gittermass: \(Gittermass)")
        
        if ((NSGraphicsContext.current?.isDrawingToScreen) != nil)
        {
            //print("ProfilGraph drawRect screen")
            screen = 1
            anzahlmaschen = Int(breite/Gittermass)
            //print("anzahlmaschen: \(anzahlmaschen)")
        }
        else
        {
            anzahlmaschen = 28
            breite = Double(anzahlmaschen) * Gittermass;
            screen = 0
        }
        var  HorizontaleLinie:NSBezierPath = NSBezierPath()
        var  i:Int = 0
        
        // waagrechte Linien
        let anzvertikal:Int = Int((h/Gittermass))
        //print("anzvertikal: \(anzvertikal)")
        for i in 0...anzvertikal
        {
            var A:NSPoint = NSMakePoint(0, 1+Gittermass*Double(i))
            var B:NSPoint = NSMakePoint(w, 1+Gittermass*Double(i))
            HorizontaleLinie.move(to:A)
            HorizontaleLinie.line(to:B)
            
        }
        HorizontaleLinie.lineWidth = 0.3
        NSColor.darkGray.set()
        HorizontaleLinie.stroke()
        
        // senkrechte Linien
        
        var  VertikaleLinie:NSBezierPath = NSBezierPath()
        i = 0
        
 
        //print("anzvertikal: \(anzvertikal)")
        for i in 0...anzahlmaschen
        {
            var A:NSPoint = NSMakePoint(1.1+Gittermass*Double(i),0)
            var B:NSPoint = NSMakePoint(1.1+Gittermass*Double(i),self.frame.size.height)
            VertikaleLinie.move(to:A)
            VertikaleLinie.line(to:B)
            
        }
        VertikaleLinie.lineWidth = 0.3
        NSColor.darkGray.set()
        VertikaleLinie.stroke()
        
 
        
    }

    // end Profilgraph
    
   var weg: NSBezierPath = NSBezierPath()
   var kreuz: NSBezierPath = NSBezierPath()
   var achsen: NSBezierPath = NSBezierPath()
   var mittelpunkt:NSPoint = NSZeroPoint
   var winkel:CGFloat = 0
   var hyp:CGFloat = 0
   var hgfarbe:NSColor = NSColor()
    
    
   required init?(coder  aDecoder : NSCoder)
   {
      super.init(coder: aDecoder)
      //Swift.print("JoystickView init")
      //   NSColor.blue.set() // choose color
      // let achsen = NSBezierPath() // container for line(s)
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height
      let mittex:CGFloat = bounds.size.width / 2
      let mittey:CGFloat = bounds.size.height / 2
      mittelpunkt = NSMakePoint(mittex, mittey)
      hyp = bounds.size.height / 2
      //Swift.print("JoystickView init mittex: \(mittex) mittey: \(mittey) hyp: \(hyp)")
      achsen.move(to: NSMakePoint(0, mittey)) // start point
      achsen.line(to: NSMakePoint(w, mittey)) // destination
      achsen.move(to: NSMakePoint(mittex, 0)) // start point
      achsen.line(to: NSMakePoint(mittex, h)) // destination
      achsen.lineWidth = 1  // hair line
      //achsen.stroke()  // draw line(s) in color
      if let joystickident = self.identifier
      {
       //  Swift.print("JoystickView ident: \(joystickident) raw: \(joystickident.rawValue)")
         
      }
      else
      {
         Swift.print("JoystickView no ident")
      }
      
   }
   
   // https://stackoverflow.com/questions/21751105/mac-os-x-convert-between-nsview-coordinates-and-global-screen-coordinates
   override func draw(_ dirtyRect: NSRect) 
    {
        //Swift.print("Profilfeld drawRect dirtyRect: \(dirtyRect) Datearray: \(DatenArray)")
        let bgcolor:NSColor = NSColor.init(calibratedRed:1.0, green:1.0, blue: 1.0, alpha: 1.0)
        bgcolor.setFill()
        if scale == 0
        {
            scale = 4
        }
        var mitabbrand = 0
        var abbranddelay:Int = 5
        
        if (NSGraphicsContext.currentContextDrawingToScreen() == true)
        {
            //print("Profilfeld drawRect to screen ")
            screen=1;
        }
        else
        {
            print("Profilfeld drawRect print ")
            screen=0;
        }
        
        
        // https://stackoverflow.com/questions/36596545/how-to-draw-a-dash-line-border-for-nsview
        super.draw(dirtyRect)
        
        // dash customization parameters
        let dashHeight: CGFloat = 1
        let dashColor: NSColor = .gray
        
        // setup the context
        let currentContext = NSGraphicsContext.current!.cgContext
        currentContext.setLineWidth(dashHeight)
        //currentContext.setLineDash(phase: 0, lengths: [dashLength])
        currentContext.setStrokeColor(dashColor.cgColor)
        
        // draw the dashed path
        currentContext.addRect(bounds.insetBy(dx: dashHeight, dy: dashHeight))
        currentContext.strokePath()
        
        let w:CGFloat = bounds.size.width
        let h:CGFloat = bounds.size.height
        
        
        GitterZeichnen()
        //print("Profilfeld drawRect DatenArray: \(DatenArray)")
        let anz = DatenArray.count
        if DatenArray.count > 0
        {
            var line = DatenArray[0] as! [String:Double]
            //print("Profilfeld drawRect line 0: \(line)")
            var ax = line["ax"]!
            var ay = line["ay"]!
            StartPunktA = NSMakePoint(ax*scale,ay*scale)
            var bx = line["bx"]!
            //bx += CGFloat(GraphOffset)
            var by = line["by"]!
            by += CGFloat(GraphOffset)
            StartPunktB = NSMakePoint(bx * scale , by*scale)
            
            line = DatenArray[anz - 1] as! [String:Double]
            //          print("Profilfeld drawRect line anz-1: \(line)")
            ax = line["ax"]!
            ay = line["ay"]!
            EndPunktA = NSMakePoint(ax*scale,ay*scale)
            bx = line["bx"]!
            by = line["by"]!
            EndPunktB = NSMakePoint(bx*scale,by*scale)
            
            // print("Profilfeld drawRect StartpunktA: \(StartPunktA)  StartpunktB:\(StartPunktB)")
            //         print("Profilfeld drawRect  EndPunktA: \(EndPunktA) EndPunktB: \(EndPunktB)")
            
            
            
            
            
            if screen > 0
            {
                
                var line = DatenArray[0] as! [String:Any]
                
                var ax = line["ax"] as! Double
                var ay = line["ay"] as! Double
                
                
                let AA = NSMakePoint(0,ay*scale)
                let AB = NSMakePoint(w - AA.x - 4,ay*scale)
                
                var GrundLinieA = NSBezierPath()
                GrundLinieA.move(to: AA)
                GrundLinieA.line(to: AB)
                GrundLinieA.lineWidth = 0.3
                NSColor.blue.set() // choose color
                
                var bx = line["bx"] as! Double
                var by = line["by"] as! Double
                
                let BA = NSMakePoint(0,(by + Double(GraphOffset))*scale)
                let BB = NSMakePoint(w - BA.x - 4,(by + Double(GraphOffset))*scale)
                
                var GrundLinieB = NSBezierPath()
                GrundLinieB.move(to: BA)
                GrundLinieB.line(to: BB)
                GrundLinieB.lineWidth = 0.3
                NSColor.blue.set() // choose color
                
                
                GrundLinieA.stroke()
                GrundLinieB.stroke()
                
                
            }//  if screen > 0
            
            else
            {
                print("screen ist 0")
            }
            
            var  StartMarkARect:NSRect = NSMakeRect(StartPunktA.x-1.5, StartPunktA.y-1, 3, 3)
            //NSLog(@"StartMarkARect: x: %d y: %d ",StartMarkARect.origin.x, StartMarkARect.origin.y);
            var StartMarkA = NSBezierPath.init(ovalIn:StartMarkARect)
            NSColor.blue.set()
            StartMarkA.stroke()
            var LinieA = NSBezierPath()
            var KlickLinieA = NSBezierPath()
            LinieA.move(to:StartPunktA)
            
            var  StartMarkBRect:NSRect = NSMakeRect(StartPunktB.x-1.5, StartPunktB.y-1, 3, 3)
            //NSLog(@"StartMarkARect: x: %d y: %d ",StartMarkARect.origin.x, StartMarkARect.origin.y);
            var StartMarkB = NSBezierPath.init(ovalIn:StartMarkBRect)
            NSColor.blue.set()
            StartMarkB.stroke()
            var LinieB = NSBezierPath()
            var KlickLinieB = NSBezierPath()
            LinieB.move(to:StartPunktB)
            
            
            // ********************************************
            // Abbrand
            //  Seite 1
            var AbbrandLinieA = NSBezierPath()
            var startabbrandindexA:Int = 0
            var AbbrandLinieB = NSBezierPath()
            var startabbrandindexB:Int = 0
            
            var abrax:Double = 0
            var abray:Double = 0
            
            var abrbx:Double = 0
            var abrby:Double = 0
            
            var l = 0
            var controlarr = [[String:Double]]()
            
            
            // erstes vorkommen von abr suchen
            for i in 0..<anz
            {
                //print("i: \(i)")
                
                var line = DatenArray[i] as! [String:Double]
                var ok = 0
                //print(" line: \(line)")
                if let s = line["abrax"]
                {
                    controlarr.append(line)
                    if line["teil"] == 15
                    {
                        l = i
                        ok = 1
                        startabbrandindexA = i
                    }
                    //break
                }
                if ok == 1
                {
                    break
                }
            }
            
            if startabbrandindexA > 0
            {
                mitabbrand = 1
            }
            //startabbrandindexA -= 1
            //print("draw startabbrandindexA: \(startabbrandindexA)")
            let startlineA =  DatenArray[startabbrandindexA] as! [String:Double]
            let startlineB =  DatenArray[startabbrandindexA] as! [String:Double]
            //print("startlineA: \(startlineA)")
            
            let startabrax = startlineA["ax"]
            let startabray = startlineA["ay"]! + 5
            
            var AbbrandStartPunktA = NSMakePoint(startabrax! * scale,startabray * scale)
            AbbrandLinieA.move(to: AbbrandStartPunktA)

            let startabrbx = startlineA["bx"]
            let startabrby = startlineA["by"]! + 5

             var AbbrandStartPunktB = NSMakePoint(startabrbx! * scale,startabrby * scale)
            AbbrandLinieB.move(to: AbbrandStartPunktB)
            if mitabbrand > 0
            {
                
            }
            
            
            // Seite 2
            
            for i in 0..<anz
            {
                var line = DatenArray[i] as! [String:Any]
                if let s = line["abrbx"]
                {
                    startabbrandindexB = i
                    break
                }
            }
            print("startabbrandindexB: \(startabbrandindexB)")
             
            for i in 0..<anz
            {
                line = DatenArray[i] as! [String:Double]
                //line = DatenArray[i] as! [String:Double]
                ax = line["ax"]!
                ay = line["ay"]!
                //wenn kein Abbrand
                abrax = ax
                abray = ay
                
                var PunktA = NSMakePoint(ax * scale, ay * scale)
                LinieA.line(to:PunktA)
                var tempMarkA = NSBezierPath()
                
                bx = line["bx"]!
                by = line["by"]!
                abrbx = bx
                abrby = by
                
                var PunktB = NSMakePoint(bx * scale, by * scale)
                LinieB.line(to:PunktB)
                var tempMarkB = NSBezierPath()
                
                if i == Klickpunkt && screen > 0
                {
                    let tempMarkARect = NSMakeRect(PunktA.x-4.1, PunktA.y-4.1, 8.1, 8.1)
                    tempMarkA = NSBezierPath.init(ovalIn: tempMarkARect)
                    NSColor.gray.set()
                    tempMarkA.stroke()
                    
                    let tempMarkBRect = NSMakeRect(PunktB.x-1.5, PunktB.y-1.5, 3.1, 3.1)
                    tempMarkB = NSBezierPath.init(ovalIn: tempMarkBRect)
                    NSColor.red.set()
                    tempMarkB.stroke()
                    
                    
                }// i == Klickpunkt
                else
                {
                    NSColor.gray.set()
                    let tempMarkARect = NSMakeRect(PunktA.x-2.5, PunktA.y-2.5, 5.1, 5.1)
                    tempMarkA = NSBezierPath.init(ovalIn: tempMarkARect)
                    tempMarkA.stroke()
                    
                    let tempMarkBRect = NSMakeRect(PunktB.x-1.5, PunktB.y-1.5, 3.1, 3.1)
                    tempMarkB = NSBezierPath.init(ovalIn: tempMarkBRect)
                    tempMarkB.stroke()
                    
                    if screen > 0
                    {
                        if i > stepperposition
                        {
                            NSColor.blue.set()
                            tempMarkA.stroke()
                        }
                        else
                        {
                            NSColor.red.set()
                            // Kreuz
                            NSBezierPath.strokeLine(from:NSMakePoint(PunktA.x - 4.1, PunktA.y - 4.1), to:NSMakePoint(PunktA.x + 4.1, PunktA.y + 4.1))
                            NSBezierPath.strokeLine(from:NSMakePoint(PunktA.x + 4.1, PunktA.y - 4.1), to:NSMakePoint(PunktA.x - 4.1, PunktA.y + 4.1))
                        }
                    }// if screen > 0
                }
                
                if KlicksetA.count > 0 && screen > 0
                {
                    if i == KlicksetA.firstIndex
                    {
                        KlickLinieA.move(to:PunktA)
                    }
                    
                    if KlicksetA.contains(i) && screen > 0
                    {
                        let tempMarkRect = NSMakeRect(PunktA.x-1.5, PunktA.y-1.5, 3.1, 3.1)
                        tempMarkA = NSBezierPath.init(ovalIn: tempMarkRect)
                        NSColor.black.set()
                        tempMarkA.fill()
                        if KlicksetA.count > 0 && i > KlicksetA.firstIndex
                        {
                            KlickLinieA.line(to:PunktA)
                        }
                    }
                }//  if KlicksetA.count
                
                if mitabbrand > 0
                {
                    // Abbrandlinien
                    // Seite A
                    var abbrandaok = 0
                    var AbbrandPunktA = NSMakePoint(0, 0)
                    if let abrax = line["abrax"]
                    {
                        abbrandaok += 1
                    }
                    if let abray = line["abray"]
                    {
                        abbrandaok += 1
                        
                    }
                    if abbrandaok == 2
                    {
                        AbbrandPunktA.x = line["abrax"]! * scale
                        AbbrandPunktA.y = line["abray"]! * scale
                        if (AbbrandPunktA.x == PunktA.x) && (AbbrandPunktA.y == PunktA.y)
                        {
                            print("kein abbrand A an i: \(i)")
                        }
                        else
                        {
                            AbbrandPunktA.y  += CGFloat(abbranddelay)
                            AbbrandLinieA.line(to:AbbrandPunktA)
                            var AbbranddeltaA = NSBezierPath()
                            
                            AbbranddeltaA.move(to: PunktA)
                            AbbranddeltaA.line(to: AbbrandPunktA)
                            AbbranddeltaA.stroke()
                        }
                    }
                    
                    // Seite B
                    var abbrandbok = 0
                    var AbbrandPunktB = NSMakePoint(0, 0)
                    if let abrbx = line["abrbx"]
                    {
                        abbrandbok += 1
                        
                    }
                    if let abrby = line["abrby"]
                    {
                        abbrandbok += 1
                        
                    }
                    if abbrandbok == 2
                    {
                        AbbrandPunktB.x = line["abrbx"]! * scale
                        AbbrandPunktB.y = line["abrby"]! * scale
                        
                        if (AbbrandPunktB.x == PunktB.x) && (AbbrandPunktB.y == PunktB.y)
                        {
                            print("kein abbrand B an i: \(i)")
                        }
                        else
                        {
                            AbbrandPunktB.y  += CGFloat(abbranddelay)
                            AbbrandLinieB.line(to:AbbrandPunktB)
                            
                            var AbbranddeltaB = NSBezierPath()
                            AbbranddeltaB.move(to: PunktB)
                            AbbranddeltaB.line(to: AbbrandPunktB)
                            AbbranddeltaB.stroke()
                        }
                    }
                }
                
                
                
            }// for i
            
            NSColor.blue.set()
            LinieA.stroke()
            
            NSColor.gray.set()
            LinieB.stroke()
            
            if KlickLinieA.isEmpty
            {
                
            }
            else
            {
                NSColor.green.set()
                KlickLinieA.stroke()
            }
            
               
            
            if mitabbrand > 0
            {
                NSColor.gray.set()
                AbbrandLinieA.stroke()
                AbbrandLinieB.stroke()
            }
            
        } // if DatenArray.count > 0
        
       
        /*
        if RahmenArray.count > 0
        {
            var RahmenPath = NSBezierPath()
            var startpunkt = RahmenArray[0] as! NSPoint
            startpunkt.x *= scale
            startpunkt.y *= scale
            RahmenPath.move(to:startpunkt)
            for i in 0..<RahmenArray.count
            {
                var rahmenpunkt = RahmenArray[i] as! NSPoint
                rahmenpunkt.x *= scale
                rahmenpunkt.y *= scale
                RahmenPath.line(to:rahmenpunkt)
                
            }
            RahmenPath.line(to:startpunkt)
            NSColor.gray.set()
            RahmenPath.stroke()
        }
        */
    }
   
   override func mouseDown(with theEvent: NSEvent) 
    {
        
        super.mouseDown(with: theEvent)
        let nc = NotificationCenter.default
        
        let shift = NSEvent.ModifierFlags.shift.rawValue
        
        //let ident  = self.identifier as! String
        let ident  = self.identifier
        
        //Swift.print("rProfilfeldView mouseDown ident: \(ident)")
        var identstring = ""
        if let rawident:String = ident?.rawValue
        {
            identstring = rawident
        }
        else
        {
            identstring = "13"
        }
        
        let location = theEvent.locationInWindow
        Swift.print("mousedown location \(location)")
        var local_point = convert(theEvent.locationInWindow, from: nil)
        Swift.print(local_point)
        mausistdown = 1
        
        
        var MausDic:[String:Any] = [:]
        MausDic["mausistdown"] = 1
        MausDic["graphoffset"] = GraphOffset
        print("mouseDown Mausdic: \(MausDic)")
        
        //nc.post(name: NSNotification.Name(rawValue: "mausdaten") , object: nil, userInfo: MausDic)
        
        local_point.x /= scale
        local_point.y /= scale
        
        // von joystick
        // setup the context
        // setup the context
        //let dashHeight: CGFloat = 1
        //let dashColor: NSColor = .green
        
        if (oldMauspunkt.x == local_point.x) && (oldMauspunkt.y == local_point.y)
        {
            print("mousedown gleicher punkt")
        }
        else
        {
            print("mousedown neuer punkt")
            oldMauspunkt = local_point
        }
        print("mousedown x: \(local_point.x) y: \(local_point.y)")
        
        //var linehit:Int = 0
        
        if DatenArray.count > 3
        {
            var clickAbschnitt = self.clickedAbschnittvonMaus(derPunkt: local_point)
            if clickAbschnitt >= 0
            {
                var NotificationDic = [String:Any]()
                NotificationDic["mauspunktx"] = Int(local_point.x)
                NotificationDic["mauspunkty"] = Int(local_point.y)
                NotificationDic["mauspunkt"] = NSStringFromPoint(local_point)
                NotificationDic["klickabschnitt"] = clickAbschnitt
                NotificationDic["mausklick"] = clickAbschnitt
                NotificationDic["graphoffset"] = GraphOffset
                nc.post(name: NSNotification.Name(rawValue: "mausklick") , object: nil, userInfo: NotificationDic)
            }
            else
            {
                print("kein Klick")
            }
        } // count > 3
        
        var NotificationDic = [String:Any]()
        Klickpunkt = self.clickedPunktvonMaus(derPunkt: local_point)
        if Klickpunkt >= 0x0FFF
        {
            Klickseite = 2
        }
        else
        {
            Klickseite = 1
        }
        
        NotificationDic["klickseite"] = Klickseite
        print("mousedown startklickpunkt: \(startklickpunkt) Klickpunkt: \(Klickpunkt)")
        
        if Klickpunkt > -1 // Punkt angeklickt
        {
            if shift > 0
            {
                if (startklickpunkt >= 0) && (!(startklickpunkt == Klickpunkt))
                {
                    
                    if Klickpunkt > startklickpunkt
                    {
                        klickrange = NSMakeRange(startklickpunkt, (Klickpunkt - startklickpunkt))
                        NotificationDic["startklickpunkt"] = startklickpunkt
                        
                    }// Klickpunkt > startklickpunkt
                    else
                    {
                        klickrange = NSMakeRange(startklickpunkt, (startklickpunkt - Klickpunkt))
                        NotificationDic["startklickpunkt"] = startklickpunkt
                    }
                    NotificationDic["klickrange"] = NSStringFromRange(klickrange)
                    
                    KlicksetA.add(in: klickrange)
                    NotificationDic["klickindexset"] = KlicksetA
                    klickrange=NSMakeRange(0,0)
                    startklickpunkt = -1
                }// startklickpunkt >=0)
                else
                {
                    KlicksetA.removeAllIndexes()
                    startklickpunkt=Klickpunkt
                    klickrange=NSMakeRange(0,0)
                    
                }
                
            }  // if shift
            else // Neuanfang, Vorbereitung fuer Aktion mit shift
            {
                KlicksetA.removeAllIndexes()
                startklickpunkt = Klickpunkt  // Punkt merken
                NotificationDic["klickrange"] = NSStringFromRange(NSMakeRange(0,0))
                NotificationDic["graphoffet"] = GraphOffset
                klickrange = NSMakeRange(0,0)
                
            } // Neuanfang
            
            // Koord Mauspunkt
            if Klickseite == 2
            {
                local_point.y -= CGFloat(GraphOffset)
            }
            
            NotificationDic["mauspunkt"] = NSStringFromPoint(local_point)
            
            // Nummer des angeklickten Punktes
            NotificationDic["klickpunkt"] = Klickpunkt
            
            nc.post(name: NSNotification.Name(rawValue: "mausklick") , object: nil, userInfo: NotificationDic)
        } // Klickpunkt < -1
        
        
        else // Range reseten
        {
            var NotificationDic = [String:Any]()
            NotificationDic["mauspunkt"] = NSStringFromPoint(local_point)
            NotificationDic["graphoffet"] = GraphOffset
            print("mousedown Range reseten: NotificationDic: \(NotificationDic)+")
            klickrange=NSMakeRange(0,0)
            startklickpunkt = -1
            nc.post(name: NSNotification.Name(rawValue: "mauspunkt") , object: nil, userInfo: NotificationDic)
            
        }
        print("mousedown end")
    }
   
   override func rightMouseDown(with theEvent: NSEvent) 
   {
      self.clearWeg()
      Swift.print("rJoystickView right mouse")
      let location = theEvent.locationInWindow
      Swift.print(location)
       self.setNeedsDisplay(self.frame)
      //needsDisplay = true
   }
   
   
   override func mouseDragged(with theEvent: NSEvent) 
    {
        Swift.print("** Swift Profilfeld mouseDragged ")
        let nc = NotificationCenter.default
        let location = theEvent.locationInWindow
        //Swift.print(location)
        var lokalpunkt = convert(theEvent.locationInWindow, from: nil)
        lokalpunkt.x /= scale;
        lokalpunkt.y /= scale;
        var userinformation:[String : Any]
        let hyp =  hypot((oldMauspunkt.x - lokalpunkt.x), (oldMauspunkt.y - lokalpunkt.y))
        Swift.print("Profilfeld mouseDragged lokalpunkt: \(lokalpunkt) oldMauspunkt: \(oldMauspunkt) hyp: \(hyp) Klickseite: \(Klickseite) Klickpunkt: \(Klickpunkt)")
        if Klickseite == 2
        {
            lokalpunkt.y -= Double(GraphOffset)
        }
        
        if (lokalpunkt.x >= self.bounds.size.width)
        {
            lokalpunkt.x = self.bounds.size.width
            print("mouseDragged width")
        }
        if (lokalpunkt.x <= 0)
        {
            lokalpunkt.x = 0
            print("mouseDragged width<0")
        }
        
        if (lokalpunkt.y > self.bounds.size.height)
        {
            lokalpunkt.y = self.bounds.size.height
            print("mouseDragged height")
        }
        if (lokalpunkt.y <= 0)
        {
            lokalpunkt.y = 0
            print("mouseDragged height < 0")
        }
        if (Klickseite == 2)
        {
            lokalpunkt.y -= CGFloat(GraphOffset)
        }
        
        print("mouseDragged  Klickseite: \(Klickseite) Klickpunkt: \(Klickpunkt)")
        
        if Klickpunkt >= 0 && DatenArray.count > Klickpunkt
        {
            var line = DatenArray[Klickpunkt] as! [String:Any]
            var ax = line["ax"] as! Double
            var ay = line["ay"] as! Double
            
            var aktivPunkt:NSPoint = NSPoint(x: ax  * scale, y: ay * scale)
            var aktivFeld:NSRect = NSMakeRect(aktivPunkt.x-3, aktivPunkt.y-3, 6, 6 )
            // let hyp = Int(sqrt(pow(triPerpendicular, 2) + pow(triBase, 2)))
            
            if (self.mouse(aktivPunkt, in: aktivFeld)) // Maus ziehen
            {
                print("mouseDragged in  Feld: ax: \(aktivPunkt.x) y: \(aktivPunkt.y)")
                var NotificationDic = [String:Any]()
                NotificationDic["ax"] = Int(lokalpunkt.x)
                NotificationDic["ay"] = Int(lokalpunkt.y)
                NotificationDic["mauspunkt"] = NSStringFromPoint(lokalpunkt)
                NotificationDic["klickpunkt"] = Klickpunkt
                NotificationDic["klickseite"] = Klickseite
                NotificationDic["graphoffset"] = GraphOffset
                print("mouseDragged in  Feld: NotificationDic: \(NotificationDic)")
                nc.post(name: NSNotification.Name(rawValue: "mausdrag") , object: nil, userInfo: NotificationDic)
            }
        }// Klickpunkt >= 0
        else if hypot((oldMauspunkt.x - lokalpunkt.x), (oldMauspunkt.y - lokalpunkt.y))>4 // Abstad gross genug für neuen Punkt
        {

            oldMauspunkt = lokalpunkt
            print("mouseDragged neuer Punkt: ax: \(lokalpunkt.x) y: \(lokalpunkt.y)")

            var NotificationDic = [String:Any]()
            NotificationDic["ax"] = Int(lokalpunkt.x)
            NotificationDic["ay"] = Int(lokalpunkt.y)
            NotificationDic["mauspunkt"] = NSStringFromPoint(lokalpunkt)
            NotificationDic["graphoffset"] = GraphOffset
            print("mouseDragged gross genug: NotificationDic: \(NotificationDic)")
            nc.post(name: NSNotification.Name(rawValue: "mauspunkt") , object: nil, userInfo: NotificationDic)
            
        }
        
         
          
    }
   
   func clearWeg()
   {
      weg.removeAllPoints()
      kreuz.removeAllPoints()
      needsDisplay = true
      
   }
   /*
    override func rotate(byDegrees angle: CGFloat) 
    {
    var transform = NSAffineTransform()
    transform.rotate(byDegrees: angle)
    weg.transform(using: transform as AffineTransform)
    }
    */
   override func keyDown(with theEvent: NSEvent)
    {
        let optionKeyPressed = theEvent.modifierFlags.contains(.option)
        var arrowstep:Int32 = 100
        Swift.print( "Profilfeld Key Pressed" )
        Swift.print(theEvent.keyCode)
        let loc = theEvent.locationInWindow
        Swift.print( "Profilfeld loc: \(loc)")
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
   
} // rJoystickView

