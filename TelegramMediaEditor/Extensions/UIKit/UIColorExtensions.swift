//
//  UIColorExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import UIKit

extension UIColor {
    
    var hsbColor: HSBColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return HSBColor(hue: h, saturation: s, brightness: b, alpha: a)
    }
    
    var rgbColor: RGBColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "%06x", rgb)
    }
    
    convenience init(hsbColor: HSBColor) {
        self.init(
            hue: hsbColor.hue,
            saturation: hsbColor.saturation,
            brightness: hsbColor.brightness,
            alpha: hsbColor.alpha
        )
    }
    
    convenience init?(hex: String) {
        var hex = hex
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        
        guard hex.count == 6 else { return nil }
        
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            self.init(
                red: CGFloat((hexNumber & 0xFF0000) >> 16) / 255,
                green: CGFloat((hexNumber & 0x00FF00) >> 8) / 255,
                blue: CGFloat(hexNumber & 0x0000FF) / 255,
                alpha: 1
            )
        } else {
            return nil
        }
    }
}
