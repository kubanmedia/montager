import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'video_database.dart';

final getIt = GetIt.instance;

/// Initializes the dependency injection container with database services
void configureDependencies() {
  // Register the database as a singleton
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase.getInstance());
  
  // Additional service registrations can go here
}

/// Convenience getter for the database instance
AppDatabase get database => getIt<AppDatabase>();