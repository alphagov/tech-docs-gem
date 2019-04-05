# Enable API reference 

This feature extracts endpoint information from an Open API v3 yaml file that describes an API.

## Amend the tech-docs.yml file

Add the following to your tech-docs.yml file:

```
api_path: path/to/file.yaml
```

This can be a relative path to a file in your tech docs repo folder, for example:

```
api_path: ./source/pets.yaml
```

This can also be a URL to a file hosted elsewhere, for example: 

```
api_path: https://raw.githubusercontent.com/OAI/OpenAPI-Specification/master/examples/v3.0/petstore.yaml
```

## Amend the content file

Add the following line to the content file that you want to output the API information to:

```
api>
```

You can specify individual endpoints to be outputted rather than all API information, for example::

```
api> /pets
```
