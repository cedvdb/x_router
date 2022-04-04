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
      expect(
          redirectResolver.resolve('/'), equals(const Redirect('/dashboard')));
      shouldRedirect = false;
      expect(redirectResolver.resolve('/'), equals(const Next()));
      expect(redirectResolver.resolve('/other'), equals(const Next()));
      expect(redirectWithParamsResolver.resolve('/products/123'),
          equals(const Redirect('/products/123/info')));
    });
  });
}
