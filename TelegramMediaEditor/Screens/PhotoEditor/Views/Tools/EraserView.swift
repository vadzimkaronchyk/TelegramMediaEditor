//
//  EraserView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class EraserView: DrawingToolView {
    
    init() {
        super.init(imageName: "eraser")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
