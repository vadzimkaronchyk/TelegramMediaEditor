//
//  Progress.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

struct Progress {
    
    let value: Double
    
    static var min: Self { .init(0) }
    static var mid: Self { .init(0.5) }
    static var max: Self { .init(1) }
    
    init(_ value: Double) {
        self.value = value.clamped(minValue: 0, maxValue: 1)
    }
    
    init(value: Double, min: Double, max: Double) {
        self.init((value - min)/(max - min))
    }
    
    func value(min: Double, max: Double) -> Double {
        min + (max - min)*value
    }
}
