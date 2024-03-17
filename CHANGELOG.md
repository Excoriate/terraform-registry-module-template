# Changelog

## [0.1.3](https://github.com/Excoriate/terraform-registry-module-template/compare/v0.1.2...v0.1.3) (2024-03-17)


### Bug Fixes

* ci linter ([88fa38d](https://github.com/Excoriate/terraform-registry-module-template/commit/88fa38d9f0ebcc0590e4d55069ab1ec7c0c4b5de))
* ci workflows on github ([f304bc9](https://github.com/Excoriate/terraform-registry-module-template/commit/f304bc96b187a0f6bdbc3e6bcc83d26e742838d4))
* Update version of various hooks ([#6](https://github.com/Excoriate/terraform-registry-module-template/issues/6)) ([2f92b9f](https://github.com/Excoriate/terraform-registry-module-template/commit/2f92b9ff27bc6e49830cb7c93051439f96dec9ee))


### Refactoring

* Update task file to streamline unit and integration testing ([#4](https://github.com/Excoriate/terraform-registry-module-template/issues/4)) ([54638cd](https://github.com/Excoriate/terraform-registry-module-template/commit/54638cd916075befe3724d6cf680c1246d189723))

## [0.1.2](https://github.com/Excoriate/terraform-registry-module-template/compare/v0.1.1...v0.1.2) (2023-12-14)


### Features

* Add new task for managing entirely recipe's lifecycle ([1c37e7c](https://github.com/Excoriate/terraform-registry-module-template/commit/1c37e7cc1c5af05e6811d4d81fca4e2c346d9d3a))
* Add new tasks for recursively generate docs, and validate files ([04539ed](https://github.com/Excoriate/terraform-registry-module-template/commit/04539ed8164ae7a2dda87ca0e04a823eaf52d403))


### Bug Fixes

* Add proper tflint --init flag to pre-commit hook for each module and recipe ([23bcedb](https://github.com/Excoriate/terraform-registry-module-template/commit/23bcedb19d580999eb885efbb831ba57a3174d63))
* Remove clean hook from taskfile, it removes states whle tsting locally ([6cc0976](https://github.com/Excoriate/terraform-registry-module-template/commit/6cc097696551856986b8877221e721ef42102a08))


### Refactoring

* Add recipe-lint specific task and makeFile target ([cdf8888](https://github.com/Excoriate/terraform-registry-module-template/commit/cdf888808e85c2c20e18906c14191f6ab7468a75))


### Docs

* Update readme.md adding proposed roadmap ([7e220cd](https://github.com/Excoriate/terraform-registry-module-template/commit/7e220cdfe547cc51d58c070a25d5a2e00c13fc39))
* Update readme.md adding proposed roadmap ([952dd25](https://github.com/Excoriate/terraform-registry-module-template/commit/952dd2535fe3c7304e0095178f12beb0e1345252))


### Other

* fix pre-commit markdown linter, added fixer ([40a2e2c](https://github.com/Excoriate/terraform-registry-module-template/commit/40a2e2c8323d34289bc77352e222d79ea36d0a0f))

## [0.1.1](https://github.com/Excoriate/terraform-registry-module-template/compare/v0.1.0...v0.1.1) (2023-12-04)


### Refactoring

* Fix text in example module. Changed go module's name ([e0ad3ba](https://github.com/Excoriate/terraform-registry-module-template/commit/e0ad3ba398577d3cf7691d2ebbc026a1a0c5ce90))
* Fix text in example module. Changed go module's name ([f940e6e](https://github.com/Excoriate/terraform-registry-module-template/commit/f940e6e585ff5ea73144a3d71a1a30e72218e7b3))

## 0.1.0 (2023-12-04)


### Features

* add markdown linter ([c0fcd64](https://github.com/Excoriate/terraform-registry-module-template/commit/c0fcd6495830db003b823f1762e015a045e14d8b))
* add markdown linter ([5ce7a51](https://github.com/Excoriate/terraform-registry-module-template/commit/5ce7a512d829ab02da990401629bb36b54fc0bbc))
* first structure, and skeleton ([2284cde](https://github.com/Excoriate/terraform-registry-module-template/commit/2284cdedeba622b9315a1e9ddf2044dc82bf5878))


### Bug Fixes

* linter issues ([0a91add](https://github.com/Excoriate/terraform-registry-module-template/commit/0a91add44d30b1b57fb4cfe4d8d421117f59f8da))
* remove issues ([84e61bd](https://github.com/Excoriate/terraform-registry-module-template/commit/84e61bdc1d413aa23d94f7fad308f7084170d50f))


### Refactoring

* Add better dotFiles, add better hooks for pre-commit ([4c22c86](https://github.com/Excoriate/terraform-registry-module-template/commit/4c22c861713b04b82e55ee12495ba63a7bfa5c1a))
* Add better github configuration files ([503d37f](https://github.com/Excoriate/terraform-registry-module-template/commit/503d37fbf3eb3783cef62054e9e91b1c3a8b0920))
* Add golangci-lint as a hook ([b46e6c2](https://github.com/Excoriate/terraform-registry-module-template/commit/b46e6c2d58488b76ed49021bc98353d7882edfdc))
* Add golangci-lint as a hook with dynamic identification of tests ([f8d5727](https://github.com/Excoriate/terraform-registry-module-template/commit/f8d572700665c4ed6f2a2a1fb70bf01b52ac4c52))


### Docs

* Update readme.md ([0df3759](https://github.com/Excoriate/terraform-registry-module-template/commit/0df3759ca18508f3336b81a3f4e7e866462a9abd))


### Other

* add extra commands to taskfile ([53344e4](https://github.com/Excoriate/terraform-registry-module-template/commit/53344e490a4eceb83c839085a0c2489f68ffe5c3))
* Fix badge link ([f834b2c](https://github.com/Excoriate/terraform-registry-module-template/commit/f834b2cef7e4b5fa35b84b64a319861ced9b9a3d))
