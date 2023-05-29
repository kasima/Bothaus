//
//  KeyboardEntryView.swift
//  DreamsAI21
//
//  Created by kasima on 5/24/23.
//

import SwiftUI
import FirebaseAnalytics

struct KeyboardEntryView: View {
    @EnvironmentObject var chatModel: ChatModel
    @Binding var keyboardEntry: Bool

    @State private var text: String
    @FocusState private var textFieldFocused: Bool

    init(keyboardEntry: Binding<Bool>, initialText: String = "") {
        self._keyboardEntry = keyboardEntry
        self.text = initialText
    }

    var body: some View {
        HStack {
            TextField("What do you want to see?", text: $text, axis: .vertical)
                .lineLimit(3)
                .textFieldStyle(.roundedBorder)
                .focused($textFieldFocused)
                .padding(.leading)
                .padding(.bottom, 5)
                .disabled(!keyboardEntry)

            if chatModel.chatState == .waitingForResponse {
                ProgressView()
                    .padding(.trailing)
                    .padding(.leading, 3)
            } else {
                if text.isEmpty {
                    Button(action: {
                        keyboardEntry = false
                    }, label: {
                        Image(systemName: "waveform")
                    })
                    .font(.title2)
                    .padding(.trailing)
                } else {
                    Button(action: {
                        sendMessage()
                    }, label: {
                        Image(systemName: "arrow.up.circle.fill")
                    })
                    .font(.title2)
                    .padding(.trailing)
                }
            }
        }
        .padding(.top, 5)
        .background(Color.black.opacity(0.3))
        .onAppear {
            textFieldFocused = true
        }
    }

    private func sendMessage() {
        textFieldFocused = true
        if (!text.isEmpty && chatModel.chatState == .standby) {
            Analytics.logEvent("generate_from_keyboard", parameters: nil)
            chatModel.generateChatResponse(from: text)
            text = ""
        }
    }
}
struct KeyboardEntryView_Previews: PreviewProvider {
    @State static var keyboardEntry: Bool = true

    static var previews: some View {
        Group {
            KeyboardEntryView(keyboardEntry: $keyboardEntry)
                .environmentObject(ChatModel(bot: Bot()))
            KeyboardEntryView(keyboardEntry: $keyboardEntry, initialText: "Are you alive?")
                .environmentObject(ChatModel(bot: Bot()))
            KeyboardEntryView(keyboardEntry: $keyboardEntry)
                .environmentObject(ChatModel(bot: Bot(), chatState: .waitingForResponse))
        }
    }
}
