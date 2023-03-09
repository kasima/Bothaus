//
//  ContentView.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            Text("Prompt: \(appModel.promptText)")
                .padding()

            Spacer()

            Text("Response: \(appModel.responseText)")
                .padding()

            Spacer()

            ChatButton(state: appModel.chatState, appModel: appModel)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel())
    }
}
