# Run with docker

```
docker run --rm -it -v $(pwd):/usr/src/app -w /usr/src/app ruby ruby -Ku gen.rb
```

# usage
```
ruby -Ku <TEMPLATE_FILENAME(guiflow)> "APP_TITLE"
```
