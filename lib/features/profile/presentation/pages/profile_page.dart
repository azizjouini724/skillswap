import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:skillswap/features/profile/presentation/widgets/add_skill_sheet.dart';
import 'package:skillswap/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:skillswap/features/settings/presentation/widgets/settings_tile.dart';
import 'package:skillswap/features/skills/domain/entities/skill_type.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_chip.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/credits/presentation/bloc/credits_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retour de "Change password" (email envoyé ou erreur).
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, state) => state is PasswordResetSent || state is AuthError,
      listener: (context, state) {
        final message = state is AuthError
            ? state.message
            : 'Reset link sent, check your inbox';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (_, state) => state is ProfileActionFailed,
        listener: (context, state) {
          if (state is ProfileActionFailed) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        buildWhen: (_, state) => state is! ProfileActionFailed,
        builder: (context, state) {
          if (state is ProfileLoaded) {
            return _ProfileContent(profile: state.profile);
          }
          if (state is ProfileFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 40, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(state.message),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileEntity profile;
  const _ProfileContent({required this.profile});

  Future<void> _edit(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => EditProfileSheet(profile: profile),
    );
    if (result != null && context.mounted) {
      context.read<ProfileBloc>().add(ProfileSaveRequested(
            name: result['name']!,
            bio: result['bio']!,
            city: result['city']!,
          ));
    }
  }

  Future<void> _addSkill(BuildContext context, SkillType type) async {
    final skill = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddSkillSheet(
        type: type,
        taken: [...profile.skillsToTeach, ...profile.skillsToLearn],
      ),
    );
    if (skill != null && context.mounted) {
      context.read<ProfileBloc>().add(SkillAdded(type: type, skill: skill));
    }
  }

  Future<void> _photoOptions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, 'gallery'),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(sheetContext, 'camera'),
              ),
            if (profile.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(sheetContext, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    if (action == 'remove') {
      context.read<ProfileBloc>().add(const PhotoRemoved());
    } else {
      await _pickPhoto(
        context,
        action == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
    }
  }

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 300,
      maxHeight: 300,
      imageQuality: 70,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    context.read<ProfileBloc>().add(PhotoChanged(bytes));
  }

  Future<void> _confirmPassword(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change password'),
        content: Text('We will send a reset link to ${profile.email}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AuthBloc>().add(PasswordResetRequested(profile.email));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Do you really want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AuthBloc>().add(const SignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                'Profile',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _HeaderCard(
                profile: profile,
                onPhoto: () => _photoOptions(context),
                onEdit: () => _edit(context),
              ),
              const SizedBox(height: 16),
              _CompletionCard(profile: profile),
              const SizedBox(height: 16),
              _SkillSection(
                type: SkillType.teach,
                skills: profile.skillsToTeach,
                onAdd: () => _addSkill(context, SkillType.teach),
              ),
              const SizedBox(height: 16),
              _SkillSection(
                type: SkillType.learn,
                skills: profile.skillsToLearn,
                onAdd: () => _addSkill(context, SkillType.learn),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Settings'),
              const SizedBox(height: 8),
              SettingsGroup(children: [
                BlocBuilder<CreditsBloc, CreditsState>(
                  builder: (context, state) {
                    final balance =
                        state is CreditsLoaded ? state.balance : null;
                    return SettingsTile(
                      icon: Icons.stars_rounded,
                      title: 'Your credits',
                      subtitle: balance == null ? null : '$balance credits',
                      onTap: () => context.push(AppRoutes.credits),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Appearance',
                  subtitle: 'Light, dark or system',
                  onTap: () => showAppearanceSheet(context),
                ),
                SettingsTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'Change password',
                  onTap: () => _confirmPassword(context),
                ),
              ]),
              const SizedBox(height: 12),
              SettingsGroup(children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About SkillSwap',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'SkillSwap',
                    applicationVersion: '1.0.0',
                    children: const [Text('Learn • Teach • Exchange')],
                  ),
                ),
                SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  danger: true,
                  onTap: () => _confirmLogout(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onPhoto;
  final VoidCallback onEdit;

  const _HeaderCard({
    required this.profile,
    required this.onPhoto,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: Column(
          children: [
            Stack(
              children: [
                ProfileAvatar(
                  photoUrl: profile.photoUrl,
                  initials: profile.initials,
                  radius: 48,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppColors.primary,
                    shape: CircleBorder(
                      side: BorderSide(color: scheme.surface, width: 3),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onPhoto,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.photo_camera_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            if (profile.city.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 15, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    profile.city,
                    style:
                        TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ],
            if (profile.hasBio) ...[
              const SizedBox(height: 12),
              Text(
                profile.bio,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(190, 48),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final ProfileEntity profile;
  const _CompletionCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final complete = profile.completedSteps == ProfileEntity.totalSteps;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  complete
                      ? Icons.verified_rounded
                      : Icons.swap_horizontal_circle_outlined,
                  color: primary,
                ),
                const SizedBox(width: 8),
                Text(
                  complete ? 'Swap-ready' : 'Get swap-ready',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '${profile.completedSteps}/${ProfileEntity.totalSteps}',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, color: primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: profile.completion,
                minHeight: 8,
                backgroundColor: primary.withValues(alpha: 0.14),
                color: primary,
              ),
            ),
            const SizedBox(height: 14),
            _Step(done: profile.hasBio, label: 'Write a short bio'),
            _Step(
                done: profile.hasEnoughToTeach,
                label: 'Add 2 skills you can teach'),
            _Step(
                done: profile.hasEnoughToLearn,
                label: 'Add 2 skills you want to learn'),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final bool done;
  final String label;
  const _Step({required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: done ? AppColors.success : AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: done ? AppColors.textLight : null,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillSection extends StatelessWidget {
  final SkillType type;
  final List<String> skills;
  final VoidCallback onAdd;

  const _SkillSection({
    required this.type,
    required this.skills,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final teach = type == SkillType.teach;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    teach ? Icons.school_outlined : Icons.auto_stories_outlined,
                    color: primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teach ? 'I can teach' : 'I want to learn',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    Text(
                      '${skills.length} skill${skills.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in skills)
                  SkillChip(
                    label: s,
                    filled: teach,
                    onDeleted: () => context
                        .read<ProfileBloc>()
                        .add(SkillRemoved(type: type, skill: s)),
                  ),
                SkillChip(
                  label: 'Add',
                  icon: Icons.add_rounded,
                  onTap: onAdd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}