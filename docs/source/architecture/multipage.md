# Build a multipage site

You can create a technical documentation site that splits its content across multiple pages.

This is suitable for documentation sites that have too much content for the single page format.

You should use the search feature [link] with multipage documentation sites.

## Basic multipage

You can split the content into multiple individual pages. An example is the [GOV.UK PaaS technical documentation](https://docs.cloud.service.gov.uk/).

### Amend the tech-docs.yml file

Add this to your project’s `tech-docs.yml` file, or set it to true if it is already there:

```
# Enable multipage navigation in the sidebar
multipage_nav: true
```

### Repo folder structure

A typical single page documentation repo has this folder structure:

<br/><br/>
![](/diagrams/Single_page.svg)
<br/><br/>

A basic multipage documentation repo can have this structure:

<br/><br/>
![](/diagrams/Basic_multipage.svg)
<br/><br/>

You must amend the documentation repo folder structure to reflect this structure.

### Create multiple .html.md.erb files

Basic multipage requires multiple `.html.md.erb` files in the tech docs repo __source__ folder.

Each `.html.md.erb` file relates to one separate page within the tech docs, and references the markdown files in the associated folder.

Additionally, the tech doc repo must have at least one `.html.md.erb` file in the __source__ folder named `index.html.md.erb`.

The .html.md.erb files must not have the same name as the folders that the .html.md.erb files use partials refer to.

For example, you cannot have a support.html.md.erb file that contains the partial `<%= partial 'support/contact_us' %>`.

### Amend the multiple .html.md.erb files

1. Add a weight argument and value to the title of each .html.md.erb file. This builds the structure of the multipage documentation.

    For example:

    ```bash
    ---
    title: "Product Technical Documentation"
    ---
    ```

    becomes

    ```bash
    ---
    title: "Product Technical Documentation"
    weight: 10
    ---
    ```

    Higher weights mean that the content is lower down in the documentation hierarchy. An easy way to remember this is to think “heavier pages sink to the bottom”.

    For example, a single `.html.md.erb` file becomes multiple `.html.md.erb` files:

    <div style="height:1px;font-size:1px;">&nbsp;</div>

    |Single page|Multipage|
    |:---|:---|
    |---<br>weight: 10<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/index' %>|---<br>weight: 10<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/index' %>|
    ||---<br>weight: 10<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/index' %>|
    ||---<br>weight: 20<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/start' %>|
    ||---<br>weight: 30<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/users' %>|

    <div style="height:1px;font-size:1px;">&nbsp;</div>

### Add H1 heading if required

Add an H1 heading to either the `.html.md.erb` file or at the start of the first markdown file for each individual content page.

If there is an H1 heading in both, you will see two H1s when the documentation site builds and renders in your internet browser.

## Nested multipage

You can split the content into multiple individual pages, and can have pages "nested" within one another. Two examples:

- [GOV.UK PaaS technical documentation - Deploying services](https://docs.cloud.service.gov.uk/deploying_services/)
- [GOV.UK Pay technical documentation - Switching to live](https://docs.payments.service.gov.uk/switching_to_live/#switching-to-live)

### Amend the tech-docs.yml file

Add this to your project’s `tech-docs.yml` file, or set it to true if it is already there:

```
# Enable multipage navigation in the sidebar
multipage_nav: true
```

### Repo folder structure

A typical single page documentation repo has this folder structure:

<br/><br/>
![](/diagrams/Single_page.svg)
<br/><br/>

A nested multipage documentation repo can have this structure:

<br/><br/>
![](/diagrams/Nested_multipage.svg)
<br/><br/>

You must amend the documentation repo folder structure to reflect this structure.

### Create multiple .html.md.erb files

Basic multipage requires multiple `.html.md.erb` files in the tech docs repo __source__ folder.

Each `.html.md.erb` file relates to one separate page within the tech docs, and references the markdown files in the associated folder.

Additionally, the tech doc repo must have at least one `.html.md.erb` file in the __source__ folder named `index.html.md.erb`.

### Amend the multiple .html.md.erb files

1. Add a weight argument and value to the title of each .html.md.erb file. This builds the structure of the multipage documentation.

    For example:

    ```bash
    ---
    title: "Product Technical Documentation"
    ---
    ```

    becomes

    ```bash
    ---
    title: "Product Technical Documentation"
    weight: 10
    ---
    ```

    Higher weights mean that the content is lower down in the documentation hierarchy. An easy way to remember this is to think “heavier pages sink to the bottom”.

    For example, a single `.html.md.erb` file becomes multiple `.html.md.erb` files:

    <div style="height:1px;font-size:1px;">&nbsp;</div>

    |Single page|Multipage|
    |:---|:---|
    |---<br>weight: 10<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/index' %>|---<br>weight: 10<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/index' %>|
    ||---<br>weight: 10<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/index' %>|
    ||---<br>weight: 20<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/start' %>|
    ||---<br>weight: 30<br>title: "Product Technical Documentation"<br>---<br><br><%= partial 'documentation/users' %>|

    <div style="height:1px;font-size:1px;">&nbsp;</div>

### Add H1 heading if required

Add an H1 heading to either the `.html.md.erb` file or at the start of the first markdown file for each individual content page.

If there is an H1 heading in both, you will see two H1s when the documentation site builds and renders in your internet browser.

### Create folder for nested content .html.md.erb files

Refer to the GOV.UK PaaS technical documentation repo [nested content folder](https://github.com/alphagov/paas-tech-docs/tree/master/source/deploying_services) as an example.

1. Create a folder within the __source__ folder. This is where the `.html.md.erb` files for your nested content must live.

1. Create an `index.html.md.erb` file within the nested content folder. This will be the "wrapper" for the nested content. It can refer to another content file through partials or have the content in itself.

    Note that each `.html.md.erb` must have a weight value that preserves the overall hierarchy both within the nested content and compared to the other non-nested content.

1. Create sub-folders for each nested page under the "wrapper".

1. Create an `index.html.md.erb` file within each sub-folder. Each `.html.md.erb` file can refer to another content file through partials or have the content in itself.

    Note that each `.html.md.erb` file must have a weight value that preserves the overall hierarchy both within the nested content and compared to the other non-nested content.

### Add H1 heading if required

Add an H1 heading to either the `.html.md.erb` file or at the start of the first markdown file for each individual content page.

If there is an H1 heading in both, you will see two H1s when the documentation site builds and renders in your internet browser.
