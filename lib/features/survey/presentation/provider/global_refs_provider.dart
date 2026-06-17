import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/provider/auth_provider.dart';


class GlobalRefs {
  final List<String> services;
  final List<String> aftercares;
  final List<String> visitTypes;
  final List<String> explorations;

  const GlobalRefs({
    required this.services,
    required this.aftercares,
    required this.visitTypes,
    required this.explorations,
  });

  factory GlobalRefs.fromMap(Map<String, dynamic> lists) {
    List<String> _toStringList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return GlobalRefs(
      services:   _toStringList(lists['services']),
      aftercares: _toStringList(lists['aftercares']),
      visitTypes: _toStringList(lists['visit_types']),
      explorations: _toStringList(lists['explorations']),
    );
  }

  static const empty = GlobalRefs(
    services: [],
    aftercares: [],
    visitTypes: [],
    explorations: [],
  );
}

final globalRefsProvider = FutureProvider<GlobalRefs>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);

  final data = await supabase
      .from('global_references')
      .select('lists')
      .limit(1)
      .maybeSingle();

  if (data == null) return GlobalRefs.empty;

  final lists = data['lists'];
  if (lists == null) return GlobalRefs.empty;

  return GlobalRefs.fromMap(Map<String, dynamic>.from(lists as Map));
});