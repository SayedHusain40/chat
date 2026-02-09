import 'package:firebase_auth/firebase_auth.dart';

String getFirebaseAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'The email address is not valid.';

    case 'invalid-credential':
      return 'Incorrect email or password.';

    case 'email-already-in-use':
      return 'This email is already registered.';

    case 'weak-password':
      return 'Password is too weak.';

    case 'user-disabled':
      return 'This account has been disabled.';

    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';

    case 'network-request-failed':
      return 'No internet connection.';

    default:
      return 'Authentication failed. Please try again.';
  }
}

String getFirestoreMessage(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'You do not have permission to perform this action.';

    case 'unavailable':
      return 'Service is currently unavailable. Please try again later.';

    case 'not-found':
      return 'Requested data was not found.';

    case 'already-exists':
      return 'This data already exists.';

    case 'cancelled':
      return 'Request was cancelled.';

    case 'deadline-exceeded':
      return 'Request timeout. Please try again.';

    case 'resource-exhausted':
      return 'Too many requests. Please wait and try again.';

    case 'invalid-argument':
      return 'Invalid data provided.';

    default:
      return 'Something went wrong. Please try again.';
  }
}
