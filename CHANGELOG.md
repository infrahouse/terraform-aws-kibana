# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security
- Mark kibana_system_password as sensitive ([68067c3](https://github.com/infrahouse/terraform-aws-kibana/commit/68067c3))

### Documentation
- Add output descriptions and mark password as sensitive ([0967567](https://github.com/infrahouse/terraform-aws-kibana/commit/0967567))

### Breaking Changes
- Upgrade ECS module to v7.0.0 ([393acd9](https://github.com/infrahouse/terraform-aws-kibana/commit/393acd9))

### Chores
- Prepare for ECS v7 upgrade ([16383e1](https://github.com/infrahouse/terraform-aws-kibana/commit/16383e1))

## [1.13.1] - 2024-XX-XX

### Changed
- Publish on self-hosted runner ([e97d9e7](https://github.com/infrahouse/terraform-aws-kibana/commit/e97d9e7))

### Dependencies
- Update dependency python to 3.14 (#32) ([9c5c693](https://github.com/infrahouse/terraform-aws-kibana/commit/9c5c693))

## [1.13.0] - 2024-XX-XX

### Added
- Add AWS provider 6 support and GitHub Actions CI/CD workflows (#31) ([faa33df](https://github.com/infrahouse/terraform-aws-kibana/commit/faa33df))

### Dependencies
- Update actions/checkout action to v5 (#33) ([508e587](https://github.com/infrahouse/terraform-aws-kibana/commit/508e587))
- Update aws-actions/configure-aws-credentials action to v5 (#34) ([7eb1b8a](https://github.com/infrahouse/terraform-aws-kibana/commit/7eb1b8a))

## [1.12.0] - 2023-XX-XX

### Changed
- Update ECS module ([c848b59](https://github.com/infrahouse/terraform-aws-kibana/commit/c848b59))
- Update ECS module ([67c5a32](https://github.com/infrahouse/terraform-aws-kibana/commit/67c5a32))

## [1.11.0] - 2023-XX-XX

### Changed
- Bump ECS version to 5.10.0 ([a288601](https://github.com/infrahouse/terraform-aws-kibana/commit/a288601))

## [1.10.2] - 2023-XX-XX

### Dependencies
- Update dependency pytest-rerunfailures to v15 (#27) ([2b4de83](https://github.com/infrahouse/terraform-aws-kibana/commit/2b4de83))
- Update dependency myst-parser to v4 (#26) ([b7b2daf](https://github.com/infrahouse/terraform-aws-kibana/commit/b7b2daf))
- Update aws-actions/configure-aws-credentials action to v4 (#25) ([a14de78](https://github.com/infrahouse/terraform-aws-kibana/commit/a14de78))
- Update actions/checkout action to v4 (#23) ([16302e9](https://github.com/infrahouse/terraform-aws-kibana/commit/16302e9))
- Update terraform registry.infrahouse.com/infrahouse/ecs/aws to v5.8.3 (#22) ([b093363](https://github.com/infrahouse/terraform-aws-kibana/commit/b093363))

## [1.10.1] - 2023-XX-XX

### Changed
- Upgrade infrahouse/secret/aws to 1.0.2 (#20) ([4f8252d](https://github.com/infrahouse/terraform-aws-kibana/commit/4f8252d))

### Added
- Add renovate.json (#21) ([b0f394b](https://github.com/infrahouse/terraform-aws-kibana/commit/b0f394b))

## [1.10.0] - 2023-XX-XX

### Added
- Add on-demand base capacity (#19) ([123aaf7](https://github.com/infrahouse/terraform-aws-kibana/commit/123aaf7))

## [1.9.0] - 2023-XX-XX

### Added
- Add extra commands for cloudinit (#18) ([9013c78](https://github.com/infrahouse/terraform-aws-kibana/commit/9013c78))

## [1.8.0] - 2023-XX-XX

### Added
- Add extra instance profile permissions (#17) ([d37a2a6](https://github.com/infrahouse/terraform-aws-kibana/commit/d37a2a6))

## [1.7.2] - 2023-XX-XX

### Changed
- Use ECS module with less module_version tags ([c3ed4b5](https://github.com/infrahouse/terraform-aws-kibana/commit/c3ed4b5))

## [1.7.1] - 2023-XX-XX

### Fixed
- Fix pytest-infrahouse dependency conflict ([fa0cb19](https://github.com/infrahouse/terraform-aws-kibana/commit/fa0cb19))

## [1.7.0] - 2023-XX-XX

### Changed
- Set default elasticsearch_request_timeout to 4000 (#16) ([5e8b271](https://github.com/infrahouse/terraform-aws-kibana/commit/5e8b271))

## [1.6.0] - 2023-XX-XX

### Added
- Make elasticsearch request timeout parametrized (#15) ([59a50e7](https://github.com/infrahouse/terraform-aws-kibana/commit/59a50e7))

## [1.5.0] - 2023-XX-XX

### Changed
- Set elastic client timeout to 5 mins (#14) ([76bebf2](https://github.com/infrahouse/terraform-aws-kibana/commit/76bebf2))

## [1.4.0] - 2023-XX-XX

### Added
- Output load_balancer_arn (#13) ([0c03269](https://github.com/infrahouse/terraform-aws-kibana/commit/0c03269))

## [1.3.0] - 2023-XX-XX

### Changed
- Bump ECS module to 5.2.0 (#12) ([d93f4ed](https://github.com/infrahouse/terraform-aws-kibana/commit/d93f4ed))

## [1.2.1] - 2023-XX-XX

### Changed
- Upgrade ECS version to 3.7.0 to tag resources (#11) ([8b424d7](https://github.com/infrahouse/terraform-aws-kibana/commit/8b424d7))

## [1.2.0] - 2023-XX-XX

### Added
- Add variable ssh_cidr_block (#10) ([3d331c7](https://github.com/infrahouse/terraform-aws-kibana/commit/3d331c7))

## [1.1.0] - 2023-XX-XX

### Changed
- Migrate to ECS version 3.5.1 (#9) ([9b8e668](https://github.com/infrahouse/terraform-aws-kibana/commit/9b8e668))

## [1.0.1] - 2023-XX-XX

### Security
- Restrict SSH access to kibana instances to subnets where it was created (#8) ([98f230d](https://github.com/infrahouse/terraform-aws-kibana/commit/98f230d))

## [1.0.0] - 2023-XX-XX

### Changed
- Migrate kibana's ECS to 3.1.1 (#7) ([fc7a75e](https://github.com/infrahouse/terraform-aws-kibana/commit/fc7a75e))

## [0.4.0] - 2023-XX-XX

### Added
- Add variable alb_internal (#6) ([41f8604](https://github.com/infrahouse/terraform-aws-kibana/commit/41f8604))

## [0.3.1] - 2023-XX-XX

### Changed
- Bump ECS module to 2.7 that accepts AMI ([9665cf9](https://github.com/infrahouse/terraform-aws-kibana/commit/9665cf9))

## [0.3.0] - 2023-XX-XX

### Added
- Allow user to specify AMI ([afc02a1](https://github.com/infrahouse/terraform-aws-kibana/commit/afc02a1))

## [0.2.2] - 2023-XX-XX

### Added
- Configure CD for terraform-aws-kibana (#3) ([f38e41e](https://github.com/infrahouse/terraform-aws-kibana/commit/f38e41e))

## [0.2.1] - 2023-XX-XX

### Changed
- Switch ECS module from Terraform registry to Github ([bd73f6f](https://github.com/infrahouse/terraform-aws-kibana/commit/bd73f6f))

## [0.2.0] - 2023-XX-XX

### Fixed
- Fix asg-subnets typo ([dfc7172](https://github.com/infrahouse/terraform-aws-kibana/commit/dfc7172))

## [0.1.0] - 2023-XX-XX

### Added
- Initial kibana implementation ([b9c9a59](https://github.com/infrahouse/terraform-aws-kibana/commit/b9c9a59))

[Unreleased]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.13.1...HEAD
[1.13.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.13.0...1.13.1
[1.13.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.12.0...1.13.0
[1.12.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.11.0...1.12.0
[1.11.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.10.2...1.11.0
[1.10.2]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.10.1...1.10.2
[1.10.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.10.0...1.10.1
[1.10.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.9.0...1.10.0
[1.9.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.8.0...1.9.0
[1.8.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.7.2...1.8.0
[1.7.2]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.7.1...1.7.2
[1.7.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.7.0...1.7.1
[1.7.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.6.0...1.7.0
[1.6.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.2.1...1.3.0
[1.2.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.4.0...1.0.0
[0.4.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.3.1...0.4.0
[0.3.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.2.2...0.3.0
[0.2.2]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/infrahouse/terraform-aws-kibana/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/infrahouse/terraform-aws-kibana/releases/tag/0.1.0
