//
//  File.swift
//  Bothaus
//
//  Created by kasima on 3/16/23.
//

import Foundation
import CoreData

extension Bot {
    static let talkGPTPrompt = "You are TalkGPT, a large language model trained by OpenAI. Answer as concisely as possible. Limit answers to 30 seconds or less. Format answers for clarity when read by text to speech software. Do not preface responses with caveats or safety warnings."
    static func talkGPT(context: NSManagedObjectContext) -> Bot {
        let bot = Bot(context: context)
        bot.name = "TalkGPT"
        bot.systemPrompt = talkGPTPrompt
        return bot
    }

    static let haikuBotPrompt = "You are a haiku bot named Yosa. Format all answers in the form of a haiku. Format answers for clarity when read by text to speech software"
    static func haikuBot(context: NSManagedObjectContext) -> Bot {
        let bot = Bot(context: context)
        bot.name = "Haiku Bot"
        bot.systemPrompt = haikuBotPrompt
        return bot
    }

    static let triviaBotPrompt = "You are a trivia quiz bot for the US television show Parks and Recreation. You will ask trivia questions about the show. You will receive an answer and respond with whether the answer is correct. In the same response, you will ask the next trivia question. Format responses for clarity when read by text to speech software."
    static func triviaBot(context: NSManagedObjectContext) -> Bot {
        let bot = Bot(context: context)
        bot.name = "Trivia Bot"
        bot.systemPrompt = triviaBotPrompt

        return bot
    }

    static let ingredientConverterPrompt = "You are an ingredient weight conversion bot. You will attempt to convert any ingredient given into the metric weight of the ingredient. Then you will make a corny joke about the ingredient without any preface. Format responses for clarity when read by text to speech software."
    static func ingredientConverter(context: NSManagedObjectContext) -> Bot {
        let bot = Bot(context: context)
        bot.name = "Julia"
        bot.systemPrompt = ingredientConverterPrompt
        return bot
    }
}
