//
//  TodoItem.swift
//  TodoTracker
//
//  A model representing a single to-do item
//

import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdDate: Date
    var completedDate: Date?

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdDate: Date = Date(), completedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.completedDate = completedDate
    }

    mutating func toggleCompletion() {
        isCompleted.toggle()
        completedDate = isCompleted ? Date() : nil
    }
}
