# NOTICE
The webpack config has been removed!
If you want to use it with webpack, please use old version by docker-image:
```
 docker run -v $(pwd):/usr/src/app -t azumag/vuegen flow.txt test
```


# Run with docker

```
docker run --rm -it -v $(pwd):/usr/src/app -w /usr/src/app ruby ruby -Ku gen.rb <TEMPLATE_FILENAME(guiflow)> "APP_TITLE"
```

# usage
```
ruby -Ku gen.rb <TEMPLATE_FILENAME(guiflow)> "APP_TITLE"
```
