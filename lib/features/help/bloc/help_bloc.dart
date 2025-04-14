import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:online_shop/database/user_database.dart';
import 'package:online_shop/models/user.dart';

part 'help_event.dart';
part 'help_state.dart';

class HelpBloc extends Bloc<HelpEvent, HelpState> {
  StreamSubscription? _messageSubscription;
  HelpBloc() : super(HelpInitial()) {
    on<HelpInitialEvent>(_onHelpInitialEvent);
    on<HelpMessagesUpdated>(_onHelpMessagesUpdated);
    on<HelpSendMessageEvent>(_onHelpSendMessageEvent);
  }

  FutureOr<void> _onHelpInitialEvent(
    HelpInitialEvent event,
    Emitter<HelpState> emit,
  ) async {
    final uid = event.uid;
    final UserDatabase db = UserDatabase(uid: uid);
    emit(HelpLoadingState());

    await _messageSubscription?.cancel();

    _messageSubscription = db.getMessagesStream().listen(
      (messages) {
        add(HelpMessagesUpdated(messages: messages));
      },
      onError: (error) {
        addError(error); // Or emit HelpErrorState directly here
      },
    );
  }

  FutureOr<void> _onHelpMessagesUpdated(
    HelpMessagesUpdated event,
    Emitter<HelpState> emit,
  ) {
    emit(HelpLoadedState(message: event.messages));
  }

  FutureOr<void> _onHelpSendMessageEvent(
    HelpSendMessageEvent event,
    Emitter<HelpState> emit,
  ) async {
    final uid = event.uid;
    final UserDatabase db = UserDatabase(uid: uid);
    try {
      await db.sendMessage(event.message, event.sender);
    } catch (e) {}
  }
}
