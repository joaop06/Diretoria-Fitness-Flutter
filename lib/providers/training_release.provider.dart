import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/training_release.service.dart';

class TrainingReleaseProvider with ChangeNotifier {
  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final TrainingReleaseService _trainingReleaseService;
  TrainingReleaseProvider(this._trainingReleaseService);

  Future<String> create({
    required Uint8List image,
    required Map<String, dynamic> trainingRelease,
  }) async {
    return await _trainingReleaseService.create(
      image: image,
      trainingRelease: trainingRelease,
    );
  }
}
