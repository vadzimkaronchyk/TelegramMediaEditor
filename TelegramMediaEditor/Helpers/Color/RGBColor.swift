//
//  RGBColor.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import UIKit

struct RGBColor {
    
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    /// https://gist.github.com/FredrikSjoberg/cdea97af68c6bdb0a89e3aba57a966ce
    var hsb: HSBColor {
        let min = red < green ? (red < blue ? red : blue) : (green < blue ? green : blue)
        let max = red > green ? (red > blue ? red : blue) : (green > blue ? green : blue)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return .init(hue: 0, saturation: 0, brightness: max) }
        guard max > 0 else { return .init(hue: -1, saturation: 0, brightness: v) } // Undefined, achromatic grey
        let s = delta / max
        
        let hue: (CGFloat, CGFloat) -> CGFloat = { max, delta -> CGFloat in
            if red == max { return (green-blue)/delta } // between yellow & magenta
            else if green == max { return 2 + (blue-red)/delta } // between cyan & yellow
            else { return 4 + (red-green)/delta } // between magenta & cyan
        }
        
        let h = hue(max, delta) * 60 // In degrees
        
        return .init(hue: (h < 0 ? h+360 : h) / 360, saturation: s, brightness: v)
    }
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
