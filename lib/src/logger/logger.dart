import 'package:logger/logger.dart';

// create own logging logic for the mesh library
final logger = Logger(
  printer: SimplePrinter(
    colors: false,
    printTime: true,
  ),
);
