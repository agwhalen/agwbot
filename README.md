# TodoTracker & TodoistMac - Task Management Apps

A collection of elegant task management applications for Apple platforms, built with SwiftUI.

## Apps

### TodoistMac - macOS Task Manager

A powerful, Todoist-inspired task management app for macOS with a three-column layout, projects, priorities, and more.

**Features:**
- **Sidebar Navigation**: Quick access to Inbox, Today, Upcoming, and Completed views
- **Projects**: Organize tasks into color-coded projects with custom icons
- **Priority Levels**: Four priority levels (P1-P4) with visual indicators
- **Due Dates**: Set and manage due dates with smart date suggestions
- **Labels/Tags**: Categorize tasks with multiple labels
- **Subtasks**: Break down tasks into smaller, manageable subtasks
- **Quick Add**: Fast task entry with keyboard shortcut (⌘N)
- **Search**: Full-text search across all tasks
- **Keyboard Shortcuts**: Efficient navigation with keyboard commands
- **Data Persistence**: Automatic saving with UserDefaults
- **Dark Mode**: Full support for macOS dark and light modes

### TodoTracker - iOS To-Do List

A simple and elegant iOS application for tracking your daily to-do list.

**Features:**
- **Add Tasks**: Quickly add new tasks to your to-do list
- **Mark Complete**: Tap tasks to mark them as complete or incomplete
- **Delete Tasks**: Swipe to delete tasks you no longer need
- **Progress Tracking**: Visual progress bar showing completion percentage
- **Data Persistence**: All tasks are automatically saved using UserDefaults

## Requirements

### TodoistMac (macOS)
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later

### TodoTracker (iOS)
- iOS 15.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later

## Installation

### macOS App (TodoistMac)

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd agwbot
   ```

2. Open the project in Xcode:
   ```bash
   open TodoistMac/TodoistMac.xcodeproj
   ```

3. Click the Run button (⌘R) to build and run the app

### iOS App (TodoTracker)

1. Open the project in Xcode:
   ```bash
   open TodoTracker/TodoTracker.xcodeproj
   ```

2. Select your target device or simulator

3. Click the Run button (⌘R) to build and run the app

## Project Structure

```
agwbot/
├── TodoistMac/                         # macOS Todoist-like App
│   ├── TodoistMac.xcodeproj/
│   └── TodoistMac/
│       ├── TodoistMacApp.swift         # App entry point with commands
│       ├── MainView.swift              # Main navigation view
│       ├── Models/
│       │   ├── TodoItem.swift          # Task data model
│       │   └── Project.swift           # Project & label models
│       ├── ViewModels/
│       │   └── TodoViewModel.swift     # Business logic & persistence
│       ├── Views/
│       │   ├── SidebarView.swift       # Left sidebar navigation
│       │   ├── TaskListView.swift      # Task list display
│       │   ├── TaskRowView.swift       # Individual task row
│       │   ├── TaskDetailView.swift    # Task editing panel
│       │   ├── AddTaskView.swift       # Add task dialog
│       │   ├── QuickAddView.swift      # Quick add overlay
│       │   ├── ProjectListView.swift   # Project management
│       │   ├── SearchView.swift        # Search functionality
│       │   └── SettingsView.swift      # App settings
│       ├── Utilities/
│       │   └── Extensions.swift        # Helper extensions
│       └── Assets.xcassets/
│
└── TodoTracker/                        # iOS Simple Todo App
    ├── TodoTracker.xcodeproj/
    └── TodoTracker/
        ├── TodoTrackerApp.swift
        ├── ContentView.swift
        ├── AddTodoView.swift
        ├── TodoItem.swift
        ├── TodoViewModel.swift
        └── Assets.xcassets/
```

## TodoistMac Architecture

The macOS app follows the MVVM (Model-View-ViewModel) pattern with a three-column NavigationSplitView:

### Models
- **TodoItem**: Task with title, description, priority, due date, labels, subtasks
- **Project**: Task container with name, color, and icon
- **Priority**: Enum with urgent, high, medium, low, none levels
- **Label**: Tag for categorizing tasks

### ViewModel
- **TodoViewModel**: Central state management with:
  - CRUD operations for tasks, projects, and labels
  - Smart filtering (inbox, today, upcoming, completed, by project/label)
  - Sorting options (due date, priority, alphabetical, created date)
  - Auto-save with Combine debouncing
  - Search functionality

### Views
- **MainView**: Three-column layout with sidebar, content, and detail
- **SidebarView**: Navigation with smart badges and project list
- **TaskListView**: Filtered task display with sorting
- **TaskDetailView**: Full task editing with subtasks and labels
- **QuickAddView**: Modal quick task entry

## Keyboard Shortcuts (macOS)

| Shortcut | Action |
|----------|--------|
| ⌘N | New Task |
| ⇧⌘N | Quick Add |
| ⌘F | Search |
| ⌘1 | Go to Inbox |
| ⌘2 | Go to Today |
| ⌘3 | Go to Upcoming |
| ⌘4 | Go to Completed |
| ⌘⏎ | Complete Selected Task |
| ⌘⌫ | Delete Selected Task |
| Esc | Close/Deselect |

## Data Model

### TodoItem
```swift
struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var projectId: UUID?
    var labels: [String]
    var subtasks: [Subtask]
    var createdDate: Date
    var completedDate: Date?
}
```

### Priority
```swift
enum Priority: Int, Codable, CaseIterable {
    case none = 0
    case low = 1      // P4 - Blue
    case medium = 2   // P3 - Yellow
    case high = 3     // P2 - Orange
    case urgent = 4   // P1 - Red
}
```

## Customization

### Changing Colors
1. Open `Assets.xcassets/AccentColor.colorset`
2. Modify the color values for light and dark modes

### Adding App Icons
1. Prepare a 1024x1024 PNG image
2. Add it to `Assets.xcassets/AppIcon.appiconset/`

### Modifying Project Colors
Edit the `ProjectColor` enum in `Project.swift` to add custom colors.

## Future Enhancements

- iCloud sync across devices
- Recurring tasks
- Reminders and notifications
- Calendar integration
- Widget support
- Import/Export functionality
- Collaboration features

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
