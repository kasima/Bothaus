//
//  ContentView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI
import OpenAIKit

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            ZStack {
                ChatView(messages: appModel.messages)
                    .environmentObject(appModel)

                if (appModel.chatState == .listening && appModel.promptText != "") {
                    VStack {
                        Spacer()
                        Text(appModel.promptText)
                            .font(.title)
                            .padding()
                            .frame(maxWidth: .infinity)
                            // .background(Color(UIColor.systemGray5).opacity(0.8))
                            .background(.ultraThinMaterial)
                            .foregroundColor(Color(UIColor.label))
                    }
                }
            }

            ChatButton(state: appModel.chatState, appModel: appModel)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
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

        ContentView()
            .environmentObject(appModel)
    }
}
