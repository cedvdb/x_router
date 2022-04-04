# x_router

A simple and powerful routing framework for flutter.

## Features

  - [Easy navigation](#navigation)
  - [Async guards / resolvers](#resolvers)
  - [Child routers](#child-router)
  - [Relative navigation](#relative-navigation)
  - [Redirects](#add-redirects)
  - [Tabs / bottom navigation support](#tabs-and-bottom-navigation-support)
  - [Translated browser tab title](#browser-tab-title)
  - [Url matching](#url-matching)
  - Router history
  - Event driven
  - Test coverage


<br><br>

<img src="https://raw.githubusercontent.com/cedvdb/x_router/main/recordings/recording_example.gif" width="600"/>



## Core idea

One area that seem to be a point of confusion for developers is the different back buttons. On the web there is the back button, usually using the browser arrow ◀, to navigate chronologically through the pages we visited before. While in an application there is typically also an up button, usually the icon ⬅ at the top of the app bar, to navigate up in the stack of pages that are superimposed on each others. In this doc, the word **upstack** is used to refer to the stack of pages accessible when pressing ⬅ and popping the current page.
(for more information see https://developer.android.com/guide/navigation/navigation-principles)

The main idea of this package is that the __upstack is a function of the url__ 

That is that for an url like `/products/123` we have a stack of two pages `[ProductsPage, ProductsDetailsPage]` by default.

Let's take this fairly common and complex scenario:

```
  '/sign-in' => user access this page when unauthenticated
  '/sign-in/verify_phone' => user can access this nested page when unauthenticated 
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
  - `pop`: if upstack is not empty `goTo` first location in upstack
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

For nested routing you have the choice between using a child router or build on top of a tab system. 


## Child Router

First setup your view with flutter's `Router` as a child. That is where your child routes will be rendered:

```dart

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  initState() {
    _tabController = TabController(length: 2, vsync: this, );
    super.initState();
  }

  @override
  dispose() {
    _routerSubscription?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('product details: ${widget.product!.name}'),
        bottom: TabBar(
          controller: _tabController,
          onTap: _navigate,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
            ),
            Tab(
              icon: Icon(Icons.comment),
            ),
          ],
        ),
      ),
      body: Router(
        routerDelegate: router.childRouterStore.findDelegate(
          RouteLocations.productDetail,
        ),
      ),
    );
  }
}

```

Next you probably want to react to navigation changes, in the example above we want to animate the tabs

```dart
  final Map<String, int> _tabIndexes = const {
    RouteLocations.productInfo: 0,
    RouteLocations.productComments: 1,
  };

  @override
  initState() {
    _tabController = TabController(length: 2, vsync: this);
    _routerSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .listen((_) => _changeTabIndex(router.history.currentUrl));
    super.initState();
  }

  /// changes tab index given a path
  _changeTabIndex(String path) {
    final index = _findTabIndex(path);
    if (index != null && index != _tabController?.index) {
      _tabController?.animateTo(index);
    }
  }

  /// finds the tab index given a path
  int? _findTabIndex(String path) {
    try {
      return _tabIndexes.entries
          .firstWhere((entry) => path.startsWith(entry.key))
          .value;
    } catch (e) {
      return null;
    }
  }
```

Finally you have to define your routes:


```dart
XRoute(
  path: RouteLocations.productDetail,
  builder: (ctx, route) => ProductDetailsPage(route.pathParams['id']!),
  // here is a nested router
  childRouterConfig: XChildRouterConfig(
    resolvers: [
      XRedirectResolver(
        from: RouteLocations.productDetail,
        to: RouteLocations.productInfo,
      ),
    ],
    routes: [
      XRoute(
        path: RouteLocations.productInfo,
        builder: (_, __) =>
            const Center(child: Text('info (Displayed via nested router)')),
      ),
      XRoute(
        path: RouteLocations.productComments,
        builder: (_, __) => const Center(
            child: Text('comments (displayed via nested router)')),
      ),
    ],
  ),
),
```

# Tabs and Bottom navigation support

For tabs support you have to make the url react to tab changes and the tabs have to react to url changes themselves. This is the same idea as for the child router. Let's see an example with bottom nav

1. First let's create a reactive bottom nav.  This bottom bar will react to navigation events to animate itself

```dart

class BottomNav extends StatefulWidget {
  const BottomNav({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final _tabsIndex = <String, int>{
    RouteLocations.dashboard: 0,
    RouteLocations.products: 1,
    RouteLocations.favorites: 2,
  };
  StreamSubscription? navSubscription;

  int _selectedTab = 0;

  @override
  void initState() {
    _selectedTab = _findTabIndex(router.history.currentUrl) ?? 0;
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

  /// finds the tab index associated with a path
  int? _findTabIndex(String path) {
    try {
      return _tabsIndex.entries
          .firstWhere((entry) => path.startsWith(entry.key))
          .value;
    } catch (e) {
      return null;
    }
  }

  /// changes the selected tab when the url changes
  _refreshBottomBar() {
    final foundIndex = _findTabIndex(router.history.currentUrl);
    if (foundIndex != null) {
      setState(() => _selectedTab = foundIndex);
    }
  }

  /// when a tab is clicked, navigate to the target location
  _navigate(int index) {
    router.goTo(_findRoutePath(index));
  }

  /// finds the url path given a tab index
  String _findRoutePath(int index) {
    return _tabsIndex.entries.firstWhere((entry) => entry.value == index).key;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: _navigate,
      selectedIndex: _selectedTab,
      key: const ValueKey('bottom-navigation-bar'),
      destinations: const [
        // material you
        NavigationDestination(label: 'dashboard', icon: Icon(Icons.home)),
        NavigationDestination(
            label: 'products', icon: Icon(Icons.shopping_bag)),
        NavigationDestination(label: 'favorites', icon: Icon(Icons.favorite))
      ],
    );
  }
}

```


 2. Next let's create an App layout that uses this bottom bar. It has a child input, and animates itself when its input changes

```dart

class HomeLayout extends StatefulWidget {
  final Widget child;
  const HomeLayout({
    Key? key,
    required this.child,
  }) : super(key: const ValueKey('homelayout'));

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late Widget child;

  @override
  void initState() {
    super.initState();
    child = widget.child;
  }

  @override
  void didUpdateWidget(HomeLayout old) {
    child = widget.child;
    super.didUpdateWidget(old);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

```

3. You can now use your layout when defining you routes

```dart
    XRoute(
    path: RouteLocations.dashboard,
    builder: (ctx, route) => const HomeLayout(
      child: DashboardPage(),
    ),
    titleBuilder: (_, __) => 'dashboard',
  ),
  XRoute(
    path: RouteLocations.products,
    builder: (ctx, route) => const HomeLayout(
      child: ProductsPage(),
    ),
    titleBuilder: (_, __) => 'products',
  ),
  XRoute(
    path: RouteLocations.favorites,
    builder: (ctx, route) => const HomeLayout(
      child: FavoritesPage(),
    ),
    titleBuilder: (_, __) => 'My favorites',
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