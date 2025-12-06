import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .none
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var selectedProjectId: UUID?
    @State private var labelText = ""
    @State private var labels: [String] = []

    @FocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Task")
                    .font(.headline)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    TextField("Task name", text: $title)
                        .font(.title3)
                        .textFieldStyle(.plain)
                        .focused($isTitleFocused)

                    // Description
                    TextField("Description", text: $description)
                        .font(.body)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.secondary)

                    Divider()

                    // Options row
                    HStack(spacing: 12) {
                        // Due date
                        Menu {
                            Button {
                                dueDate = Date()
                                hasDueDate = true
                            } label: {
                                Label("Today", systemImage: "calendar")
                            }

                            Button {
                                dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                                hasDueDate = true
                            } label: {
                                Label("Tomorrow", systemImage: "sunrise")
                            }

                            Button {
                                dueDate = Calendar.current.nextWeekend(startingAfter: Date())?.start
                                hasDueDate = true
                            } label: {
                                Label("This Weekend", systemImage: "sun.max")
                            }

                            Button {
                                dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                                hasDueDate = true
                            } label: {
                                Label("Next Week", systemImage: "calendar.badge.plus")
                            }

                            Divider()

                            if hasDueDate {
                                Button {
                                    dueDate = nil
                                    hasDueDate = false
                                } label: {
                                    Label("No Date", systemImage: "xmark.circle")
                                }
                            }
                        } label: {
                            Label {
                                if let date = dueDate {
                                    Text(formattedDueDate(date))
                                } else {
                                    Text("Due date")
                                }
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .menuStyle(.borderlessButton)

                        // Priority
                        Menu {
                            ForEach(Priority.allCases, id: \.self) { p in
                                Button {
                                    priority = p
                                } label: {
                                    HStack {
                                        if p != .none {
                                            Image(systemName: "flag.fill")
                                        }
                                        Text(p.label)
                                        if priority == p {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label {
                                Text(priority == .none ? "Priority" : priority.shortLabel)
                            } icon: {
                                Image(systemName: priority == .none ? "flag" : "flag.fill")
                                    .foregroundStyle(priorityColor)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .menuStyle(.borderlessButton)

                        // Project
                        Menu {
                            Button {
                                selectedProjectId = nil
                            } label: {
                                Label("Inbox", systemImage: "tray")
                            }

                            if !viewModel.projects.isEmpty {
                                Divider()
                                ForEach(viewModel.projects) { project in
                                    Button {
                                        selectedProjectId = project.id
                                    } label: {
                                        Label(project.name, systemImage: project.icon)
                                    }
                                }
                            }
                        } label: {
                            Label {
                                if let projectId = selectedProjectId,
                                   let project = viewModel.projects.first(where: { $0.id == projectId }) {
                                    Text(project.name)
                                } else {
                                    Text("Inbox")
                                }
                            } icon: {
                                Image(systemName: selectedProjectId == nil ? "tray" : "folder")
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .menuStyle(.borderlessButton)

                        Spacer()
                    }

                    // Labels
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Labels")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            TextField("Add label", text: $labelText)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addLabel()
                                }

                            Button("Add") {
                                addLabel()
                            }
                            .disabled(labelText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }

                        if !labels.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(labels, id: \.self) { label in
                                    HStack(spacing: 4) {
                                        Image(systemName: "tag")
                                            .font(.caption2)
                                        Text(label)
                                            .font(.caption)
                                        Button {
                                            labels.removeAll { $0 == label }
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
                    }
                }
                .padding()
            }

            Divider()

            // Footer buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Add Task") {
                    addTask()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .onAppear {
            isTitleFocused = true
            // Set default project based on current filter
            if case .project(let id) = viewModel.selectedFilter {
                selectedProjectId = id
            }
        }
    }

    private var priorityColor: Color {
        switch priority {
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
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func addLabel() {
        let trimmed = labelText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !labels.contains(trimmed) {
            labels.append(trimmed)
            labelText = ""
        }
    }

    private func addTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        viewModel.addTodo(
            title: trimmedTitle,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            dueDate: dueDate,
            projectId: selectedProjectId,
            labels: labels
        )

        isPresented = false
    }
}

// Simple flow layout for labels
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

#Preview {
    AddTaskView(viewModel: TodoViewModel(), isPresented: .constant(true))
}
