# [2.8.0](https://github.com/hexonet/perl-sdk/compare/v2.7.1...v2.8.0) (2020-05-12)


### Features

* **apiclient:** allow to specify additional libraries via setUserAgent ([26cb7e4](https://github.com/hexonet/perl-sdk/commit/26cb7e439e22709f042d4a2983857f24f6c2f8ea))

## [2.7.1](https://github.com/hexonet/perl-sdk/compare/v2.7.0...v2.7.1) (2020-05-12)


### Bug Fixes

* **security:** replace passwords whereever they could be used for output ([b055db5](https://github.com/hexonet/perl-sdk/commit/b055db543f3f7cce7c19ca9dec852a46f301d55f))

# [2.7.0](https://github.com/hexonet/perl-sdk/compare/v2.6.1...v2.7.0) (2020-05-12)


### Features

* **response:** added getCommandPlain (getting used command in plain text) ([aeed347](https://github.com/hexonet/perl-sdk/commit/aeed347c901444fc1edbda7d9fcf34da4c3f4f00))

## [2.6.1](https://github.com/hexonet/perl-sdk/compare/v2.6.0...v2.6.1) (2020-05-12)


### Bug Fixes

* **messaging:** return a specific error template in case code or description are missing ([f519750](https://github.com/hexonet/perl-sdk/commit/f5197508a73d25db15c11829275db984ce7a00a4))

# [2.6.0](https://github.com/hexonet/perl-sdk/compare/v2.5.0...v2.6.0) (2020-05-12)


### Features

* **response:** possibility of placeholder vars in standard responses to improve error details ([9e2f076](https://github.com/hexonet/perl-sdk/commit/9e2f076f87d43a91d62cb858815393335b7bcde7))

# [2.5.0](https://github.com/hexonet/perl-sdk/compare/v2.4.0...v2.5.0) (2020-05-11)


### Features

* **apiclient:** support the `High Performance Proxy Setup`. see README.md ([6a8d596](https://github.com/hexonet/perl-sdk/commit/6a8d5964c48e906d67f3bfec0adad76788f2d119))

# [2.4.0](https://github.com/hexonet/perl-sdk/compare/v2.3.0...v2.4.0) (2020-05-11)


### Features

* **apiclient:** automatic IDN conversion of API command parameters to punycode ([3ce590c](https://github.com/hexonet/perl-sdk/commit/3ce590cbfb3c2d6e2a07fb3569963f4f1908aff2))

# [2.3.0](https://github.com/hexonet/perl-sdk/compare/v2.2.5...v2.3.0) (2020-03-16)


### Features

* **apiclient:** support bulk parameter through nested array in api command, see README.md ([8a0f0e1](https://github.com/hexonet/perl-sdk/commit/8a0f0e1e245c03019c2d402fc5bf4c4af16347de))

## [2.2.5](https://github.com/hexonet/perl-sdk/compare/v2.2.4...v2.2.5) (2019-10-04)


### Bug Fixes

* **responsetemplate/mgr:** improve description for `423 Empty API response` ([b81621e](https://github.com/hexonet/perl-sdk/commit/b81621e))

## [2.2.4](https://github.com/hexonet/perl-sdk/compare/v2.2.3...v2.2.4) (2019-09-20)


### Bug Fixes

* **dev-deps:** reviewed necessary list of deps for tests ([8c40644](https://github.com/hexonet/perl-sdk/commit/8c40644))
* **Travis:** check apt installation change ([6bad49a](https://github.com/hexonet/perl-sdk/commit/6bad49a))
* **Travis:** include default package installation ([a5bebe3](https://github.com/hexonet/perl-sdk/commit/a5bebe3))
* **Travis:** install specific package versions ([124c11c](https://github.com/hexonet/perl-sdk/commit/124c11c))
* **Travis:** review cpanm and dep installation ([0436ca5](https://github.com/hexonet/perl-sdk/commit/0436ca5))
* **Travis:** review installation of cpanimus ([6066687](https://github.com/hexonet/perl-sdk/commit/6066687))

## [2.2.3](https://github.com/hexonet/perl-sdk/compare/v2.2.2...v2.2.3) (2019-09-19)


### Bug Fixes

* **release process:** migrate configuration ([26efd60](https://github.com/hexonet/perl-sdk/commit/26efd60))

## [2.2.2](https://github.com/hexonet/perl-sdk/compare/v2.2.1...v2.2.2) (2019-08-16)


### Bug Fixes

* **Makefile:** remove it from repository (use auto-build) ([8a44026](https://github.com/hexonet/perl-sdk/commit/8a44026))

## [2.2.1](https://github.com/hexonet/perl-sdk/compare/v2.2.0...v2.2.1) (2019-08-16)


### Bug Fixes

* **APIClient:** change default SDK url ([e8973a8](https://github.com/hexonet/perl-sdk/commit/e8973a8))

# [2.2.0](https://github.com/hexonet/perl-sdk/compare/v2.1.0...v2.2.0) (2019-04-18)


### Features

* **responsetemplate:** add isPending method ([abe830c](https://github.com/hexonet/perl-sdk/commit/abe830c))

# [2.1.0](https://github.com/hexonet/perl-sdk/compare/v2.0.1...v2.1.0) (2019-04-03)


### Bug Fixes

* **npm:** security dep bump ([3e1d2fe](https://github.com/hexonet/perl-sdk/commit/3e1d2fe))


### Features

* **APIClient:** review user-agent usage ([dbc9b62](https://github.com/hexonet/perl-sdk/commit/dbc9b62))

## [2.0.1](https://github.com/hexonet/perl-sdk/compare/v2.0.0...v2.0.1) (2018-12-17)


### Bug Fixes

* **readme:** installation steps and examples ([407f86b](https://github.com/hexonet/perl-sdk/commit/407f86b))

# [2.0.0](https://github.com/hexonet/perl-sdk/compare/v1.12.0...v2.0.0) (2018-12-17)


### Bug Fixes

* **releasing:** add x-bit to buildrelease.sh ([ec7d366](https://github.com/hexonet/perl-sdk/commit/ec7d366))
* **releasing:** archive file name version ([ce094cc](https://github.com/hexonet/perl-sdk/commit/ce094cc))
* **releasing:** suppress stderr output of rm ([03eb2fa](https://github.com/hexonet/perl-sdk/commit/03eb2fa))


### Code Refactoring

* **pkg:** rewrite in direction of our cross-SDK UML Diagram ([1cd1cbf](https://github.com/hexonet/perl-sdk/commit/1cd1cbf))


### BREAKING CHANGES

* **pkg:** Downward incompatible, please migrate. The whole class structure and usage behavior
has changed.
