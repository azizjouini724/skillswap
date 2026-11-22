class Validators {
  static String? required(String? v, [String field = 'Ce champ']) {
    if (v == null || v.trim().isEmpty) return '$field est obligatoire';
    return null;
  }

  static String? email(String? v) {
    final e = v?.trim() ?? '';
    if (e.isEmpty) return "L'email est obligatoire";
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(e) ? null : 'Email invalide';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Le mot de passe est obligatoire';
    if (v.length < 6) return 'Minimum 6 caractères';
    return null;
  }
}