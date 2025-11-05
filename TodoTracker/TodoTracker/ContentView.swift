//
//  ContentView.swift
//  TodoTracker
//
//  Main view displaying the to-do list
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var showingAddTodo = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.todos.isEmpty {
                    emptyStateView
                } else {
                    todoListView
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTodo = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            Text("Tap the + button to add your first task")
                .font(.body)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Todo List View

    private var todoListView: some View {
        VStack(spacing: 0) {
            // Progress indicator
            if !viewModel.todos.isEmpty {
                progressView
            }

            // List of todos
            List {
                ForEach(viewModel.todos) { todo in
                    TodoRowView(todo: todo, viewModel: viewModel)
                }
                .onDelete(perform: viewModel.deleteTodo)
            }
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Progress View

    private var progressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(viewModel.completedTodos.count)/\(viewModel.todos.count) completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: Double(viewModel.completedTodos.count), total: Double(viewModel.todos.count))
                .tint(.blue)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Todo Row View

struct TodoRowView: View {
    let todo: TodoItem
    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                withAnimation {
                    viewModel.toggleTodo(todo: todo)
                }
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)

                if todo.isCompleted, let completedDate = todo.completedDate {
                    Text("Completed \(completedDate, style: .relative) ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                viewModel.toggleTodo(todo: todo)
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
