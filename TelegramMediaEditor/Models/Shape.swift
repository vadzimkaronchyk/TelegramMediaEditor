//
//  Shape.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

enum Shape: CaseIterable {
    case rectangle
    case ellipse
    case bubble
    case star
    case arrow
}

extension Shape: MenuPopoverItem {
    
    var title: String {
        switch self {
        case .rectangle: return "Rectangle"
        case .ellipse: return "Ellipse"
        case .bubble: return "Bubble"
        case .star: return "Star"
        case .arrow: return "Arrow"
        }
    }
    
    var imageName: String {
        switch self {
        case .rectangle: return "shapeRectangle"
        case .ellipse: return "shapeEllipse"
        case .bubble: return "shapeBubble"
        case .star: return "shapeStar"
        case .arrow: return "shapeArrow"
        }
    }
}
