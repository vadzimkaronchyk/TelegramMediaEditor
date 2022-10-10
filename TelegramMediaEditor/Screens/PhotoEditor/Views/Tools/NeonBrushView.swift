//
//  NeonBrushView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class NeonBrushView: DrawingToolView {
    
    init() {
        super.init(imageName: "neon")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
