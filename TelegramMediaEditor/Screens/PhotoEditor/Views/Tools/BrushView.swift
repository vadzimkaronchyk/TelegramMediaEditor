//
//  BrushView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class BrushView: DrawingToolView {
    
    init() {
        super.init(imageName: "brush")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
