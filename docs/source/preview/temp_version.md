# Push a temporary documentation site to the GOV.UK PaaS

You can preview your documentation on a temporary documentation website on the GOV.UK PaaS.

## Download the Autopilot plugin

Autopilot is a Cloud Foundry plugin for zero-downtime app deployment.

1. Go to `https://github.com/contraband/autopilot/releases` and download the latest `autopilot-darwin` file.

1. Open your command line interface and go to the folder containing the `autopilot-darwin` file.

1. Run `chmod +x autopilot-darwin` in the command line to make the `autopilot-darwin` file executable.

1. Run `cf install-plugin autopilot-darwin` to install the plugin.

## Sign in to the GOV.UK PaaS

1. Run the following in the command line:

    ```
    cf login -a api.cloud.service.gov.uk -u <YOUR-USERNAME>@digital.cabinet-office.gov.uk
    ```

1. [Target](https://docs.cloud.service.gov.uk/deploying_apps.html#set-a-target) the org and space by running:

    ```
    cf target -o ORG_  NAME -s SPACE_NAME
    ```
    
    where ORG_NAME is the name of the org, and SPACE_NAME is the name of the space.

1. Run `cf apps` to check what apps are running in the targeted space.

## Push the documentation site to the GOV.UK PaaS

1. Create the following manifest file in your tech docs repo:

    ```
    applications:
     - name: NAME
       memory: 64M
       path: ./build
       buildpack: staticfile_buildpack
       instances: 2
    ```

1. In your command line, go to the folder containing the manifest file. 

1. Run the following in the command line to push the site to a temporary site:

    ```
    cf zero-downtime-push NEW_APP_NAME_TO_BE_DEPLOYED -f MANIFEST_PATH_AND_NAME 
    ```

    You can run this command from a folder that does not contain the manifest file by adding `-p YOUR_FILE_PATH`, for example:

    ```
    cf zero-downtime-push NEW_APP_NAME_TO_BE_DEPLOYED -f MANIFEST_PATH_AND_NAME -p YOUR_FILE_PATH
    ```
    >Include example for cf push if not using autopilot?

1. Run `cf apps` to check your new app appears in the targeted org and space. 

1. Check your app has deployed by going to ` NEW_APP_NAME_TO_BE_DEPLOYED.cloudapps.digital`.

# Preview from your local machine

You can preview your documentation from your local machine.

Run the following from the documentation repo folder on your local machine:

```
bundle exec middleman server
```

Go to your internet browser and navigate to `http://localhost:4567/` to preview your documentation.

You can change your content files and see the documentation update immediately.

