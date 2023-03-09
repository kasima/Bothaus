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
    private let client: OpenAIKit.Client
    private let model = Model.GPT3.gpt3_5Turbo
    private let maxTokens = 1024

    init(apiKey: String, organization: String) {
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        let configuration = Configuration(apiKey: apiKey, organization: organization)
        client = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
    }

    func sendToChatGPTAPI(system: String, messages: [Chat.Message]) async throws -> String {
        let systemMessage = Chat.Message(role: "system", content: system)
        let fullMessages = [systemMessage] + messages
        let completion = try await client.chats.create(
            model: model,
            messages: fullMessages,
            maxTokens: maxTokens
        )
        return completion.choices[0].message.content
    }
}
