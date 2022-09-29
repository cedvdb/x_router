## [0.3.0] 
 - removed reactive resolvers
 - made resolvers async

## [0.2.0] - 02/06/2022

 - This minor release was foccussed on having
   good support for child routers.
 - The pop method has been removed, you should use Navigator.of(ctx).pop() instead.

## [0.1.6] - 31/05/2022

 - Fix issue where child router would refresh on parent router path.

## [0.1.5] - 29/05/2022

 - Fix issue where first declared routes in child router were matched first.

## [0.1.4] - 27/05/2022

 - inconsequential internal change

## [0.1.3] - 04/04/2022

 - added ByPass Resolver action


## [0.1.2]
 - display initial route if the router is navigated before the app started (for example in unit tests setup)

## [0.1.1]
 - add `when` param on redirect resolver
 - title builder no longer receives the activatedRoute as param
 - page builder return type is no longer dynamic
 - added toString to XRouterException

## [0.1.0+2] - 27/11/2021
- docs

## [0.1.0] - 27/11/2021

- Added child router support !
- Added more test coverage
- Fixed relative navigation
- Reworked some of the internals

## [0.0.4] - 24/11/2021

- [Breakign]: made XRoute receive a titleBuilder instead of a String

## [0.0.3] - 24/11/2021

- [Breakign]: made Loading screen receive a builder instead of a widget

## [0.0.2] - 24/11/2021

- [Breaking]: static methods changed into instance method as deemed too much of an anti pattern
- redirectTo in XNotFoundResolver now required as it felt too magical

## [0.0.1+3] - 23/11/2021

* docs

## [0.0.1+2] - 23/11/2021

* docs

## [0.0.1+1] - 23/11/2021

* docs

## [0.0.1] - 23/11/2021

* Initial release
