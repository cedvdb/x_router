# x_router

Flutter navigation made easy by providing a simple API.

# Features

  - router history
  - tabs support
  - nested router support
  - redirects
  - reactive guards
  - simple
  - event driven


# Core idea

Flutter brings web navigation and app navigation together with Navigator 2.0. 

One area that seem to be a point of confusion for developers is the different back buttons. On the web there is the back button, usually using the browser arrow ◀, to navigate chronologically through the pages we visited before. While in an application there is typically also an up button, usually the icon ⬅ at the top of the app bar, to navigate up in the stack of pages that are superimposed on each others. In this doc, the word **upstack** is used to refer to the stack of pages accessible when pressing ⬅ and popping the current page.
(for more information see https://developer.android.com/guide/navigation/navigation-principles)

The main idea of this package is that the __upstack is a function of the url__ 

That is that for an url like `/products/123` we have a stack of two pages `[ProductsPage, ProductsDetailsPage]`

Let's take this fairly common and complex scenario:

```
  '/sign-in' => user access this page when unauthenticated
  '/sign-in/verify_phone' => user can access this nested page when unauthenticated 
  '/create-profile' => when user is authenticated but doesn't have a profile 
  '/dashboard' => when the user is authenticated & has a profile, the dashboard
  '/products' => when the user is authenticated & has a profile and clicked on a menu item to see the products
  '/products/:id' => when the user wants to see a specific product
```

In this scenario it is apparent that the **upstack** can be defined as a function of the url path where each segment of the path is a screen in the stack.
For example when on the '/products/:id' route the **upstack** will look like this:

```
  - ProductsScreen
  - ProductDetailsScreen
```

This is the approach this library takes to create the **upstack** by default.


# Usage

## 1. Simple usage

The router in its simplest form defines a series of routes and builders associated with them

```dart
XRouter(
  routes: [
    XRoute( path: '/sign-in', builder: (ctx, activatedRoute) => SignInPage()),
    XRoute( path: '/dashboard', builder: (ctx, activatedRoute) => DashboardPage()),
    XRoute( path: '/products', builder: (ctx, activatedRoute) => ProductsPage()),
    XRoute(
      path: '/products/:id',
      builder: (ctx, activatedRoute) => ProductDetailsPage(activatedRoute.params['id']),
    ),
  ],
);
```

## 2. Add redirects

The next step is to add a series of redirect so the user on the web are always redirected where you want

```dart
XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    XRedirectResolver(from: '/', to: 'dashboard'),
  ],
  routes: [
    XRoute( path: '/dashboard', builder: (ctx, activatedRoute) => DashboardPage()),
    XRoute( path: '/products', builder: (ctx, activatedRoute) => ProductsPage()),
    XRoute(
      path: '/products/:id',
      builder: (ctx, activatedRoute) => ProductDetailsPage(activatedRoute.params['id']),
    ),
  ],
);
```

## 3. Guard your routes 

Usually your app will have authentication where the authentication is in 3 possible state (unauthenticated, authenticated, unkow). You want to protect pages that are not supposed to
be accessible.

```dart
XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    XRedirectResolver(from: '/', to: 'dashboard'),
    MyAuthGuard()
  ],
  routes: [
    XRoute( path: '/dashboard', builder: (ctx, activatedRoute) => DashboardPage()),
    XRoute( path: '/products', builder: (ctx, activatedRoute) => ProductsPage()),
    XRoute(
      path: '/products/:id',
      builder: (ctx, activatedRoute) => ProductDetailsPage(activatedRoute.params['id']),
    ),
  ],
);
```

## Real world usage

In any real world application however, you might have an authentication status, redirectors, and take care of not found routes. Therefor your code, in a real world scenario will look more like this:

```dart
final router = XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    AuthResolver(),
  ],
  routes: [
    XRoute(
      path: AppRoutes.home, 
      builder: null, 
      resolvers[XRedirectResolver(from: AppRoutes.home, to: AppRoutes.dashboard),],
    ),
    XRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => DashboardPage(),
    ),
    XRoute(
      path: AppRoutes.products,
      builder: (_, __) => ProductsPage(),
    ),
    XRoute(
      resolvers: [ProductExists]
      path: AppRoutes.productDetail,
      builder: (_, activatedRoute) => ProductDetailsPage(activatedRoute.params['id']),
    ),
    XRoute(
      path: AppRoutes.loading,
      builder: (_, __) => LoadingPage(),
    ),
    XRoute(
      path: AppRoutes.signIn,
      builder: (_, __) => SignInPage(),
    )
  ],
  // onEvent: (ev) => print(ev),
);
```

Then you can use the router in a material app


```
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.parser,
      routerDelegate: router.delegate,
      // ...
    );
  }
}
```


## Navigating

For navigation you can use the static method `XRoute.goTo(location)`

```
  // to access the /products/:id page you can:
  XRouter.goTo('/products/123x');
  // or you can:
  XRouter.goTo('/products/:id', params: { 'id': '123x' });
```

While the first way is more common in routers, the second way of putting parameters separately can be useful if you have your routes in a static class:

```
  XRouter.goTo(AppRoute.productDetails, params: { 'id': '123x' });
```

### All navigation methods

  - `goTo`: goes to location adding the target to history
  - `replace`: removes current location from history and `goTo` location
  - `pop`: if upstack is not empty `goTo` first location in upstack
  - `back`: go back chronologically



# Reactive guards / resolvers


The XRouter class accepts resolvers as parameters. When a page is accessed via a path ('/route'). That route goes through each resolvers `resolve(String target)` sequentially and output a path which may or may not be the one received.

In other words if you access '/route', the resolving process first takes the first resolver, which may output '/not-found' then the second resolver receives '/not-found' and outputs '/sign-in.

Here is an example of redirect resolver (a more complete version is available in the library):

```dart
// A redirect resolver is provided by the library 
class XRedirectResolver extends XResolver {
  final String from;
  final String to;

  XRedirectResolver({
    required this.from,
    required this.to,
  });

  @override
  Future<String> resolve(String target) async {
    if (target.startsWith(from)) {
      return to;
    }
    return target;
  }
}

```

Those resolvers have a state. If that state changes, then the current route is recalculated.

Here is an example of an authentication resolver:

```dart
import 'package:example/services/auth_service.dart';
import 'package:x_router/x_router.dart';

class AuthResolver extends XResolver<AuthStatus> {
  
  AuthResolver() : super(initialState: AuthStatus.unknown) {
    AuthService.instance.authStatus$
      .listen((status) => state = status);
  }

  @override
  Future<String> resolve(String target) async {
    switch (state) {
      case AuthStatus.authenticated:
        if (target.startsWith('/sign-in')) return '/';
        if (target.startsWith('/loading')) {
          // when we are on the loading page, the remaining part of 
          // the url is where we want to navigate after.
          return target.replaceFirst('/loading', '');
        }
        return target;
      case AuthStatus.unautenticated:
        return '/sign-in';
      case AuthStatus.unknown:
      default:
        if (target.startsWith('/loading')) return target;
        return '/loading$target';
    }
  }
}
```

This is powerful because you then don't need to worry about redirection on user authentication.

Note: You can add resolvers on specific routes, in which case they will only be active on that route & children.

## Provided resolvers

A series of resolvers are provided by the library:

 - XNotFoundResolver: to redirect when no route is found
 - XRedirect: to redirect a specific path
 - XSimpleResolver: A simple resolver for creating resolvers in line via its constructor



# Why don't I need context to access the XRouter

As stated in the core idea section, the page displayed is a function of the URL. There is only one URL.