class KpiInfo {
  final String title;
  final String fullName;
  final String question;
  final String targetTeam;
  final List<String>? verbatims;

  const KpiInfo({
    required this.title,
    required this.fullName,
    required this.question,
    required this.targetTeam,
    this.verbatims,
  });
}

const Map<String, KpiInfo> kpiInfoMap = {
  'ISGPP': KpiInfo(
    title: 'ISGPP',
    fullName: 'Indice de Satisfaction Globale du Parcours Patient',
    question:
    'Comment évaluez-vous la qualité de votre prise en charge médicale dans notre établissement ?',
    targetTeam: 'Ensemble du personnel soignant et administratif',
  ),
  'EMP': KpiInfo(
    title: 'EMP',
    fullName: 'Efficacité Médicale Perçue',
    question:
    'À l\'issue de cette visite, estimez-vous que vos attentes de soins ont été prises en compte ?',
    targetTeam: 'Corps médical · Équipe soignante',
  ),
  'VQPS': KpiInfo(
    title: 'VQPS',
    fullName: 'Vécu Qualitatif du Parcours de Soins',
    question:
    'Pouvez-vous nous raconter, avec vos propres mots, ce qui s\'est bien passé ou moins bien passé pendant votre parcours de soins ?',
    targetTeam: 'Médecins · Infirmiers · Aides-soignants · Personnel d\'accueil',
    verbatims: [
      'accueil', 'attente', 'empathie', 'écoute', 'médecin',
      'soins', 'douleur', 'explication', 'propreté',
      'manque d\'hygiène', 'coordination', 'orientation',
      'disponibilité du matériel',
    ],
  ),
  'MCR': KpiInfo(
    title: 'MCR',
    fullName: 'Moments Critiques & Réputation de l\'Établissement',
    question:
    'Quel a été le moment le plus marquant de votre parcours de soins lors de cette visite ?',
    targetTeam: 'Toutes équipes — indicateur direct de réputation',
    verbatims: [
      'geste soignant', 'soulagement', 'réconfort', 'douleur',
      'longue attente', 'indifférence', 'stress', 'interaction humaine',
      'compétence', 'confiance', 'propreté', 'structure', 'flexibilité',
    ],
  ),
  'IAR': KpiInfo(
    title: 'IAR',
    fullName: 'Indice d\'Amélioration & de Réputation',
    question:
    'Qu\'aurions-nous pu faire différemment pour mieux vous soulager et vous donner envie de nous recommander ?',
    targetTeam: 'Direction médicale · Responsable qualité · Tous services',
    verbatims: [
      'douleur', 'anxiété', 'attente', 'accueil', 'suivi',
      'propreté', 'compétence', 'disponibilité', 'facturation',
    ],
  ),
};