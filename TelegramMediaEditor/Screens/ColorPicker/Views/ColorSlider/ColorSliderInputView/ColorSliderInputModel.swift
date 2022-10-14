//
//  ColorSliderInputModel.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

struct ColorSliderInputModel {
    
    let sliderModel: ColorSliderModel
    let textFieldModel: ColorSliderTextFieldModel
}

extension ColorSliderInputModel {
    
    static var red: Self {
        .init(sliderModel: .red, textFieldModel: .rgb)
    }
    
    static var green: Self {
        .init(sliderModel: .green, textFieldModel: .rgb)
    }
    
    static var blue: Self {
        .init(sliderModel: .blue, textFieldModel: .rgb)
    }
    
    static var alpha: Self {
        .init(sliderModel: .alpha, textFieldModel: .alpha)
    }
}
