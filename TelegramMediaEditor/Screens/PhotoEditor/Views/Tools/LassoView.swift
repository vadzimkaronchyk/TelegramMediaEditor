//
//  LassoView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/10/22.
//

import UIKit

final class LassoView: DrawingToolView {
    
    init() {
        super.init(imageName: "lasso")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
