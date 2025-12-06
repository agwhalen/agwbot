import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var hoveredTaskId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(headerTitle)
                        .font(.title2.bold())

                    if viewModel.selectedFilter == .today {
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Sort menu
                Menu {
                    ForEach(TodoViewModel.SortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Image(systemName: option.icon)
                                Text(option.rawValue)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)
            }
            .padding()

            Divider()

            if viewModel.filteredTodos.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filteredTodos) { todo in
                            TaskRowView(
                                todo: todo,
                                viewModel: viewModel,
                                isHovered: hoveredTaskId == todo.id
                            )
                            .onHover { isHovered in
                                hoveredTaskId = isHovered ? todo.id : nil
                            }
                            .onTapGesture {
                                viewModel.selectedTask = todo
                            }

                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            // Add task button
            Button {
                viewModel.isShowingAddTask = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.red)
                    Text("Add task")
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(minWidth: 400)
        .sheet(isPresented: $viewModel.isShowingAddTask) {
            AddTaskView(viewModel: viewModel, isPresented: $viewModel.isShowingAddTask)
        }
    }

    private var headerTitle: String {
        switch viewModel.selectedFilter {
        case .inbox: return "Inbox"
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .completed: return "Completed"
        case .project(let id):
            return viewModel.projects.first { $0.id == id }?.name ?? "Project"
        case .label(let name): return "#\(name)"
        case .search: return "Search Results"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: emptyStateIcon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)

            Text(emptyStateTitle)
                .font(.headline)

            Text(emptyStateSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if viewModel.selectedFilter != .completed && viewModel.selectedFilter != .search {
                Button("Add Task") {
                    viewModel.isShowingAddTask = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }

            Spacer()
        }
        .padding()
    }

    private var emptyStateIcon: String {
        switch viewModel.selectedFilter {
        case .inbox: return "tray"
        case .today: return "sun.max"
        case .upcoming: return "calendar"
        case .completed: return "checkmark.circle"
        case .project: return "folder"
        case .label: return "tag"
        case .search: return "magnifyingglass"
        }
    }

    private var emptyStateTitle: String {
        switch viewModel.selectedFilter {
        case .inbox: return "Your inbox is empty"
        case .today: return "No tasks for today"
        case .upcoming: return "No upcoming tasks"
        case .completed: return "No completed tasks"
        case .project: return "No tasks in this project"
        case .label: return "No tasks with this label"
        case .search: return "No results found"
        }
    }

    private var emptyStateSubtitle: String {
        switch viewModel.selectedFilter {
        case .inbox: return "Tasks without a project will appear here"
        case .today: return "Enjoy your day! Or add a new task."
        case .upcoming: return "Tasks with due dates will appear here"
        case .completed: return "Completed tasks will appear here"
        case .project: return "Add tasks to this project to get started"
        case .label: return "Tasks with this label will appear here"
        case .search: return "Try a different search term"
        }
    }
}

#Preview {
    TaskListView(viewModel: TodoViewModel())
}
