import SwiftUI

struct QuickAddView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme

    @State private var taskTitle = ""
    @State private var selectedPriority: Priority = .none
    @State private var selectedDueDate: QuickDueDate = .none
    @State private var selectedProjectId: UUID?

    @FocusState private var isFocused: Bool

    enum QuickDueDate: String, CaseIterable {
        case none = "No date"
        case today = "Today"
        case tomorrow = "Tomorrow"
        case nextWeek = "Next week"

        var date: Date? {
            switch self {
            case .none: return nil
            case .today: return Date()
            case .tomorrow: return Calendar.current.date(byAdding: .day, value: 1, to: Date())
            case .nextWeek: return Calendar.current.date(byAdding: .day, value: 7, to: Date())
            }
        }

        var icon: String {
            switch self {
            case .none: return "calendar.badge.minus"
            case .today: return "calendar"
            case .tomorrow: return "sunrise"
            case .nextWeek: return "calendar.badge.plus"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Input field
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)

                TextField("Add a task...", text: $taskTitle)
                    .font(.title3)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        addTask()
                    }

                if !taskTitle.isEmpty {
                    Button {
                        taskTitle = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()

            Divider()

            // Quick options
            HStack(spacing: 16) {
                // Due date options
                ForEach(QuickDueDate.allCases, id: \.self) { option in
                    Button {
                        selectedDueDate = option
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: option.icon)
                            Text(option.rawValue)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(selectedDueDate == option ? Color.accentColor.opacity(0.2) : Color.clear)
                        .foregroundStyle(selectedDueDate == option ? .primary : .secondary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .frame(height: 20)

                // Priority
                Menu {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Button {
                            selectedPriority = priority
                        } label: {
                            HStack {
                                if priority != .none {
                                    Image(systemName: "flag.fill")
                                }
                                Text(priority.label)
                                if selectedPriority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: selectedPriority == .none ? "flag" : "flag.fill")
                            .foregroundStyle(priorityColor)
                        if selectedPriority != .none {
                            Text(selectedPriority.shortLabel)
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(selectedPriority != .none ? priorityColor.opacity(0.2) : Color.clear)
                    .clipShape(Capsule())
                }
                .menuStyle(.borderlessButton)

                // Project
                if !viewModel.projects.isEmpty {
                    Menu {
                        Button {
                            selectedProjectId = nil
                        } label: {
                            Label("Inbox", systemImage: "tray")
                        }

                        Divider()

                        ForEach(viewModel.projects) { project in
                            Button {
                                selectedProjectId = project.id
                            } label: {
                                Label(project.name, systemImage: project.icon)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if let projectId = selectedProjectId,
                               let project = viewModel.projects.first(where: { $0.id == projectId }) {
                                Image(systemName: project.icon)
                                    .foregroundStyle(project.color.color)
                                Text(project.name)
                            } else {
                                Image(systemName: "tray")
                                Text("Inbox")
                            }
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .menuStyle(.borderlessButton)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Actions
            HStack {
                Text("Press ⏎ to add, ⎋ to cancel")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Button("Add Task") {
                    addTask()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.return)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color(nsColor: .windowBackgroundColor) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(width: 600)
        .onAppear {
            isFocused = true
            // Set default project based on current filter
            if case .project(let id) = viewModel.selectedFilter {
                selectedProjectId = id
            }
            // Set default due date for Today view
            if viewModel.selectedFilter == .today {
                selectedDueDate = .today
            }
        }
    }

    private var priorityColor: Color {
        switch selectedPriority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .none: return .gray
        }
    }

    private func addTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        viewModel.addTodo(
            title: trimmedTitle,
            priority: selectedPriority,
            dueDate: selectedDueDate.date,
            projectId: selectedProjectId
        )

        // Reset and close
        taskTitle = ""
        selectedPriority = .none
        selectedDueDate = .none
        selectedProjectId = nil
        isPresented = false
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)

        QuickAddView(viewModel: TodoViewModel(), isPresented: .constant(true))
            .padding()
    }
}
