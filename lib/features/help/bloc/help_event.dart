part of 'help_bloc.dart';

@immutable
abstract class HelpEvent {}

class HelpInitialEvent extends HelpEvent {
  final String uid;
  HelpInitialEvent({required this.uid});
}

class HelpSendMessageEvent extends HelpEvent {
  final String uid;
  final String message;
  final String sender;
  HelpSendMessageEvent({
    required this.uid,
    required this.message,
    required this.sender,
  });
}

class HelpMessagesUpdated extends HelpEvent {
  final List<Map<String, dynamic>> messages;
  HelpMessagesUpdated({required this.messages});
}

