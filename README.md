# x_router

Flutter navigation made easy by providing a simple API.

# Features

  - redirects
  - reactive guards
  - tabs support
  - router history
  - tab title
  - simple
  - event driven
  - test coverage


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


# Reactive guards / resolvers


When a page is accessed via a path ('/route'). That route goes through each resolvers provided to the router, sequentially and either `Redirect` or goest to the `Next` resolver.


Here is an example of redirect resolver:

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
  XResolverAction resolve(String target) async {
    if (target.startsWith(from)) {
      return Redirect(to);
    }
    return Next();
  }
}
```

resolvers can return 3 type of value:

  - `Redirect`: redirects to a target (and go through each resolver again)
  - `Next`: proceeds to the next resolver until we reach the end (no redirect)
  - `Loading`: stops the resolving process and display a widget on screen until it is ready (see next section)

## Reactive resolvers

If you need your resolver to trigger on state change, you can simply implement any `Listenable` (ChangeNotifier, ValueNotifier,...).

The canonical example of a reactive resolver use case is authentication. 

In the following example, when the authentication status changes, the XRouter will be notified of
such a change and will trigger `XRouter.refresh()` which will start the resolving process again.

- If the user is authenticated he will be redirected to /home (if not already there)
- If the user is unauthenticated he will be redirected to /sign-in (if not already there)
- If the auth status is unknow a loadingScreen will be shown until `notifyListeners` or `XRouter.refresh()` is called.


```dart
class AuthResolver extends ValueNotifier with XResolver {
  AuthResolver() : super(AuthStatus.unknown) {
    AuthService.instance.authStatusStream.listen((authStatus) => value = authStatus);
  }

  @override
  XResolverAction resolve(String target) {
    switch (value) {
      case AuthStatus.authenticated:
        if (target.startsWith(AppRoutes.signIn)) {
          return const Redirect(AppRoutes.home);
        } else {
          return const Next();
        }
      case AuthStatus.unautenticated:
        if (target.startsWith(AppRoutes.signIn)) {
          return const Next();
        } else {
          return const Redirect(AppRoutes.signIn);
        }
      case AuthStatus.unknown:
      default:
        return const Loading(
          LoadingPage(text: 'Checking Auth Status'),
        );
    }
  }
}
```

This is powerful because you then don't need to worry about redirection on user authentication.


## Provided resolvers

A series of resolvers are provided by the library:

 - XNotFoundResolver: to redirect when no route is found
 - XRedirect: to redirect a specific path


# Navigating

For navigation you can use the static method `XRoute.goTo(location)`

```dart
  XRouter.goTo('/products/:id', params: { 'id': '123' });
  // Generally you will store your routes somewhere:
  XRouter.goTo(AppRoutes.productDetails, params: { 'id': '123' });
```

## All navigation methods

  - `goTo`: goes to location adding the target to history
  - `replace`: removes current location from history and `goTo` location
  - `pop`: if upstack is not empty `goTo` first location in upstack
  - `back`: go back chronologically
  - `refresh`: go to current location (useful for your resolvers have state)


# Tabs

For tabs, you need to redirect when a new tab is clicked

```dart
  _navigate(int index) {
    if (index == 0) {
      XRouter.goTo(AppRoutes.dashboard);
    } else if (index == 1) {
      XRouter.goTo(AppRoutes.products);
    } else if (index == 2) {
      XRouter.goTo(AppRoutes.favorites);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tabs'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => _navigate(index),
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.star)),
            Tab(icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DashboardPage(),
          ProductsPage(),
          FavoritesPage(),
        ],
      ),
    );
```

You also need to change the tab when the url changes:

```dart
class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription? navSubscription;

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    navSubscription = XRouter.eventStream
        .where((event) => event is NavigationEnd)
        .cast<NavigationEnd>()
        .listen((nav) {
      if (nav.target.startsWith(AppRoutes.products) &&
          _tabController.index != 1) {
        _tabController.animateTo(1);
      }
      if (nav.target.startsWith(AppRoutes.dashboard) &&
          _tabController.index != 0) {
        _tabController.animateTo(0);
      }
      if (nav.target.startsWith(AppRoutes.favorites) &&
          _tabController.index != 2) {
        _tabController.animateTo(2);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _tabController.animateTo(widget.index);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    navSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  _navigate(int index) {
    if (index == 0) {
      XRouter.goTo(AppRoutes.dashboard);
    } else if (index == 1) {
      XRouter.goTo(AppRoutes.products);
    } else if (index == 2) {
      XRouter.goTo(AppRoutes.favorites);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tabs'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => _navigate(index),
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.star)),
            Tab(icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DashboardPage(),
          ProductsPage(),
          FavoritesPage(),
        ],
      ),
    );
  }
}

```

finally you have to setup your routes in such a way that page transition does not happen,
here the `HomeLayout`

```dart

```


# Why don't I need context to access the XRouter

As stated in the core idea section, the page displayed is a function of the URL. There is only one URL.