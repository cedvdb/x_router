# Router implementation design

# Goals

Taking the API design document to generate an overview of what needs to be built.

requirements:
  - The state of the routing has to be observable
  - The state of the routing has to be debuggable (by seeing the state in the widget tree)

# State

We need a class ActivatedRoute that holds the information about the currently navigated route:
  - params

We need a class RouterState that holds the following information:

  - ActivatedRoute current route
  - ActivatedRoute target route
  - Dynamic state of guards / resolvers ,



# Classes

From the API document we can see that we need:
  - Router
  - Route
  - RouteGroup
  - Guard

From the state section above:
  - ActivatedRoute
  - RouterState

From the Flutter Navigator 2.0 API we need
  - RouterDelegate
  - RouterInfoParser


For the state the classes needed still need to be defined


## Router

Main entry point of the implementation, once initialized with routes we can use `.delegate` and `.parser` to give them to the material app.

## Route

A route path that can be navigated to '/products/:id'

## RouteGroup

Groups multiple routes

## RouteGuard

Resolves the target route into a specific one which may or may not be the target route

## ActivatedRoute

Holds the information about the current navigated route like the parameters, the matching route

## RouterState

Holds the information about the state of the routing in the app (resolvers state mainly)

## RouterDelegate

Holds the state of the app to generate the stack

## RouterInfoParser

converts url into a class representing the active route (TBD)


# Implementation



