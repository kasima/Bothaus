//
//  ChatView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI
import OpenAIKit

struct ChatView: View {
    var messages: [Message]
    
    @EnvironmentObject var talkModel: TalkModel

    init(messages: [Message]) {
        self.messages = messages
        UITableView.appearance().separatorStyle = .none
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(messages, id: \.id) { message in
                        MessageView(message: message)
                            .id(message.id)
                    }
                }
                .onChange(of: messages.count) { newCount in
                    // This closure holds the old state of messages, even though newCount is correct, so we need to go back to the model
                    // TODO - Make messages conform to Equatable so that onChange can be used with messages instead of messages.count
                    withAnimation {
                        proxy.scrollTo(talkModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(messages: [
            Message(id: 1, role: "user", content: "Hey you"),
            Message(id: 2, role: "assistant", content: "Who me?"),
            Message(id: 3, role: "user", content: "Yeah you"),
            Message(id: 4, role: "assistant", content: "Get into my car! Awwwwwwwww yeah. Get out of my dreams. Get into my car. Beep beep, yeah.")

        ])
    }
}
