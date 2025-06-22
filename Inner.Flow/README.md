# Inner Flow - iOS Mood Tracking App

A beautiful iOS app for tracking daily moods and reflections, built with SwiftUI and Firebase.

## Features

### 🔐 Authentication
- Email/password sign up and sign in
- Password reset functionality
- Secure user authentication with Firebase Auth

### 📊 Dashboard
- Overview of recent mood trends
- Quick access to create new daily logs
- Summary statistics and recent activity

### 📝 Daily Logs
- Create detailed mood entries with emoji selection
- Add notes and reflections
- Track activities and daily events
- View and edit previous entries

### 📈 Analytics
- Visual mood trends over time
- Mood distribution analysis
- Activity frequency tracking
- Customizable timeframes (week, month, 3 months)

### ⚙️ Settings
- User profile management
- Notification preferences
- App settings and preferences
- Account management

## Design

- **Color Palette**: Purple theme with primary color #8A7CFF
- **Modern UI**: Clean, card-based design with smooth animations
- **Responsive**: Optimized for all iOS devices
- **Accessible**: Built with accessibility in mind

## Tech Stack

- **Frontend**: SwiftUI
- **Backend**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Firestore
- **State Management**: ObservableObject with @Published properties
- **Architecture**: MVVM pattern

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Firebase account

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable Email/Password authentication
4. Enable Firestore:
   - Go to Firestore Database
   - Create database in test mode
   - Set up security rules (see below)
5. Add iOS app to your Firebase project:
   - Click "Add app" > iOS
   - Enter your bundle identifier
   - Download the `GoogleService-Info.plist` file

### 2. Project Setup

1. Open the project in Xcode
2. Replace the placeholder `GoogleService-Info.plist` with your actual Firebase configuration file
3. Update the bundle identifier in Xcode to match your Firebase project
4. Add Firebase SDK dependencies:
   - In Xcode, go to File > Add Package Dependencies
   - Add: `https://github.com/firebase/firebase-ios-sdk.git`
   - Select the following products:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseFirestoreSwift

### 3. Firestore Security Rules

Set up the following security rules in your Firestore database:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can access their own daily logs
      match /daily_logs/{logId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 4. Build and Run

1. Select your target device or simulator
2. Build and run the project (⌘+R)
3. The app should launch and show the authentication screen

## Project Structure

```
Inner.Flow/
├── Inner.Flow/
│   ├── Inner_FlowApp.swift          # Main app entry point
│   ├── ContentView.swift            # Root view with auth logic
│   ├── GoogleService-Info.plist     # Firebase configuration
│   ├── Models/                      # Data models
│   │   ├── UserProfile.swift
│   │   └── DailyLog.swift
│   ├── Managers/                    # Business logic
│   │   ├── AuthenticationManager.swift
│   │   └── DataManager.swift
│   ├── Theme/                       # Design system
│   │   └── AppTheme.swift
│   └── Views/                       # UI components
│       ├── Authentication/
│       │   ├── AuthenticationView.swift
│       │   ├── SignInView.swift
│       │   ├── SignUpView.swift
│       │   └── ForgotPasswordView.swift
│       ├── Main/
│       │   └── MainTabView.swift
│       ├── Dashboard/
│       │   └── DashboardView.swift
│       ├── DailyLog/
│       │   ├── DailyLogView.swift
│       │   ├── DailyLogFormView.swift
│       │   └── DailyLogDetailView.swift
│       ├── Analytics/
│       │   └── AnalyticsView.swift
│       └── Settings/
│           ├── SettingsView.swift
│           └── ProfileEditView.swift
```

## Key Features Implementation

### Authentication Flow
- Uses Firebase Auth for secure user authentication
- Automatic profile creation on sign up
- Persistent login state

### Data Management
- Firestore for real-time data synchronization
- Optimistic updates for better UX
- Proper error handling and loading states

### UI/UX
- Consistent design system with custom colors and typography
- Smooth animations and transitions
- Responsive layout for all screen sizes
- Loading indicators and error states

### Analytics
- Custom chart implementation for mood trends
- Statistical analysis of user data
- Activity tracking and insights

## Customization

### Colors
Edit `AppTheme.swift` to customize the color palette:

```swift
static let primary = Color(hex: "8A7CFF")      // Main purple
static let secondary = Color(hex: "B8B0FF")    // Light purple
static let tertiary = Color(hex: "E0DDFF")     // Very light purple
static let background = Color(hex: "F8F7FF")   // Background color
```

### Features
- Add new mood emojis in `DailyLog.swift`
- Modify available activities in `DailyLogFormView.swift`
- Customize analytics timeframes in `AnalyticsView.swift`

## Troubleshooting

### Common Issues

1. **Firebase not configured**
   - Ensure `GoogleService-Info.plist` is properly added to the project
   - Check that Firebase SDK dependencies are installed

2. **Authentication errors**
   - Verify Firebase Auth is enabled in the console
   - Check network connectivity

3. **Data not loading**
   - Ensure Firestore rules allow read/write access
   - Check Firebase console for any errors

4. **Build errors**
   - Clean build folder (⌘+Shift+K)
   - Check that all dependencies are properly linked

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions, please open an issue in the repository or contact the development team.

---

**Note**: This is a template project. You'll need to configure Firebase with your own project settings and replace the placeholder configuration files with your actual Firebase credentials. 