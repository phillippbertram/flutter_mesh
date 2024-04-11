import 'package:logger/logger.dart';

// create own logging logic for the mesh library
final logger = Logger(
  printer: PrettyPrinter(
    colors: false,
    printTime: true,
    methodCount: 1,
  ),
);
