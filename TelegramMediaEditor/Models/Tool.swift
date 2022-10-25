//
//  Tool.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

enum Tool {
    
    enum Drawing {
        case pen
        case brush
        case neonBrush
        case pencil
        case lasso
        case eraser
    }
    
    case drawing(Drawing)
    case text
}
