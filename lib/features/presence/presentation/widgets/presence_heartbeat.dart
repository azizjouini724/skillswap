import 'dart:async';

import 'package:flutter/material.dart';

/// Appelle [onBeat] au démarrage, toutes les 2 minutes tant que l'app est
/// au premier plan, et à chaque retour au premier plan.
class PresenceHeartbeat extends StatefulWidget {
  final VoidCallback onBeat;
  final Widget child;

  const PresenceHeartbeat({
    super.key,
    required this.onBeat,
    required this.child,
  });

  @override
  State<PresenceHeartbeat> createState() => _PresenceHeartbeatState();
}

class _PresenceHeartbeatState extends State<PresenceHeartbeat>
    with WidgetsBindingObserver {
  static const _interval = Duration(minutes: 2);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  void _start() {
    _timer?.cancel();
    widget.onBeat();
    _timer = Timer.periodic(_interval, (_) => widget.onBeat());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}