import 'package:flutter/material.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.purple),
    );
  }
}
