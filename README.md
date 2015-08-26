# Scooter

A CLI for the Marathon Rest API, with some opinionated configuration management of Marathon jobs.

## Installation

````
gem install marathon-scooter
````

## Usage

To see the a complete set of global and command specific command line arguments you can use the following:

`scooter --help`

and

`scooter COMMAND --help`

## Commands

### app

This command retrieves the configuration for a given application id, including the option of a specific application version, and output as JSON.

### clean

This command will remove job configurations *FROM* Marathon that do not exist within a given directory.

*Note: This command is destructive and requires an additional flag to execute the clean*

### delete

This command will delete the job configuration *FROM* Marathon for a given application id.

*Note: This command is destructive and requires an additional flag to execute the delete*

### export

This command provides a method of exporting Marathon job configurations to given directory.  By default all jobs are exported, however, a regex can be provided to export a certain subset as needed.

### help

This command provides general usage information.

### info

This command retrieves basic Marathon and job configuration data and presents it to the user.

### scale

This command scales the number of instances of a given application.  Setting instances to 0 (zero) will suspend the application.

### sync

This command will sync the given application file or directory with the Marathon.  Marathon will update the application configuration if the application already exists, otherwise, it will createa a new application.

### tidy

This command will clean up the JSON for a given file or directory of files, removing any unnecessary configuration, and sorting the keys to reduce file differences when storing job configuration in Git.

## Environment Variables

Scooter provides the ability to set global options via environment variables for the following:

SCOOTER_COLOR
SCOOTER_MARATHON_HOST
SCOOTER_MARATHON_USER
SCOOTER_MARATHON_PASS
SCOOTER_MARATHON_PROXY_HOST
SCOOTER_MARATHON_PROXY_PORT
SCOOTER_MARATHON_PROXY_USER
SCOOTER_MARATHON_PROXY_PASS
SCOOTER_VERBOSE

## Examples

### General

The following command will retrieve general Marathon information.

````
scooter info
````

### Specific Marathon Host

By default Scooter looks for Marathon on localhost and provides an option to specify what Marathon host to target:

````
scooter --marathon=https://somecluster.marathon.service.consul info
````

