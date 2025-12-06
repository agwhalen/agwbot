import Foundation
import SwiftUI

struct Project: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: ProjectColor
    var icon: String
    var isFavorite: Bool
    var isArchived: Bool
    var createdDate: Date
    var order: Int

    init(
        id: UUID = UUID(),
        name: String,
        color: ProjectColor = .blue,
        icon: String = "folder",
        isFavorite: Bool = false,
        isArchived: Bool = false,
        createdDate: Date = Date(),
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.createdDate = createdDate
        self.order = order
    }
}

enum ProjectColor: String, Codable, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case teal
    case blue
    case indigo
    case purple
    case pink
    case brown
    case gray

    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .teal: return .teal
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        case .brown: return .brown
        case .gray: return .gray
        }
    }

    var name: String {
        rawValue.capitalized
    }
}

enum SidebarFilter: Hashable {
    case inbox
    case today
    case upcoming
    case completed
    case project(UUID)
    case label(String)
    case search

    var title: String {
        switch self {
        case .inbox: return "Inbox"
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .completed: return "Completed"
        case .project: return "Project"
        case .label(let name): return name
        case .search: return "Search"
        }
    }

    var icon: String {
        switch self {
        case .inbox: return "tray"
        case .today: return "calendar"
        case .upcoming: return "calendar.badge.clock"
        case .completed: return "checkmark.circle"
        case .project: return "folder"
        case .label: return "tag"
        case .search: return "magnifyingglass"
        }
    }
}

struct Label: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: ProjectColor

    init(id: UUID = UUID(), name: String, color: ProjectColor = .gray) {
        self.id = id
        self.name = name
        self.color = color
    }
}
