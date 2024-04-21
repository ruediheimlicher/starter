//
//  Netz.swift
//  SwiftStarter
//
//  Created by Ruedi Heimlicher on 30.10.2014.
//  Copyright (c) 2014 Ruedi Heimlicher. All rights reserved.
//


import Cocoa
import Foundation
import AVFoundation
import Darwin

let BUFFER_SIZE:Int   = Int(BufferSize())

var new_Data:ObjCBool = false

class rTimerInfo {
    var count = 0
}




 @objc class usb_teensy: NSObject
{
   var hid_usbstatus: Int32 = 0
   
    var boardindex:Int = 0 // 0: teensy++2  1: teensy3.xx
   
    var read_byteArray = [UInt8](repeating: 0x00, count: BUFFER_SIZE)
   var last_read_byteArray = [UInt8](repeating: 0x00, count: BUFFER_SIZE)
   var write_byteArray: Array<UInt8> = Array(repeating: 0x00, count: BUFFER_SIZE)
   // var testArray = [UInt8]()
     
   var testArray: Array<UInt8>  = [0xAB,0xDC,0x69,0x66,0x74,0x73,0x6f,0x64,0x61]
   
   var read_OK:ObjCBool = false
   
   var datatruecounter = 0
   var datafalsecounter = 0
   
    var readtimer: Timer?
   
   var manustring:String = ""
   var prodstring:String = ""
   
  
     var USBTimerInfo = rTimerInfo()
     
   // von CNC_Mill
     var lastreadarray = [UInt8](repeating: 0x00, count: BUFFER_SIZE)
     var readarray = [UInt8](repeating: 0x00, count: BUFFER_SIZE)
     
     
     
   override init()
   {
      super.init()
   }
   
    open func USBOpen(code:[String:Any] , board: Int)->Int32
   {
      boardindex = board
      var r:Int32 = 0
      
      let PID:Int32 = Int32(code["PID"] as! Int32)//
      let VID:Int32 = Int32(code["VID"] as! Int32)//
      print("func usb_teensy.USBOpen PID: \(PID) VID: \(VID)")
      // rawhid_open(int max, int vid, int pid, int usage_page, int usage)
      
      if (hid_usbstatus > 0)
      {
         print("func usb_teensy.USBOpen USB schon offen")
         let alert = NSAlert()
         alert.messageText = "USB Device"
         alert.informativeText = "USB ist schon offen"
         alert.alertStyle = .warning
         alert.addButton(withTitle: "OK")
        // alert.addButton(withTitle: "Cancel")
         let antwort =  alert.runModal() == .alertFirstButtonReturn
         return 1;
      }

      
      
      let    out = rawhid_open(1,  VID, PID, 0xFFAB, 0x0200)
      
       
      print("func usb_teensy.USBOpen out: \(out)")
      
      hid_usbstatus = out as Int32;
      globalusbstatus = Int(hid_usbstatus)
      if (out <= 0)
      {
         NSLog("USBOpen: no rawhid device found");
         //AVR.setUSB_Device_Status:0
      }
      else
      {
         NSLog("USBOpen: found rawhid device hid_usbstatus: %d",hid_usbstatus)
         let manu   = get_manu()
         let manustr:String = String(cString: manu!)
         
         if (manustr == "")
         {
            manustring = "-"
         }
         else
         {
            manustring = manustr
            //manustring = String(cString: UnsafePointer<CChar>(manustr))
         }
          
         let prod = get_prod();
         if (prod == nil)
         {
            prodstring = "-"
         }
         else 
         {
         //fprintf(stderr,"prod: %s\n",prod);
         let prodstr:String = String(cString: prod!)
         if (prodstr == nil)
         {
            prodstring = "-"
         }
         else
         {
            prodstring = String(cString: UnsafePointer<CChar>(prod!))
         }
         }
         var USBDatenDic = ["prod": prod, "manu":manu]
          
         
      }
      
      
      return out;
   } // end USBOpen
   
   open func manufactorer()->String?
   {
      return manustring
   }
   
   open func producer()->String?
   {
      return prodstring
   }
   
    open func setboardindex(board:Int)
    {
       boardindex = board
    }
   
   open func status()->Int32
   {
      return get_hid_usbstatus()
   }
   
   open func dev_present()->Int32
   {
      return usb_present()
   }
   
    open func timer_valid()->Bool
    {
       return ((readtimer?.isValid) != nil)
    }
   /*
    func appendCRLFAndConvertToUTF8_1(_ s: String) -> Data {
    let crlfString: NSString = s + "\r\n" as NSString
    let buffer = crlfString.utf8String
    let bufferLength = crlfString.lengthOfBytes(using: String.Encoding.utf8.rawValue)
    let data = Data(bytes: UnsafePointer<UInt8>(buffer!), count: bufferLength)
    return data;
    }
    */
   
    open func iscont()-> Int
    {
       if (read_OK).boolValue == true
       {
            return 1
       }
       return 0
    }
   
   open func getlastDataRead()->Data
   {
      return lastDataRead
   }
   
   @objc func start_read_USB(_ cont: Bool, dic:[String:Any])-> Int
   {
      read_OK = ObjCBool(cont)
      var home = 0
      var timerDic:NSMutableDictionary  = ["count": 0,"home":home]
      
 //     let result = rawhid_recv(0, &read_byteArray, Int32(BUFFER_SIZE), 50);
      
    //  print("\ result: \(result) cont: \(cont)")
      //print("usb.swift start_read_byteArray start: *\n\(read_byteArray)*")
  //    let usbData = Data(bytes:read_byteArray)
  //    print("\n+++ new read_byteArray in start_read_USB:")
  //     for  i in 0..<BUFFER_SIZE
  //     {
  //        print(" \(read_byteArray[i])", terminator: "")
  //     }
      // print("\n")
/*
      let nc = NotificationCenter.default
      nc.post(name:Notification.Name(rawValue:"newdata"),
              object: nil,
              userInfo: ["message":"neue Daten", "data":read_byteArray,"startdata":usbData])
  */    
      // var somethingToPass = "It worked in teensy_send_USB"
     
      
      let xcont = cont;
      
      if (xcont == true)
      {
         
         
         if readtimer?.isValid == true
         {
            readtimer?.invalidate()
         }
         readtimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(usb_teensy.cont_read_USB(_:)), userInfo: USBTimerInfo, repeats: true)
      
      }
      return 0
      //return Int(result) //
   }
   
   
   
   @objc open func cont_read_USB(_ timer: Timer)
   {
     // print("\n*** cont_read_USB start")
    //  print("*read_OK: \(read_OK)")
      if (read_OK).boolValue
      {
         //var tempbyteArray = [UInt8](count: 32, repeatedValue: 0x00)
         
         var result = rawhid_recv(0, &read_byteArray, Int32(BUFFER_SIZE), 0)
         
         var usbrecvcount = 0
         for  i in 0..<BUFFER_SIZE
         {
            if read_byteArray[i] > 0
            {
               usbrecvcount += 1
            }
         }
    //     print("*cont_read_USB usbrecvcount: \(usbrecvcount)")
         if usbrecvcount == 0
         {
            return
         }
         if read_byteArray[0] > 0xA0
         {
            //print("*cont_read_USB result: \(result) code: \(read_byteArray[0])")
         }
         //print("tempbyteArray in Timer: *\(read_byteArray)*")
        // var timerdic: [String: Int]
         
         guard let timerInfo = timer.userInfo as? rTimerInfo else 
         { 
            print("cont_read_USB timerinfo not OK")
            return 
            
         }
         
             timerInfo.count += 1
     
          
          //print("cont_read_USB timerInfo: \(timerInfo.count)")
      
           
         if !(last_read_byteArray == read_byteArray)
         {
           print("last_read_byteArray not eq read byteArray ");
            /*
                 guard let timerInfo = timer.userInfo as? rTimerInfo else { return }

                        timerInfo.count += 1
                       // print("cont_read_USB timerInfo: \(timerInfo.count)")
            */
            
           // print("cont_read_USB timerInfo: \(timerInfo) read_byteArray 0: \(read_byteArray[0])")

            
            last_read_byteArray = read_byteArray
            lastDataRead = Data(bytes:read_byteArray)
            let usbData = Data(bytes:read_byteArray)
            new_Data = true
            datatruecounter += 1
            let codehex = read_byteArray[0]
            let codehexstring = String(codehex, radix:16, uppercase:true)
       //     print("cont_read_USB new Data codehex: \(codehex) codehex: \(codehexstring)")
            
            
            //print("\n+++ cont_read_USB new read_byteArray in Timer. code: \(read_byteArray[0])")
            
            
            if (read_byteArray[0] == 0xBD)
            {
               print("usb code BD")
            }
             
     //        print("read_byteArray: \(read_byteArray)")
            /*
             for  i in 0..<BUFFER_SIZE
            {
               print("i: \(i)  \(read_byteArray[i]) ")
            }
            print("\n")
            */
            // http://dev.iachieved.it/iachievedit/notifications-and-userinfo-with-swift-3-0/
            
            //let usbdic = ["message":"neue Daten", "data":read_byteArray] as [String : UInt8]
            let nc = NotificationCenter.default
            /*       
             nc.post(name:Notification.Name(rawValue:"newdata"),
             object: nil,
             userInfo: ["message":"neue Daten", "data":read_byteArray, "usbdata":usbData])
             */
            // CNC
            nc.post(name:Notification.Name(rawValue:"newdata"),
                    object: nil,
                    userInfo: ["message":"neue Daten", "data":read_byteArray, "contdata":usbData])
            
            // print("+ new read_byteArray in Timer:", terminator: "")
            //for  i in 0...31
            //{
            // print(" \(read_byteArray[i])", terminator: "")
            //}
            //print("")
            //let stL = NSString(format:"%2X", read_byteArray[0]) as String
            //print(" * \(stL)", terminator: "")
            //let stH = NSString(format:"%2X", read_byteArray[1]) as String
            //print(" * \(stH)", terminator: "")
            
            //var resultat:UInt32 = UInt32(read_byteArray[1])
            //resultat   <<= 8
            //resultat    += UInt32(read_byteArray[0])
            //print(" Wert von 0,1: \(resultat) ")
            
            //print("")
            //var st = NSString(format:"%2X", n) as String
            //     } // end if codehex
         }
         else
         {
            //new_Data = false
            if (read_byteArray[0] > 0)
            {
            //print("---nix neues  \(read_byteArray[0])\t\(datafalsecounter)\n")
            }
            datafalsecounter += 1
            //stop_read_USB()
         }
         //println("*read_USB in Timer result: \(result)")
         
         //let theStringToPrint = timer.userInfo as String
         //println(theStringToPrint)
         //timer.invalidate()
      }
      else
      {
         print("* usb cont_read_USB timer.invalidate")
         timer.invalidate()
      }
      //print("+++ end cont_read +++\n")
   }
   
   open func report_stop_read_USB(_ inTimer: Timer)
   {
      
      read_OK = false
   }
   
   @objc func stop_read_USB()
   {
      read_OK = false
   }
 
    @objc func clear_data()
    {
       for  i in 0..<BUFFER_SIZE
       {
          read_byteArray[i] = 0
          if write_byteArray.count > i
          {
          write_byteArray[i] = 0
          }
       }
       
    }

    @objc func stop_timer()
    {
       if ((readtimer) != nil)
            
       {
          if ((readtimer?.isValid) != nil)
          {
             NSLog("writeCNCAbschnitt HALT timer inval");
             readtimer?.invalidate();
          }
          readtimer = nil
          
       }
       read_OK = false

    }

    
   open func send_USB()->Int32
   {
      // http://www.swiftsoda.com/swift-coding/get-bytes-from-nsdata/
      // Test Array to generate some Test Data
      //var testData = Data(bytes: UnsafePointer<UInt8>(testArray),count: testArray.count)
  /*    
      write_byteArray[0] = testArray[0]
      write_byteArray[1] = testArray[1]
      write_byteArray[2] = testArray[2]
      
      if (testArray[0] < 0xFF)
      {
         testArray[0] += 1
      }
      else
      {
         testArray[0] = 0;
      }
      if (testArray[1] < 0xFF)
      {
         testArray[1] += 1
      }
      else
      {
         testArray[1] = 0;
      }
      if (testArray[2] < 0xFF)
      {
         testArray[2] += 1
      }
      else
      {
         testArray[2] = 0;
      }
      
      //println("write_byteArray: \(write_byteArray)")
//      print("write_byteArray in send_USB: ", terminator: "")
      
      for  i in 0...16
      {
//         print(" \(write_byteArray[i])", terminator: "\t")
      }
      print("")
  */    
      
     //    let senderfolg = rawhid_send(0,&write_byteArray, Int32(BUFFER_SIZE), 50)
      var senderfolg:Int32 = 0xFF
      if  boardindex == 0 // teensy++2
      {
         senderfolg = rawhid_send(0,&write_byteArray, 32, 50)
      }
      else if boardindex == 1 // teensy3.xx
      {
         senderfolg = rawhid_send(0,&write_byteArray, 64, 50)
      }
      
         
         if hid_usbstatus == 0
         {
            //print("hid_usbstatus 0: \(hid_usbstatus)")
         }
         else
         {
            //print("hid_usbstatus not 0: \(hid_usbstatus)")
            
         }
         
         return senderfolg
      
   }
   
   
   
   open func rep_read_USB(_ inTimer: Timer)
   {
      var result:Int32  = 0;
      var reportSize:Int = 32;   
      var buffer = [UInt8]();
      result = rawhid_recv(0, &buffer, Int32(BUFFER_SIZE), 50);
      
      var dataRead:Data = Data(bytes:buffer)
      if (dataRead != lastDataRead)
      {
         print("neue Daten")
      }
      print(dataRead as NSData);   
            
   }
   
}


open class Hello
{
   open func setU()
   {
      print("Hi Netzteil")
   }
}

