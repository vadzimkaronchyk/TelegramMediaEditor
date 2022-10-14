//
//  ComparableExtensions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 19.10.22.
//

extension Comparable {
    
    func clamped(minValue: Self, maxValue: Self) -> Self {
        min(max(self, minValue), maxValue)
    }
}
