import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/insurance_profile.dart';

/// Thrown when the Aura backend cannot be reached or returns an error.
class AuraApiException implements Exception {
  final String message;
  const AuraApiException(this.message);

  @override
  String toString() => 'AuraApiException: $message';
}

/// A single chat turn exchanged with the backend.
class ChatTurn {
  final String role; // 'user' | 'assistant'
  final String content;

  const ChatTurn({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// A selectable option (Claude-style guided choice) returned by the backend.
/// Shown as a tappable chip; [value] is sent as the user's next message.
class AuraOption {
  final String label;
  final String value;

  const AuraOption({required this.label, required this.value});

  factory AuraOption.fromJson(Map<String, dynamic> json) => AuraOption(
        label: (json['label'] ?? '').toString(),
        value: (json['value'] ?? '').toString(),
      );
}

/// The deterministic calculation block from the backend (Python owns all math).
class AuraCalculations {
  final double? incomeNeeded;
  final double? totalDebts;
  final double? futureGoals;
  final double? existingCoverage;
  final double? recommendedCoverage;
  final bool isComplete;
  final List<String> missingFields;
  final List<AuraBreakdownItem> breakdown;
  final String? explanation;

  const AuraCalculations({
    this.incomeNeeded,
    this.totalDebts,
    this.futureGoals,
    this.existingCoverage,
    this.recommendedCoverage,
    required this.isComplete,
    required this.missingFields,
    required this.breakdown,
    this.explanation,
  });

  factory AuraCalculations.fromJson(Map<String, dynamic> json) {
    return AuraCalculations(
      incomeNeeded: _toDouble(json['income_needed']),
      totalDebts: _toDouble(json['total_debts']),
      futureGoals: _toDouble(json['future_goals']),
      existingCoverage: _toDouble(json['existing_coverage']),
      recommendedCoverage: _toDouble(json['recommended_coverage']),
      isComplete: json['is_complete'] == true,
      missingFields: ((json['missing_fields'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      breakdown: ((json['breakdown'] as List?) ?? const [])
          .map((e) => AuraBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String?,
    );
  }
}

/// One line of the DIME waterfall (e.g. "Income replacement", add, 900000).
class AuraBreakdownItem {
  final String label;
  final double amount;
  final String operation; // 'add' | 'subtract'

  const AuraBreakdownItem({
    required this.label,
    required this.amount,
    required this.operation,
  });

  factory AuraBreakdownItem.fromJson(Map<String, dynamic> json) =>
      AuraBreakdownItem(
        label: (json['label'] ?? '').toString(),
        amount: _toDouble(json['amount']) ?? 0,
        operation: (json['operation'] ?? 'add').toString(),
      );
}

/// Profile fields the backend extracted from the conversation (any may be null).
class AuraProfile {
  final int? dependentsCount;
  final int? yearsOfSupport;
  final double? annualIncome;
  final double? totalDebts;
  final double? futureGoals;
  final double? existingCoverage;

  const AuraProfile({
    this.dependentsCount,
    this.yearsOfSupport,
    this.annualIncome,
    this.totalDebts,
    this.futureGoals,
    this.existingCoverage,
  });

  factory AuraProfile.fromJson(Map<String, dynamic> json) => AuraProfile(
        dependentsCount: _toInt(json['dependents_count']),
        yearsOfSupport: _toInt(json['years_of_support']),
        annualIncome: _toDouble(json['annual_income']),
        totalDebts: _toDouble(json['total_debts']),
        futureGoals: _toDouble(json['future_goals']),
        existingCoverage: _toDouble(json['existing_coverage']),
      );

  /// Merge the extracted values into the app's [InsuranceProfile], keeping any
  /// existing value when the backend hasn't learned that field yet (null).
  InsuranceProfile mergeInto(InsuranceProfile base) {
    return base.copyWith(
      dependents: dependentsCount ?? base.dependents,
      annualIncome: annualIncome ?? base.annualIncome,
      debts: totalDebts ?? base.debts,
      futureNeeds: futureGoals ?? base.futureNeeds,
      existingCoverage: existingCoverage ?? base.existingCoverage,
    );
  }
}

/// The full `/chat` response.
class AuraChatResponse {
  final String reply;
  final AuraProfile profile;
  final AuraCalculations calculations;
  final List<AuraOption> options;
  final String? disclaimer;

  const AuraChatResponse({
    required this.reply,
    required this.profile,
    required this.calculations,
    required this.options,
    this.disclaimer,
  });

  factory AuraChatResponse.fromJson(Map<String, dynamic> json) {
    return AuraChatResponse(
      reply: (json['reply'] ?? '').toString(),
      profile: AuraProfile.fromJson(
          (json['extracted_profile'] as Map?)?.cast<String, dynamic>() ?? {}),
      calculations: AuraCalculations.fromJson(
          (json['calculations'] as Map?)?.cast<String, dynamic>() ?? {}),
      options: ((json['options'] as List?) ?? const [])
          .map((e) => AuraOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String?,
    );
  }
}

/// Client for the Lincoln Life "Aura" backend.
///
/// Base URL is read from the `AURA_API_BASE_URL` dart-define so you can point at
/// a deployed server without editing code:
///   flutter run --dart-define=AURA_API_BASE_URL=https://your-host
///
/// Default resolves to localhost, with the Android emulator's 10.0.2.2 alias so
/// the app reaches a backend running on the host machine.
class AuraApi {
  final String baseUrl;
  final http.Client _client;

  AuraApi({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _client = client ?? http.Client();

  static String _defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('AURA_API_BASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    // Android emulator cannot see the host as "localhost"; 10.0.2.2 is the alias.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  /// Send the full conversation and get Aura's next turn.
  Future<AuraChatResponse> chat(List<ChatTurn> messages) async {
    final uri = Uri.parse('$baseUrl/chat');
    try {
      final res = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'messages': messages.map((m) => m.toJson()).toList()}),
          )
          .timeout(const Duration(seconds: 45));

      if (res.statusCode != 200) {
        throw AuraApiException('Backend returned ${res.statusCode}: ${res.body}');
      }
      return AuraChatResponse.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on AuraApiException {
      rethrow;
    } catch (e) {
      throw AuraApiException('Could not reach Aura at $baseUrl ($e)');
    }
  }

  /// Get the personalized term-vs-permanent comparison (stretch goal).
  /// Returns null if the profile is incomplete (backend responds 422) so the
  /// caller can show static copy instead.
  Future<AuraTradeoff?> tradeoffs(AuraProfile profile) async {
    final uri = Uri.parse('$baseUrl/tradeoffs');
    try {
      final res = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'profile': {
                'dependents_count': profile.dependentsCount,
                'years_of_support': profile.yearsOfSupport,
                'annual_income': profile.annualIncome,
                'total_debts': profile.totalDebts,
                'future_goals': profile.futureGoals,
                'existing_coverage': profile.existingCoverage,
              },
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (res.statusCode == 422) return null; // incomplete profile
      if (res.statusCode != 200) {
        throw AuraApiException('Backend returned ${res.statusCode}: ${res.body}');
      }
      return AuraTradeoff.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on AuraApiException {
      rethrow;
    } catch (e) {
      throw AuraApiException('Could not reach Aura at $baseUrl ($e)');
    }
  }

  void dispose() => _client.close();
}

/// The `/tradeoffs` response: term vs Lincoln's permanent options (IUL/VUL).
class AuraTradeoff {
  final String tradeoffAnalysis;
  final String termFit;
  final String permanentFit;
  final List<String> keyTradeoffs;
  final String nextStep;
  final String? disclaimer;

  const AuraTradeoff({
    required this.tradeoffAnalysis,
    required this.termFit,
    required this.permanentFit,
    required this.keyTradeoffs,
    required this.nextStep,
    this.disclaimer,
  });

  factory AuraTradeoff.fromJson(Map<String, dynamic> json) => AuraTradeoff(
        tradeoffAnalysis: (json['tradeoff_analysis'] ?? '').toString(),
        termFit: (json['term_fit'] ?? '').toString(),
        permanentFit: (json['permanent_fit'] ?? '').toString(),
        keyTradeoffs: ((json['key_tradeoffs'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        nextStep: (json['next_step'] ?? '').toString(),
        disclaimer: json['disclaimer'] as String?,
      );
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
