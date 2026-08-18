import 'package:flutter/material.dart';

import '../main.dart';
import 'glass_card.dart';

/// Dynamic "chips" skill entry widget matching the `Required Skills` field
/// from the reference design. Skills are added by pressing Enter/Done and
/// removed by tapping the "x" on a chip. State is fully controlled by the
/// parent via [onChanged] so it can be persisted across navigation.
class SkillInput extends StatefulWidget {
  final List<String> initialSkills;
  final ValueChanged<List<String>> onChanged;

  const SkillInput({
    super.key,
    this.initialSkills = const [],
    required this.onChanged,
  });

  @override
  State<SkillInput> createState() => _SkillInputState();
}

class _SkillInputState extends State<SkillInput> {
  late final List<String> _skills;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _skills = List<String>.from(widget.initialSkills);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addSkill(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    final alreadyExists = _skills.any((s) => s.toLowerCase() == value.toLowerCase());
    if (alreadyExists) {
      _controller.clear();
      return;
    }
    setState(() {
      _skills.add(value);
      _controller.clear();
    });
    widget.onChanged(List<String>.from(_skills));
    _focusNode.requestFocus();
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
    widget.onChanged(List<String>.from(_skills));
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 12,
      padding: const EdgeInsets.all(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final skill in _skills) _SkillChip(label: skill, onRemove: () => _removeSkill(skill)),
            SizedBox(
              width: 140,
              height: 32,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 14, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add skill...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                ),
                onSubmitted: _addSkill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _SkillChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.onSurface)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.close, size: 14, color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
