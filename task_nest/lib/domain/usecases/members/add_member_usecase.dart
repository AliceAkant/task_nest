import 'package:dartz/dartz.dart';
import 'package:task_nest/core/error/failures.dart';
import 'package:task_nest/domain/entities/member.dart';
import 'package:task_nest/domain/repositories/members_repository.dart';
import 'package:task_nest/domain/enums/avatar.dart';
import 'package:task_nest/domain/enums/member_theme.dart';

class AddMemberUseCase {
  final MembersRepository repository;

  AddMemberUseCase(this.repository);

  Future<Either<Failure, Member>> call(
    String name,
    MemberTheme color,
    Avatar avatar,
  ) {
    final member = Member(id: null, name: name, theme: color, avatar: avatar);
    return repository.addMember(member);
  }
}
