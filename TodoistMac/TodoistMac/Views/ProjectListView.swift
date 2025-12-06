import SwiftUI

struct ProjectListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var isAddingProject = false
    @State private var editingProject: Project?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Projects")
                    .font(.title2.bold())

                Spacer()

                Button {
                    isAddingProject = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if viewModel.projects.isEmpty {
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "folder")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)

                    Text("No projects yet")
                        .font(.headline)

                    Text("Create projects to organize your tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Create Project") {
                        isAddingProject = true
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }
            } else {
                List {
                    Section("Favorites") {
                        ForEach(viewModel.projects.filter { $0.isFavorite }) { project in
                            ProjectRow(project: project, viewModel: viewModel, onEdit: {
                                editingProject = project
                            })
                        }
                    }

                    Section("All Projects") {
                        ForEach(viewModel.projects.filter { !$0.isFavorite && !$0.isArchived }) { project in
                            ProjectRow(project: project, viewModel: viewModel, onEdit: {
                                editingProject = project
                            })
                        }
                    }

                    if viewModel.projects.contains(where: { $0.isArchived }) {
                        Section("Archived") {
                            ForEach(viewModel.projects.filter { $0.isArchived }) { project in
                                ProjectRow(project: project, viewModel: viewModel, onEdit: {
                                    editingProject = project
                                })
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .sheet(isPresented: $isAddingProject) {
            AddProjectSheet(viewModel: viewModel, isPresented: $isAddingProject)
        }
        .sheet(item: $editingProject) { project in
            EditProjectSheet(viewModel: viewModel, project: project, isPresented: Binding(
                get: { editingProject != nil },
                set: { if !$0 { editingProject = nil } }
            ))
        }
    }
}

struct ProjectRow: View {
    let project: Project
    @ObservedObject var viewModel: TodoViewModel
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: project.icon)
                .foregroundStyle(project.color.color)
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(project.name)
                    .fontWeight(.medium)

                Text("\(viewModel.taskCount(for: project)) tasks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if project.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

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
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EditProjectSheet: View {
    @ObservedObject var viewModel: TodoViewModel
    let project: Project
    @Binding var isPresented: Bool

    @State private var name: String
    @State private var selectedColor: ProjectColor
    @State private var selectedIcon: String
    @State private var isFavorite: Bool

    let icons = ["folder", "book", "briefcase", "house", "heart", "star", "flag", "bolt", "gear", "graduationcap"]

    init(viewModel: TodoViewModel, project: Project, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.project = project
        self._isPresented = isPresented
        self._name = State(initialValue: project.name)
        self._selectedColor = State(initialValue: project.color)
        self._selectedIcon = State(initialValue: project.icon)
        self._isFavorite = State(initialValue: project.isFavorite)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Project")
                .font(.headline)

            TextField("Project name", text: $name)
                .textFieldStyle(.roundedBorder)

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

            Toggle("Favorite", isOn: $isFavorite)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Spacer()

                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }

    private func saveChanges() {
        var updatedProject = project
        updatedProject.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedProject.color = selectedColor
        updatedProject.icon = selectedIcon
        updatedProject.isFavorite = isFavorite

        viewModel.updateProject(updatedProject)
        isPresented = false
    }
}

#Preview {
    ProjectListView(viewModel: TodoViewModel())
}
