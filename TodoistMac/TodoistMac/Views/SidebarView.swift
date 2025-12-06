import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var isAddingProject = false
    @State private var newProjectName = ""

    var body: some View {
        List(selection: $viewModel.selectedFilter) {
            Section {
                NavigationLink(value: SidebarFilter.inbox) {
                    Label {
                        HStack {
                            Text("Inbox")
                            Spacer()
                            if viewModel.inboxCount > 0 {
                                Text("\(viewModel.inboxCount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "tray.fill")
                            .foregroundStyle(.blue)
                    }
                }

                NavigationLink(value: SidebarFilter.today) {
                    Label {
                        HStack {
                            Text("Today")
                            Spacer()
                            if viewModel.todayTasksCount > 0 {
                                Text("\(viewModel.todayTasksCount)")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(viewModel.overdueTasksCount > 0 ? Color.red : Color.green)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.green)
                    }
                }

                NavigationLink(value: SidebarFilter.upcoming) {
                    Label {
                        HStack {
                            Text("Upcoming")
                            Spacer()
                            if viewModel.upcomingCount > 0 {
                                Text("\(viewModel.upcomingCount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(.purple)
                    }
                }

                NavigationLink(value: SidebarFilter.calendar) {
                    Label {
                        Text("Calendar")
                    } icon: {
                        Image(systemName: "calendar.day.timeline.left")
                            .foregroundStyle(.orange)
                    }
                }

                NavigationLink(value: SidebarFilter.completed) {
                    Label {
                        HStack {
                            Text("Completed")
                            Spacer()
                            if viewModel.completedCount > 0 {
                                Text("\(viewModel.completedCount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }

            Section("Favorites") {
                ForEach(viewModel.projects.filter { $0.isFavorite }) { project in
                    NavigationLink(value: SidebarFilter.project(project.id)) {
                        Label {
                            HStack {
                                Text(project.name)
                                Spacer()
                                if viewModel.taskCount(for: project) > 0 {
                                    Text("\(viewModel.taskCount(for: project))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: project.icon)
                                .foregroundStyle(project.color.color)
                        }
                    }
                    .contextMenu {
                        ProjectContextMenu(project: project, viewModel: viewModel)
                    }
                }
            }

            Section("Projects") {
                ForEach(viewModel.projects.filter { !$0.isFavorite && !$0.isArchived }) { project in
                    NavigationLink(value: SidebarFilter.project(project.id)) {
                        Label {
                            HStack {
                                Text(project.name)
                                Spacer()
                                if viewModel.taskCount(for: project) > 0 {
                                    Text("\(viewModel.taskCount(for: project))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: project.icon)
                                .foregroundStyle(project.color.color)
                        }
                    }
                    .contextMenu {
                        ProjectContextMenu(project: project, viewModel: viewModel)
                    }
                }

                Button {
                    isAddingProject = true
                } label: {
                    Label("Add Project", systemImage: "plus")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if !viewModel.allLabels.isEmpty {
                Section("Labels") {
                    ForEach(viewModel.allLabels, id: \.self) { label in
                        NavigationLink(value: SidebarFilter.label(label)) {
                            Label(label, systemImage: "tag")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
        .sheet(isPresented: $isAddingProject) {
            AddProjectSheet(viewModel: viewModel, isPresented: $isAddingProject)
        }
    }
}

struct ProjectContextMenu: View {
    let project: Project
    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        Button {
            viewModel.toggleProjectFavorite(project)
        } label: {
            Label(project.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                  systemImage: project.isFavorite ? "star.slash" : "star")
        }

        Divider()

        Button(role: .destructive) {
            viewModel.deleteProject(project)
        } label: {
            Label("Delete Project", systemImage: "trash")
        }
    }
}

struct AddProjectSheet: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var selectedColor: ProjectColor = .blue
    @State private var selectedIcon = "folder"
    @FocusState private var isFocused: Bool

    let icons = ["folder", "book", "briefcase", "house", "heart", "star", "flag", "bolt", "gear", "graduationcap"]

    var body: some View {
        VStack(spacing: 20) {
            Text("New Project")
                .font(.headline)

            TextField("Project name", text: $name)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)

            VStack(alignment: .leading, spacing: 8) {
                Text("Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(30)), count: 6), spacing: 8) {
                    ForEach(ProjectColor.allCases, id: \.self) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 24, height: 24)
                            .overlay {
                                if selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Icon")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(36)), count: 5), spacing: 8) {
                    ForEach(icons, id: \.self) { icon in
                        Image(systemName: icon)
                            .frame(width: 30, height: 30)
                            .background(selectedIcon == icon ? selectedColor.color.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .onTapGesture {
                                selectedIcon = icon
                            }
                    }
                }
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Add Project") {
                    if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.addProject(name: name, color: selectedColor, icon: selectedIcon)
                        isPresented = false
                    }
                }
                .keyboardShortcut(.return)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    SidebarView(viewModel: TodoViewModel())
}
