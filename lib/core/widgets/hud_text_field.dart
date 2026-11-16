import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_typography.dart';

class HudTextField extends StatefulWidget {
  const HudTextField({
    required this.label,
    required this.icon,
    this.initialValue,
    this.obscure = false,
    this.mono = false,
    this.textInputAction,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? initialValue;
  final bool obscure;
  final bool mono;
  final TextInputAction? textInputAction;

  @override
  State<HudTextField> createState() => _HudTextFieldState();
}

class _HudTextFieldState extends State<HudTextField> {
  final _focus = FocusNode();
  late final _controller = TextEditingController(text: widget.initialValue);
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: AppMotion.fast,
          style: AppText.hud.copyWith(
            color: focused ? AppColors.glow : AppColors.ivoryMuted,
            fontSize: 9.5,
          ),
          child: Text(widget.label.toUpperCase()),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.easeOut,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: focused
                ? AppColors.raised.withValues(alpha: 0.85)
                : AppColors.deep.withValues(alpha: 0.7),
            border: Border.all(
              color: focused
                  ? AppColors.glow.withValues(alpha: 0.7)
                  : AppColors.hairline,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.glow.withValues(alpha: focused ? 0.18 : 0),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  widget.icon,
                  key: ValueKey(focused),
                  size: 19,
                  color: focused ? AppColors.glow : AppColors.ivoryFaint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  obscureText: _hidden,
                  obscuringCharacter: '•',
                  textInputAction: widget.textInputAction,
                  onTapOutside: (_) => _focus.unfocus(),
                  style: (widget.mono ? AppText.data : AppText.label).copyWith(
                    fontSize: 15,
                    letterSpacing: widget.mono ? 1.2 : 0,
                  ),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (widget.obscure)
                GestureDetector(
                  onTap: () => setState(() => _hidden = !_hidden),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AnimatedSwitcher(
                      duration: AppMotion.fast,
                      child: Icon(
                        _hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        key: ValueKey(_hidden),
                        size: 19,
                        color: AppColors.ivoryFaint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
