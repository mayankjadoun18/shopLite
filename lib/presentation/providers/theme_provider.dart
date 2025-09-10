import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A StateProvider to manage the app's light/dark theme
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
