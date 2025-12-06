import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TodoViewModel
    @AppStorage("defaultView") private var defaultView = "inbox"
    @AppStorage("showCompletedTasks") private var showCompletedTasks = true
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete = true
    @AppStorage("autoArchiveCompleted") private var autoArchiveCompleted = false

    var body: some View {
        TabView {
            GeneralSettingsView(
                defaultView: $defaultView,
                showCompletedTasks: $showCompletedTasks,
                confirmBeforeDelete: $confirmBeforeDelete,
                autoArchiveCompleted: $autoArchiveCompleted
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }

            KeyboardShortcutsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            DataManagementView(viewModel: viewModel)
                .tabItem {
                    Label("Data", systemImage: "externaldrive")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct GeneralSettingsView: View {
    @Binding var defaultView: String
    @Binding var showCompletedTasks: Bool
    @Binding var confirmBeforeDelete: Bool
    @Binding var autoArchiveCompleted: Bool

    var body: some View {
        Form {
            Picker("Default view", selection: $defaultView) {
                Text("Inbox").tag("inbox")
                Text("Today").tag("today")
                Text("Upcoming").tag("upcoming")
            }

            Toggle("Show completed tasks in lists", isOn: $showCompletedTasks)

            Toggle("Confirm before deleting tasks", isOn: $confirmBeforeDelete)

            Toggle("Auto-archive completed tasks after 7 days", isOn: $autoArchiveCompleted)
        }
        .padding()
    }
}

struct KeyboardShortcutsView: View {
    var body: some View {
        Form {
            Section("Global") {
                ShortcutRow(action: "Quick Add Task", shortcut: "⌘ N")
                ShortcutRow(action: "Search", shortcut: "⌘ F")
                ShortcutRow(action: "Go to Inbox", shortcut: "⌘ 1")
                ShortcutRow(action: "Go to Today", shortcut: "⌘ 2")
                ShortcutRow(action: "Go to Upcoming", shortcut: "⌘ 3")
            }

            Section("Task Actions") {
                ShortcutRow(action: "Complete Task", shortcut: "⌘ ⏎")
                ShortcutRow(action: "Delete Task", shortcut: "⌘ ⌫")
                ShortcutRow(action: "Edit Task", shortcut: "⌘ E")
                ShortcutRow(action: "Set Priority 1", shortcut: "⌘ 1")
                ShortcutRow(action: "Set Priority 2", shortcut: "⌘ 2")
                ShortcutRow(action: "Set Priority 3", shortcut: "⌘ 3")
                ShortcutRow(action: "Set Priority 4", shortcut: "⌘ 4")
            }

            Section("Due Dates") {
                ShortcutRow(action: "Set Due Today", shortcut: "T")
                ShortcutRow(action: "Set Due Tomorrow", shortcut: "M")
                ShortcutRow(action: "Set Due Next Week", shortcut: "W")
                ShortcutRow(action: "Remove Due Date", shortcut: "R")
            }
        }
        .padding()
    }
}

struct ShortcutRow: View {
    let action: String
    let shortcut: String

    var body: some View {
        HStack {
            Text(action)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

struct DataManagementView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var showingClearAlert = false
    @State private var exportMessage = ""
    @State private var showingExportMessage = false

    var body: some View {
        Form {
            Section("Statistics") {
                LabeledContent("Total Tasks", value: "\(viewModel.todos.count)")
                LabeledContent("Completed", value: "\(viewModel.completedCount)")
                LabeledContent("Active", value: "\(viewModel.todos.count - viewModel.completedCount)")
                LabeledContent("Projects", value: "\(viewModel.projects.count)")
                LabeledContent("Labels", value: "\(viewModel.allLabels.count)")
            }

            Section("Actions") {
                Button("Export Data") {
                    exportData()
                }

                Button("Clear Completed Tasks") {
                    viewModel.clearCompleted()
                }

                Button("Clear All Data", role: .destructive) {
                    showingClearAlert = true
                }
            }
        }
        .padding()
        .alert("Clear All Data?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all tasks, projects, and labels. This action cannot be undone.")
        }
        .alert("Export", isPresented: $showingExportMessage) {
            Button("OK") {}
        } message: {
            Text(exportMessage)
        }
    }

    private func exportData() {
        let data: [String: Any] = [
            "tasks": viewModel.todos.count,
            "projects": viewModel.projects.count,
            "exportDate": Date().description
        ]

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "todoist-export.json"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted

                    struct ExportData: Codable {
                        let todos: [TodoItem]
                        let projects: [Project]
                        let labels: [Label]
                        let exportDate: Date
                    }

                    let exportData = ExportData(
                        todos: viewModel.todos,
                        projects: viewModel.projects,
                        labels: viewModel.labels,
                        exportDate: Date()
                    )

                    let jsonData = try encoder.encode(exportData)
                    try jsonData.write(to: url)
                    exportMessage = "Data exported successfully!"
                } catch {
                    exportMessage = "Export failed: \(error.localizedDescription)"
                }
                showingExportMessage = true
            }
        }
    }

    private func clearAllData() {
        viewModel.todos.removeAll()
        viewModel.projects.removeAll()
        viewModel.labels.removeAll()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            Text("TodoistMac")
                .font(.title.bold())

            Text("Version 1.0")
                .foregroundStyle(.secondary)

            Text("A powerful task management app for macOS")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()

            Text("Built with SwiftUI")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

#Preview {
    SettingsView(viewModel: TodoViewModel())
}
