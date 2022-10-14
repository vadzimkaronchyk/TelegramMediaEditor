//
//  TimingFunctions.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 21.10.22.
//

import Darwin

func easeInOutSine(x: Double) -> Double {
    1 + (cos(.pi * x) - 1) / 2
}

func reversingEaseInOutSine(x: Double) -> Double {
    1 - acos(1 - 2*x) / .pi
}
