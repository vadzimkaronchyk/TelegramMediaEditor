//
//  AppWindow.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 24.10.22.
//

import UIKit

final class AppWindow: UIWindow {
    
    weak var receivingTouchesWindow: UIWindow?
    
    override func sendEvent(_ event: UIEvent) {
        guard
            let receivingTouchesWindow = receivingTouchesWindow,
            let touches = event.allTouches,
            let touch = touches.first
        else {
            super.sendEvent(event)
            return
        }
        
        switch touch.phase {
        case .began:
            receivingTouchesWindow.touchesBegan(touches, with: event)
        case .moved:
            receivingTouchesWindow.touchesMoved(touches, with: event)
        case .ended:
            receivingTouchesWindow.touchesEnded(touches, with: event)
        case .cancelled:
            receivingTouchesWindow.touchesCancelled(touches, with: event)
        default:
            break
        }
    }
}
