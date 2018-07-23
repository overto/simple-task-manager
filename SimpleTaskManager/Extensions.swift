//
//  Extensions.swift
//  SimpleTaskManager
//
//  Created by Richard Overton on 7/14/18.
//  Copyright © 2018 Richard Overton. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func colorFromHex(_ hex: String) -> UIColor {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            return UIColor.white
        }
        
        var rgb: UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
        
    } 
}

extension Notification.Name {
    static let localNotificationsPermissionGranted = Notification.Name("LocalNotificationsPermissionGranted")
}
