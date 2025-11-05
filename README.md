# TodoTracker - iOS Daily To-Do List App

A simple and elegant iOS application for tracking your daily to-do list, built with SwiftUI.

## Features

- **Add Tasks**: Quickly add new tasks to your to-do list
- **Mark Complete**: Tap tasks to mark them as complete or incomplete
- **Delete Tasks**: Swipe to delete tasks you no longer need
- **Progress Tracking**: Visual progress bar showing completion percentage
- **Data Persistence**: All tasks are automatically saved using UserDefaults
- **Clean UI**: Modern, intuitive interface following iOS design guidelines
- **Empty State**: Helpful guidance when your list is empty

## Requirements

- iOS 15.0 or later
- Xcode 15.0 or later
- Swift 5.0 or later

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd agwbot
   ```

2. Open the project in Xcode:
   ```bash
   open TodoTracker/TodoTracker.xcodeproj
   ```

3. Select your target device or simulator

4. Click the Run button (⌘R) to build and run the app

## Project Structure

```
TodoTracker/
├── TodoTracker.xcodeproj/
│   └── project.pbxproj          # Xcode project configuration
└── TodoTracker/
    ├── TodoTrackerApp.swift      # App entry point
    ├── ContentView.swift         # Main view with to-do list
    ├── AddTodoView.swift         # View for adding new tasks
    ├── TodoItem.swift            # Data model for to-do items
    ├── TodoViewModel.swift       # ViewModel with business logic
    └── Assets.xcassets/          # App assets and icons
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architectural pattern:

- **Model** (`TodoItem.swift`): Defines the data structure for to-do items with Codable support for persistence
- **View** (`ContentView.swift`, `AddTodoView.swift`): SwiftUI views that display the UI
- **ViewModel** (`TodoViewModel.swift`): Manages app state, business logic, and data persistence

## Key Features Implementation

### Data Persistence
Tasks are automatically saved to UserDefaults whenever changes are made. The app loads saved tasks when launched, ensuring your to-do list persists between sessions.

### Task Management
- **Add**: Tap the "+" button in the navigation bar to add a new task
- **Complete**: Tap any task or its checkbox to toggle completion status
- **Delete**: Swipe left on a task to reveal the delete button

### Progress Tracking
The progress indicator shows:
- Number of completed tasks vs. total tasks
- Visual progress bar
- Percentage completion

## Code Highlights

### TodoItem Model
```swift
struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdDate: Date
    var completedDate: Date?
}
```

### TodoViewModel
Handles all CRUD operations and persistence:
- `addTodo(title:)`: Add a new task
- `toggleTodo(todo:)`: Toggle completion status
- `deleteTodo(at:)`: Delete tasks
- `saveTodos()`: Persist to UserDefaults
- `loadTodos()`: Load from UserDefaults

## Customization

### Change the App's Bundle Identifier
Open the project in Xcode, select the TodoTracker target, and modify the Bundle Identifier in the Signing & Capabilities tab.

### Customize Colors
The app uses system colors for adaptability. To customize:
1. Open `Assets.xcassets/AccentColor.colorset`
2. Modify the color values in the Contents.json file

### Add Icons
To add a custom app icon:
1. Prepare a 1024x1024 PNG image
2. Add it to `Assets.xcassets/AppIcon.appiconset/`

## Future Enhancements

Potential features for future versions:
- Categories or tags for tasks
- Due dates and reminders
- Priority levels
- Search and filter functionality
- iCloud sync across devices
- Widget support
- Dark mode customization

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
