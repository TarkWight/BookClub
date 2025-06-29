//
//  TextHighlightingServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Combine
import Foundation

/// Протокол отвечает за разбивку чанка на предложения и управление авто-скроллом/подсветкой
protocol TextHighlightingServiceProtocol: Sendable {
    /// Подготовить службе текст чанка: разбить на предложения
    func prepareHighlighting(for text: String) async

    /// Начать авто-скролл с интервалом между предложениями (в секундах).
    /// При каждом шаге будет вызван коллбэк с индексом очередного предложения.
    func start(
        interval: TimeInterval,
        onHighlight: @escaping (_ sentenceIndex: Int) -> Void
    ) async

    /// Остановить авто-скролл и сбросить внутренний счётчик
    func stop() async
}
