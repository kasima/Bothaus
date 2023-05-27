//
//  KeyboardEntryView.swift
//  DreamsAI21
//
//  Created by kasima on 5/24/23.
//

import SwiftUI
import FirebaseAnalytics

struct KeyboardEntryView: View {
    @EnvironmentObject var appModel: AppModel
    @Binding var keyboardEntry: Bool

    @State private var text: String = ""
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        HStack {
            TextField("What do you want to see?", text: $text, onCommit: {
                sendMessage()
            })
                .textFieldStyle(.roundedBorder)
                .padding(.leading)
                .padding(.bottom, 5)
                .focused($textFieldFocused)
                .disabled(appModel.chatState == .waitingForResponse || !keyboardEntry)

            if appModel.chatState == .waitingForResponse {
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
                    .padding(.trailing)
                } else {
                    Button(action: {
                        sendMessage()
                    }, label: {
                        Image(systemName: "paperplane.fill")
                    })
                    .foregroundColor(.white)
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
        if !text.isEmpty {
            Analytics.logEvent("generate_from_keyboard", parameters: nil)
            appModel.generateChatResponse(from: text)
        }
    }
}
struct KeyboardEntryView_Previews: PreviewProvider {
    @State static var keyboardEntry: Bool = true

    static var previews: some View {
        Group {
            KeyboardEntryView(keyboardEntry: $keyboardEntry)
                .environmentObject(AppModel(bot: Bot()))
            KeyboardEntryView(keyboardEntry: $keyboardEntry)
                .environmentObject(AppModel(bot: Bot(), chatState: .waitingForResponse))
        }
    }
}
