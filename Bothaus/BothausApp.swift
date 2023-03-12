//
//  BothausApp.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

@main
struct BothausApp: App {
    @StateObject var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .onAppear() {
                    appModel.loaded()
                    // appModel.voiceTest()
                }
        }
    }
}
