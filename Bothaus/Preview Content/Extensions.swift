//
//  File.swift
//  Bothaus
//
//  Created by kasima on 3/16/23.
//

import Foundation
import CoreData

extension Bot {
    static var talkGPT: Bot {
        let context = PersistenceController.preview.container.viewContext
        let bot = Bot(context: context)
        bot.name = "TalkGPT"
        bot.systemPrompt = "You are Talk GPT"
        return bot
    }
}
