# Update docs to use latest tech-docs-gem

## Clone the remote documentation repo

1. Open your internet browser and go to your remote documentation repo on GitHub.

1. Select the __Clone or download__ button.

1. Select either __Use HTTPS__ or __Use SSH__.

1. Select the copy button.

1. In the command line, clone the remote repo to a local directory:

    ```
    git clone [repo address]
    ```

## Update the ruby gems in the documentation repo

1. Update all ruby gems in the cloned local documentation repo:

    ```
    bundle update
    ```

    This updates all the ruby gems that your repo uses, including the `tech-docs-gem`.

    You should get the message `Bundle updated!` once the update is finished.

1. Add all changes to the next commit:

    ```
    git add .
    ```

1. Commit the changes:

    ```
    git commit -m "[commit message]"
    ```
    where `COMMIT_MESSAGE` is the description of the commit.

1. Push the new branch to the remote documentation repo on GitHub:

    ```
    git push -u origin [BRANCH NAME]
    ```
1. Review, approve and merge the changes in line with your service team processes.
