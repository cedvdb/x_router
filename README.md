# x_router

A simple and powerful routing lib that simplify having multiple child router.

## Features

  - [Easy navigation](#navigation)
  - [Child routers](#child-router)
  - [Async guards / resolvers](#resolvers)
  - [Relative navigation](#relative-navigation)
  - [Redirects](#add-redirects)
  - [Translated browser tab title](#browser-tab-title)
  - [Url matching](#url-matching)
  - Router history
  - Event driven
  - Test coverage


<br><br>

<img src="https://raw.githubusercontent.com/cedvdb/x_router/main/recordings/recording_example.gif" width="600"/>



## Core idea

One area that seem to be a point of confusion for developers is the different back buttons. On the web there is the back button, usually using the browser arrow ◀, to navigate chronologically through the pages we visited before. While in an application there is typically also an down button, usually the icon ⬅ at the top of the app bar, to navigate down in the stack of pages that are superimposed on each others. In this doc, the word **downstack** is used to refer to the stack of pages accessible when pressing ⬅ and popping the current page.
(for more information see https://developer.android.com/guide/navigation/navigation-principles)

One of the design decision idea of this package is that the __downstack is a function of the url__ 

That is that for an url like `/products/123` we have a stack of two pages `[ProductsPage, ProductsDetailsPage]` by default.

Let's take this fairly common and complex scenario:

```
  '/sign-in' => user access this page when unauthenticated
  '/sign-in/verify_phone' => user can access this nested page when unauthenticated 
  '/dashboard' => when the user is authenticated & has a profile, the dashboard
  '/products' => when the user is authenticated & has a profile and clicked on a menu item to see the products
  '/products/:id' => when the user wants to see a specific product
```

In this scenario it is apparent that the **downstack** can be defined as a function of the url path where each segment of the path is a screen in the stack.
For example when on the '/products/:id' route the **downstack** will look like this:

```
  - ProductsScreen
  - ProductDetailsScreen
```

This is the approach this library takes to create the **downstack** by default.


## Usage

### Navigation


For navigation you can use the `goTo(location)` method:

```dart
  final router = XRouter(routes: []);

  router.goTo('/products/:id', params: { 'id': '123' }); // products/123
  // Generally you will store your routes somewhere:
  router.goTo(AppRoutes.productDetails, params: { 'id': '123' }); 
```

#### All navigation methods

  - `goTo`: goes to location adding the target to history 
  - `replace`: removes current location from history and `goTo` location
  - `pop`: if downstack is not empty `goTo` first location in downstack, else does nothing
  - `back`: go back chronologically 


#### Relative navigation

You can also navigate relative to the current route

```dart
  // goes to `products/123/info`, we were on /products/123/comments 
  router.goTo('./info'); 
  // goes to /preferences, when we were on /products/123/info
  router.goTo('../../preferences');
```


# Setup

## 1. Simple setup

The router in its simplest form defines a series of routes with builders and paths associated with them. The first step is to define those routes:

```dart
XRouter(
  routes: [
    XRoute( path: '/sign-in', builder: (ctx, activatedRoute) => SignInPage(),),
    XRoute( 
      path: '/dashboard', 
      builder: (ctx, activatedRoute) => DashboardPage(),
      // tab title
      titleBuilder: (ctx, activatedRoute) => AppLocalization.of(ctx).dashboard

    ),
    XRoute( 
      path: '/products', 
      builder: (ctx, activatedRoute) => ProductsPage(), 
    ),
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
    // ...
  ],
);
```

## 3. Guard your routes 

Usually your app will have authentication where the authentication is in 3 possible state (unauthenticated, authenticated, unknown). You want to protect pages that are not supposed to be accessible.

```dart
XRouter(
  resolvers: [
    XNotFoundResolver(redirectTo: '/'),
    XRedirectResolver(from: '/', to: 'dashboard'),
    AuthResolver()
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


# Resolvers


When a page is accessed via a path ('/path'). That path goes through each resolvers provided to the router sequentially to return a resolved path.

Each resolver can return either `Redirect`,  `Next`, `ByPass` or `Loading`. The difference between those is explained later.

To create a resolver, just use the mixin `XResolver`. Here is an example of a redirect resolver:

```dart
// A redirect resolver is provided by the library 
class XRedirectResolver with XResolver {
  final String from;
  final String to;

  XRedirectResolver({
    required this.from,
    required this.to,
  });

  @override
  XResolverAction resolve(String target) async {
    // you can use the XRoutePattern class instead of startsWith
    // which will also match for patterns like /products/:id
    if (target.startsWith(from)) {
      return Redirect(to);
    }
    return Next();
  }
}
```

resolvers can return 3 type of value:

  - `Next`: proceeds to the next resolver until we reach the end 
  - `Redirect`: redirects to a target and goes through each resolver again with a new path
  - `ByPass`: stops the resolving process at the current target
  - `Loading`: stops the resolving process at the target but display a custom widget on screen until it is ready (see next section)


# Reactive resolvers

Reactive resolvers are resolvers that react to changes in your application app state.

If you need your resolver to trigger on state change, you can simply implement any `Listenable` (ChangeNotifier, ValueNotifier,...).

The canonical example of a reactive resolver use case is authentication. 

In the following example, when the authentication status changes, the XRouter will be notified of
such a change and the resolving process will start again.

- If the user is authenticated he will be redirected to /home (if not already there)
- If the user is unauthenticated he will be redirected to /sign-in (if not already there)
- If the auth status is unknow a loadingScreen will be shown until `notifyListeners()` is called.


```dart
class AuthResolver extends ValueNotifier with XResolver {

  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.authStatusStream
        .listen((authStatus) => value = authStatus);
  }

  @override
  XResolverAction resolve(String target) {
    switch (value) {
      case AuthStatus.authenticated:
        if (target.startsWith(RouteLocations.signIn)) {
          return const Redirect(RouteLocations.home);
        } else {
          return const Next();
        }
      case AuthStatus.unautenticated:
        if (target.startsWith(RouteLocations.signIn)) {
          return const Next();
        } else {
          return const Redirect(RouteLocations.signIn);
        }
      case AuthStatus.unknown:
      default:
        return Loading(
          (_, __) => const LoadingPage(text: 'Guard: Checking Auth Status'),
        );
    }
  }
}
```

This is powerful because you then don't need to worry about redirection on user authentication anywhere in your app, you just login and logout. 

When the app does not know the authentication status, at the start of the application, it will be in a pending state and display the widget of your choice.


```diff
! Note: All resolvers are active for all paths
```

A good practice for resolver is to have them light and decoupled from your app. Your app should not call them.

```diff
+  // good

+  class AuthResolver extends ValueNotifier implements XResolver {
+
+    AuthResolver() : super(AuthStatus.unknown) {
+      AuthService.authStatusStream
+          .listen((authStatus) => value = authStatus);
+    }
+
+    @override
+    XResolverAction resolve(String target) {
+      // ...
+    }
+  }

- // bad

-  class AuthResolver extends ValueNotifier implements XResolver {
-    AuthResolver() : super(null);
-
-    signIn() => value = true;
-
-    signOut() => value = false;
-
-    @override
-    XResolverAction resolve(String target) {
-      // ...
-    }
-  }

```


### Built-resolvers

A series of resolvers are provided by the library:

 - XNotFoundResolver: to redirect when no route is found
 - XRedirect: to redirect a specific path


# Nested routing


## Child Router

First setup your view with flutter's `Router` as a child. That is where your child routes will be rendered:

```dart

class HomeLayout extends StatelessWidget {
  const HomeLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NavRail(),
        Expanded(
          child: Router(
            routerDelegate:
                router.childRouterStore.findDelegate(RouteLocations.app),
          ),
        ),
      ],
    );
  }
}


```

Next you probably want to react to navigation changes, in the example above we want to animate the rail

```dart
 class NavRail extends StatefulWidget {
  const NavRail({
    Key? key,
  }) : super(key: key);

  @override
  State<NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<NavRail> {
  final _tabsIndex = <XRoutePattern, int>{
    XRoutePattern(RouteLocations.dashboard): 0,
    XRoutePattern(RouteLocations.products): 1,
    XRoutePattern(RouteLocations.favorites): 2,
  };
  StreamSubscription? navSubscription;

  int _selectedTab = 0;

  @override
  void initState() {
    _selectedTab = _findTabIndex(router.history.currentUrl) ?? 0;
    // if the user changes the URL via the browser, you want your rail to react
    navSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .listen((nav) => _refreshBottomBar());
    super.initState();
  }

  @override
  dispose() {
    navSubscription?.cancel();
    super.dispose();
  }

  /// changes the selected tab when the url changes
  _refreshBottomBar() {
    final foundIndex = _findTabIndex(router.history.currentUrl);
    if (foundIndex != null) {
      setState(() => _selectedTab = foundIndex);
    }
  }

  /// finds the tab index associated with a path
  int? _findTabIndex(String path) {
    for (final pattern in _tabsIndex.keys) {
      if (pattern.match(path, matchChildren: true)) {
        return _tabsIndex[pattern];
      }
    }
    return null;
  }

  /// when a tab is clicked, navigate to the target location
  _navigate(int index) {
    router.goTo(_findRoutePath(index));
  }

  /// finds the url path given a tab index
  String _findRoutePath(int index) {
    for (final entry in _tabsIndex.entries) {
      if (entry.value == index) {
        return entry.key.path;
      }
    }
    return _tabsIndex.keys.first.path;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      onDestinationSelected: _navigate,
      selectedIndex: _selectedTab,
      extended: true,
      destinations: const [
        // material you
        NavigationRailDestination(
            label: Text('dashboard'), icon: Icon(Icons.home)),
        NavigationRailDestination(
            label: Text('products'), icon: Icon(Icons.shopping_bag)),
        NavigationRailDestination(
            label: Text('favorites'), icon: Icon(Icons.favorite))
      ],
    );
  }
}
```

Finally you have to define your routes:


```dart
  // this is the main page where the nav rail appears
  XRoute(
    path: RouteLocations.app,
    builder: (ctx, route) => const HomeLayout(),
    // those page will be placed inside the home layout page
    childRouterConfig: XChildRouterConfig(
      routes: [
        XRoute(
          path: RouteLocations.dashboard,
          builder: (ctx, route) => const DashboardPage(),
          titleBuilder: (_) => 'dashboard',
        ),
        XRoute(
          path: RouteLocations.favorites,
          builder: (ctx, route) => const FavoritesPage(),
          titleBuilder: (_) => 'My favorites',
        ),
        XRoute(
          path: RouteLocations.products,
          builder: (ctx, route) {
            return const ProductsPage();
          },
          titleBuilder: (_) => 'products',
        ),
        XRoute(
          path: RouteLocations.productDetail,
          builder: (ctx, activatedRoute) =>
              ProductDetailsPage(activatedRoute.pathParams['id']!),
        ),
      ],
    ),
  ),
```

# Browser tab titles

To customize your routes a bit you can add tab titles:

```dart

  XRoute( 
    path: '/dashboard', 
    builder: (ctx, activatedRoute) => DashboardPage(),
    // tab title
    titleBuilder: (ctx, activatedRoute) => AppLocalization.of(ctx).dashboard
  )

```

# Url matching

When an user access a path in your application, the url will automatically shrink to find the matching route.

That means that if you defined a router with only a `/dashboard` route:

```dart
    XRoute( 
      path: '/dashboard', 
      builder: (ctx, activatedRoute) => DashboardPage(),
    ),
```

When the user access the path `/dashboard/something-undefined`, the url in the browser will change to `/dashboard` and the user 
will access `/dashboard`.

