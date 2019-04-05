# Publish your documentation

To publish your documentation, you must:

- push your documentation to the remote GitHub repo
- deploy your site

## Push documentation to GitHub

These instructions assume that you have documentation changes ready to push to GitHub.

To push your documentation changes to GitHub for the first time, you must:

- create local and remote GitHub repos
- commit all changes in the local repo
- link the local repo to the remote repo
- push the staged commit to the remote repo

### Create local and remote GitHub repos

1. [Create a remote empty repo](https://help.github.com/articles/create-a-repo/) in your organisation on GitHub.

1. [Create a new local documentation repo](/create_new_project.html#create-a-new-project) if required.

### Commit all changes in the local repo

1. Go to the local repo directory in the command line.

1. Make the created local repo into a Git repo:

    ```
    git init
    ```

1. If applicable, add all files in the local repo and stage them for commit:

    ```
    git add .
    ```

1. Commit the staged files:

    ```
    git commit -m "COMMIT-MESSAGE"`
    ```

    where `COMMIT-MESSAGE` is the message describing the commit.

### Link the local repo to the remote repo

1. Go to the remote repo in GitHub.

1. Select the __Clone or download__ button.

1. Select either __Use HTTPS__ or __Use SSH__.

1. Select the copy button.

1. In the command line, link the local repo to the remote repo:

    ```
    git remote add origin REMOTE-REPO-URL
    ```

1. Verify the remote repo:

    ```
    git remote -v
    ```

### Push the staged commit to the remote repo

Push the changes in your local repo to the remote repo:

```
git push -u origin master
```

You have now created a remote documentation repo on GitHub.

For more information, refer to [Adding an existing project to GitHub](https://help.github.com/articles/adding-an-existing-project-to-github-using-the-command-line/).

## Deploy your site

The Tech Docs Template is built on Middleman, which is a static
site generator. You can therefore deploy your site anywhere that supports
static sites.

### Use the GOV.UK PaaS

We recommend that government services use the [GOV.UK
PaaS](https://www.cloud.service.gov.uk/) to deploy documentation sites built
with the Tech Docs Template. This is also free of charge for
government services.

### GitHub Pages

With some modification, you can also deploy your site with [GitHub
Pages](https://pages.github.com/), but we do not support this. To do this, you
could for example use the [`middleman-gh-pages`]
tool](https://github.com/edgecase/middleman-gh-pages), which we do not
support. We also cannot guarantee that all features of the tool will work if
you deploy your site with GitHub Pages.

### Add basic authentication

There are many ways to add basic authentication to your documentation site.

The following instructions apply if you want to deploy your documentation site on the GOV.UK PaaS or another platform using the [Cloud Foundry open source cloud application platform](https://www.cloudfoundry.org/).

This method relies on adding a `Staticfile.auth` file to the `build` folder because building the documentation doesn't automatically add the `Staticfile.auth` file. If you added `Staticfile.auth` once and run the build command again, the file will disappear. You need to add `Staticfile.auth` again to enable basic authentication for the new build.

1. In the command line, navigate to your local documentation repo.

1. If required, run `bundle exec middleman build` to create a `build` folder.

1. Create a new `Staticfile.auth` file in the `build` folder.

1. Go to the [Htpasswd Generator](http://www.htaccesstools.com/htpasswd-generator).

1. Complete the __Username__ and __Password__ fields, and select __Create .htpasswd file__.

1. Copy the generated username and password hash into the `Staticfile.auth` file and save.

1. Deploy your documentation site in line with your normal process.

## Continuous integration

The GOV.UK PaaS documentation explains how to set up continuous integration (CI) with [Travis and Jenkins](https://docs.cloud.service.gov.uk/using_ci.html#using-the-travis-ci-tool). We recommend this method for documentation sites built using the Tech Docs Template.
