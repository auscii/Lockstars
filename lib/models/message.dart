import 'package:cloud_firestore/cloud_firestore.dart';

class messagesForMe {
  String? towhom;
  String? title;
  String? message;
  Timestamp? logtime;
  String? type;

  messagesForMe({
    required this.towhom,
    required this.title,
    required this.message,
    required this.type,
    required this.logtime,
  });
}

class mnotifications {
  messagesForMe data;
  mnotifications({
    required this.data,
  });
}

class mcharges {
  messagesForMe data;
  mcharges({
    required this.data,
  });
}
