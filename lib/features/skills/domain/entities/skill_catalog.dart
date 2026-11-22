class SkillCategory {
  final String id;
  final String label;
  const SkillCategory(this.id, this.label);
}

class CatalogSkill {
  final String name;
  final String categoryId;
  const CatalogSkill(this.name, this.categoryId);
}

class SkillCatalog {
  static const otherId = 'other';

  static const categories = <SkillCategory>[
    SkillCategory('tech', 'Tech'),
    SkillCategory('design', 'Design'),
    SkillCategory('languages', 'Languages'),
    SkillCategory('music', 'Music'),
    SkillCategory('business', 'Business'),
    SkillCategory('science', 'Science'),
    SkillCategory('lifestyle', 'Lifestyle'),
  ];

  static const skills = <CatalogSkill>[
    CatalogSkill('Flutter', 'tech'),
    CatalogSkill('Dart', 'tech'),
    CatalogSkill('Python', 'tech'),
    CatalogSkill('Java', 'tech'),
    CatalogSkill('Spring Boot', 'tech'),
    CatalogSkill('Web Development', 'tech'),
    CatalogSkill('React', 'tech'),
    CatalogSkill('SQL', 'tech'),
    CatalogSkill('Git', 'tech'),
    CatalogSkill('Cybersecurity', 'tech'),
    CatalogSkill('Data Analysis', 'tech'),
    CatalogSkill('Photoshop', 'design'),
    CatalogSkill('UI/UX Design', 'design'),
    CatalogSkill('Figma', 'design'),
    CatalogSkill('Illustrator', 'design'),
    CatalogSkill('Video Editing', 'design'),
    CatalogSkill('Photography', 'design'),
    CatalogSkill('Branding', 'design'),
    CatalogSkill('English', 'languages'),
    CatalogSkill('French', 'languages'),
    CatalogSkill('Arabic', 'languages'),
    CatalogSkill('Spanish', 'languages'),
    CatalogSkill('German', 'languages'),
    CatalogSkill('Italian', 'languages'),
    CatalogSkill('Guitar', 'music'),
    CatalogSkill('Piano', 'music'),
    CatalogSkill('Singing', 'music'),
    CatalogSkill('Music Production', 'music'),
    CatalogSkill('Marketing', 'business'),
    CatalogSkill('Public Speaking', 'business'),
    CatalogSkill('Excel', 'business'),
    CatalogSkill('Project Management', 'business'),
    CatalogSkill('Entrepreneurship', 'business'),
    CatalogSkill('Mathematics', 'science'),
    CatalogSkill('Physics', 'science'),
    CatalogSkill('Statistics', 'science'),
    CatalogSkill('Chemistry', 'science'),
    CatalogSkill('Cooking', 'lifestyle'),
    CatalogSkill('Fitness', 'lifestyle'),
    CatalogSkill('Chess', 'lifestyle'),
    CatalogSkill('Writing', 'lifestyle'),
    CatalogSkill('Drawing', 'lifestyle'),
  ];

  /// Clé de comparaison : "UI/UX  design" et "ui/ux design" sont identiques.
  static String normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String categoryOf(String skill) {
    final key = normalize(skill);
    for (final s in skills) {
      if (normalize(s.name) == key) return s.categoryId;
    }
    return otherId;
  }

  /// Nom canonique du catalogue, sinon première lettre en majuscule.
  static String displayName(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return '';
    final key = normalize(cleaned);
    for (final s in skills) {
      if (normalize(s.name) == key) return s.name;
    }
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}