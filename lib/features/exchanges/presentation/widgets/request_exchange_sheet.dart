import 'package:flutter/material.dart';
import 'package:skillswap/features/matching/domain/usecases/match_finder.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';

class RequestDraft {
  final String offered;
  final String requested;
  final String message;
  const RequestDraft(this.offered, this.requested, this.message);
}

/// Renvoie un RequestDraft via Navigator.pop.
class RequestExchangeSheet extends StatefulWidget {
  final ProfileEntity me;
  final ProfileEntity other;

  const RequestExchangeSheet({super.key, required this.me, required this.other});

  @override
  State<RequestExchangeSheet> createState() => _RequestExchangeSheetState();
}

class _RequestExchangeSheetState extends State<RequestExchangeSheet> {
  final _message = TextEditingController();
  String? _offered;
  String? _requested;

  @override
  void initState() {
    super.initState();
    final me = widget.me;
    final other = widget.other;

    // Pré-remplissage avec le Smart Match s'il existe.
    final matches = MatchFinder.find(me, [other]);
    if (matches.isNotEmpty) {
      _offered = matches.first.youTeach.first;
      _requested = matches.first.youLearn.first;
    } else {
      _offered = me.skillsToTeach.isEmpty ? null : me.skillsToTeach.first;
      _requested = other.skillsToTeach.isEmpty ? null : other.skillsToTeach.first;
    }
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Widget _options(List<String> skills, String? selected, ValueChanged<String> onPick) {
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in skills)
          ChoiceChip(
            showCheckmark: false,
            label: Text(s),
            selected: selected == s,
            selectedColor: primary.withValues(alpha: 0.18),
            onSelected: (_) => setState(() => onPick(s)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final me = widget.me;
    final other = widget.other;
    final first = other.name.trim().split(RegExp(r'\s+')).first;

    final blocked = me.skillsToTeach.isEmpty || other.skillsToTeach.isEmpty;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request an exchange with $first',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (blocked)
                Text(
                  me.skillsToTeach.isEmpty
                      ? 'Add a skill you can teach in your profile first.'
                      : '$first does not teach any skill yet.',
                  style: TextStyle(color: muted, height: 1.4),
                )
              else ...[
                Text('I teach',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: muted)),
                const SizedBox(height: 8),
                _options(me.skillsToTeach, _offered, (s) => _offered = s),
                const SizedBox(height: 16),
                Text('I want to learn',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: muted)),
                const SizedBox(height: 8),
                _options(
                    other.skillsToTeach, _requested, (s) => _requested = s),
                const SizedBox(height: 16),
                TextField(
                  controller: _message,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Message (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: blocked || _offered == null || _requested == null
                    ? null
                    : () => Navigator.of(context).pop(RequestDraft(
                          _offered!,
                          _requested!,
                          _message.text.trim(),
                        )),
                child: const Text('Send request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}