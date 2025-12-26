part of 'bottom_navigation_cubit.dart';

class BottomNavigationState extends Equatable {
  final String tab;
  final int index;

  const BottomNavigationState({required this.tab, required this.index});

  @override
  List<Object> get props => [tab, index];
}
