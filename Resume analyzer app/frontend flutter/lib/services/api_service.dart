import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// A single ranked candidate returned by the `/analyze-job` endpoint.
class CandidateResult {
  final String name;
  final double score;

  const CandidateResult({required this.name, required this.score});

  factory CandidateResult.fromJson(Map<String, dynamic> json) {
    return CandidateResult(
      name: (json['name'] as String?) ?? 'Unknown candidate',
      score: ((json['score'] as num?) ?? 0).toDouble(),
    );
  }
}

/// Full response payload from `/analyze-job`.
class AnalysisResponse {
  final String jobRole;
  final int totalResumes;
  final List<CandidateResult> results;

  const AnalysisResponse({
    required this.jobRole,
    required this.totalResumes,
    required this.results,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = (json['results'] as List<dynamic>?) ?? const [];
    final results = rawResults.map((e) => CandidateResult.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return AnalysisResponse(
      jobRole: (json['job_role'] as String?) ?? '',
      totalResumes: (json['total_resumes'] as int?) ?? results.length,
      results: results,
    );
  }
}

/// User-facing exception thrown for any failure in [ApiService.analyzeJob].
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Handles all communication with the FastAPI backend.
///
/// Treats the backend as a black box: it only guarantees the correct
/// multipart request shape and safe parsing of the documented response
/// format.
class ApiService {
  ApiService._internal();

  static final ApiService instance = ApiService._internal();

  /// Android emulator loopback address for the host machine's localhost.
  /// Update this if you're running on a physical device or iOS simulator.
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String analyzeEndpoint = '/analyze-job';

  bool _isRequestInFlight = false;

  /// Prevents accidental duplicate submissions (e.g. double-tapping the
  /// Analyze button while a request is already in flight).
  bool get isRequestInFlight => _isRequestInFlight;

  Future<AnalysisResponse> analyzeJob({
    required String jobRole,
    required List<String> skills,
    required int experience,
    required List<File> files,
  }) async {
    if (_isRequestInFlight) {
      throw const ApiException('An analysis is already in progress. Please wait.');
    }
    if (jobRole.trim().isEmpty) {
      throw const ApiException('Please enter a job role.');
    }
    if (skills.isEmpty) {
      throw const ApiException('Please add at least one required skill.');
    }
    if (files.isEmpty) {
      throw const ApiException('Please select at least one resume to analyze.');
    }

    _isRequestInFlight = true;
    try {
      final uri = Uri.parse('$baseUrl$analyzeEndpoint');
      final request = http.MultipartRequest('POST', uri)
        ..fields['job_role'] = jobRole.trim()
        ..fields['skills'] = skills.join(',')
        ..fields['experience'] = experience.toString();

      for (final file in files) {
        request.files.add(await http.MultipartFile.fromPath('files', file.path));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return AnalysisResponse.fromJson(decoded);
      } else {
        throw ApiException('Server error (${response.statusCode}). Please try again.');
      }
    } on SocketException {
      throw const ApiException('Could not connect to the server. Check your connection and try again.');
    } on FormatException {
      throw const ApiException('Received an unexpected response from the server.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Something went wrong: $e');
    } finally {
      _isRequestInFlight = false;
    }
  }
}
