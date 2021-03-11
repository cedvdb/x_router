# x_router

Flutter routing 2.0 requires a lot of setup. The goal of this package is to make that setup easy by providing a simpler API.

# Features

  - Navigator 2.0
  - Child / nested Routing
  - Reactive Guards / resolvers
  - Simple Api


# Philosophy

Flutter brings web navigation and app navigation together with Navigator 2.0. 

One area that seem to be a point of confusion for developers is the different back buttons. On the web there is the back button, usually using the icon ◀, to navigate chronologically through the pages we visited before. While in an application there is typically also an up button, usually the icon ⬅ at the top of the app bar, to navigate up in the stack of pages that are superimposed on each others. In this doc, the word **upstack** is used to refer to the stack of pages accessible when pressing ⬅.
(for more information see https://developer.android.com/guide/navigation/navigation-principles)

The philosophy of this package is to use the url to create the upstack. 

Let's take this fairly common and complex scenario:

```
  '/loading' => user access this page when the authentication state is unknown
  '/sign-in' => user access this page when unauthenticated
  '/sign-in/phone' => user can access this nested page when unauthenticated 
  '/create-profile' => when user is authenticated but doesn't have a profile 
  '/dashboard' => when the user is authenticated & has a profile, the dashboard
  '/products' => when the user is authenticated & has a profile and clicked on a menu item to see the products
  '/products/:id' => when the user wants to see a specific product
```

In this scenario it is apparent that the **upstack** can be defined as a function of the url path where each segment is a screen in the stack.
For example when on the '/sign-in/phone' route the **upstack** will look like this:

```
  - SignInScreen
  - SignInWithPhoneScreen
```

On the product details page the up stack will look like this

```
  - ProductsScreen
  - ProductDetailsScreen
```

This is the approach this library takes to create the **upstack** by default.

# Usage

## Simple usage

A very simple routing scenario might look like this:

```

XRouter(
  routes: [
    XRoute( path: '/dashboard, builder: (ctx, params) => DashboardPage()),
    XRoute( path: '/products', builder: (ctx, params) => ProductsPage()),
    XRoute(
      path: '/products/:id',
      builder: (ctx, params) => ProductDetailsPage(params['id']),
    ),
  ],
);
```

## Real world usage

In any real world application however, you might have an authentication status, redirectors, and take care of not found routes. Therefor your code, in a real world scenario will look more like this:

```

final router = XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    AuthResolver(),
    XRedirectResolver(from: '/', to: '/dashboard'),
  ],
  routes: [
    XRoute(
      path: AppRoutes.dashboard,
      builder: (ctx, params) => DashboardPage(),
    ),
    XRoute(
      path: AppRoutes.products,
      builder: (ctx, params) => ProductsPage(),
    ),
    XRoute(
      resolvers: [ProductExists]
      path: AppRoutes.productDetail,
      builder: (ctx, params) => ProductDetailsPage(params['id']),
    ),
    XRoute(
      path: AppRoutes.loading,
      builder: (ctx, params) => LoadingPage(),
    ),
    XRoute(
      path: AppRoutes.signIn,
      builder: (ctx, params) => SignInPage(),
    )
  ],
  onRouterStateChanges: (s) => print(s),
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

While the first way is more common in routers, the second way of putting parameters separately can be useful if you have your routes
is a static class:

```
  XRouter.goTo(AppRoute.productDetails, params: { 'id': '123x' });
```


# Reactive guards / resolvers


The XRouter class accepts resolvers as parameters. When a page is accessed via a path ('/route'). That route goes through each resolvers `Future<String> resolve(String target)` sequentially and output a path which may or may not be the one received.

In other words if you access '/route', the resolving process first takes the first resolver, which may output '/not-found' then the second resolver receives '/not-found' and outputs '/sign-in.

Those resolvers can be `ChangeNotifier` in which case the resolving process happens again when the resolvers `notifyListeners()`.

Here is an example of an authentication resolver:

```dart
class AuthResolver extends ValueNotifier with XRouteResolver {


  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatus$.listen((status) {
      value = status;
    });
  }

  // this will run every time the value changes
  @override
  Future<String> resolve(String target) async {
    switch (value) {
      case AuthStatus.authenticated:
        if (target.startsWith('/sign-in')) return '/';
        if (target.startsWith('/loading')) {
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


# Child Router 

To create a child router use the XRouter.child constructor and add it to the parent:

```
final childRouter = XRouter.child(
    routes: [
      XRoute(path: '/products/:id/info', builder: (_, __) => ProductInfo()),
      XRoute(
        path: '/products/:id/comments',
        builder: (_, __) => ProductComments(),
      ),
    ],
  )
parentRouter.addChildren([childRouter]);
```

