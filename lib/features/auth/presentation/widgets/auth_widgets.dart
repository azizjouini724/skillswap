import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skillswap/core/theme/app_colors.dart';

/// Fond commun : grand cercle lavande qui s'estompe, comme la référence.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final d = w * 0.95;
            return ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    top: -w * 0.1,
                    left: -w * 0.15,
                    child: Container(
                      width: d,
                      height: d,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.30),
                            AppColors.primary.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(child: child),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Champ arrondi avec label flottant (texte, email ou mot de passe).
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Widget? trailing;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.trailing,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, [double width = 1.2]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget? _suffix() {
    if (!widget.isPassword && widget.trailing == null) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.trailing != null) widget.trailing!,
        if (widget.isPassword)
          IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textLight,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        const SizedBox(width: 6),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      style: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.textLight),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: Icon(widget.icon, color: AppColors.textLight, size: 20),
        suffixIcon: _suffix(),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.85),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, 1.6),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, 1.6),
      ),
    );
  }
}

/// Bouton pilule aligné à droite, avec icône.
class AuthPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  const AuthPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 52),
          padding: const EdgeInsets.symmetric(horizontal: 26),
          shape: const StadiumBorder(),
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 10),
                  Icon(icon, size: 20),
                ],
              ),
      ),
    );
  }
}

/// Ligne "Don't have an account? sign up".
class AuthSwitchLine extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchLine({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$question ',
          style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// Boutons sociaux (visuels pour l'instant).
class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    const icons = <FaIconData>[
      FontAwesomeIcons.google,
      FontAwesomeIcons.apple,
      FontAwesomeIcons.facebookF,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final icon in icons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bientôt disponible')),
              ),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: FaIcon(icon, size: 18, color: AppColors.primary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}