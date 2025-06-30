//
//  ChapterEntity+Status.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import CoreData

@objc enum ChapterStatus: Int16, CaseIterable, Codable {
    case notStarted = -1
    case inProgress = 0
    case completed = 1
}

extension ChapterEntity {
    var status: ChapterStatus {
        get { ChapterStatus(rawValue: statusRaw) ?? .notStarted }
        set { statusRaw = newValue.rawValue }
    }
}
