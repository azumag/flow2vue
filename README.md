# Welcome
This script allows us to convert uiflow format to vue code.
- Ver 0.01: Only ruby version is implemented

# Usage

## example demo
```
cd ruby
docker-compose run --rm flow2vue bash
ruby -Ku main.rb -t title -i flow.txt --nuxt --demo -f
```

## For Product
use demo scaffold as initial project structure
or
1. prepare the project structure such as nuxt: 
https://ja.nuxtjs.org/guide/installation
2. generate pages with flow2vue
```
ruby -Ku main.rb -t title -i flow.txt --nuxt --pageonly
```
3. replace the project page srcs with generated file (e.g., dst/pages)


### options
- `-t` TITLE of application
- `-i` input file
- `--demo` use demo scaffold 
- `--nuxt` use scaffold with nuxt patterns
- `--cli2` [NOT RECOMMENDED] use scaffold with vue-cli2's settings
- `-f` rewrite dst directory
- `--pageonly` rewrite `dst/src` only

# NOTICE
If you want to use old version, please use the docker-image as follows:
```
 docker run -v $(pwd):/usr/src/app/mount azumag/vuegen mount/flows.txt title
```

