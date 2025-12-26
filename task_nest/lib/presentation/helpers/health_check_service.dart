import 'package:flutter/material.dart';
import 'package:task_nest/presentation/blocs/members/members_cubit.dart';
import 'package:task_nest/presentation/blocs/user/user_cubit.dart';
import 'package:task_nest/presentation/extensions/build_context_extension.dart';

const requiredGlobalCubits = <Type>[MembersCubit, UserCubit];

class HealthCheckService {
  static ({bool isStable, String info}) isStable(BuildContext context) {
    List<Type> notProvidedCubits = [];

    for (final cubitType in requiredGlobalCubits) {
      final isProvided = _check(context, cubitType);
      if (!isProvided) {
        notProvidedCubits.add(cubitType);
      }
    }

    final result = (
      isStable: notProvidedCubits.isEmpty,
      info: "[ATTENTION]: not provided Cubits ${notProvidedCubits.toString()}",
    );

    return result;
  }

  static bool _check(BuildContext context, Type type) {
    try {
      if (type == MembersCubit) {
        return context.safeReadCubit<MembersCubit>() != null;
      } else if (type == UserCubit) {
        return context.safeReadCubit<UserCubit>() != null;
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
