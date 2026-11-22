import 'package:flutter/material.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';

class SessionDraft {
  final DateTime startAt;
  final int durationMinutes;
  final String meetingMode;
  const SessionDraft(this.startAt, this.durationMinutes, this.meetingMode);
}

/// Renvoie un SessionDraft via Navigator.pop.
class PlanSessionSheet extends StatefulWidget {
  final String otherName;
  final bool counter;
  const PlanSessionSheet({
    super.key,
    required this.otherName,
    this.counter = false,
  });

  @override
  State<PlanSessionSheet> createState() => _PlanSessionSheetState();
}

class _PlanSessionSheetState extends State<PlanSessionSheet> {
  DateTime? _date;
  TimeOfDay? _time;
  int _duration = 60;
  String _mode = MeetingMode.online;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    final d = _date!;
    final t = _time!;
    Navigator.of(context).pop(SessionDraft(
      DateTime(d.year, d.month, d.day, t.hour, t.minute),
      _duration,
      _mode,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final first = widget.otherName.trim().split(RegExp(r'\s+')).first;
    final pill = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(50),
      shape: const StadiumBorder(),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.counter
                    ? 'Suggest another time to $first'
                    : 'Plan a session with $first',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                style: pill,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(_date == null ? 'Pick a date' : DateFmt.date(_date!)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickTime,
                style: pill,
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(_time == null ? 'Pick a time' : _time!.format(context)),
              ),
              const SizedBox(height: 18),
              Text('Duration',
                  style: TextStyle(fontWeight: FontWeight.w700, color: muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in const [30, 45, 60, 90])
                    ChoiceChip(
                      showCheckmark: false,
                      label: Text('$m min'),
                      selected: _duration == m,
                      selectedColor: scheme.primary.withValues(alpha: 0.18),
                      onSelected: (_) => setState(() => _duration = m),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Where',
                  style: TextStyle(fontWeight: FontWeight.w700, color: muted)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: MeetingMode.online,
                      icon: Icon(Icons.videocam_outlined),
                      label: Text('Online'),
                    ),
                    ButtonSegment(
                      value: MeetingMode.inPerson,
                      icon: Icon(Icons.place_outlined),
                      label: Text('In person'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _date != null && _time != null ? _submit : null,
                child: Text(
                    widget.counter ? 'Send new proposal' : 'Propose session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}