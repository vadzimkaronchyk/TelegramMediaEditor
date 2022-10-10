//
//  PencilView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class PencilView: DrawingToolView {
    
    init() {
        super.init(imageName: "pencil")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
