# Run with docker

```
docker run --rm -it -v $(pwd):/usr/src/app -w /usr/src/app ruby ruby -Ku gen.rb <TEMPLATE_FILENAME(guiflow)> "APP_TITLE"
```

# usage
```
ruby -Ku gen.rb <TEMPLATE_FILENAME(guiflow)> "APP_TITLE"
```
