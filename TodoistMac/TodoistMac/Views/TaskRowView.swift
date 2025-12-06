import SwiftUI

struct TaskRowView: View {
    let todo: TodoItem
    @ObservedObject var viewModel: TodoViewModel
    var isHovered: Bool = false

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
                    // Priority flag
                    if todo.priority != .none {
                        Image(systemName: "flag.fill")
                            .font(.caption)
                            .foregroundStyle(priorityColor)
                    }

                    // Title
                    Text(todo.title)
                        .strikethrough(todo.isCompleted)
                        .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                        .lineLimit(2)
                }

                // Description
                if !todo.description.isEmpty {
                    Text(todo.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Metadata row
                HStack(spacing: 8) {
                    // Due date
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(formattedDueDate(dueDate))
                        }
                        .font(.caption)
                        .foregroundStyle(dueDateColor(dueDate))
                    }

                    // Project
                    if let projectId = todo.projectId,
                       let project = viewModel.projects.first(where: { $0.id == projectId }) {
                        HStack(spacing: 4) {
                            Image(systemName: project.icon)
                            Text(project.name)
                        }
                        .font(.caption)
                        .foregroundStyle(project.color.color)
                    }

                    // Subtasks
                    if todo.totalSubtasksCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "checklist")
                            Text("\(todo.completedSubtasksCount)/\(todo.totalSubtasksCount)")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    // Labels
                    ForEach(todo.labels.prefix(2), id: \.self) { label in
                        HStack(spacing: 2) {
                            Image(systemName: "tag")
                            Text(label)
                        }
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }

                    if todo.labels.count > 2 {
                        Text("+\(todo.labels.count - 2)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Action buttons (shown on hover)
            if isHovered && !todo.isCompleted {
                HStack(spacing: 8) {
                    Button {
                        viewModel.selectedTask = todo
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Edit task")

                    Button {
                        // Schedule for today
                        var updatedTodo = todo
                        updatedTodo.dueDate = Date()
                        viewModel.updateTodo(updatedTodo)
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Schedule")

                    Button {
                        viewModel.deleteTodo(todo)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Delete task")
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .contextMenu {
            TaskContextMenu(todo: todo, viewModel: viewModel)
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

    private func formattedDueDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
                formatter.dateFormat = "MMM d"
            } else {
                formatter.dateFormat = "MMM d, yyyy"
            }
            return formatter.string(from: date)
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        if todo.isCompleted {
            return .secondary
        }
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: Date()) {
            return .red
        } else if calendar.isDateInToday(date) {
            return .green
        } else if calendar.isDateInTomorrow(date) {
            return .orange
        }
        return .secondary
    }
}

struct TaskContextMenu: View {
    let todo: TodoItem
    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        Button {
            viewModel.toggleTodo(todo)
        } label: {
            Label(todo.isCompleted ? "Mark Incomplete" : "Mark Complete",
                  systemImage: todo.isCompleted ? "circle" : "checkmark.circle")
        }

        Divider()

        Menu("Priority") {
            ForEach(Priority.allCases, id: \.self) { priority in
                Button {
                    var updatedTodo = todo
                    updatedTodo.priority = priority
                    viewModel.updateTodo(updatedTodo)
                } label: {
                    HStack {
                        if priority != .none {
                            Image(systemName: "flag.fill")
                        }
                        Text(priority.label)
                        if todo.priority == priority {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }

        Menu("Due Date") {
            Button {
                var updatedTodo = todo
                updatedTodo.dueDate = Date()
                viewModel.updateTodo(updatedTodo)
            } label: {
                Label("Today", systemImage: "calendar")
            }

            Button {
                var updatedTodo = todo
                updatedTodo.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                viewModel.updateTodo(updatedTodo)
            } label: {
                Label("Tomorrow", systemImage: "sunrise")
            }

            Button {
                var updatedTodo = todo
                updatedTodo.dueDate = Calendar.current.nextWeekend(startingAfter: Date())?.start
                viewModel.updateTodo(updatedTodo)
            } label: {
                Label("This Weekend", systemImage: "sun.max")
            }

            Button {
                var updatedTodo = todo
                updatedTodo.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                viewModel.updateTodo(updatedTodo)
            } label: {
                Label("Next Week", systemImage: "calendar.badge.plus")
            }

            if todo.dueDate != nil {
                Divider()
                Button {
                    var updatedTodo = todo
                    updatedTodo.dueDate = nil
                    viewModel.updateTodo(updatedTodo)
                } label: {
                    Label("No Date", systemImage: "xmark.circle")
                }
            }
        }

        if !viewModel.projects.isEmpty {
            Menu("Move to Project") {
                Button {
                    viewModel.moveTodoToProject(todo, projectId: nil)
                } label: {
                    Label("Inbox", systemImage: "tray")
                }

                Divider()

                ForEach(viewModel.projects) { project in
                    Button {
                        viewModel.moveTodoToProject(todo, projectId: project.id)
                    } label: {
                        Label(project.name, systemImage: project.icon)
                    }
                }
            }
        }

        Divider()

        Button {
            viewModel.duplicateTask(todo)
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        Button {
            viewModel.selectedTask = todo
        } label: {
            Label("Edit", systemImage: "pencil")
        }

        Divider()

        Button(role: .destructive) {
            viewModel.deleteTodo(todo)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    VStack {
        TaskRowView(
            todo: TodoItem(
                title: "Sample task with priority",
                priority: .high,
                dueDate: Date(),
                labels: ["work", "urgent"]
            ),
            viewModel: TodoViewModel(),
            isHovered: true
        )
        TaskRowView(
            todo: TodoItem(
                title: "Completed task",
                isCompleted: true
            ),
            viewModel: TodoViewModel()
        )
    }
}
