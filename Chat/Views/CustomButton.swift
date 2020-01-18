//
//  CustomButton.swift
//  Chat
//
//  Created by Zizo Adel on 12/25/19.
//  Copyright © 2019 Zizo Adel. All rights reserved.
//

import UIKit

@IBDesignable
class CustomButton: UIButton {

    @IBInspectable var BorderWidth: CGFloat = 0 {
         didSet {
             self.layer.borderWidth = BorderWidth
          }
     }
    @IBInspectable var BorderColor: UIColor = UIColor.clear {
             didSet {
            self.layer.borderColor = BorderColor.cgColor
             }
     }
     @IBInspectable var CornerRadius: CGFloat = 0 {
         didSet {
             self.layer.cornerRadius = CornerRadius
         }
     }
            
}
