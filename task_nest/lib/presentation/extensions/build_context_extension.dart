import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_nest/presentation/theme/app_colors.dart';

extension BuildContextExt on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  double get bottomInset => MediaQuery.paddingOf(this).bottom;

  T? safeReadCubit<T extends StateStreamableSource<Object?>>() {
    try {
      return BlocProvider.of<T>(this, listen: false);
    } catch (_) {
      return null;
    }
  }
}
