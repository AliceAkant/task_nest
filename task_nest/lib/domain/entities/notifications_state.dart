/// Snapshot of the user's effective notifications state.
///
/// Three meaningful UI states derive from this:
///   * active           — `osGranted && !muted`
///   * mutedLocally     — `osGranted && muted`
///   * disabledByOS     — `!osGranted`
class NotificationsState {
  final bool osGranted;
  final bool muted;

  const NotificationsState({
    required this.osGranted,
    required this.muted,
  });

  bool get isActive => osGranted && !muted;
  bool get isMutedLocally => osGranted && muted;
  bool get isDisabledByOS => !osGranted;
}
