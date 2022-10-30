//
//  ColorSliderTextFieldModel.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

struct ColorSliderTextFieldModel {
    
    let isCursorMovesToEnd: () -> Bool
    let formattedText: (String) -> String
    let textToProgress: ((String) -> Progress)
    let progressToText: ((Progress) -> String)
}

extension ColorSliderTextFieldModel {
    
    static var rgb: Self {
        .init(
            isCursorMovesToEnd: { true },
            formattedText: { text in
                guard let value = Int(text) else { return "0" }
                let formattedValue = value.clamped(minValue: 0, maxValue: 255)
                return "\(formattedValue)"
            },
            textToProgress: { text in
                guard let value = Double(text) else { return .min }
                return .init(value / 255)
            },
            progressToText: { progress in
                let value = progress.value * 255
                return "\(Int(value))"
            }
        )
    }
    
    static var alpha: Self {
        .init(
            isCursorMovesToEnd: { false },
            formattedText: { text in
                var text = text
                if text.last == "%" {
                    text.removeLast()
                }
                
                guard let value = Int(text) else { return "0%" }
                
                let formattedValue = value.clamped(minValue: 0, maxValue: 100)
                return "\(formattedValue)%"
            },
            textToProgress: { text in
                var text = text
                if text.last == "%" {
                    text.removeLast()
                }
                
                guard let value = Double(text) else { return .min }
                return .init(value / 100)
            },
            progressToText: { progress in
                let value = progress.value * 100
                return "\(Int(value))%"
            }
        )
    }
}
