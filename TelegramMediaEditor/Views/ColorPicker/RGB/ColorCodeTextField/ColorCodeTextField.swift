//
//  ColorCodeTextField.swift
//  TelegramMediaEditor
//
//  Created by Vadim Koronchik on 20.10.22.
//

import UIKit

final class ColorCodeTextField: PaddedTextField {

    var color: HSBColor {
        get { model.textToColor(text ?? "") }
        set { text = model.colorToText(newValue) }
    }
    
    var onColorChanged: Closure<HSBColor>?
    
    private let model: ColorCodeTextFieldModel
    
    init(model: ColorCodeTextFieldModel) {
        self.model = model
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ColorCodeTextField {
    
    func setupView() {
        delegate = self
        textColor = .white
        font = .systemFont(ofSize: 17, weight: .semibold)
        backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.5)
        keyboardType = .asciiCapable
        returnKeyType = .done
        textAlignment = .center
        borderStyle = .roundedRect
        addTarget(self, action: #selector(handleValueTextFieldChanged), for: .editingChanged)
    }
    
    @objc func handleValueTextFieldChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        let color = model.textToColor(text)
        onColorChanged?(color)
    }
}

extension ColorCodeTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        textField.text = model.formattedText(textField.text ?? "")
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let newText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return model.shouldChangeText(newText)
    }
}
