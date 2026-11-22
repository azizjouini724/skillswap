import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_chip.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_icons.dart';

/// Renvoie le nom de la compétence choisie via Navigator.pop.
class AddSkillSheet extends StatefulWidget {
  final SkillType type;
  final List<String> taken;

  const AddSkillSheet({super.key, required this.type, required this.taken});

  @override
  State<AddSkillSheet> createState() => _AddSkillSheetState();
}

class _AddSkillSheetState extends State<AddSkillSheet> {
  final _controller = TextEditingController();
  String _query = '';
  String? _categoryId;

  late final Set<String> _takenKeys =
      widget.taken.map(SkillCatalog.normalize).toSet();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
    

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final q = SkillCatalog.normalize(_query);

    final visible = SkillCatalog.skills.where((s) {
      final key = SkillCatalog.normalize(s.name);
      if (_takenKeys.contains(key)) return false;
      if (_categoryId != null && s.categoryId != _categoryId) return false;
      return q.isEmpty || key.contains(q);
    }).toList();

    final exactExists = _takenKeys.contains(q) ||
        SkillCatalog.skills.any((s) => SkillCatalog.normalize(s.name) == q);
    final showCustom = q.length >= 2 && !exactExists;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.72),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.type == SkillType.teach
                    ? 'Add a skill you can teach'
                    : 'Add a skill you want to learn',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search or type a skill',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in SkillCatalog.categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(SkillIcons.forCategory(c.id), size: 16),
                          label: Text(c.label),
                          selected: _categoryId == c.id,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.18),
                          onSelected: (_) => setState(() {
                            _categoryId = _categoryId == c.id ? null : c.id;
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showCustom)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.add_circle_outline_rounded,
                              color: AppColors.primary),
                          title: Text('Add "${_query.trim()}"'),
                          subtitle: const Text('Custom skill'),
                          onTap: () =>
                              Navigator.of(context).pop(_query.trim()),
                        ),
                      if (visible.isEmpty && !showCustom)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No skill found',
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in visible)
                            SkillChip(
                              label: s.name,
                              onTap: () => Navigator.of(context).pop(s.name),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}