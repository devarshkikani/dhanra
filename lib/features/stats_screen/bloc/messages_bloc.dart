import 'package:flutter_bloc/flutter_bloc.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final SmsParserService smsParserService;
  MessagesBloc({required this.smsParserService})
      : super(const MessagesState()) {
    on<LoadMessagesData>(_onLoadMessagesData);
  }

  Future<void> _onLoadMessagesData(
    LoadMessagesData event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      emit(state.copyWith(
          status: MessagesStatus.loading, statusMessage: 'Loading...'));
      // Here you would fetch and process SMS for the selected month
      // For now, just emit success with empty data
      // TODO: Integrate actual SMS fetching logic
      emit(state.copyWith(
          status: MessagesStatus.success, statusMessage: 'Loaded'));
    } catch (e) {
      emit(state.copyWith(
          status: MessagesStatus.failure, statusMessage: e.toString()));
    }
  }
}
