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
            ChatView(messages: appModel.messages)
                .environmentObject(appModel)

            Spacer()

            Text(appModel.promptText)
               .font(.title)
               .padding()

           ChatButton(state: appModel.chatState, appModel: appModel)
               .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(
            promptText: "This is the prompt",
            messages: [
                Message(id: 1, role: "user", content: "Hey you"),
                Message(id: 2, role: "assistant", content: "Who me?")
            ]
        )

        ContentView()
            .environmentObject(appModel)
    }
}
