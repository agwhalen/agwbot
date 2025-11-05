//
//  AddTodoView.swift
//  TodoTracker
//
//  View for adding new to-do items
//

import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TodoViewModel
    @State private var todoTitle: String = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What do you need to do?")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextField("Enter task description", text: $todoTitle, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .lineLimit(3...6)
                        .submitLabel(.done)
                        .onSubmit {
                            addTodo()
                        }
                }
                .padding()

                Spacer()
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTodo()
                    }
                    .fontWeight(.semibold)
                    .disabled(todoTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                // Automatically focus the text field when view appears
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Helper Methods

    private func addTodo() {
        let trimmedTitle = todoTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        withAnimation {
            viewModel.addTodo(title: trimmedTitle)
        }
        dismiss()
    }
}

// MARK: - Preview

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView(viewModel: TodoViewModel())
    }
}
