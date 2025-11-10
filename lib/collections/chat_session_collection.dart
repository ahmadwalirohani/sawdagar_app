import 'package:afghan_bazar/models/chat_session_model.dart';

class ChatSessionCollection {
  List<ChatSessionModel> chats;

  ChatSessionCollection({required this.chats});

  // Deserialize a JSON list into a collection of AdDetails objects
  factory ChatSessionCollection.fromJson(List<dynamic> jsonList) {
    List<ChatSessionModel> chats = jsonList
        .map((json) => ChatSessionModel.fromJson(json))
        .toList();
    return ChatSessionCollection(chats: chats);
  }

  // Serialize the collection of AdDetails objects to a JSON list
  List<Map<String, dynamic>> toJson() {
    return chats.map((chat) => chat.toJson()).toList();
  }
}
