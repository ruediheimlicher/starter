//
//  rHotwireView.swift
//  CNC_Interface
//
//  Created by Ruedi Heimlicher on 06.03.2024.
//  Copyright © 2024 Ruedi Heimlicher. All rights reserved.
//
import Cocoa
import Foundation


class rHotwireView:NSView
{
   var hgfarbe:NSColor = NSColor()
   
   
   required init?(coder  aDecoder : NSCoder) 
   {
      super.init(coder: aDecoder)
      let w:CGFloat = bounds.size.width
      let h:CGFloat = bounds.size.height

   }
}// rHotwireView
