//
//  SpeechEntryView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

struct SpeechEntryView: View {
    var state: ChatState

    @EnvironmentObject var talkModel: TalkModel

    var body: some View {
        Button(action: {
            switch state {
            case .standby:
                talkModel.startRecording()
            case .listening:
                talkModel.stopRecording()
            case .waitingForResponse:
                print("Should be something else in here")
            case .speaking:
                talkModel.stopSpeaking()
            }
        }, label: {
            VStack {
                switch state {
                case .standby:
                    Image(systemName: "mic")
                        .font(.title)
                        .padding(.bottom, 1)
                case .listening:
                    Image(systemName: "mic.slash")
                        .font(.title)
                        .padding(.bottom, 1)
                case .waitingForResponse:
                    ProgressView()
                case .speaking:
                    Image(systemName: "speaker.slash")
                        .font(.title)
                        .padding(.bottom, 1)
                }
            }
        })
        .disabled(state == .waitingForResponse)
        .padding(20)
        .frame(width: 100, height: 100)
        .background(backgroundColor())
        .foregroundColor(.white)
        .cornerRadius(radius())
    }

    func backgroundColor() -> Color {
        switch state {
        case .listening:
            return Color.red
        case .waitingForResponse:
            return Color.gray
        case .speaking:
            return Color(UIColor(red: 117/255, green: 169/255, blue: 156/255, alpha: 1.0))
        default:
            return Color.blue
        }
    }

    func radius() -> CGFloat {
        switch state {
        case .speaking:
            return 10
        default:
            return 50
        }
    }
}

struct SpeechEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpeechEntryView(state: .standby)
            SpeechEntryView(state: .listening)
            SpeechEntryView(state: .waitingForResponse)
            SpeechEntryView(state: .speaking)
        }
        .environmentObject(TalkModel(bot: Bot()))
        .previewLayout(.fixed(width:300, height: 100))
    }
}
