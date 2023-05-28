//
//  MessageTextField.swift
//  Bothaus
//
//  Created by kasima on 5/28/23.
//

import SwiftUI
import UIKit

struct MessageTextField: UIViewRepresentable {
    @Binding var text: String
    let textFieldDelegate: UITextFieldDelegate

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
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
