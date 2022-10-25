//
//  StrokeShape.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

enum StrokeShape: CaseIterable {
    case round
    case arrow
}

extension StrokeShape: MenuPopoverItem {
    
    var title: String {
        switch self {
        case .round: return "Round"
        case .arrow: return "Arrow"
        }
    }
    
    var imageName: String {
        switch self {
        case .round: return "roundTip"
        case .arrow: return "arrowTip"
        }
    }
}
