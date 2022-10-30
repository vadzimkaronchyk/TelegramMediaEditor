//
//  EyeDropperColorPickerWindow.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 23.10.22.
//

import UIKit

final class EyeDropperColorPickerWindow: UIWindow {
    
    private let colorReticleView = ColorReticleView()
    
    var onColorSelected: Closure<HSBColor>?
    
    private var selectedColor: HSBColor = .white
    
    private let bottomWindow: UIWindow
    
    init(
        windowScene: UIWindowScene,
        bottomWindow: UIWindow,
        initialLocation: CGPoint?
    ) {
        self.bottomWindow = bottomWindow
        super.init(windowScene: windowScene)
        
        addSubview(colorReticleView)
        addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handleWindowTapGesture)
        ))
        
        colorReticleView.frame.size = .square(size: 146)
        
        if let initialLocation = initialLocation {
            updateColorReticleViewLocation(initialLocation)
        } else {
            updateColorReticleViewLocation(center)
        }
        
        colorReticleView.addGestureRecognizer(UIPanGestureRecognizer(
            target: self,
            action: #selector(handleColorReticleViewPanGesture)
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRedirectedTouches(touches), let touch = touches.first {
            let location = touch.location(in: self)
            updateColorReticleViewLocation(location)
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRedirectedTouches(touches), let touch = touches.first {
            let location = touch.location(in: self)
            updateColorReticleViewLocation(location)
        } else {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRedirectedTouches(touches) {
            onColorSelected?(selectedColor)
        } else {
            super.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isRedirectedTouches(touches) {
            onColorSelected?(selectedColor)
        } else {
            super.touchesCancelled(touches, with: event)
        }
    }
    
    private func isRedirectedTouches(_ touches: Set<UITouch>) -> Bool {
        guard let touch = touches.first else { return false }
        return touch.view == nil && touch.gestureRecognizers?.isEmpty != false
    }
}

private extension EyeDropperColorPickerWindow {
    
    @objc func handleWindowTapGesture(_ gestureRecognzer: UITapGestureRecognizer) {
        onColorSelected?(selectedColor)
    }
    
    @objc func handleColorReticleViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let center = colorReticleView.center
            updateColorReticleViewLocation(.init(
                x: center.x + translation.x,
                y: center.y + translation.y
            ))
            gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
        case .ended, .failed, .cancelled:
            onColorSelected?(selectedColor)
        default:
            break
        }
    }
    
    @objc func handleInitialGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            updateColorReticleViewLocation(gestureRecognizer.location(in: self))
        case .ended, .cancelled, .failed:
            onColorSelected?(selectedColor)
            colorReticleView.removeGestureRecognizer(gestureRecognizer)
        default:
            break
        }
    }
    
    func updateColorReticleViewLocation(_ location: CGPoint) {
        colorReticleView.center = location
        
        let width = 9
        let context = CGContext(
            data: nil,
            width: width,
            height: width,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )!
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        context.translateBy(x: -location.x, y: -location.y)
        bottomWindow.layer.render(in: context)
        
        struct Pixel {
            let r, g, b, a: UInt8
        }
        guard let data = context.data else { return }
        
        let centerColor = data.load(
            fromByteOffset: MemoryLayout<Pixel>.size * 40,
            as: Pixel.self
        )
        
        guard let cgImage = context.makeImage() else { return }
        
        let color = UIColor(
            red: Double(centerColor.r) / 255,
            green: Double(centerColor.g) / 255,
            blue: Double(centerColor.b) / 255,
            alpha: Double(centerColor.a) / 255
        ).hsbColor
        selectedColor = color
        colorReticleView.color = color
        colorReticleView.image = .init(
            cgImage: cgImage,
            scale: 1,
            orientation: .downMirrored
        )
    }
}
