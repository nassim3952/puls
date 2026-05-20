// lib/core/provider/notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import 'auth_provider.dart';


class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final SupabaseClient _supabase;
  final String? _hospitalId;
  RealtimeChannel? _channel;

  NotificationsNotifier(this._supabase, this._hospitalId)
      : super(const NotificationsState()) {
    if (_hospitalId != null) {
      _loadNotifications();
      _subscribeRealtime();
    }
  }

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = _supabase.auth.currentUser?.id;
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('hospital_id', _hospitalId!)
          .or('user_id.eq.$uid,user_id.is.null')
          .order('created_at', ascending: false)
          .limit(50);

      final notifs = (data as List)
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(notifications: notifs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _subscribeRealtime() {
    _channel = _supabase
        .channel('notifications:$_hospitalId')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'hospital_id',
        value: _hospitalId!,
      ),
      callback: (payload) {
        final newNotif = NotificationModel.fromMap(
          payload.newRecord as Map<String, dynamic>,
        );
        // On n'ajoute que si ciblée pour cet user ou broadcast
        final uid = _supabase.auth.currentUser?.id;
        if (newNotif.userId == null || newNotif.userId == uid) {
          state = state.copyWith(
            notifications: [newNotif, ...state.notifications],
          );
        }
      },
    )
        .subscribe();
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notifId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', notifId);

      state = state.copyWith(
        notifications: state.notifications.map((n) {
          return n.id == notifId
              ? n.copyWith(isRead: true, readAt: DateTime.now())
              : n;
        }).toList(),
      );
    } catch (_) {}
  }

  /// Tout marquer comme lu
  Future<void> markAllAsRead() async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('hospital_id', _hospitalId!)
          .eq('is_read', false)
          .or('user_id.eq.$uid,user_id.is.null');

      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
            .toList(),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

// ── Provider public ───────────────────────────────────────────────────────────
final notificationsProvider =
StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final authState = ref.watch(authProvider);
  final hospitalId = authState.user?.hospitalId;

  return NotificationsNotifier(supabase, hospitalId);
});

// Raccourci : nombre de non-lus
final unreadNotifCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});