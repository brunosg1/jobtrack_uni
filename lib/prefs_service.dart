import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jobtrack_uni/domain/entities/job_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Chaves de persistência definidas no PRD.
class PrefsKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String policiesVersionAccepted = 'policies_version_accepted';
  static const String privacyRead = 'privacy_read_v1';
  static const String termsRead = 'terms_read_v1';
  static const String acceptedAt = 'accepted_at';
  static const String jobCards = 'job_cards'; // Nova chave
  static const String themeMode = 'theme_mode';
  static const String lastSyncAt = 'last_sync_at';
}

class PrefsService {
  late SharedPreferences _prefs;
  static const String _currentPoliciesVersion = 'v1';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Onboarding ---
  bool getOnboardingCompleted() => _prefs.getBool(PrefsKeys.onboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(PrefsKeys.onboardingCompleted, value);

  // --- Políticas e Consentimento ---
  String getPoliciesVersionAccepted() => _prefs.getString(PrefsKeys.policiesVersionAccepted) ?? '';
  Future<void> setPoliciesVersionAccepted(String version) => _prefs.setString(PrefsKeys.policiesVersionAccepted, version);
  
  bool getPrivacyPolicyRead() => _prefs.getBool(PrefsKeys.privacyRead) ?? false;
  Future<void> setPrivacyPolicyRead(bool value) => _prefs.setBool(PrefsKeys.privacyRead, value);

  bool getTermsOfUseRead() => _prefs.getBool(PrefsKeys.termsRead) ?? false;
  Future<void> setTermsOfUseRead(bool value) => _prefs.setBool(PrefsKeys.termsRead, value);
  
  Future<void> saveConsent() async {
    await setPoliciesVersionAccepted(_currentPoliciesVersion);
    await _prefs.setString(PrefsKeys.acceptedAt, DateTime.now().toIso8601String());
    await setOnboardingCompleted(true);
  }
  
  Future<void> revokeConsent() async {
    await _prefs.remove(PrefsKeys.policiesVersionAccepted);
    await _prefs.remove(PrefsKeys.acceptedAt);
  }
  
  bool hasAcceptedCurrentPolicies() {
    return getPoliciesVersionAccepted() == _currentPoliciesVersion;
  }

  // --- Gerenciamento de Cards de Vaga ---
  Future<void> saveJobCards(List<JobCard> cards) async {
    final List<String> cardsJson = cards.map((card) => jsonEncode(card.toJson())).toList();
    await _prefs.setStringList(PrefsKeys.jobCards, cardsJson);
  }

  List<JobCard> getJobCards() {
    final List<String> cardsJson = _prefs.getStringList(PrefsKeys.jobCards) ?? [];
    return cardsJson.map((cardString) => JobCard.fromJson(jsonDecode(cardString))).toList();
  }

  // Limpa todas as preferências (útil para testes).
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Limpa somente os dados de cache do app (ex.: job cards), preservando
  // configurações e consentimento.
  Future<void> clearCache() async {
    await _prefs.remove(PrefsKeys.jobCards);
  }

  // --- Theme mode persistence ---
  Future<void> setThemeMode(ThemeMode mode) async {
    final String str;
    switch (mode) {
      case ThemeMode.light:
        str = 'light';
        break;
      case ThemeMode.dark:
        str = 'dark';
        break;
      case ThemeMode.system:
        str = 'system';
        break;
    }
    await _prefs.setString(PrefsKeys.themeMode, str);
  }

  ThemeMode getThemeMode() {
    final value = _prefs.getString(PrefsKeys.themeMode) ?? 'system';
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // --- Last sync timestamp ---
  Future<void> setLastSyncAt(DateTime at) async {
    await _prefs.setString(PrefsKeys.lastSyncAt, at.toIso8601String());
  }

  DateTime? getLastSyncAt() {
    final s = _prefs.getString(PrefsKeys.lastSyncAt);
    if (s == null) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}
