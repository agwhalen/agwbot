import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: TodoViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Search header
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search tasks...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.title3)
                    .focused($isSearchFocused)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))

            Divider()

            if viewModel.searchText.isEmpty {
                // Empty state - show recent searches or suggestions
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)

                    Text("Search your tasks")
                        .font(.headline)

                    Text("Find tasks by title, description, or labels")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick filters")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            SearchSuggestionButton(text: "p1", icon: "flag.fill", color: .red) {
                                viewModel.searchText = "p1"
                            }

                            SearchSuggestionButton(text: "overdue", icon: "exclamationmark.circle", color: .orange) {
                                viewModel.searchText = "overdue"
                            }

                            SearchSuggestionButton(text: "today", icon: "calendar", color: .green) {
                                viewModel.searchText = "today"
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Spacer()
                }
                .padding()
            } else if viewModel.searchResults.isEmpty {
                // No results
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)

                    Text("No results found")
                        .font(.headline)

                    Text("Try a different search term")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
            } else {
                // Results list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        HStack {
                            Text("\(viewModel.searchResults.count) results")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                        ForEach(viewModel.searchResults) { todo in
                            SearchResultRow(todo: todo, searchText: viewModel.searchText, viewModel: viewModel)
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 400)
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct SearchSuggestionButton: View {
    let text: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(text)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct SearchResultRow: View {
    let todo: TodoItem
    let searchText: String
    @ObservedObject var viewModel: TodoViewModel
    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                viewModel.toggleTodo(todo)
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(todo.isCompleted ? .gray : priorityColor)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                // Highlighted title
                Text(highlightedText(todo.title))
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)

                if !todo.description.isEmpty {
                    Text(highlightedText(todo.description))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text(formattedDueDate(dueDate))
                        }
                        .font(.caption)
                        .foregroundStyle(dueDateColor(dueDate))
                    }

                    if let projectId = todo.projectId,
                       let project = viewModel.projects.first(where: { $0.id == projectId }) {
                        HStack(spacing: 4) {
                            Image(systemName: project.icon)
                            Text(project.name)
                        }
                        .font(.caption)
                        .foregroundStyle(project.color.color)
                    }

                    ForEach(todo.labels.filter { $0.lowercased().contains(searchText.lowercased()) }, id: \.self) { label in
                        HStack(spacing: 2) {
                            Image(systemName: "tag")
                            Text(label)
                        }
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()
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

    private var priorityColor: Color {
        switch todo.priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        case .none: return .gray
        }
    }

    private func highlightedText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)

        if let range = text.range(of: searchText, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: text)
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].backgroundColor = .yellow.opacity(0.3)
            }
        }

        return attributedString
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
        if todo.isCompleted { return .secondary }
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: Date()) {
            return .red
        } else if calendar.isDateInToday(date) {
            return .green
        }
        return .secondary
    }
}

#Preview {
    SearchView(viewModel: TodoViewModel())
}
