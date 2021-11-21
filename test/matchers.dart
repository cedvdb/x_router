import 'package:flutter_test/flutter_test.dart';

class IsMatch extends Matcher {
  const IsMatch();
  @override
  bool matches(item, Map matchState) => item.matches == true;
  @override
  Description describe(Description description) => description.add('a match');
}

class IsNotMatch extends Matcher {
  const IsNotMatch();
  @override
  bool matches(item, Map matchState) => item.matches == false;
  @override
  Description describe(Description description) =>
      description.add('not a match');
}
