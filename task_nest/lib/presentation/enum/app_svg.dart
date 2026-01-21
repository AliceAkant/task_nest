enum AppSvg {
  addPerson('add_person'),
  attention('attention'),
  calendarEdit('calendar_edit'),
  calendar('calendar'),
  cat('cat'),
  checkMark('check_mark'),
  dog('dog'),
  duck('duck'),
  giraffe('giraffe'),
  hamster('hamster'),
  heart('heart'),
  moon('moon'),
  mouse('mouse'),
  noAvatar('no_avatar'),
  parrot('parrot'),
  plan('plan'),
  refresh('refresh'),
  settings('settings'),
  sheep('sheep'),
  snail('snail'),
  sun('sun'),
  tiger('tiger'),
  time('time');

  final String fileName;

  const AppSvg(this.fileName);

  String get svgPath => 'assets/svg/$fileName.svg';
}
