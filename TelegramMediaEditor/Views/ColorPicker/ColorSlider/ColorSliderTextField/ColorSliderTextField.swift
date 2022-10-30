//
//  ColorSliderTextField.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

import UIKit

final class ColorSliderTextField: UITextField {
    
    var progress: Progress {
        get { model.textToProgress(text ?? "") }
        set { text = model.progressToText(newValue) }
    }
    
    var onProgressChanged: Closure<Progress>?
    
    private let model: ColorSliderTextFieldModel
    
    init(model: ColorSliderTextFieldModel) {
        self.model = model
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        guard !model.isCursorMovesToEnd() else { return super.caretRect(for: position) }
        
        if position == self.position(from: endOfDocument, offset: 0),
           let newPosition = self.position(from: endOfDocument, offset: -1) {
            selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            return super.caretRect(for: newPosition)
        } else {
            return super.caretRect(for: position)
        }
    }
}

private extension ColorSliderTextField {
    
    func setupView() {
        setupTextField()
        setupToolbar()
    }
    
    func setupTextField() {
        textColor = .white
        font = .systemFont(ofSize: 17, weight: .semibold)
        backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        keyboardType = .asciiCapableNumberPad
        textAlignment = .center
        borderStyle = .roundedRect
        addTarget(self, action: #selector(handleValueTextFieldChanged), for: .editingChanged)
    }
    
    func setupToolbar() {
        let toolbar = UIToolbar()
        let flexibleBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneBarButtonItemTapped)
        )
        toolbar.setItems([flexibleBarButtonItem, doneBarButtonItem], animated: false)
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
    
    @objc func handleValueTextFieldChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        let formattedText = model.formattedText(text)
        
        if text != formattedText {
            textField.text = formattedText
        }
        
        let progress = model.textToProgress(formattedText)
        onProgressChanged?(progress)
    }
    
    @objc func doneBarButtonItemTapped(_ barButtonItem: UIBarButtonItem) {
        endEditing(false)
    }
}
