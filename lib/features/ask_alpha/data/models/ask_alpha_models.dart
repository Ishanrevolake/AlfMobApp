class AskAlphaOrder {
  final String id;
  final String userId;
  final String name;
  final String meta;
  final String status;
  final String pack;
  final int credits;
  final num amount;
  final String? paymentSlipPath;
  final DateTime createdAt;

  const AskAlphaOrder({
    required this.id,
    required this.userId,
    required this.name,
    required this.meta,
    required this.status,
    required this.pack,
    required this.credits,
    required this.amount,
    this.paymentSlipPath,
    required this.createdAt,
  });

  factory AskAlphaOrder.fromJson(Map<String, dynamic> json) {
    final created = json['submitted_at'] ?? json['created_at'];
    return AskAlphaOrder(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['client_id'] ?? '').toString(),
      name: (json['product_title'] ?? json['name'] ?? 'Ask Alpha').toString(),
      meta: (json['reference'] ?? json['meta'] ?? 'Submitted').toString(),
      status: (json['status'] ?? 'pending_verification').toString(),
      pack: (json['product_id'] ?? json['pack'] ?? '').toString(),
      credits: _asInt(json['question_credits'] ?? 0),
      amount: _asNum(json['amount_lkr'] ?? json['amount'] ?? 0),
      paymentSlipPath: (json['slip_storage_path'] ?? json['payment_slip_path'])
          ?.toString(),
      createdAt: DateTime.tryParse(created?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static int _asInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
  static num _asNum(dynamic value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
}

class AskAlphaThread {
  final String id;
  final String orderId;
  final String userId;
  final String subject;
  final String status;
  final DateTime updatedAt;

  const AskAlphaThread({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.subject,
    required this.status,
    required this.updatedAt,
  });

  factory AskAlphaThread.fromJson(Map<String, dynamic> json) => AskAlphaThread(
    id: (json['id'] ?? '').toString(),
    orderId: (json['order_id'] ?? '').toString(),
    userId: (json['user_id'] ?? '').toString(),
    subject: (json['subject'] ?? 'Ask Alpha question').toString(),
    status: (json['status'] ?? 'open').toString(),
    updatedAt:
        DateTime.tryParse(
          (json['updated_at'] ?? json['created_at'] ?? '').toString(),
        ) ??
        DateTime.now(),
  );
}

class AskAlphaMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String senderRole;
  final String content;
  final DateTime createdAt;

  const AskAlphaMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  factory AskAlphaMessage.fromJson(Map<String, dynamic> json) =>
      AskAlphaMessage(
        id: (json['id'] ?? '').toString(),
        threadId: (json['thread_id'] ?? '').toString(),
        senderId: (json['sender_id'] ?? '').toString(),
        senderRole: (json['sender_role'] ?? 'client').toString(),
        content: (json['body'] ?? json['content'] ?? '').toString(),
        createdAt:
            DateTime.tryParse((json['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );
}
