# Welcome
This script allows us to convert uiflow format to vue code.
- Ver 0.01: Only ruby version is implemented

# Usage
example for demo:
```
cd ruby
ruby -Ku main.rb -t title -i flow.txt --cli2 -f
```

### notice:
｀--cli2｀ オプションは古い vue 2 のライブラリを使ってしまうので，最初に動かして見るぶんにはいいですが，PJ土台を作るならば ｀--cli2｀ なしでやったほうがよいかも

### options
- `-t` TITLE of application
- `-i` input file
- `--cli2` use scaffold with vue-cli2's settings
- `-f` rewrite dst directory
- `--pageonly` rewrite `dst/src` only

# NOTICE
If you want to use old version, please use the docker-image as follows:
```
 docker run -v $(pwd):/usr/src/app/mount azumag/vuegen mount/flows.txt title
```
 
# Run with docker
example:
```
docker run --rm -it -u $(id -u):$(id -g) -v $(pwd):/usr/src/app -w /usr/src/app ruby ruby -Ku main.rb -t title -i flow.txt -f --cli2 --pageonly
```

