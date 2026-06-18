import 'package:ai_coach/src/core/application/writing_coach_state.dart';
import 'package:ai_coach/src/core/design/app_colors.dart';
import 'package:ai_coach/src/core/design/app_components.dart';
import 'package:ai_coach/src/core/design/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WriteScreen extends ConsumerStatefulWidget {
  const WriteScreen({super.key});

  @override
  ConsumerState<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends ConsumerState<WriteScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(writingCoachProvider);
    final user = state.user;
    final analysis = state.latestAnalysis;
    final canSubmit =
        state.wordCount >= 20 &&
        (user?.credits ?? 0) > 0 &&
        !state.isSubmittingEssay;

    if (_controller.text != state.draftEssay) {
      _controller.value = TextEditingValue(
        text: state.draftEssay,
        selection: TextSelection.collapsed(offset: state.draftEssay.length),
      );
    }

    return AppScreen(
      screenKey: const ValueKey('screen-write'),
      title: 'Write',
      children: [
        _PromptCard(examType: user?.examType ?? ExamType.ielts),
        _EditorCard(
          controller: _controller,
          wordCount: state.wordCount,
          progress: state.targetProgress,
          credits: user?.credits ?? 0,
          canSubmit: canSubmit,
          isSubmitting: state.isSubmittingEssay,
          errorMessage: state.essayError,
          onChanged: (value) =>
              ref.read(writingCoachProvider.notifier).updateDraft(value),
          onSample: () =>
              ref.read(writingCoachProvider.notifier).loadSampleEssay(),
          onClear: () => ref.read(writingCoachProvider.notifier).clearDraft(),
          onSubmit: () => ref.read(writingCoachProvider.notifier).submitEssay(),
        ),
        if (analysis != null) _AnalysisResultCard(analysis: analysis),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.examType});

  final ExamType examType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppPill(label: '${examType.label} Task 2'),
              const Spacer(),
              AppPill(
                icon: Icons.timer_outlined,
                label: '40 min',
                backgroundColor: colors.warnTint,
                foregroundColor: colors.warn,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            WritingCoachController.samplePrompt,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.ink,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorCard extends StatelessWidget {
  const _EditorCard({
    required this.controller,
    required this.wordCount,
    required this.progress,
    required this.credits,
    required this.canSubmit,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onChanged,
    required this.onSample,
    required this.onClear,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final int wordCount;
  final double progress;
  final int credits;
  final bool canSubmit;
  final bool isSubmitting;
  final String? errorMessage;
  final ValueChanged<String> onChanged;
  final VoidCallback onSample;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                AppPill(
                  icon: Icons.bolt_rounded,
                  label: '$credits credits',
                  backgroundColor: colors.goodTint,
                  foregroundColor: colors.good,
                ),
                const Spacer(),
                TextButton(onPressed: onSample, child: const Text('Sample')),
                TextButton(onPressed: onClear, child: const Text('Clear')),
              ],
            ),
          ),
          Divider(height: 1, color: colors.line2),
          TextField(
            key: const ValueKey('essay-input'),
            controller: controller,
            minLines: 12,
            maxLines: 18,
            onChanged: onChanged,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Start writing your response here...',
              hintStyle: TextStyle(color: colors.ink4),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
            ),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.ink, height: 1.55),
          ),
          Divider(height: 1, color: colors.line2),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '$wordCount / 250 words',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.ink2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _statusLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: canSubmit ? colors.good : colors.ink3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AppProgressBar(value: progress),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  key: const ValueKey('submit-essay'),
                  onPressed: canSubmit ? onSubmit : null,
                  icon: isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: colors.primaryInk,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    isSubmitting ? 'Saving analysis...' : 'Analyze essay',
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.bad,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _statusLabel {
    if (isSubmitting) {
      return 'Saving';
    }
    if (credits <= 0) {
      return 'No credits';
    }
    return canSubmit ? 'Ready' : '20 words minimum';
  }
}

class _AnalysisResultCard extends StatelessWidget {
  const _AnalysisResultCard({required this.analysis});

  final EssayAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                analysis.rawScore,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  '${analysis.normalizedScore}/100 health',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.ink3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            analysis.generalFeedback,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.ink2, height: 1.45),
          ),
          const SizedBox(height: 18),
          Text(
            'Skill breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...analysis.skillScores.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SkillRow(skill: skill),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Corrections',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (analysis.corrections.isEmpty)
            Text(
              'No major recurring issue found in this mock pass.',
              style: TextStyle(color: colors.ink2),
            )
          else
            ...analysis.corrections.map(
              (correction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CorrectionTile(correction: correction),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill});

  final SkillScore skill;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final score = skill.score.clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                skill.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$score',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppProgressBar(value: score / 100, height: 6),
      ],
    );
  }
}

class _CorrectionTile extends StatelessWidget {
  const _CorrectionTile({required this.correction});

  final Correction correction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.sunken,
        borderRadius: AppSpacing.mediumRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPill(
            label: correction.type,
            backgroundColor: colors.badTint,
            foregroundColor: colors.bad,
          ),
          const SizedBox(height: 10),
          Text(
            correction.original,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.bad,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            correction.corrected,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.good,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            correction.explanation,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.ink2, height: 1.4),
          ),
        ],
      ),
    );
  }
}
