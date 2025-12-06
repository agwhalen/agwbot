import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        HSplitView {
            // Calendar Panel
            VStack(spacing: 0) {
                // Month Navigation Header
                HStack {
                    Button {
                        previousMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(monthYearString)
                        .font(.title2.bold())

                    Spacer()

                    Button {
                        currentMonth = Date()
                        selectedDate = Date()
                    } label: {
                        Text("Today")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        nextMonth()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding()

                Divider()

                // Days of Week Header
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.05))

                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                    ForEach(calendarDays, id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            taskCount: tasksCount(for: date),
                            hasOverdue: hasOverdueTasks(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    }
                }
                .padding(.horizontal, 8)

                Spacer()

                // Month Overview
                VStack(alignment: .leading, spacing: 12) {
                    Divider()

                    Text("This Month")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 20) {
                        OverviewStat(
                            title: "Total Tasks",
                            value: "\(monthTasksCount)",
                            color: .blue
                        )

                        OverviewStat(
                            title: "Overdue",
                            value: "\(monthOverdueCount)",
                            color: .red
                        )

                        OverviewStat(
                            title: "Completed",
                            value: "\(monthCompletedCount)",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.gray.opacity(0.03))
            }
            .frame(minWidth: 350, idealWidth: 400)

            // Tasks for Selected Date
            VStack(spacing: 0) {
                // Selected Date Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedDateString)
                            .font(.title2.bold())

                        Text(selectedDateSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        addTaskForSelectedDate()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .help("Add task for this date")
                }
                .padding()

                Divider()

                // Tasks List
                if tasksForSelectedDate.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()

                        Image(systemName: selectedDateIcon)
                            .font(.system(size: 48))
                            .foregroundStyle(.tertiary)

                        Text(selectedDateEmptyTitle)
                            .font(.headline)

                        Text(selectedDateEmptySubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Add Task") {
                            addTaskForSelectedDate()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(tasksForSelectedDate) { todo in
                                CalendarTaskRow(todo: todo, viewModel: viewModel)
                                Divider()
                                    .padding(.leading, 44)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 300)
        }
        .sheet(isPresented: $viewModel.isShowingAddTask) {
            AddTaskView(viewModel: viewModel, isPresented: $viewModel.isShowingAddTask)
        }
    }

    // MARK: - Computed Properties

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    private var selectedDateSubtitle: String {
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: selectedDate)).day ?? 0
            if days > 0 {
                return "In \(days) day\(days == 1 ? "" : "s")"
            } else {
                return "\(abs(days)) day\(abs(days) == 1 ? "" : "s") ago"
            }
        }
    }

    private var selectedDateIcon: String {
        if calendar.isDateInToday(selectedDate) {
            return "sun.max"
        } else if selectedDate > Date() {
            return "calendar.badge.clock"
        } else {
            return "calendar"
        }
    }

    private var selectedDateEmptyTitle: String {
        if calendar.isDateInToday(selectedDate) {
            return "No tasks for today"
        } else if selectedDate > Date() {
            return "No tasks scheduled"
        } else {
            return "No tasks were due"
        }
    }

    private var selectedDateEmptySubtitle: String {
        if calendar.isDateInToday(selectedDate) {
            return "Enjoy your free day or add a task"
        } else if selectedDate > Date() {
            return "Plan ahead by adding tasks"
        } else {
            return "Nothing was scheduled for this day"
        }
    }

    private var calendarDays: [Date] {
        var days: [Date] = []

        // Get the first day of the month
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return days }

        // Get the weekday of the first day (0 = Sunday)
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        // Add days from previous month to fill the first week
        if let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: firstOfMonth) {
            // Generate 42 days (6 weeks) to ensure we cover the full month
            for i in 0..<42 {
                if let day = calendar.date(byAdding: .day, value: i, to: startDate) {
                    days.append(day)
                }
            }
        }

        return days
    }

    private var tasksForSelectedDate: [TodoItem] {
        viewModel.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }.sorted { task1, task2 in
            // Sort by completion status first, then by priority
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            return task1.priority > task2.priority
        }
    }

    private var monthTasksCount: Int {
        viewModel.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, equalTo: currentMonth, toGranularity: .month)
        }.count
    }

    private var monthOverdueCount: Int {
        viewModel.todos.filter { todo in
            guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
            return calendar.isDate(dueDate, equalTo: currentMonth, toGranularity: .month) &&
                   dueDate < calendar.startOfDay(for: Date())
        }.count
    }

    private var monthCompletedCount: Int {
        viewModel.todos.filter { todo in
            guard let dueDate = todo.dueDate else { return false }
            return calendar.isDate(dueDate, equalTo: currentMonth, toGranularity: .month) && todo.isCompleted
        }.count
    }

    // MARK: - Helper Methods

    private func tasksCount(for date: Date) -> Int {
        viewModel.todos.filter { todo in
            guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }.count
    }

    private func hasOverdueTasks(for date: Date) -> Bool {
        let startOfToday = calendar.startOfDay(for: Date())
        guard date < startOfToday else { return false }

        return viewModel.todos.contains { todo in
            guard let dueDate = todo.dueDate, !todo.isCompleted else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
    }

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func addTaskForSelectedDate() {
        // Set the selected date as default for the new task
        viewModel.isShowingAddTask = true
    }
}

// MARK: - Supporting Views

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let taskCount: Int
    let hasOverdue: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(textColor)

            // Task indicator dots
            if taskCount > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<min(taskCount, 3), id: \.self) { _ in
                        Circle()
                            .fill(hasOverdue ? Color.red : Color.blue)
                            .frame(width: 5, height: 5)
                    }
                    if taskCount > 3 {
                        Text("+")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // Placeholder to maintain height
                Color.clear
                    .frame(height: 5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.red : Color.clear, lineWidth: 2)
        )
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isCurrentMonth {
            return .secondary.opacity(0.5)
        } else if isToday {
            return .red
        }
        return .primary
    }

    private var backgroundColor: Color {
        if isSelected {
            return .red
        } else if isToday {
            return .red.opacity(0.1)
        }
        return .clear
    }
}

struct CalendarTaskRow: View {
    let todo: TodoItem
    @ObservedObject var viewModel: TodoViewModel
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Checkbox
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleTodo(todo)
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checkboxColor)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if todo.priority != .none {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                    }

                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                }

                if !todo.description.isEmpty {
                    Text(todo.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Project indicator
                if let projectId = todo.projectId,
                   let project = viewModel.projects.first(where: { $0.id == projectId }) {
                    HStack(spacing: 4) {
                        Image(systemName: project.icon)
                        Text(project.name)
                    }
                    .font(.caption)
                    .foregroundStyle(project.color.color)
                }
            }

            Spacer()

            // Quick actions on hover
            if isHovered && !todo.isCompleted {
                Button {
                    viewModel.selectedTask = todo
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            viewModel.selectedTask = todo
        }
    }

    private var checkboxColor: Color {
        if todo.isCompleted {
            return .gray
        }
        switch todo.priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .none: return .gray
        }
    }

    private var priorityColor: Color {
        switch todo.priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .none: return .gray
        }
    }
}

struct OverviewStat: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    CalendarView(viewModel: TodoViewModel())
        .frame(width: 800, height: 600)
}
