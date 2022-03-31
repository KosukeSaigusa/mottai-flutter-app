import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mottai_flutter_app_models/models.dart';

part 'room_page_state.freezed.dart';

@freezed
class RoomPageState with _$RoomPageState {
  const factory RoomPageState({
    @Default(true) bool loading,
    @Default(false) bool sending,
    @Default(false) bool isValid,
    @Default(<Message>[]) List<Message> messages,
    @Default(true) bool hasNext,
    DateTime? lastVisibleCreatedAt,
    QueryDocumentSnapshot<Message>? lastVisibleQds,
  }) = _RoomPageState;
}
