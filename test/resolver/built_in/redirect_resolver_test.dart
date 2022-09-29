import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/x_router.dart';

void main() {
  group('XRedirectResolver should redirect', () {
    test('should redirect', () async {
      bool shouldRedirect = true;
      final redirectResolver = XRedirectResolver(
        from: '/',
        to: '/dashboard',
        when: () => shouldRedirect,
      );
      final redirectWithParamsResolver =
          XRedirectResolver(from: '/products/:id', to: '/products/:id/info');
      expect(await redirectResolver.resolve('/'),
          equals(const Redirect('/dashboard')));
      shouldRedirect = false;
      expect(await redirectResolver.resolve('/'), equals(const Next()));
      expect(await redirectResolver.resolve('/other'), equals(const Next()));
      expect(await redirectWithParamsResolver.resolve('/products/123'),
          equals(const Redirect('/products/123/info')));
    });
  });
}
