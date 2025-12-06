import Foundation

enum Priority: Int, Codable, CaseIterable, Comparable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4

    var color: String {
        switch self {
        case .none: return "gray"
        case .low: return "blue"
        case .medium: return "yellow"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }

    var label: String {
        switch self {
        case .none: return "No Priority"
        case .low: return "Priority 4"
        case .medium: return "Priority 3"
        case .high: return "Priority 2"
        case .urgent: return "Priority 1"
        }
    }

    var shortLabel: String {
        switch self {
        case .none: return ""
        case .low: return "P4"
        case .medium: return "P3"
        case .high: return "P2"
        case .urgent: return "P1"
        }
    }

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var projectId: UUID?
    var labels: [String]
    var createdDate: Date
    var completedDate: Date?
    var subtasks: [Subtask]
    var isRecurring: Bool
    var recurringPattern: RecurringPattern?

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        priority: Priority = .none,
        dueDate: Date? = nil,
        projectId: UUID? = nil,
        labels: [String] = [],
        createdDate: Date = Date(),
        completedDate: Date? = nil,
        subtasks: [Subtask] = [],
        isRecurring: Bool = false,
        recurringPattern: RecurringPattern? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.projectId = projectId
        self.labels = labels
        self.createdDate = createdDate
        self.completedDate = completedDate
        self.subtasks = subtasks
        self.isRecurring = isRecurring
        self.recurringPattern = recurringPattern
    }

    mutating func toggleCompletion() {
        isCompleted.toggle()
        completedDate = isCompleted ? Date() : nil
    }

    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: Date())
    }

    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var isDueTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }

    var isDueThisWeek: Bool {
        guard let dueDate = dueDate else { return false }
        let calendar = Calendar.current
        let today = Date()
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: today) else { return false }
        return dueDate >= today && dueDate <= weekEnd
    }

    var completedSubtasksCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }

    var totalSubtasksCount: Int {
        subtasks.count
    }
}

struct Subtask: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }

    mutating func toggleCompletion() {
        isCompleted.toggle()
    }
}

enum RecurringPattern: Codable, Equatable, Hashable {
    case daily
    case weekly(daysOfWeek: [Int])
    case monthly(dayOfMonth: Int)
    case yearly
    case custom(days: Int)

    var description: String {
        switch self {
        case .daily:
            return "Every day"
        case .weekly(let days):
            if days.isEmpty { return "Every week" }
            let dayNames = days.map { Calendar.current.weekdaySymbols[$0 - 1] }
            return "Every \(dayNames.joined(separator: ", "))"
        case .monthly(let day):
            return "Every month on day \(day)"
        case .yearly:
            return "Every year"
        case .custom(let days):
            return "Every \(days) days"
        }
    }
}
