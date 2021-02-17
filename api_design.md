# Introduction

Flutter routing 2.0 requires a lot of setup. The goal of this package is to make that setup
easy by providing a simpler API.

Flutter brings web navigation and app navigation together and with that resulted some confusion. The confusion lies in the difference between the back button on the web and the up button in an app. The API will also make it clear that those are not to be confused for one and another.

See the material navigation principles for more information on the back and up buttons: https://developer.android.com/guide/navigation/navigation-principles

# Wording

During the design phase of this document `up stack` is used to describe the back stack to clearly delimitate the difference between up and back buttons.


# Design goals

  - The pages on the stack have to be evident
  - Seemless experience between web and mobile (up and back buttons acting the same)
  - Reactive resolvers, navigation based on state (eg: auth state)
  - Passing parameters easily
  - Allow users to specify the transitions they want if needed

# Routing API design

## Scenario

For designing the API this fairly common and complex scenario will be taken as the base case to solve:

```
  '/loading' => user access this page when the authentication state is unknown
  '/sign-in' => user access this page when unauthenticated
  '/sign-in/phone' => user can access this nested page when unauthenticated 
  '/create-profile' => when user is authenticated but doesn't have a profile 
  '/dashboard' => when the user is authenticated & has a profile, the dashboard
  '/products' => when the user is authenticated & has a profile and clicked on a menu item to see the products
  '/products/:id' => when the user wants to see a specific product
```

## Route naming convention 

From the scenario go we can notice that the up stack can be defined as a function of the url path where each segment is a screen in the stack.
For example when on the '/sign-in/phone' route the up stack will look like this:

```
  - SignInScreen
  - SignInWithPhoneScreen
```

On the product details page the up stack will look like this

```
  - ProductsScreen
  - ProductDetailsScreen
```

The only question mark is what happens with the path '/' that we will call home route.


## Home route

Websites are firstly accessed by their main url, eg: www.facebook.com. That main url we define it as `home route` or '/' for short.

The problem with the home route is that the material specs aren't realistic as a webapp standpoint in our scenario. The material specs specify that the home must be the upper most activity in the up stack. Thaht doesn't play well with /sign-in page.

2 question marks remain for that home route:

  - Should the home route be part of the stack when navigating to '/products'
  - What happens when the user types the home route in our scenario since we didn't define it

The two question are intertwined depending on how we approach it:
  1. Either the user is redirected to another page, eg: /dashboard in which case 
    the home route is only part of the stack when we are on /dashboard
  2. Either '/' is not redirected, always defined and always part of the stack in which case
    we have to define what happens when we go to /sign-in
  3. Either '/' must be defined and only sometimes part of the stack, which makes it tricky both as an API and as implementation
  4. Either '/' must be defined and never part of the stack


1 can be picked as a default scenario by introducing the parameter home:
```
  home: '/dashboard'
```
3. is too complex

For 1 & 4 they could as well be in the spec but it's not clear which one should be favorited. While The material design specs says the home route should be the top most page of every application, it doesn't fit the narative of an app having a /sign-in route

## Design 1 : Strict routing naming conventions

```
Router(
  home: '/dashboard', 
  routes: {
    '/sign-in': (context, params) => SignInPage(),
    '/sign-in/phone': (context, params) => SignInWithPhonePage(),
    '/create-profile': (context, params) => CreateProfilePage(),
    '/dashboard': (context, params) => Dashboard(),
    '/products': (context, params) => ProductsPage(),
    '/products/:id': (context, params) => ProductDetailsPage(params['id']),
  },

)
```

In this scenario the routing mechanism obey strict conventions of the url to manage the stack. As discussed before.

```
'/': redirect on /dashboard
'/sign-in/phone': has SignInScreen and SignInWithPhoneScreen in the stack
'/dashboard': has dashboard in the stack
'/products/:id': has ProductDetailScreen and ProductsScreen in the stack
```

If the user wants the home to be the top most Screen in the up stack of products, the user can change the routing as such:

```
Router(
  home: '/app',
  routes: {
    '/sign-in': (context, params) => SignInPage(),
    '/sign-in/phone': (context, params) => SignInWithPhonePage(),
    '/create-profile': (context, params) => CreateProfilePage(),
    '/app': (context, params) => HomePage(),
    '/app/products': (context, params) => ProductsPage(),
    '/app/products/:id': (context, params) => ProductDetailsPage(params['id']),
  }
)
```

*Drawbacks*: 
  - url might not be exactly to user preferences 

## Design 2 : Nesting

```
Router(
  home: '/app',
  routes: [
    RouteConfig(
      path: '/sign-in',
      builder: (context, params) => SignInPage(),
      children: [
        RouteConfig( 
          path: '/phone', 
          builder: (context, params) => SignInWithPhonePage()
        )
      ]
    ),
    //...
  }
)
```

We can see that if the route naming convention has to be respected here too, it doesn't offer any advantage in readability. We have to check the parent to see the whole path

*Drawbacks*:
  - Less readability
  - harder to implement as we have to check parents (tree) instead of just checking the segments of a path.


## Scenario 3: pattern matching


```
Router(
  home: '/dashboard',
  routes: {
    '/sign-in': (context, params) => SignInPage(),
    '/sign-in/**': (context, params) => SignInPage(),
    '/sign-in/phone': (context, params) => SignInWithPhonePage(),
    '/create-profile': (context, params) => CreateProfilePage(),
    '/dashboard': (context, params) => DashBoardPage(),
    '/products': (context, params) => ProductsPage(),
    '/products/**': (context, params) => ProductsPage(),
    '/products/:id': (context, params) => ProductDetailsPage(params['id']),
  }
)
```

Here we have repetition but we could make a rule that ** allow the current directory as well or add another wildcard

```
Router(
  home: '/dashboard',
  routes: {
    '/sign-in/?': (context, params) => SignInPage(),
    '/sign-in/phone': (context, params) => SignInWithPhonePage(),
    '/create-profile': (context, params) => CreateProfilePage(),
    '/dashboard': (context, params) => DashboardPage(),
    '/products/?': (context, params) => ProductsPage(),
    '/products/:id': (context, params) => ProductDetailsPage(params['id']),
  }
)
```


*advantages* :
  - the user has more control over the stack
*drawbacks* :
  - user has to learn a pattern


## Scenario 4 Add stack properties to the routes 

```
Router(
  home: '/dashboard',
  routes: [
    Route(
      path: '/sign-in/', 
      builder: (context, params) => SignInPage(),
    ),
    Route(
      path: '/sign-in/phone', 
      builder: (context, params) => SignInWithPhonePage(),
      upstack: ['/sign-in'] 
    ),
  ]
)
```

 - Although a bit less consise, having a route class would make typing easier for future version.
 - It remains to be defined if custom stacks in this scenario would be useful.

A possible scenario would be: 
We could have /forms/:formId/submit-status and want an up buttons that lets the user go back to the list of forms but not modify the form he already submitted. The stack would look like ['forms'] (+ current route).


## Scenarios conclusions

Scenario 1 to have the easiest API in the widest range of scenarios. While scenario 1 is really easy to setup, scenario 3 offers a bit more control as well as scenario 4. Scenario 4 introduce Route class that would make it more future proof.

Route can be kept for future proofing. The final scenario below will be implemented. Then if the need is apparent, the stack property will be added.


```
Router(
  home: '/home',
  home: '/dashboard',
  routes: [
    Route(
      path: '/sign-in', 
      builder: (context, params) => SignInPage(),
    ),
    Route(
      path: '/sign-in/phone', 
      builder: (context, params) => SignInWithPhonePage(),
    ),
  ]
)
```


# Reactive guards API design

Guards should be reactive to reroute the user when the app state changes. Thankfully the Navigator 2.0 makes that easy.

*requirements:*
  - The guards API must also fit with the design we picked above. 
  - The guards must be reactive, reroute when the state changes
  - The guards must apply to only certain routes
  - The guards must be self contained



## Scenario 1. Reactive resolvers for all the routes:



```
  // Router(resolvers: [AuthResolver(), HasProfileResolver()], routes:...)

  class AuthResolver extends RouteResolver {
    // setting auth state will notify listeners
    state = 'unknown'; // can be 'authenticated', 'unauthenticated' or 'unknown'

    AuthResolver() {
      AuthRepository.authState$.listen((authState) => state = authState);
    }

    resolve(targetRoute) {

      switch(state) {
        case 'unknown':
          return '/loading';
        case 'authenticated':
          if (targetRoute.startsWith('/sign-in')) return '/dashboard';
          else return targetRoute;
        case 'unauthenticated':
          if (! targetRoute.startsWith('/sign-in')) return targetRoute;
          else return '/sign-in;
      }
    }
  }

  class HasProfileResolver extends RouteResolver {
    // setting auth state will notify listeners
    state = 'unknown'; // can be 'has', 'has_not' or 'unknown'

    HasProfileResolver() {
      ProfileRepository.profileState$.listen((profileState) => state = profileState);
    }

    resolve(targetRoute) {
      

      switch(state) {
        case 'unknown':
          return '/loading';
        case 'has':
          if (targetRoute.startsWith('/create-profile')) return '/dashboard';
          else return targetRoute;
        case 'has_not':
          return '/create-profile;
      }
    }
  }

```

Note: 
What happens when the client visit /sign-in and is authenticated but doesn't have a profile ?
  - AuthResolver resolves then on the second pass for the redirect to /dashboard then resolves the results to /create-profile
What happens when the user visits /loading

*advantages*:
  - easy to implement
*drawbacks*:
  - very manual we have to setup everything 
  - full control


## Scenario 2. Reactive guards for specific routes:


```
Router(
    routes: [
      Route(path: '/sign-in', builder:..., resolvers: [unauthenticatedResolver]  ),
      Route(path: '/sign-in/phone', builder:...,  ), // we don't specify resolve here since it's child
      Route(path: '/dashboard', builder:..., resolvers: [authenticatedResolver]  ),
      // ...
    ]
)

  class AuthenticatedResolver extends RouteResolver {
    // setting auth state will notify listeners
    state = 'unknown'; // can be 'authenticated', 'unauthenticated' or 'unknown'

    AuthenticatedResolver() {
      AuthRepository.authState$
        .listen((authState) => state = authState);
    }

    resolve(targetRoute) {
      switch(state) {
        case 'unknown':
          return '/loading';
        case 'unauthenticated':
          return '/sign-in':
        case 'authenticated':
          return targetRoute;
      }
    }
  }

  class UnauthenticatedResolver extends RouteResolver {
    // setting auth state will notify listeners
    state = 'unknown'; // can be 'authenticated', 'unauthenticated' or 'unknown'

    UnauthenticatedResolver() {
      AuthRepository.authState$.listen((authState) => state = authState);
    }

    resolve(targetRoute) {

      switch(state) {
        case 'unknown':
          return '/loading';
        case 'unauthenticated':
          return targetRoute:
        case 'authenticated':
          return '/dashboard';
      }
    }
  }

```

*advantages*:
  - easier to see which route is affected
  - easy API
*drawbacks*:
  - we have to duplicate resolvers for descendant of '/' that are not sign-in
  - in this scenario requires 2 different instance for authenticatedResolver and unauthenticatedResolver


## Scenario 3 route grouping

```
Router(
    home: '/dashboard'
    routes: [
      RouteGroup(
        description: 'unauthenticated'
        guards: [unauthenticatedGuard],
        routes: [
          Route(path: '/sign-in', builder:... ),
          Route(path: '/sign-in/phone', builder:...,  ),         
        ]
      ),
      RouteGroup(
        description: 'authenticated'
        guards: [authenticatedGuard],
        routes: [
          Route(path: '/dashboard', builder: (context, params) => DashboardPage() ),
          Route(path: '/products', builder: (context, params) => ProductsPage()),
          Route(path: '/products/:id', builder: (context, params) => ProductDetailsPage(params['id'])),
        ]
      ),
    ]
)
```

*advantages*:
  - no repetition for guards
  - can protect routes on specific paths from home without relying on the path
*drawbacks*
  - a more convoluted API


## Scenarios conclusions

Scenario 3. has the most advantages, although it adds route grouping wich brings a bit more nesting in the API.

The advantages seem to outweight the cons though.


# Final API design


```
Router(
  home: '/dashboard'
    routes: [
      RouteGroup(
        description: 'unauthenticated'
        guards: [unauthenticatedGuard],
        routes: [
          Route(path: '/sign-in', builder:... ),
          Route(path: '/sign-in/phone', builder:...,  ),         
        ]
      ),
      RouteGroup(
        description: 'authenticated'
        guards: [authenticatedGuard],
        routes: [
          Route(path: '/dashboard', builder: (context, params) => DashboardPage() ),
          Route(path: '/products', builder: (context, params) => ProductsPage()),
          Route(path: '/products/:id', builder: (context, params) => ProductDetailsPage(params['id'])),
        ]
      ),
    ]
)
```