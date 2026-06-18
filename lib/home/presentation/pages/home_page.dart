import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../checklist/presentation/controllers/checklist_controller.dart';
import '../../../core/controllers/nav_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final checklist = context.watch<ChecklistController>();
    final nav = context.read<NavController>();
    final profile = auth.userProfile;

    final firstName = profile != null
        ? (profile['firstName'] as String? ?? '').trim()
        : 'there';
    final city = profile != null ? (profile['city'] as String? ?? '') : '';

    // Aggregate checklist stats
    int totalItems = 0;
    int doneItems = 0;
    for (final task in checklist.tasks) {
      totalItems += task.items.length;
      doneItems += task.items.where((i) => i.done).length;
    }
    final double overallProgress =
        totalItems == 0 ? 0 : doneItems / totalItems;
    final int progressPercent = (overallProgress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ─────────────────────────────────────────────
            Text(
              'Hello, ${firstName.isEmpty ? 'there' : firstName} 👋',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              city.isNotEmpty
                  ? 'Here\'s your FastLane overview in $city.'
                  : 'Here\'s your FastLane overview.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 24),

            // ── Progress card ─────────────────────────────────────────
            _ProgressCard(
              totalItems: totalItems,
              doneItems: doneItems,
              progress: overallProgress,
              progressPercent: progressPercent,
              onTap: () => nav.setIndex(1),
            ),

            const SizedBox(height: 24),

            // ── Quick actions label ───────────────────────────────────
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height: 14),

            // ── Quick action cards ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.checklist_rounded,
                    label: 'Checklist',
                    subtitle: '$doneItems / $totalItems done',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => nav.setIndex(1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Ask BINO',
                    subtitle: 'AI document guide',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => nav.setIndex(2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _QuickActionCard(
              icon: Icons.map_rounded,
              label: 'Find Nearby Offices',
              subtitle: 'Government offices, town halls & more',
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () => nav.setIndex(3),
              wide: true,
            ),

            const SizedBox(height: 24),

            // ── Active tasks ──────────────────────────────────────────
            if (checklist.tasks.isNotEmpty) ...[
              const Text(
                'Your Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              ...checklist.tasks.map(
                (task) => _TaskSummaryCard(
                  task: task,
                  onTap: () => nav.setIndex(1),
                ),
              ),
            ] else ...[
              _EmptyTasksCard(onTap: () => nav.setIndex(2)),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Progress Card
// ──────────────────────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final int totalItems;
  final int doneItems;
  final double progress;
  final int progressPercent;
  final VoidCallback onTap;

  const _ProgressCard({
    required this.totalItems,
    required this.doneItems,
    required this.progress,
    required this.progressPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$progressPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              totalItems == 0
                  ? 'No tasks yet'
                  : '$doneItems of $totalItems items complete',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalItems == 0 ? 0 : progress,
                backgroundColor: Colors.white.withAlpha(51),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Quick Action Card
// ──────────────────────────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool wide;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: wide ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: wide ? 18 : 20,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(64),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: wide
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 16),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Task Summary Card
// ──────────────────────────────────────────────────────────────────────────────
class _TaskSummaryCard extends StatelessWidget {
  final dynamic task;
  final VoidCallback onTap;

  const _TaskSummaryCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int total = task.items.length as int;
    final int done = (task.items as List).where((i) => i.done).length;
    final double prog = total == 0 ? 0 : done / total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.taskName as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: prog,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(
                  prog == 1.0
                      ? const Color(0xFF10B981)
                      : const Color(0xFF3B82F6),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Empty Tasks Card
// ──────────────────────────────────────────────────────────────────────────────
class _EmptyTasksCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyTasksCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            const Text(
              'No tasks yet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Chat with BINO to get started on your documents.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              icon: const Icon(Icons.chat_bubble_rounded, size: 16),
              label: const Text('Ask BINO'),
            ),
          ],
        ),
      ),
    );
  }
}