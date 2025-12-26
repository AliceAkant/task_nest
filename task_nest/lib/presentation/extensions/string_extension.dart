extension StringExtension on String {
  String firstCharUppercase() {
    var firstChar = length > 0 ? this[0].toUpperCase() : '';
    return firstChar + (length > 1 ? substring(1).toLowerCase() : '');
  }

  String truncate({int maxLength = 20}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
