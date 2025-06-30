//
//  TextHighlightingService.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Combine
import Foundation

actor TextHighlightingService: TextHighlightingServiceProtocol {
    private var sentences: [String] = []
    private var currentIndex = 0
    private var timerCancellable: AnyCancellable?

    func prepareHighlighting(for text: String) async {
        let tagger = NSLinguisticTagger(
            tagSchemes: [.lexicalClass],
            options: 0
        )
        tagger.string = text
        let range = NSRange(text.startIndex..., in: text)

        var array: [String] = []
        tagger.enumerateTags(
            in: range,
            unit: .sentence,
            scheme: .lexicalClass
        ) { _, sentenceRange, _ in
            let sentence = (text as NSString).substring(with: sentenceRange)
            array.append(sentence)
        }

        sentences = array
        currentIndex = 0
    }

    func start(
        interval: TimeInterval,
        onHighlight: @escaping (_ sentenceIndex: Int) -> Void
    ) async {
        await stop()

        timerCancellable =
            Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task { await self.tick(onHighlight: onHighlight) }
            }
    }

    func stop() async {
        timerCancellable?.cancel()
        timerCancellable = nil
        currentIndex = 0
    }

    private func tick(onHighlight: @escaping (_ sentenceIndex: Int) -> Void)
        async {
        if currentIndex < sentences.count {
            onHighlight(currentIndex)
            currentIndex += 1
        } else {
            await stop()
        }
    }
}
