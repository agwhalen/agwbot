import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        ZStack {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarView(viewModel: viewModel)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
            } content: {
                contentView
                    .navigationSplitViewColumnWidth(min: 350, ideal: 450, max: .infinity)
            } detail: {
                TaskDetailView(viewModel: viewModel, task: $viewModel.selectedTask)
            }
            .navigationSplitViewStyle(.balanced)
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Button {
                        withAnimation {
                            columnVisibility = columnVisibility == .all ? .detailOnly : .all
                        }
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                    .help("Toggle Sidebar")
                }

                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        viewModel.selectedFilter = .search
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .keyboardShortcut("f", modifiers: .command)
                    .help("Search (⌘F)")

                    Button {
                        viewModel.isShowingQuickAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    .help("Add Task (⌘N)")

                    Button {
                        viewModel.isShowingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .help("Settings")
                }
            }

            // Quick add overlay
            if viewModel.isShowingQuickAdd {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.isShowingQuickAdd = false
                    }

                VStack {
                    Spacer()
                        .frame(height: 100)

                    QuickAddView(viewModel: viewModel, isPresented: $viewModel.isShowingQuickAdd)
                        .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.isShowingQuickAdd)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            setupKeyboardShortcuts()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedFilter {
        case .search:
            SearchView(viewModel: viewModel)
        default:
            TaskListView(viewModel: viewModel)
        }
    }

    private func setupKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Escape to close quick add or deselect task
            if event.keyCode == 53 { // Escape key
                if viewModel.isShowingQuickAdd {
                    viewModel.isShowingQuickAdd = false
                    return nil
                }
                if viewModel.selectedTask != nil {
                    viewModel.selectedTask = nil
                    return nil
                }
            }

            // Handle keyboard shortcuts for selected task
            if let task = viewModel.selectedTask {
                // Delete key
                if event.keyCode == 51 && event.modifierFlags.contains(.command) {
                    viewModel.deleteTodo(task)
                    viewModel.selectedTask = nil
                    return nil
                }

                // Enter to complete
                if event.keyCode == 36 && event.modifierFlags.contains(.command) {
                    viewModel.toggleTodo(task)
                    return nil
                }
            }

            return event
        }
    }
}

#Preview {
    MainView()
        .environmentObject(TodoViewModel())
}
