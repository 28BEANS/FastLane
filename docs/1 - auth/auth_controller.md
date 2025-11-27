# AuthController (auth_controller.dart)
AuthController manages form state, validation, UI visibility, and flows for login, registration, and password reset.

It communicates with AuthService to perform authentication operations.

## Overview
AuthController is a ChangeNotifier used to manage:
<ul>
<li>Input controllers for authentication forms</li>
<li>Login / register / forgot password UI state</li>
<li>User metadata storage (FireStore)</li>
<li>Username updates</li>
<li>Reauthentication and password reset from old password</li>
</ul>
A global <code>ValueNotifier<\AuthService\></code> is used to make the service reactive across the app.

## Functions
### 1. signIn()
```dart
Future<void> signIn(String email, String password)
```
<b>Purpose:</b>

Authenticates an existing user with email and password.

<b>Behavior:</b>
<li>Calls signInWithEmailAndPassword</li>
<li>Throws a FirebaseAuthException on error</li>

### 2. createAccount()
```dart
Future<void> createAccount({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  String? middleName,
})
```
<b>Purpose:</b>

Creates a new FirebaseAuth account and stores user profile info in Firestore.

<b>Behavior:</b>
<li>Creates the Firebase user</li>
<li>If successful, saves user information in Firestore</li>

### 3. signOut()
```dart
Future<void> signOut()
```
<b>Purpose:</b>

Logs out the current user.

### 4. resetPassword()
```dart
Future<void> resetPassword({required String email})
```
<b>Purpose:</b>

Sends a password reset email to the user.

### 5. createAccount()
```dart
Future<void> updateUsername({required String username})
```
<b>Purpose:</b>
Updates the display name of the currently signed-in user.

### 2. resetPasswordFromCurrentPassword()
```dart
Future<void> resetPasswordFromCurrentPassword({
  required String currentPassword,
  required String newPassword,
  required String email,
})
```
<b>Purpose:</b>

Changes the user password after reauthenticating with the current password.

<b>Behavior:</b>
<li>Reauthenticate with:</li>

```dart
EmailAuthProvider.credential(email: email, password: currentPassword)
```

<li>Update password using:</li>

```dart
currentUser!.updatePassword(newPassword)
```