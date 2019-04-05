# Prerequisites for Macs

You must have the following set up on your mac laptop:

- administrator rights on your laptop
- [Xcode](https://developer.apple.com/xcode/) command line interface tools
- [Ruby](https://www.ruby-lang.org/en/)
- [Middleman](https://middlemanapp.com/) static site generator

## Administrator rights on your laptop

Email [sd-community@digital.cabinet-office.gov.uk](mailto:sd-community@digital.cabinet-office.gov.uk) to request administrator rights on your laptop.

You must be a Government Digital Service employee to do this.

## Install Xcode command line interface tools

These instructions assume that you are the Managed Software Centre on your Mac.

1. Go to the Managed Software Centre on your Mac.
1. Select Updates.
1. Install all required updates.
1. Search for xcode in the search field in Updates.
1. Install Xcode x.x.x or update if necessary.

OR

1. Go to [Apple Developer Downloads](https://developer.apple.com/download/more).
1. Search for "xcode".
1. Select the appropriate __Command Line Tools (macOS x.x) for Xcode x.x__ and download the file.
1. Install the file.

## Install Ruby

[Ruby](https://www.ruby-lang.org/en/) is installed globally. This means that you can run the install command from any location on your local machine rather than from within a specific folder.

You can install Ruby in multiple ways, for example using [Ruby Version Manager](https://rvm.io/) (RVM) or [rbenv](https://github.com/rbenv/rbenv). These instructions assume you are using RVM.

1. Run the following in the command line interface to install the ruby version manager:

    ```
    `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
    ```

1. Run `rvm install ruby-x.x.x` to install the latest version of [Ruby](https://www.ruby-lang.org/en/). The current x.x.x is `2.6.1`.

## Install Middleman

[Middleman](https://middlemanapp.com/) is installed globally. This means that you can run the install command from any location on your local machine rather than from within a specific folder.

Run the following in the command line interface to install Middleman:

```
gem install middleman
```
