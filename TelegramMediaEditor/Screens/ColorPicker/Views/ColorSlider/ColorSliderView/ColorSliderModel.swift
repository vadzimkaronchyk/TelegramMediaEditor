//
//  ColorSliderModel.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

import UIKit

struct ColorSliderModel {
    
    let progressToColor: (HSBColor, Progress) -> HSBColor
    let colorToProgress: (HSBColor) -> Progress
    let sliderColors: (HSBColor) -> (CGColor, CGColor)
}

extension ColorSliderModel {
    
    static var red: Self {
        .init(
            progressToColor: { color, progress in
                var rgb = color.rgb
                rgb.red = progress.value
                return rgb.hsb
            },
            colorToProgress: { hsb in
                Progress(hsb.uiColor.rgbColor.red)
            },
            sliderColors: { hsb in
                let rgb = hsb.uiColor.rgbColor
                return (
                    CGColor(red: 0, green: rgb.green, blue: rgb.blue, alpha: 1),
                    CGColor(red: 1, green: rgb.green, blue: rgb.blue, alpha: 1)
                )
            }
        )
    }
    
    static var green: Self {
        .init(
            progressToColor: { color, progress in
                var rgb = color.rgb
                rgb.green = progress.value
                return rgb.hsb
            },
            colorToProgress: { hsb in
                Progress(hsb.uiColor.rgbColor.green)
            },
            sliderColors: { hsb in
                let rgb = hsb.uiColor.rgbColor
                return (
                    CGColor(red: rgb.red, green: 0, blue: rgb.blue, alpha: 1),
                    CGColor(red: rgb.red, green: 1, blue: rgb.blue, alpha: 1)
                )
            }
        )
    }
    
    static var blue: Self {
        .init(
            progressToColor: { color, progress in
                var rgb = color.rgb
                rgb.blue = progress.value
                return rgb.hsb
            },
            colorToProgress: { hsb in
                Progress(hsb.rgb.blue)
            },
            sliderColors: { hsb in
                let rgb = hsb.uiColor.rgbColor
                return (
                    CGColor(red: rgb.red, green: rgb.green, blue: 0, alpha: 1),
                    CGColor(red: rgb.red, green: rgb.green, blue: 1, alpha: 1)
                )
            }
        )
    }
    
    static var alpha: Self {
        .init(
            progressToColor: { color, progress in
                var color = color
                color.alpha = progress.value
                return color
            },
            colorToProgress: { hsb in
                Progress(hsb.alpha)
            },
            sliderColors: { hsb in
                var color1 = hsb
                color1.alpha = 0
                var color2 = hsb
                color2.alpha = 1
                return (color1.cgColor, color2.cgColor)
            }
        )
    }
}
