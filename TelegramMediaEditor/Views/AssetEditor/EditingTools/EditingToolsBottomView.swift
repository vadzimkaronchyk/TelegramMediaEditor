//
//  EditingToolsBottomView.swift
//  TelegramMediaEditor
//
//  Created by Vadzim Karonchyk on 10/27/22.
//

import UIKit

final class EditingToolsBottomView: UIView {
    
    private let bottomControlsView = BottomControlsView()
    private let bottomToolSettingsView = BottomToolSettingsView()
    
    var onDrawingToolSelected: VoidClosure?
    var onTextToolSelected: VoidClosure?
    var onCancelTapped: VoidClosure?
    var onSaveTapped: VoidClosure?
    var onBackTapped: VoidClosure?
    var onStrokeSizeChanged: Closure<Progress>?
    var onStrokeShapeTapped: Closure<UIView>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupViews()
        setupState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateStrokeShape(_ strokeShape: StrokeShape) {
        bottomToolSettingsView.updateStrokeShape(strokeShape)
    }
    
    func setSaveButtonEnabled(_ enabled: Bool) {
        bottomControlsView.setSaveButtonEnabled(enabled)
    }
    
    func setLoadingActive(_ active: Bool) {
        bottomControlsView.setLoadingActive(active)
    }
    
    func showBottomControlsView() {
        bottomControlsView.isHidden = false
        bottomControlsView.transform = .init(translationX: 0, y: bottomControlsView.frame.height)
        bottomToolSettingsView.isHidden = false
        bottomToolSettingsView.transform = .identity
        
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 0.25
                ) {
                    self.bottomToolSettingsView.transform = .init(
                        translationX: -self.bottomToolSettingsView.frame.width,
                        y: 0
                    )
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1
                ) {
                    self.bottomControlsView.transform = .identity
                }
            },
            completion: { _ in
                self.bottomToolSettingsView.isHidden = true
                self.bottomControlsView.isHidden = false
            }
        )
    }
    
    func showBottomToolSettingsView() {
        bottomControlsView.isHidden = false
        bottomControlsView.transform = .identity
        bottomToolSettingsView.isHidden = false
        bottomToolSettingsView.transform = .init(
            translationX: -self.bottomToolSettingsView.frame.width,
            y: 0
        )
        
        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: 0,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 0.25
                ) {
                    self.bottomControlsView.transform = .init(
                        translationX: 0,
                        y: self.bottomControlsView.frame.height
                    )
                }
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1
                ) {
                    self.bottomToolSettingsView.transform = .identity
                }
            },
            completion: { _ in
                self.bottomControlsView.isHidden = true
                self.bottomToolSettingsView.isHidden = false
            }
        )
    }
}

private extension EditingToolsBottomView {
    
    func setupLayout() {
        addSubview(bottomControlsView)
        addSubview(bottomToolSettingsView)
        
        bottomControlsView.translatesAutoresizingMaskIntoConstraints = false
        bottomToolSettingsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomControlsView.topAnchor.constraint(equalTo: topAnchor),
            bottomControlsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            bottomControlsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            bottomControlsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomToolSettingsView.topAnchor.constraint(equalTo: topAnchor),
            bottomToolSettingsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            bottomToolSettingsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            bottomToolSettingsView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setupViews() {
        setupView()
        setupBottomControlsView()
        setupBottomToolSettingsView()
    }
    
    func setupView() {
        clipsToBounds = true
    }
    
    func setupBottomControlsView() {
        bottomControlsView.onDrawingToolSelected = { [weak self] in
            self?.onDrawingToolSelected?()
        }
        bottomControlsView.onTextToolSelected = { [weak self] in
            self?.onTextToolSelected?()
        }
        bottomControlsView.onCancelTapped = { [weak self] in
            self?.onCancelTapped?()
        }
        bottomControlsView.onSaveTapped = { [weak self] in
            self?.onSaveTapped?()
        }
    }
    
    func setupBottomToolSettingsView() {
        bottomToolSettingsView.onBackTapped = { [weak self] in
            self?.onBackTapped?()
            self?.showBottomControlsView()
        }
        bottomToolSettingsView.onStrokeSizeChanged = { [weak self] value in
            self?.onStrokeSizeChanged?(value)
        }
        bottomToolSettingsView.onStrokeShapeTapped = { [weak self] view in
            self?.onStrokeShapeTapped?(view)
        }
    }
    
    func setupState() {
        bottomControlsView.isHidden = false
        bottomToolSettingsView.isHidden = true
    }
}
