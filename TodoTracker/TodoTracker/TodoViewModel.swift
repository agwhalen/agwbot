//
//  TodoViewModel.swift
//  TodoTracker
//
//  ViewModel for managing to-do items with persistent storage
//

import Foundation
import SwiftUI

class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []

    private let todosKey = "SavedTodos"

    init() {
        loadTodos()
    }

    // MARK: - CRUD Operations

    func addTodo(title: String) {
        let newTodo = TodoItem(title: title)
        todos.insert(newTodo, at: 0) // Add to the top of the list
        saveTodos()
    }

    func toggleTodo(todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].toggleCompletion()
            saveTodos()
        }
    }

    func deleteTodo(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
        saveTodos()
    }

    func deleteTodo(todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos.remove(at: index)
            saveTodos()
        }
    }

    // MARK: - Persistence

    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
    }

    private func loadTodos() {
        guard let data = UserDefaults.standard.data(forKey: todosKey),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            // If no saved data, start with empty list
            todos = []
            return
        }
        todos = decoded
    }

    // MARK: - Computed Properties

    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }

    var incompleteTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }

    var completionPercentage: Double {
        guard !todos.isEmpty else { return 0 }
        return Double(completedTodos.count) / Double(todos.count) * 100
    }
}
