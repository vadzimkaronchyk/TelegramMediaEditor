//
//  PenVIew.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class PenView: DrawingToolView {
    
    init() {
        super.init(imageName: "pen")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
