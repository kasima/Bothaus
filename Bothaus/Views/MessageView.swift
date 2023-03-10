//
//  MessageView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI
import OpenAIKit

struct MessageFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .cornerRadius(10)
    }
}

struct MessageView: View {
    var message: Message

    var body: some View {
        HStack {
            if (message.role == "user") {
                Spacer()
                Text("\(message.id): \(message.content)")
                    .modifier(MessageFormat())
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            } else {
                Text("\(message.id): \(message.content)")
                    .modifier(MessageFormat())
                    .foregroundColor(Color.white)
                    .background(Color(UIColor(red: 117/255, green: 169/255, blue: 156/255, alpha: 1.0)))
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding()
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageView(message: Message(id: 1, role: "user", content: "Hey bot, tell me a nice little story."))
            MessageView(message: Message(id: 2, role: "assistant", content: "I told my wife she was drawing her eyebrows too high. She looked surprised.")
            )
        }
    }
}
