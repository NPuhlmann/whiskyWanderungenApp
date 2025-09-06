import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling service to sanitize error messages
/// and prevent sensitive information leakage
class ErrorHandler {
  static const bool _isDebugMode = bool.fromEnvironment('dart.vm.product') == false;

  /// Sanitize error messages by removing sensitive information
  static String sanitizeError(dynamic error) {
    if (error == null) return 'Unknown error occurred';

    final errorString = error.toString().toLowerCase();
    
    // Remove sensitive patterns
    final sensitivePatterns = [
      RegExp(r'api[_\-]key[:\s=]+[a-zA-Z0-9]+', caseSensitive: false),
      RegExp(r'secret[:\s=]+[a-zA-Z0-9]+', caseSensitive: false),
      RegExp(r'token[:\s=]+[a-zA-Z0-9]+', caseSensitive: false),
      RegExp(r'password[:\s=]+[^\s]+', caseSensitive: false),
      RegExp(r'sbp_[a-zA-Z0-9]+', caseSensitive: false), // Supabase tokens
    ];

    String sanitized = error.toString();
    for (final pattern in sensitivePatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED]');
    }

    return sanitized;
  }

  /// Get user-friendly error message based on error type
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'Ein unbekannter Fehler ist aufgetreten';

    final errorString = error.toString().toLowerCase();

    // Network related errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung.';
    }

    // Authentication errors
    if (errorString.contains('permission') || 
        errorString.contains('unauthorized') ||
        errorString.contains('access denied')) {
      return 'Keine Berechtigung für diese Aktion.';
    }

    // Database errors
    if (error is PostgrestException) {
      switch (error.code) {
        case 'PGRST116': // No rows returned
          return 'Keine Daten gefunden.';
        case 'PGRST301': // Permission denied
          return 'Keine Berechtigung für diese Aktion.';
        default:
          return 'Datenbankfehler. Bitte versuchen Sie es später erneut.';
      }
    }

    // Storage errors
    if (errorString.contains('storage') || errorString.contains('bucket')) {
      return 'Fehler beim Speichern der Datei.';
    }

    // Platform specific errors
    if (errorString.contains('platformexception')) {
      return 'Plattformspezifischer Fehler. Dies kann im Simulator auftreten.';
    }

    // Default fallback
    return 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.';
  }

  /// Log error with appropriate level and sanitization
  static void logError(String context, dynamic error, {StackTrace? stackTrace}) {
    if (_isDebugMode) {
      // In debug mode, log full error for development
      dev.log(
        'Error in $context: $error',
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      // In production, log sanitized error
      dev.log(
        'Error in $context: ${sanitizeError(error)}',
        error: sanitizeError(error),
      );
    }
  }

  /// Create a safe exception with user-friendly message
  static Exception createSafeException(String context, dynamic originalError) {
    logError(context, originalError);
    return Exception(getUserFriendlyMessage(originalError));
  }
}