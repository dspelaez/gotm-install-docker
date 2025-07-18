#  Install GOTM (General Ocean Turbulence Model) in a Docker container

To build the image:

```
docker build -t gotm-image .
```

To run the executable:

```
docker run --rm -v "$(pwd)":/case gotm-image gotm /case/gotm.yaml
```

To run interactivelly:

```
docker run --rm -it -v "$(pwd)":/case --entrypoint /bin/bash gotm-image
```

Alternativiely, we can define a function:

```
gotm() {
    docker run --rm -v "$(pwd)":/case gotm-image gotm /case/"$@"
}
```

and then run `gotm gotm.yaml` locally.
