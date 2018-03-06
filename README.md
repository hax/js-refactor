[![Build Status](https://travis-ci.org/hax/js-refactor.svg?branch=master)](https://travis-ci.org/hax/js-refactor)
[![Downloads](https://img.shields.io/apm/dm/js-refactor.svg)](https://atom.io/packages/js-refactor)
[![apm](https://img.shields.io/apm/v/js-refactor.svg)](https://atom.io/packages/js-refactor)

# JS Refactor Package

JavaScript refactoring language plugin for [Atom](https://atom.io/).
**This package requires [refactor](https://atom.io/packages/refactor) package.**
You can install from the preference pane.


## ES6+ Support

Start from v0.6.0, we already have experimental support of ES6+,
track [#6](https://github.com/hax/js-refactor/issues/6) for more details.


## Related Packages

* [refactor](https://atom.io/packages/refactor): Main package.
* [coffee-refactor](https://atom.io/packages/coffee-refactor): Language plugin for CoffeeScript.


## Changelog

### v0.8.0 on 2018-03-06
* Upgrade to babylon 7 beta, which support more new syntax
* Add `.mjs` file extension
* Enable tests

### v0.7.5 on 2016-12-28
* Fix #20, #25

### v0.7.2 on 2016-06-30
* Use original debug package to solve install failures, fix #8, #15
* Support different styles for references/mutations/declaration
* Fix #14

### v0.7.0 on 2016-06-24
*	Upgrade to babylon 6, enable all ES next syntax (include stage 0 features like
	bind operator) and JSX, Flow... all features babel support.
	Babylon 6 is not compatible with estools, so we change to babel-traverse,
	and rewrite and simplify the implementations, it should also fix all issues
	from underlying. (Of coz it may introduce new issues :)
* Implement correct renaming of object shorthand and import alias.

### v0.6.0 on 2015-09-08

* Require Atom >=1.0.0, refactor ^0.6.0
* Experimental support of ES6+ (Babel, stage >= 1)
* Start migrating from coffeescript to babel
* Improve esrefactor based on a most recent and active fork
* Use babylon (the parser of babel) instead of esprima
* Update estools (estraverse, escope) to latest version
* Add debug util
* Update travis config as latest atom/ci

### [Changelog of old versions](CHANGELOG.md)
