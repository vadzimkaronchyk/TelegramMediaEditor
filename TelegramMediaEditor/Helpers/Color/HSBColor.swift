//
//  HSBColor.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 18.10.22.
//

import UIKit

struct HSBColor: Hashable {
    
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
    
    /// https://gist.github.com/FredrikSjoberg/cdea97af68c6bdb0a89e3aba57a966ce
    var rgb: RGBColor {
        guard saturation != 0 else {
            return .init(red: brightness, green: brightness, blue: brightness) // Achromatic grey
        }
        
        let angle = hue >= 1 ? 0 : hue
        let sector = angle * 6 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h
        
        let p = brightness * (1 - saturation)
        let q = brightness * (1 - (saturation * f))
        let t = brightness * (1 - (saturation * (1 - f)))
        
        switch i {
        case 0:
            return .init(red: brightness, green: t, blue: p)
        case 1:
            return .init(red: q, green: brightness, blue: p)
        case 2:
            return .init(red: p, green: brightness, blue: t)
        case 3:
            return .init(red: p, green: q, blue: brightness)
        case 4:
            return .init(red: t, green: p, blue: brightness)
        default:
            return .init(red: brightness, green: p, blue: q)
        }
    }
}

extension HSBColor {
    
    var uiColor: UIColor {
        .init(hsbColor: self)
    }
    
    var cgColor: CGColor {
        uiColor.cgColor
    }
    
    static let black = HSBColor(hue: 0, saturation: 1, brightness: 0)
    static let white = HSBColor(hue: 0, saturation: 0, brightness: 1)
}

extension HSBColor {
    
    static func gridColors() -> [[Self]] {
        [[.init(hue: 0.3333333333, saturation: 0, brightness: 1),
          .init(hue: 0, saturation: 0, brightness: 0.92),
          .init(hue: 0, saturation: 0, brightness: 0.84),
          .init(hue: 0, saturation: 0, brightness: 0.76),
          .init(hue: 0, saturation: 0, brightness: 0.68),
          .init(hue: 0, saturation: 0, brightness: 0.6),
          .init(hue: 0, saturation: 0, brightness: 0.52),
          .init(hue: 0, saturation: 0, brightness: 0.44),
          .init(hue: 0, saturation: 0, brightness: 0.36),
          .init(hue: 0, saturation: 0, brightness: 0.28),
          .init(hue: 0, saturation: 0, brightness: 0.2),
          .init(hue: 0, saturation: 0, brightness: 0)],
         [.init(hue: 0.5416666667, saturation: 1, brightness: 0.29),
          .init(hue: 0.6111111111, saturation: 0.99, brightness: 0.34),
          .init(hue: 0.7027777778, saturation: 0.92, brightness: 0.23),
          .init(hue: 0.7888888889, saturation: 0.9, brightness: 0.24),
          .init(hue: 0.9361111111, saturation: 0.88, brightness: 0.24),
          .init(hue: 0.01111111111, saturation: 0.99, brightness: 0.36),
          .init(hue: 0.05277777778, saturation: 1, brightness: 0.35),
          .init(hue: 0.09722222222, saturation: 1, brightness: 0.35),
          .init(hue: 0.1194444444, saturation: 1, brightness: 0.34),
          .init(hue: 0.1583333333, saturation: 1, brightness: 0.4),
          .init(hue: 0.1777777778, saturation: 0.95, brightness: 0.33),
          .init(hue: 0.2527777778, saturation: 0.76, brightness: 0.24)],
         [.init(hue: 0.5388888889, saturation: 1, brightness: 0.4),
          .init(hue: 0.6027777778, saturation: 0.99, brightness: 0.48),
          .init(hue: 0.7027777778, saturation: 0.88, brightness: 0.32),
          .init(hue: 0.7888888889, saturation: 0.85, brightness: 0.35),
          .init(hue: 0.9388888889, saturation: 0.81, brightness: 0.33),
          .init(hue: 0.02222222222, saturation: 1, brightness: 0.51),
          .init(hue: 0.05555555556, saturation: 1, brightness: 0.48),
          .init(hue: 0.1, saturation: 1, brightness: 0.48),
          .init(hue: 0.1222222222, saturation: 1, brightness: 0.47),
          .init(hue: 0.1583333333, saturation: 0.99, brightness: 0.55),
          .init(hue: 0.1777777778, saturation: 0.92, brightness: 0.46),
          .init(hue: 0.25, saturation: 0.7, brightness: 0.34)],
         [.init(hue: 0.5388888889, saturation: 0.99, brightness: 0.56),
          .init(hue: 0.6027777778, saturation: 1, brightness: 0.66),
          .init(hue: 0.7194444444, saturation: 0.92, brightness: 0.47),
          .init(hue: 0.7888888889, saturation: 0.81, brightness: 0.49),
          .init(hue: 0.9388888889, saturation: 0.79, brightness: 0.47),
          .init(hue: 0.025, saturation: 1, brightness: 0.71),
          .init(hue: 0.06111111111, saturation: 1, brightness: 0.68),
          .init(hue: 0.1027777778, saturation: 1, brightness: 0.66),
          .init(hue: 0.1222222222, saturation: 0.99, brightness: 0.65),
          .init(hue: 0.1611111111, saturation: 1, brightness: 0.77),
          .init(hue: 0.1777777778, saturation: 0.92, brightness: 0.65),
          .init(hue: 0.2555555556, saturation: 0.68, brightness: 0.48)],
         [.init(hue: 0.5361111111, saturation: 1, brightness: 0.71),
          .init(hue: 0.6, saturation: 1, brightness: 0.84),
          .init(hue: 0.7055555556, saturation: 0.82, brightness: 0.58),
          .init(hue: 0.7861111111, saturation: 0.79, brightness: 0.62),
          .init(hue: 0.9388888889, saturation: 0.76, brightness: 0.6),
          .init(hue: 0.02777777778, saturation: 1, brightness: 0.89),
          .init(hue: 0.06111111111, saturation: 1, brightness: 0.85),
          .init(hue: 0.1027777778, saturation: 1, brightness: 0.83),
          .init(hue: 0.125, saturation: 1, brightness: 0.82),
          .init(hue: 0.1611111111, saturation: 1, brightness: 0.96),
          .init(hue: 0.1805555556, saturation: 0.89, brightness: 0.82),
          .init(hue: 0.2527777778, saturation: 0.67, brightness: 0.62)],
         [.init(hue: 0.5416666667, saturation: 1, brightness: 0.85),
          .init(hue: 0.6027777778, saturation: 1, brightness: 0.99),
          .init(hue: 0.7166666667, saturation: 0.81, brightness: 0.7),
          .init(hue: 0.7916666667, saturation: 0.78, brightness: 0.74),
          .init(hue: 0.9416666667, saturation: 0.76, brightness: 0.73),
          .init(hue: 0.03055555556, saturation: 0.92, brightness: 1),
          .init(hue: 0.06944444444, saturation: 1, brightness: 1),
          .init(hue: 0.1111111111, saturation: 1, brightness: 1),
          .init(hue: 0.1305555556, saturation: 1, brightness: 0.99),
          .init(hue: 0.1638888889, saturation: 0.74, brightness: 1),
          .init(hue: 0.1833333333, saturation: 0.77, brightness: 0.93),
          .init(hue: 0.2611111111, saturation: 0.66, brightness: 0.73)],
         [.init(hue: 0.5361111111, saturation: 1, brightness: 0.99),
          .init(hue: 0.6, saturation: 0.77, brightness: 0.99),
          .init(hue: 0.7083333333, saturation: 0.8, brightness: 0.92),
          .init(hue: 0.7861111111, saturation: 0.77, brightness: 0.95),
          .init(hue: 0.9388888889, saturation: 0.74, brightness: 0.9),
          .init(hue: 0.01666666667, saturation: 0.69, brightness: 1),
          .init(hue: 0.05555555556, saturation: 0.72, brightness: 1),
          .init(hue: 0.1027777778, saturation: 0.75, brightness: 1),
          .init(hue: 0.1222222222, saturation: 0.76, brightness: 1),
          .init(hue: 0.1583333333, saturation: 0.58, brightness: 1),
          .init(hue: 0.1805555556, saturation: 0.58, brightness: 0.94),
          .init(hue: 0.2555555556, saturation: 0.55, brightness: 0.83)],
         [.init(hue: 0.5361111111, saturation: 0.67, brightness: 0.99),
          .init(hue: 0.6055555556, saturation: 0.55, brightness: 1),
          .init(hue: 0.7194444444, saturation: 0.69, brightness: 0.99),
          .init(hue: 0.7916666667, saturation: 0.66, brightness: 1),
          .init(hue: 0.9388888889, saturation: 0.53, brightness: 0.93),
          .init(hue: 0.01388888889, saturation: 0.49, brightness: 1),
          .init(hue: 0.05277777778, saturation: 0.51, brightness: 1),
          .init(hue: 0.1, saturation: 0.53, brightness: 1),
          .init(hue: 0.1222222222, saturation: 0.53, brightness: 1),
          .init(hue: 0.1583333333, saturation: 0.42, brightness: 1),
          .init(hue: 0.1805555556, saturation: 0.41, brightness: 0.95),
          .init(hue: 0.2555555556, saturation: 0.37, brightness: 0.87)],
         [.init(hue: 0.5388888889, saturation: 0.42, brightness: 0.99),
          .init(hue: 0.6083333333, saturation: 0.35, brightness: 1),
          .init(hue: 0.7194444444, saturation: 0.45, brightness: 1),
          .init(hue: 0.7888888889, saturation: 0.43, brightness: 1),
          .init(hue: 0.9416666667, saturation: 0.33, brightness: 0.96),
          .init(hue: 0.01111111111, saturation: 0.31, brightness: 1),
          .init(hue: 0.05277777778, saturation: 0.33, brightness: 1),
          .init(hue: 0.09444444444, saturation: 0.34, brightness: 1),
          .init(hue: 0.1166666667, saturation: 0.34, brightness: 0.99),
          .init(hue: 0.1583333333, saturation: 0.27, brightness: 1),
          .init(hue: 0.1833333333, saturation: 0.26, brightness: 0.97),
          .init(hue: 0.2555555556, saturation: 0.22, brightness: 0.91)],
         [.init(hue: 0.5472222222, saturation: 0.2, brightness: 1),
          .init(hue: 0.6055555556, saturation: 0.17, brightness: 1),
          .init(hue: 0.7138888889, saturation: 0.21, brightness: 1),
          .init(hue: 0.7861111111, saturation: 0.2, brightness: 1),
          .init(hue: 0.9416666667, saturation: 0.15, brightness: 0.98),
          .init(hue: 0.008333333333, saturation: 0.15, brightness: 1),
          .init(hue: 0.05, saturation: 0.16, brightness: 1),
          .init(hue: 0.09444444444, saturation: 0.17, brightness: 1),
          .init(hue: 0.1138888889, saturation: 0.16, brightness: 1),
          .init(hue: 0.1555555556, saturation: 0.13, brightness: 0.99),
          .init(hue: 0.1888888889, saturation: 0.12, brightness: 0.98),
          .init(hue: 0.2694444444, saturation: 0.11, brightness: 0.93)]]
    }
}
