import 'dart:convert';

import 'package:flutter/material.dart';

class ProfileAvatar extends StatefulWidget {
  final String? photoUrl;
  final String initials;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initials,
    this.radius = 40,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  ImageProvider? _provider;

  @override
  void initState() {
    super.initState();
    _provider = _build(widget.photoUrl);
  }

  @override
  void didUpdateWidget(covariant ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoUrl != widget.photoUrl) {
      _provider = _build(widget.photoUrl);
    }
  }

  ImageProvider? _build(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      try {
        return MemoryImage(base64Decode(url.substring(url.indexOf(',') + 1)));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: primary.withValues(alpha: 0.14),
      backgroundImage: _provider,
      child: _provider == null
          ? Text(
              widget.initials,
              style: TextStyle(
                fontSize: widget.radius * 0.7,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            )
          : null,
    );
  }
}