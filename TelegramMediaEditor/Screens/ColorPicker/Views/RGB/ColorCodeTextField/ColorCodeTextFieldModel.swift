//
//  ColorCodeTextFieldModel.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

import UIKit

struct ColorCodeTextFieldModel {
    
    let formattedText: (String) -> String
    let shouldChangeText: (String) -> Bool
    let colorToText: (HSBColor) -> String
    let textToColor: (String) -> HSBColor
}

extension ColorCodeTextFieldModel {
    
    static var hex: Self {
        .init(
            formattedText: { text in
                text.padding(toLength: 6, withPad: "0", startingAt: 0).uppercased()
            },
            shouldChangeText: { text in
                let validCharacters: Set<Character> = [
                    "0", "1", "2", "3", "4", "5",
                    "6", "7", "8", "9", "a",
                    "b", "c", "d", "e", "f"
                ]
                let maxCount = 6
                return text.count <= maxCount && validCharacters.isSuperset(of: text.lowercased())
                
            },
            colorToText: { color in
                color.uiColor.hexString.uppercased()
            },
            textToColor: { hex in
                let hex = hex.padding(toLength: 6, withPad: "0", startingAt: 0).lowercased()
                let uiColor = UIColor(hex: hex) ?? .black
                return uiColor.hsbColor
            }
        )
    }
}
