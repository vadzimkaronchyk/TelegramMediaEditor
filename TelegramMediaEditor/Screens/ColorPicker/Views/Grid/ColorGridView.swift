//
//  ColorGridView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/14/22.
//

import UIKit

final class ColorGridView: UIControl {
    
    private let gridColors = HSBColor.gridColors()
    
    var tileSize: CGFloat {
        tileSize(rect: bounds)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let maskPath = UIBezierPath(roundedRect: rect, cornerRadius: 8).cgPath
        context.addPath(maskPath)
        context.clip()
        
        let tileSize = tileSize(rect: rect)
        for (rowIndex, rowColors) in gridColors.enumerated() {
            for (columnIndex, color) in rowColors.enumerated() {
                let rect = CGRect(
                    x: tileSize * Double(columnIndex),
                    y: tileSize * Double(rowIndex),
                    width: tileSize,
                    height: tileSize
                )
                context.setFillColor(color.cgColor)
                context.fill(rect)
            }
        }
    }
    
    func color(atLocation location: CGPoint) -> HSBColor {
        let row = Int(Double(gridColors.count) * (location.y/bounds.maxY)).clamped(
            minValue: 0,
            maxValue: gridColors.count-1
        )
        let columns = gridColors[row].count
        let column = Int(Double(columns) * (location.x/bounds.maxX)).clamped(
            minValue: 0,
            maxValue: columns-1
        )
        return gridColors[row][column]
    }
    
    func location(forColor color: HSBColor) -> CGPoint? {
        for (rowIndex, row) in gridColors.enumerated() {
            for (columnIndex, column) in row.enumerated() where column == color {
                let tileSize = tileSize
                let x = tileSize * Double(columnIndex)
                let y = tileSize * Double(rowIndex)
                return .init(x: x, y: y)
            }
        }
        return nil
    }
    
    private func tileSize(rect: CGRect) -> CGFloat {
        guard let row = gridColors.first else { return 1 }
        return rect.width/Double(row.count)
    }
}
