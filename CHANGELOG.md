**1.4.0**
- Added opt-in deep-merge for configuration service_attributes. When `KuberKit::Container["configs"].deep_merge_service_attributes = true`, nested hashes (e.g. `env`) from a configuration's `service_attributes` are merged into the service's definition attributes instead of replacing them entirely. Arrays are still replaced, not concatenated. Disabled by default — existing behavior is unchanged.

**1.3.8**
- Deploy initializers separately first even if they are part of the initially requested list of services

**1.3.7**
- Monkeypatch for TTY::Prompt so that we can sanitize the filter value
- Add ruby 3.3 support in specs
- Update helm deploy command to wait for service restart

**1.3.6**
- Remove dependency on ed25519 gem since it makes installation too complex

**1.3.5**
- Update git force_pull_repo command to improve performance

**1.3.4**
- Fix checking branch name in git artifact update
- Make LocalContextHelper compatible with ruby 3

**1.3.3**
- Support "partials" in the templates with "render" method.
- Cleanup artifacts after deployment if cache_result: false
- Improve fetching git artifact when branch name has changed

**1.3.2**
- Added an ability to generate helm templates using `kit generate` command

**1.3.1**
- Fix upgrade command for helm strategy

**1.3.0**
- Allow sending custom apply command for k8s deploy strategy
- Added initial support for helm deploy strategy

**1.2.7**
- Added an option to skip deployment and only build images for `deploy` command

**1.2.6**
- Lock cli-ui version on 2.1.0 (2.2.x has some bugs)

**1.2.5**
- Improve handling ContextVars, ability to convert context var to OpenStruct

**1.2.4**
- Fix a mistake in setting env variables
- Added an option to set "use local deployment" variable
- Allow finding job resources in kit attach and kit log

**1.2.2**
- Support Ruby 3.2.0

**1.2.1**
- Update shell commands so that STDERR stream won't be merged for commands using the command result.
- kit sh would also set current default configuration
- kit get supports "api" ui
- show sync description (git/local) for artifact sync

**1.2.0**
- Change minimal ruby version to 3

**1.1.1**
- Change minimal ruby version to 2.7

**1.0.1**
- Change minimal ruby version to 2.6

**1.0.0**
- Bump stable release

**0.9.9**
- Fix updating artifact if it was force-pushed
- Improve resource selector, allow connecting to job via kit console

**0.9.0-0.9.8**
- Allow skipping confirmation during deployment
- Added `kit sh` command to create a new shell
- Use tmp dir as image builds parent dir for remote compilation

**0.8.4-0.8.8**
- Added initial services support, to deploy before all other servies
- Allow namespace as symbol in kubectl commands
- Allow setting kubectl entrypoint for configuration

**0.8.3**
- Always load artifacts, if kubeconfig is an artifact

**0.8.2**
- Update Kit Env command to support kubeconfig path as artifact

**0.8.1**
- Allow deploying services without dependecies
- Default services should be first in the list
- KubeConfig should be able to take file from artifact

**0.7.1**
- Added Ruby 3.0 support

**0.6.4**
- Improve context vars, allow checking if variable is defined

**0.6.3**
- Fix updating artifacts when there is only local artifacts

**0.6.2**
- Added an ability to return build vars as a hash value.
- Skip local artifacts while updating configuration, it sometimes produce an error

**0.6.1**
- Improve performance of artifacts update by updating in threads.
- Added an ability to define default services

**0.6.0**
- Cleanup old image build dirs
- Add rotation to deployment log file

**0.5.10**
- Fix a regression when deployment result would not be properly returned as json.

**0.5.9**
- Added an ability to set custom user
- Allow setting environment variable in docker strategy
- Properly stop deployment if image compilation is failed

**0.5.8**
- Update gemspec to support ruby 2.5

**0.5.7**
- Look for kuber_kit root path in parent folders, so kit command will work in sub-folders

**0.5.6**
- Pre-process env file if it has .erb extension
- Allow attaching env file from configuration to docker container
- Change default data paths to use home directory
- Add env groups support to combine multiple env files

**0.5.5**
- Added ability to skip services during deployment using -S option

**0.5.4**
- Added disabled services support

**0.5.3**
- Change the symbol to exclude service from "-" to "!", you can pass "-s !auth_app" to exclude "auth_app"
- Added kit get command to find pods
 
**0.5.2**
- Added dependencies support to services
- Added an option to deploy all services in `kit deloy`
- Wait for rollout to finish during service deploy
- Deploy services in batches, not all of the simultaneously