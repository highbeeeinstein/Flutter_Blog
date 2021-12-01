extension CapExtension on String {
  String get sentenceCase =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  String get upperCase => this.toUpperCase();
  String get titleCase => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.sentenceCase)
      .join(" ");
}
