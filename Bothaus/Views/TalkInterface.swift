//
//  TalkInterface.swift
//  Bothaus
//
//  Created by kasima on 3/14/23.
//

import SwiftUI

struct TalkInterface: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            ZStack {
                ChatView(messages: appModel.messages)

                if (appModel.chatState == .listening && appModel.promptText != "") {
                    VStack {
                        Spacer()
                        Text(appModel.promptText)
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color(UIColor.label))
                    }
                }
            }

            ZStack {
                ChatButton(state: appModel.chatState)
                    .padding()

                HStack {
                    Spacer()
                    Button("Clear") {
                        appModel.clearMessages()
                    }
                    .font(.title2)
                    .padding()
                    .frame(width: (UIScreen.main.bounds.width-100) / 2)
                }
            }
        }
    }
}

struct TalkInterface_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(
            chatState: .listening,
            promptText: "This is the prompt",
            messages: [
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?"),
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?"),
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?"),
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?")
            ]
        )

        TalkInterface()
            .environmentObject(appModel)
    }
}
