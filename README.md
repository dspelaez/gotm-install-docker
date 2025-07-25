#  Install GOTM (General Ocean Turbulence Model) using Docker

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

Alternatively, we can define an alias:

```
alias gotm='docker run --rm -v "$(pwd)":/case gotm-image /usr/bin/gotm'
```

or define a function:

```
gotm() {
    docker run --rm -v "$(pwd)":/case gotm-image /usr/bin/gotm "$@"
}
```

and then run `gotm gotm.yaml` locally.
