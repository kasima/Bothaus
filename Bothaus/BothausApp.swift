//
//  BothausApp.swift
//  Bothaus
//
//  Created by kasima on 3/9/23.
//

import SwiftUI

@main
struct BothausApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
