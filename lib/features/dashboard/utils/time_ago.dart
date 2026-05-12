String timeAgo(DateTime date) {
  final Duration diff = DateTime.now().difference(date);

  if (diff.inDays >= 30) {
    // Calcul du nombre de mois (division entière)
    final int months = (diff.inDays / 30).floor();
    return "$months mois"; // 'mois' est invariant en français (pas de 's' supplémentaire)
  } else if (diff.inDays >= 1) {
    return "${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}";
  } else if (diff.inHours >= 1) {
    return "${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}";
  } else if (diff.inMinutes >= 1) {
    return "${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}";
  } else {
    return "à l'instant";
  }
}