import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ecosnap_1/models/snap_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnapStateService with ChangeNotifier {
  SnapStateService._internal();
  static final SnapStateService instance = SnapStateService._internal();

  static const String _ecoCountKey = 'ecoActionsCount';
  late SharedPreferences _prefs;

  final String _apiKey = "";

  int ecoActionsCount = 0;
  final int maxEcoActions = 4;

  final Map<String, List<Snap>> _unreadSnaps = {};

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    ecoActionsCount = _prefs.getInt(_ecoCountKey) ?? 0;
  }

  Future<void> _saveEcoActionsCount(int newScore) async {
    if (newScore <= maxEcoActions) {
      ecoActionsCount = newScore;
      await _prefs.setInt(_ecoCountKey, ecoActionsCount);
    }
  }

  // This function is now the main driver.
  Future<String> addSnap(Set<String> users, Snap snap) async {
    // **** CHANGE 1: Pass the user's description to the Gemini function ****
    final int newScore =
        await _getNewScoreFromGemini(snap.imagePath, snap.userDescription);

    bool scoreIncreased = newScore > ecoActionsCount;
    await _saveEcoActionsCount(newScore);
    snap.aiDescription =
        scoreIncreased ? "Eco-friendly action! +1 Point" : "A nice snap!";

    if (scoreIncreased) {
      notifyListeners();
    }

    for (final user in users) {
      _unreadSnaps.putIfAbsent(user, () => []);
      _unreadSnaps[user]!.add(snap);
    }
    return snap.aiDescription!;
  }

  // This function now returns the new score.
  // **** CHANGE 2: Accept the user's description as a parameter ****
 // In snap_state_service.dart

Future<int> _getNewScoreFromGemini(
    String imagePath, String? userDescription) async {
  try {
    final imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey");

    String prompt = """
    Analyze the image and description to determine if it shows an eco-friendly action.
    Give strong preference to the user's text description.
    The user's current score is $ecoActionsCount.
    The user's description is: "${userDescription ?? 'None'}"

    - If it IS an eco-friendly action (like recycling, reusing, conserving), increment the score by 1.
    - If it is NOT an eco-friendly action, DO NOT change the score.

    Respond ONLY with a valid JSON object with a single key "newScore" containing the resulting integer score.
    Example for eco-friendly: {"newScore": ${ecoActionsCount + 1}}
    Example for not eco-friendly: {"newScore": $ecoActionsCount}
    """;

    final requestBody = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"inline_data": {"mime_type": "image/jpeg", "data": base64Image}},
            {"text": prompt}
          ]
        }
      ],
    });

    final response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: requestBody);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String rawContent =
          data["candidates"]?[0]["content"]?["parts"]?[0]["text"]?.trim() ??
              '{}';
      print("✅ Gemini Raw Response: $rawContent");

      // **** THIS IS THE FIX ****
      // 1. Find the start and end of the JSON object within the raw string.
      final int jsonStart = rawContent.indexOf('{');
      final int jsonEnd = rawContent.lastIndexOf('}');

      // 2. If we found a valid JSON object, extract it.
      if (jsonStart != -1 && jsonEnd != -1) {
        final String extractedJson = rawContent.substring(jsonStart, jsonEnd + 1);
        print("✅ Extracted Clean JSON: $extractedJson");
        
        final result = jsonDecode(extractedJson);
        return result['newScore'] ?? ecoActionsCount;
      } else {
        // If no JSON object is found, return the old score.
        print("❌ Could not extract JSON from response.");
        return ecoActionsCount;
      }
      
    } else {
      print("❌ Gemini API Error: ${response.statusCode} ${response.body}");
      return ecoActionsCount;
    }
  } catch (e) {
    print("❌ Error during API call: $e");
    return ecoActionsCount;
  }
}
  // These functions remain the same.
  bool hasUnreadSnaps(String userName) =>
      _unreadSnaps[userName]?.isNotEmpty ?? false;
  List<Snap>? getUnreadSnaps(String userName) => _unreadSnaps[userName];
  void clearSnaps(String userName) => _unreadSnaps.remove(userName);
}