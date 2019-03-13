# CHANGELOG

## 0.1.3
* Support newer TLS versions by supporting newer savon, to use newer httpi.
* Fixed bad active_support require statement.
* Better stack traces for failures in generated model methods.
* Better syntax highlighting for generated model methods.
* Reraise test failures in generated model methods.
* Fixed development dependencies.

## 0.1.2
* Fix POODLE Vulnerability Upgrade savon version from 0.2.0 to 1.3.0 (now using httpi 2.2.7)
* Using forked version of Savon from VerticalResponse repo
* Refactor Config class to extract API Mappings
* Enabled SSL cert, ca-cert, key, password config options
* Enabled SSL options to be passed to the httpi adapter for proper handshake
* Version bump 0.1.1 to 0.1.2

## 0.1.0 (2014-04-04)

* Added support for WebSession, escaping initialize [#7](https://github.com/agoragames/vindicia-api/pull/7)

## 0.0.7 (2013-08-23)

* Locked savon dependency in gemspec to ~> 1.2.0

## 0.0.6

* Update activesupport dependency to be activesupport instead of active_support.

## 0.0.2

* Initial public release
