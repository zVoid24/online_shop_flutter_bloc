import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:online_shop/features/help/bloc/help_bloc.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final HelpBloc _helpBloc = HelpBloc();
  final user = FirebaseAuth.instance.currentUser;
  late String uid;
  TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (user == null) {
      print('No user signed in');
      uid = '';
    } else {
      uid = user!.uid;
      print('User UID: $uid');
      _helpBloc.add(HelpInitialEvent(uid: uid));
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose ScrollController
    _messageController.dispose();
    _helpBloc.close();
    super.dispose();
  }

  // Helper method to scroll to bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF328E6E),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<HelpBloc, HelpState>(
              bloc: _helpBloc,
              listenWhen: (previous, current) => current is HelpActionState,
              buildWhen: (previous, current) => current is! HelpActionState,
              listener: (context, state) {
                if (state is HelpSentFailureState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      duration: Duration(seconds: 1),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is HelpSentSuccessState) {
                  _messageController.clear();
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                switch (state.runtimeType) {
                  case HelpLoadingState:
                    return Center(
                      child: SpinKitSpinningLines(
                        color: Color(0xFF328E6E),
                        size: 50.0,
                      ),
                    );
                  case HelpErrorState:
                    return Center(
                      child: Text(
                        'No help requests at the moment.${(state as HelpErrorState).error}',
                      ),
                    );
                  case HelpLoadedState:
                    final messages = (state as HelpLoadedState).message;
                    if (messages.isEmpty) {
                      return Center(child: Text('No messages available.'));
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isUser = message['sender'] == 'user';
                        return Align(
                          alignment:
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color:
                                  isUser
                                      ? const Color(0xFF328E6E)
                                      : Color(0xFF328E6E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['text'] ?? '',
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  message['timestamp']?.toString() ??
                                      'Unknown time',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color:
                                        isUser
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  default:
                    return Center(
                      child: Text('No help requests at the moment.'),
                    );
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 1, 16, 0),
            child: const Divider(thickness: 1),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF328E6E),
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF328E6E),
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF328E6E)),
                    onPressed: () {
                      final text = _messageController.text.trim();
                      if (text.isEmpty) return;
                      _helpBloc.add(
                        HelpSendMessageEvent(
                          uid: uid,
                          message: text,
                          sender: 'user',
                        ),
                      );
                      _messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
