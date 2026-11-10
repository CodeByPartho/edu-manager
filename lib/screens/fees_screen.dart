import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/edu_logic.dart';
import '../state/edu_state.dart';
import '../utils/format.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    final month = currentMonthKey();
    final monthFees = feesForMonth(state.students, state.fees, month);
    final due = totalFeesDue(monthFees);
    final collected = totalFeesCollected(monthFees);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FeeTotal(label: 'Collected', amount: collected, color: Colors.green),
                  _FeeTotal(label: 'Due', amount: due, color: Colors.red),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                monthLabel(month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: monthFees.length,
            itemBuilder: (context, index) {
              final fee = monthFees[index];
              final student = state.students.firstWhere(
                (s) => s.id == fee.studentId,
                orElse: () => state.students.first,
              );
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Text(student.name[0])),
                  title: Text(student.name),
                  subtitle: Text(
                    '${state.classLabel(student.classId)} - ${taka(fee.amount)}',
                  ),
                  trailing: fee.paid
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Chip(
                              label: Text('Paid'),
                              backgroundColor: Colors.green,
                            ),
                            IconButton(
                              icon: const Icon(Icons.undo),
                              tooltip: 'Mark unpaid',
                              onPressed: () =>
                                  state.markFeeUnpaid(student.id, month),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Chip(
                              label: Text('Due'),
                              backgroundColor: Colors.red,
                            ),
                            TextButton(
                              onPressed: () =>
                                  state.markFeePaid(student.id, month),
                              child: const Text('Mark paid'),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeeTotal extends StatelessWidget {
  const _FeeTotal({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Text(
          taka(amount),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
