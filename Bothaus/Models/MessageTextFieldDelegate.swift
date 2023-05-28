//
//  MessageTextFieldDelegate.swift
//  Bothaus
//
//  Created by kasima on 5/28/23.
//

import Foundation
import UIKit

class MessageTextFieldDelegate: NSObject, UITextFieldDelegate {
    var onShouldReturn: (() -> Void)?

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onShouldReturn?()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // perform your UITextFieldDelegate methods here
        return true
    }
}
