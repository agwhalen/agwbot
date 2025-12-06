import SwiftUI

@main
struct TodoistMacApp: App {
    @StateObject private var viewModel = TodoViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            // Custom commands
            CommandGroup(replacing: .newItem) {
                Button("New Task") {
                    viewModel.isShowingAddTask = true
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Quick Add") {
                    viewModel.isShowingQuickAdd = true
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }

            CommandGroup(after: .sidebar) {
                Divider()

                Button("Go to Inbox") {
                    viewModel.selectedFilter = .inbox
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Go to Today") {
                    viewModel.selectedFilter = .today
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("Go to Upcoming") {
                    viewModel.selectedFilter = .upcoming
                }
                .keyboardShortcut("3", modifiers: .command)

                Button("Go to Completed") {
                    viewModel.selectedFilter = .completed
                }
                .keyboardShortcut("4", modifiers: .command)
            }

            CommandGroup(replacing: .textEditing) {
                Button("Search") {
                    viewModel.selectedFilter = .search
                }
                .keyboardShortcut("f", modifiers: .command)
            }
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
