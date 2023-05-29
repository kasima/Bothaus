//
//  MessageTextField.swift
//  Bothaus
//
//  Created by kasima on 5/28/23.
//

import SwiftUI
import UIKit

class StyledTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.borderStyle = .roundedRect
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        self.leftViewMode = .always
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        self.rightViewMode = .always
        self.clearButtonMode = .whileEditing
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct MessageTextField: UIViewRepresentable {
    @Binding var text: String
    let textFieldDelegate: UITextFieldDelegate

    func makeUIView(context: Context) -> UITextField {
        let textField = StyledTextField(frame: .zero)

        textField.delegate = textFieldDelegate
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}

struct MessageTextField_Previews: PreviewProvider {
    @State static var text: String = "some text"

    static var previews: some View {
        MessageTextField(text: $text, textFieldDelegate: MessageTextFieldDelegate())
    }
}
