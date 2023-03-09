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
            sleep(3)
            return Chat.Message(role:"assistant", content: "This is a a test of the system. Once, there was a man who was constantly misplacing his keys. He would spend hours searching for them, only to realize they were in his pocket all along.")
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
