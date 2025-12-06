import Foundation
import SwiftUI
import Combine

@MainActor
class TodoViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var todos: [TodoItem] = []
    @Published var projects: [Project] = []
    @Published var labels: [Label] = []
    @Published var selectedFilter: SidebarFilter = .inbox
    @Published var searchText: String = ""
    @Published var selectedTask: TodoItem?
    @Published var isShowingAddTask: Bool = false
    @Published var isShowingQuickAdd: Bool = false
    @Published var isShowingSettings: Bool = false
    @Published var isShowingAddProject: Bool = false
    @Published var sortOption: SortOption = .dueDate

    // MARK: - Private Properties
    private let todosKey = "SavedTodos"
    private let projectsKey = "SavedProjects"
    private let labelsKey = "SavedLabels"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        loadData()
        setupAutoSave()
    }

    // MARK: - Computed Properties
    var filteredTodos: [TodoItem] {
        var result: [TodoItem]

        switch selectedFilter {
        case .inbox:
            result = todos.filter { !$0.isCompleted && $0.projectId == nil }
        case .today:
            result = todos.filter { !$0.isCompleted && $0.isDueToday }
        case .upcoming:
            result = todos.filter { !$0.isCompleted && $0.dueDate != nil }
                .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
        case .completed:
            result = todos.filter { $0.isCompleted }
                .sorted { ($0.completedDate ?? Date.distantPast) > ($1.completedDate ?? Date.distantPast) }
        case .project(let projectId):
            result = todos.filter { !$0.isCompleted && $0.projectId == projectId }
        case .label(let labelName):
            result = todos.filter { !$0.isCompleted && $0.labels.contains(labelName) }
        case .search:
            result = searchResults
        }

        if selectedFilter != .completed && selectedFilter != .upcoming {
            result = sortTodos(result)
        }

        return result
    }

    var searchResults: [TodoItem] {
        guard !searchText.isEmpty else { return [] }
        let lowercasedSearch = searchText.lowercased()
        return todos.filter {
            $0.title.lowercased().contains(lowercasedSearch) ||
            $0.description.lowercased().contains(lowercasedSearch) ||
            $0.labels.contains { $0.lowercased().contains(lowercasedSearch) }
        }
    }

    var todayTasksCount: Int {
        todos.filter { !$0.isCompleted && $0.isDueToday }.count
    }

    var overdueTasksCount: Int {
        todos.filter { $0.isOverdue }.count
    }

    var inboxCount: Int {
        todos.filter { !$0.isCompleted && $0.projectId == nil }.count
    }

    var upcomingCount: Int {
        todos.filter { !$0.isCompleted && $0.dueDate != nil }.count
    }

    var completedCount: Int {
        todos.filter { $0.isCompleted }.count
    }

    var allLabels: [String] {
        Array(Set(todos.flatMap { $0.labels })).sorted()
    }

    // MARK: - Sort Option
    enum SortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case alphabetical = "Alphabetical"
        case createdDate = "Date Created"

        var icon: String {
            switch self {
            case .dueDate: return "calendar"
            case .priority: return "flag"
            case .alphabetical: return "textformat"
            case .createdDate: return "clock"
            }
        }
    }

    private func sortTodos(_ todos: [TodoItem]) -> [TodoItem] {
        switch sortOption {
        case .dueDate:
            return todos.sorted { task1, task2 in
                let date1 = task1.dueDate ?? Date.distantFuture
                let date2 = task2.dueDate ?? Date.distantFuture
                if date1 == date2 {
                    return task1.priority > task2.priority
                }
                return date1 < date2
            }
        case .priority:
            return todos.sorted { $0.priority > $1.priority }
        case .alphabetical:
            return todos.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .createdDate:
            return todos.sorted { $0.createdDate > $1.createdDate }
        }
    }

    // MARK: - Task CRUD Operations
    func addTodo(
        title: String,
        description: String = "",
        priority: Priority = .none,
        dueDate: Date? = nil,
        projectId: UUID? = nil,
        labels: [String] = []
    ) {
        let newTodo = TodoItem(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            projectId: projectId,
            labels: labels
        )
        todos.append(newTodo)
    }

    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
        }
    }

    func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].toggleCompletion()
        }
    }

    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
    }

    func deleteTodos(at offsets: IndexSet) {
        let todosToDelete = offsets.map { filteredTodos[$0] }
        for todo in todosToDelete {
            deleteTodo(todo)
        }
    }

    func moveTodoToProject(_ todo: TodoItem, projectId: UUID?) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].projectId = projectId
        }
    }

    // MARK: - Subtask Operations
    func addSubtask(to todo: TodoItem, title: String) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            let subtask = Subtask(title: title)
            todos[index].subtasks.append(subtask)
        }
    }

    func toggleSubtask(_ subtask: Subtask, in todo: TodoItem) {
        if let todoIndex = todos.firstIndex(where: { $0.id == todo.id }),
           let subtaskIndex = todos[todoIndex].subtasks.firstIndex(where: { $0.id == subtask.id }) {
            todos[todoIndex].subtasks[subtaskIndex].toggleCompletion()
        }
    }

    func deleteSubtask(_ subtask: Subtask, from todo: TodoItem) {
        if let todoIndex = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[todoIndex].subtasks.removeAll { $0.id == subtask.id }
        }
    }

    // MARK: - Project CRUD Operations
    func addProject(name: String, color: ProjectColor = .blue, icon: String = "folder") {
        let newProject = Project(
            name: name,
            color: color,
            icon: icon,
            order: projects.count
        )
        projects.append(newProject)
    }

    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        }
    }

    func deleteProject(_ project: Project) {
        // Move all tasks from this project to inbox
        for i in todos.indices where todos[i].projectId == project.id {
            todos[i].projectId = nil
        }
        projects.removeAll { $0.id == project.id }
    }

    func toggleProjectFavorite(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].isFavorite.toggle()
        }
    }

    func taskCount(for project: Project) -> Int {
        todos.filter { !$0.isCompleted && $0.projectId == project.id }.count
    }

    // MARK: - Label Operations
    func addLabel(name: String, color: ProjectColor = .gray) {
        let newLabel = Label(name: name, color: color)
        labels.append(newLabel)
    }

    func deleteLabel(_ label: Label) {
        // Remove label from all tasks
        for i in todos.indices {
            todos[i].labels.removeAll { $0 == label.name }
        }
        labels.removeAll { $0.id == label.id }
    }

    // MARK: - Persistence
    private func setupAutoSave() {
        $todos
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveTodos()
            }
            .store(in: &cancellables)

        $projects
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveProjects()
            }
            .store(in: &cancellables)

        $labels
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveLabels()
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        loadTodos()
        loadProjects()
        loadLabels()
    }

    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }

    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
    }

    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }

    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }

    private func loadLabels() {
        if let data = UserDefaults.standard.data(forKey: labelsKey),
           let decoded = try? JSONDecoder().decode([Label].self, from: data) {
            labels = decoded
        }
    }

    private func saveLabels() {
        if let encoded = try? JSONEncoder().encode(labels) {
            UserDefaults.standard.set(encoded, forKey: labelsKey)
        }
    }

    // MARK: - Quick Actions
    func clearCompleted() {
        todos.removeAll { $0.isCompleted }
    }

    func duplicateTask(_ todo: TodoItem) {
        var newTodo = todo
        newTodo = TodoItem(
            title: todo.title,
            description: todo.description,
            priority: todo.priority,
            dueDate: todo.dueDate,
            projectId: todo.projectId,
            labels: todo.labels,
            subtasks: todo.subtasks.map { Subtask(title: $0.title) }
        )
        todos.append(newTodo)
    }
}
