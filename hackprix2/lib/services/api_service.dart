// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/message.dart'; // Import the new Message model
import '../models/organisation.dart'; // Import the Organisation model
import '../models/charity.dart'; // Import the Charity model

class ApiService {
  static const String _baseUrl = 'http://65.2.83.136:3000/api';
  
  // This remains private
  final String _mockUserId = 'dabe0791-c4cc-40d0-9dad-383202e70b46';

  // NEW: Public getter to safely access the user ID from other files
  String get currentUserId => _mockUserId;
  
  // This function is now updated to expect 'otherUsername' from the backend
  Future<List<Conversation>> getConversations() async {
    final uri = Uri.parse('$_baseUrl/chat/conversations');
    final response = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: json.encode({ 'userId': _mockUserId }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> conversationsJson = json.decode(response.body);
      return conversationsJson.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations: ${response.body}');
    }
  }

  // Function to get message history for a chat
  Future<List<Message>> getMessages(String otherUserId) async {
    final uri = Uri.parse('$_baseUrl/chat/messages/history');
    final response = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: json.encode({
        'userId': _mockUserId,
        'otherUserId': otherUserId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = json.decode(response.body);
      return messagesJson.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.body}');
    }
  }

  // Function to send a new message
  Future<void> sendMessage(String receiverId, String content) async {
    final uri = Uri.parse('$_baseUrl/chat/messages');
    final response = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: json.encode({
        'senderId': _mockUserId,
        'receiverId': receiverId,
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
   Future<List<Organisation>> listOrganizations() async {
    final uri = Uri.parse('$_baseUrl/orgs/');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> orgsJson = json.decode(response.body);
        return orgsJson.map((json) => Organisation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load organizations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Signs the current user up for a specific organization
  Future<void> signupForOrganization(String orgId) async {
    final uri = Uri.parse('$_baseUrl/orgs/$orgId/signup');
    try {
      final response = await http.post(
        uri,
        headers: { 'Content-Type': 'application/json' },
        body: json.encode({ 'userId': _mockUserId }),
      );
      
      // Handle cases where the user is already signed up (409 Conflict)
      if (response.statusCode == 409) {
        // We can treat this as a success in the UI since the goal is to be "joined"
        return; 
      }
      
      if (response.statusCode != 200) {
        throw Exception('Failed to join organization: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // NEW: Function to get IDs of organizations the user has joined
  Future<Set<String>> getJoinedOrganizationIds() async {
    // Uses the public getter 'currentUserId'
    final uri = Uri.parse('$_baseUrl/orgs/user/$currentUserId');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> orgIdsJson = json.decode(response.body);
        // Convert to a Set for fast checking
        return orgIdsJson.cast<String>().toSet();
      } else {
        throw Exception('Failed to load joined organizations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  Future<List<Charity>> listCharities() async {
    final uri = Uri.parse('$_baseUrl/charities');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Charity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load charities');
    }
  }

  Future<Set<String>> getJoinedCharityIds() async {
    final uri = Uri.parse('$_baseUrl/charities/user/$currentUserId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<String>().toSet();
    } else {
      throw Exception('Failed to load joined charities');
    }
  }

  Future<void> signupForCharity(String charityId) async {
    final uri = Uri.parse('$_baseUrl/charities/$charityId/signup');
    final response = await http.post(
      uri,
      headers: { 'Content-Type': 'application/json' },
      body: json.encode({ 'userId': _mockUserId }),
    );
    if (response.statusCode != 200 && response.statusCode != 409) {
      throw Exception('Failed to join charity');
    }
  }
}
