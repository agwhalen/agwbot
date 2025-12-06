import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    var isPast: Bool {
        self < Date().startOfDay
    }

    func formatted(style: DateFormatStyle) -> String {
        let formatter = DateFormatter()
        switch style {
        case .short:
            if isToday { return "Today" }
            if isTomorrow { return "Tomorrow" }
            if isYesterday { return "Yesterday" }
            formatter.dateFormat = "MMM d"
        case .medium:
            formatter.dateStyle = .medium
        case .long:
            formatter.dateStyle = .long
        case .relative:
            if isToday { return "Today" }
            if isTomorrow { return "Tomorrow" }
            if isYesterday { return "Yesterday" }
            if isThisWeek {
                formatter.dateFormat = "EEEE"
            } else {
                formatter.dateFormat = "MMM d"
            }
        }
        return formatter.string(from: self)
    }

    enum DateFormatStyle {
        case short
        case medium
        case long
        case relative
    }
}

// MARK: - Color Extensions
extension Color {
    static let todoRed = Color(red: 0.85, green: 0.19, blue: 0.19)
    static let todoOrange = Color.orange
    static let todoYellow = Color.yellow
    static let todoBlue = Color.blue
    static let todoGreen = Color.green

    init(priority: Priority) {
        switch priority {
        case .urgent: self = .todoRed
        case .high: self = .todoOrange
        case .medium: self = .todoYellow
        case .low: self = .todoBlue
        case .none: self = .gray
        }
    }
}

// MARK: - String Extensions
extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }

    func highlighted(searchText: String) -> AttributedString {
        var attributed = AttributedString(self)
        guard !searchText.isEmpty else { return attributed }

        var searchRange = self.startIndex..<self.endIndex
        while let range = self.range(of: searchText, options: .caseInsensitive, range: searchRange) {
            if let attrRange = Range(NSRange(range, in: self), in: attributed) {
                attributed[attrRange].backgroundColor = .yellow.opacity(0.3)
            }
            searchRange = range.upperBound..<self.endIndex
        }

        return attributed
    }
}

// MARK: - View Extensions
extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }

    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct FirstAppearModifier: ViewModifier {
    let action: () -> Void
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                action()
            }
    }
}

// MARK: - Keyboard Shortcut Helpers
struct KeyboardShortcutModifier: ViewModifier {
    let key: KeyEquivalent
    let modifiers: EventModifiers
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .background(
                Button("") {
                    action()
                }
                .keyboardShortcut(key, modifiers: modifiers)
                .opacity(0)
            )
    }
}

extension View {
    func onKeyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command, perform action: @escaping () -> Void) -> some View {
        modifier(KeyboardShortcutModifier(key: key, modifiers: modifiers, action: action))
    }
}

// MARK: - Array Extensions
extension Array where Element == TodoItem {
    func sortedByPriority() -> [TodoItem] {
        sorted { $0.priority > $1.priority }
    }

    func sortedByDueDate() -> [TodoItem] {
        sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    func sortedByCreatedDate() -> [TodoItem] {
        sorted { $0.createdDate > $1.createdDate }
    }

    func filterCompleted() -> [TodoItem] {
        filter { $0.isCompleted }
    }

    func filterIncomplete() -> [TodoItem] {
        filter { !$0.isCompleted }
    }

    func filterByProject(_ projectId: UUID?) -> [TodoItem] {
        filter { $0.projectId == projectId }
    }

    func filterByLabel(_ label: String) -> [TodoItem] {
        filter { $0.labels.contains(label) }
    }

    func filterDueToday() -> [TodoItem] {
        filter { $0.isDueToday }
    }

    func filterOverdue() -> [TodoItem] {
        filter { $0.isOverdue }
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day ?? 0
    }
}
