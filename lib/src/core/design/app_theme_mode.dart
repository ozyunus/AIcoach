enum WritingCoachThemeMode {
  dark,
  day,
  accessible;

  WritingCoachThemeMode get next => switch (this) {
    WritingCoachThemeMode.dark => WritingCoachThemeMode.day,
    WritingCoachThemeMode.day => WritingCoachThemeMode.accessible,
    WritingCoachThemeMode.accessible => WritingCoachThemeMode.dark,
  };

  String get label => switch (this) {
    WritingCoachThemeMode.dark => 'Dark',
    WritingCoachThemeMode.day => 'Day',
    WritingCoachThemeMode.accessible => 'Access',
  };
}
