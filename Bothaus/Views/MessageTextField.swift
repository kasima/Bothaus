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
    @Binding var focused: Bool
    var onCommit: (() -> Void)?

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var focused: Bool
        var onCommit: (() -> Void)?

        init(text: Binding<String>, focused: Binding<Bool>, onCommit: (() -> Void)? = nil) {
            _text = text
            _focused = focused
            self.onCommit = onCommit
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit?()
            return true
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // perform your UITextFieldDelegate methods here
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, focused: $focused, onCommit: onCommit)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .roundedRect
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if focused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !focused && uiView.isFirstResponder {
            UIView.setAnimationsEnabled(false)
            uiView.resignFirstResponder()
            UIView.setAnimationsEnabled(true)
        }
    }
}

struct MessageTextField_Previews: PreviewProvider {
    @State static var text: String = "some text"
    @State static var focused: Bool = true

    static var previews: some View {
        MessageTextField(text: $text, focused: $focused, onCommit: {})
            .frame(maxHeight: 40)
    }
}
