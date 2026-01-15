class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String? message;
  final String? file;
  final String createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.file,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      file: json['file'],
      createdAt: json['created_at'],
    );
  }
}
