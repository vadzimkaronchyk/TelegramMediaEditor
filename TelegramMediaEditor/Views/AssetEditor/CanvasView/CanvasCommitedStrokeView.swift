//
//  CanvasCommitedStrokeView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/30/22.
//

import UIKit

final class CanvasCommitedStrokeView: UIView {
    
    private let line: Line
    
    init(line: Line) {
        self.line = line
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        line.drawInContext(context)
    }
}
