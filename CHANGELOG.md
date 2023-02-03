### v0.1.0 - 2023-2-3

- Fixed Slimy::Rails::SLITools, it now prepends actions to enable sli methods to run before rails redirect or render halting from other before_actions. `sli_tag`, `sli_tags`, `sli_ignore`, and `sli_deadline` should only be called once per subclass controller now.

### v0.0.11 - 2022-11-10

- Fixed Slimy::Reporters::RailsLogReporter, it should now be used to output logs through the host application's Rails.

### v0.0.10 - 2021-01-19

- add sidekiq middleware for sli metrics

### v0.0.9 - 2020-12-11

### v0.0.8 - 2020-12-08

- remove controller_class_name use class.name

### v0.0.7 - 2020-12-07

#### Rails Integration

- controller tag will now use controller_class_name to prevent potential namespace conflicts

### v0.0.6 - 2020-12-07

- Fix datadog issues

### v0.0.5 - 2020-12-07

- Added sli_tags to allow multiple tags on one line
- Added more tests included for rake

### v0.0.3 - 2020-12-04

- Tested changelog

### v0.0.2 - 2020-12-04

- Added changelog
