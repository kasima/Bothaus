//
//  OpenAIAPIClient.swift
//  Bothaus
//
//  Created by kasima on 3/5/23.
//

import Foundation
import OpenAIKit
import AsyncHTTPClient

class OpenAIAPIClient {
    private let testing = false
    private let client: OpenAIKit.Client
    private let model = Model.GPT3.gpt3_5Turbo
    private let maxTokens = 1024

    init(apiKey: String, organization: String) {
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        let configuration = Configuration(apiKey: apiKey, organization: organization)
        client = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
    }

    func sendToChatGPTAPI(system: String, messages: [Chat.Message]) async throws -> Chat.Message {
        if testing {
            sleep(1)
            let testResponses = [
                "This is test one. What do you call an alligator in a vest? An investigator.",
                "This is test two. I told my wife she was drawing her eyebrows too high. She looked surprised.",
                "This is test three. Why did the scarecrow win an award? Because he was outstanding in his field."
            ]
            let randomIndex = Int(arc4random_uniform(UInt32(testResponses.count)))
            return Chat.Message(role:"assistant", content: testResponses[randomIndex])
        } else {
            let systemMessage = Chat.Message(role: "system", content: system)
            let fullMessages = [systemMessage] + messages
            print ("Full messages: \(fullMessages)")
            let completion = try await client.chats.create(
                model: model,
                messages: fullMessages,
                maxTokens: maxTokens
            )
            return completion.choices[0].message
        }
    }
}
