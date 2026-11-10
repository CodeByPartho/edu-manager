import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/edu_state.dart';
import '../utils/format.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EduState>();
    if (state.notices.isEmpty) {
      return const Center(child: Text('No notices yet. Add the first one.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.notices.length,
      itemBuilder: (context, index) {
        final notice = state.notices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.campaign),
            title: Text(notice.title),
            subtitle: Text(notice.body),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(shortDate(notice.date)),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: 'Delete notice',
                  onPressed: () => state.removeNotice(notice.id),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

class AddNoticeSheet extends StatefulWidget {
  const AddNoticeSheet({super.key});

  @override
  State<AddNoticeSheet> createState() => _AddNoticeSheetState();
}

class _AddNoticeSheetState extends State<AddNoticeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<EduState>();
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add notice', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _body,
                decoration: const InputDecoration(labelText: 'Notice text'),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Notice text is required' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await state.addNotice(_title.text.trim(), _body.text.trim());
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Post notice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
