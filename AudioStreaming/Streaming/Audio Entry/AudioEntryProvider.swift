//
//  Created by Dimitrios Chatzieleftheriou on 11/11/2020.
//  Copyright © 2020 Decimal. All rights reserved.
//

import AVFoundation

protocol AudioEntryProviding {
    func provideAudioEntry(url: URL, id: UUID?, headers: [String: String]) -> AudioEntry
    func provideAudioEntry(url: URL, id: UUID?) -> AudioEntry
}

final class AudioEntryProvider: AudioEntryProviding {
    private let networkingClient: NetworkingClient
    private let underlyingQueue: DispatchQueue
    private let outputAudioFormat: AVAudioFormat

    init(networkingClient: NetworkingClient,
         underlyingQueue: DispatchQueue,
         outputAudioFormat: AVAudioFormat)
    {
        self.networkingClient = networkingClient
        self.underlyingQueue = underlyingQueue
        self.outputAudioFormat = outputAudioFormat
    }

    func provideAudioEntry(url: URL, id: UUID? = nil, headers: [String: String]) -> AudioEntry {
        let source = self.source(for: url, headers: headers)
        return AudioEntry(source: source,
                          entryId: AudioEntryId(id: id ?? UUID(),
                                                url: url),
                          outputAudioFormat: outputAudioFormat)
    }

    func provideAudioEntry(url: URL, id: UUID? = nil) -> AudioEntry {
        provideAudioEntry(url: url, id: id, headers: [:])
    }

    func provideAudioSource(url: URL, headers: [String: String]) -> AudioStreamSource {
        RemoteAudioSource(networking: networkingClient,
                          url: url,
                          underlyingQueue: underlyingQueue,
                          httpHeaders: headers)
    }

    func provideFileAudioSource(url: URL) -> CoreAudioStreamSource {
        FileAudioSource(url: url, underlyingQueue: underlyingQueue)
    }

    func source(for url: URL, headers: [String: String]) -> CoreAudioStreamSource {
        if url.isFileURL {
            return provideFileAudioSource(url: url)
        } else {
            return provideAudioSource(url: url, headers: headers)
        }
    }
}
