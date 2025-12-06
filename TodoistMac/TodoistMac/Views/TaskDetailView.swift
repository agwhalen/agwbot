import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var task: TodoItem?

    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedPriority: Priority = .none
    @State private var editedDueDate: Date?
    @State private var hasDueDate = false
    @State private var editedProjectId: UUID?
    @State private var newSubtaskTitle = ""
    @State private var newLabel = ""

    @FocusState private var isTitleFocused: Bool

    var body: some View {
        if let currentTask = task {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with close button
                    HStack {
                        Button {
                            viewModel.toggleTodo(currentTask)
                            if let updated = viewModel.todos.first(where: { $0.id == currentTask.id }) {
                                task = updated
                            }
                        } label: {
                            Image(systemName: currentTask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundStyle(currentTask.isCompleted ? .gray : priorityColor)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            saveChanges()
                            task = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    // Title
                    TextField("Task name", text: $editedTitle, axis: .vertical)
                        .font(.title2.bold())
                        .textFieldStyle(.plain)
                        .focused($isTitleFocused)

                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("Add a description...", text: $editedDescription, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(5...10)
                    }

                    Divider()

                    // Properties
                    VStack(alignment: .leading, spacing: 12) {
                        // Project
                        HStack {
                            Image(systemName: "folder")
                                .frame(width: 24)
                                .foregroundStyle(.secondary)

                            Text("Project")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Menu {
                                Button {
                                    editedProjectId = nil
                                } label: {
                                    Label("Inbox", systemImage: "tray")
                                }

                                if !viewModel.projects.isEmpty {
                                    Divider()
                                    ForEach(viewModel.projects) { project in
                                        Button {
                                            editedProjectId = project.id
                                        } label: {
                                            Label(project.name, systemImage: project.icon)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if let projectId = editedProjectId,
                                       let project = viewModel.projects.first(where: { $0.id == projectId }) {
                                        Image(systemName: project.icon)
                                            .foregroundStyle(project.color.color)
                                        Text(project.name)
                                    } else {
                                        Image(systemName: "tray")
                                        Text("Inbox")
                                    }
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                            }
                            .menuStyle(.borderlessButton)
                        }

                        // Due date
                        HStack {
                            Image(systemName: "calendar")
                                .frame(width: 24)
                                .foregroundStyle(.secondary)

                            Text("Due date")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Menu {
                                Button {
                                    editedDueDate = Date()
                                    hasDueDate = true
                                } label: {
                                    Label("Today", systemImage: "calendar")
                                }

                                Button {
                                    editedDueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                                    hasDueDate = true
                                } label: {
                                    Label("Tomorrow", systemImage: "sunrise")
                                }

                                Button {
                                    editedDueDate = Calendar.current.nextWeekend(startingAfter: Date())?.start
                                    hasDueDate = true
                                } label: {
                                    Label("This Weekend", systemImage: "sun.max")
                                }

                                Button {
                                    editedDueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                                    hasDueDate = true
                                } label: {
                                    Label("Next Week", systemImage: "calendar.badge.plus")
                                }

                                if hasDueDate {
                                    Divider()
                                    Button {
                                        editedDueDate = nil
                                        hasDueDate = false
                                    } label: {
                                        Label("Remove", systemImage: "xmark.circle")
                                    }
                                }
                            } label: {
                                HStack {
                                    if let date = editedDueDate {
                                        Text(formattedDueDate(date))
                                            .foregroundStyle(dueDateColor(date))
                                    } else {
                                        Text("No date")
                                            .foregroundStyle(.secondary)
                                    }
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                            }
                            .menuStyle(.borderlessButton)
                        }

                        // Priority
                        HStack {
                            Image(systemName: "flag")
                                .frame(width: 24)
                                .foregroundStyle(.secondary)

                            Text("Priority")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Menu {
                                ForEach(Priority.allCases, id: \.self) { p in
                                    Button {
                                        editedPriority = p
                                    } label: {
                                        HStack {
                                            if p != .none {
                                                Image(systemName: "flag.fill")
                                            }
                                            Text(p.label)
                                            if editedPriority == p {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    if editedPriority != .none {
                                        Image(systemName: "flag.fill")
                                            .foregroundStyle(priorityColor)
                                    }
                                    Text(editedPriority.label)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                            }
                            .menuStyle(.borderlessButton)
                        }
                    }

                    Divider()

                    // Subtasks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subtasks")
                            .font(.headline)

                        ForEach(currentTask.subtasks) { subtask in
                            HStack {
                                Button {
                                    viewModel.toggleSubtask(subtask, in: currentTask)
                                    if let updated = viewModel.todos.first(where: { $0.id == currentTask.id }) {
                                        task = updated
                                    }
                                } label: {
                                    Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(subtask.isCompleted ? .gray : .blue)
                                }
                                .buttonStyle(.plain)

                                Text(subtask.title)
                                    .strikethrough(subtask.isCompleted)
                                    .foregroundStyle(subtask.isCompleted ? .secondary : .primary)

                                Spacer()

                                Button {
                                    viewModel.deleteSubtask(subtask, from: currentTask)
                                    if let updated = viewModel.todos.first(where: { $0.id == currentTask.id }) {
                                        task = updated
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }

                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)

                            TextField("Add subtask", text: $newSubtaskTitle)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    addSubtask()
                                }
                        }
                    }

                    Divider()

                    // Labels
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Labels")
                            .font(.headline)

                        if !currentTask.labels.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(currentTask.labels, id: \.self) { label in
                                    HStack(spacing: 4) {
                                        Image(systemName: "tag")
                                            .font(.caption2)
                                        Text(label)
                                            .font(.caption)
                                        Button {
                                            removeLabel(label)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption2)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundStyle(.orange)
                                    .clipShape(Capsule())
                                }
                            }
                        }

                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.orange)

                            TextField("Add label", text: $newLabel)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    addLabel()
                                }
                        }
                    }

                    Divider()

                    // Metadata
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Created \(formattedFullDate(currentTask.createdDate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let completedDate = currentTask.completedDate {
                            Text("Completed \(formattedFullDate(completedDate))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Delete button
                    Button(role: .destructive) {
                        viewModel.deleteTodo(currentTask)
                        task = nil
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .frame(minWidth: 300, idealWidth: 350, maxWidth: 400)
            .onAppear {
                loadTask(currentTask)
            }
            .onChange(of: task) { _, newTask in
                if let t = newTask {
                    loadTask(t)
                }
            }
            .onDisappear {
                saveChanges()
            }
        } else {
            VStack {
                Spacer()
                Image(systemName: "sidebar.right")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                Text("Select a task to view details")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(minWidth: 300, idealWidth: 350, maxWidth: 400)
        }
    }

    private var priorityColor: Color {
        switch editedPriority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .none: return .gray
        }
    }

    private func loadTask(_ task: TodoItem) {
        editedTitle = task.title
        editedDescription = task.description
        editedPriority = task.priority
        editedDueDate = task.dueDate
        hasDueDate = task.dueDate != nil
        editedProjectId = task.projectId
    }

    private func saveChanges() {
        guard let currentTask = task else { return }

        var updatedTask = currentTask
        updatedTask.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.description = editedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.priority = editedPriority
        updatedTask.dueDate = editedDueDate
        updatedTask.projectId = editedProjectId

        if !updatedTask.title.isEmpty {
            viewModel.updateTodo(updatedTask)
        }
    }

    private func addSubtask() {
        guard let currentTask = task else { return }
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        viewModel.addSubtask(to: currentTask, title: trimmed)
        newSubtaskTitle = ""

        if let updated = viewModel.todos.first(where: { $0.id == currentTask.id }) {
            task = updated
        }
    }

    private func addLabel() {
        guard var currentTask = task else { return }
        let trimmed = newLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && !currentTask.labels.contains(trimmed) else { return }

        currentTask.labels.append(trimmed)
        viewModel.updateTodo(currentTask)
        newLabel = ""
        task = currentTask
    }

    private func removeLabel(_ label: String) {
        guard var currentTask = task else { return }
        currentTask.labels.removeAll { $0 == label }
        viewModel.updateTodo(currentTask)
        task = currentTask
    }

    private func formattedDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: Date()) {
            return .red
        } else if calendar.isDateInToday(date) {
            return .green
        }
        return .primary
    }

    private func formattedFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    TaskDetailView(
        viewModel: TodoViewModel(),
        task: .constant(TodoItem(
            title: "Sample task",
            description: "This is a sample description",
            priority: .high,
            dueDate: Date(),
            labels: ["work", "urgent"]
        ))
    )
}
