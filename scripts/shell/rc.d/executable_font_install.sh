#!/bin/sh

font_install() {

echo "installing fonts at $PWD to ~/.fonts/"
mkdir -p ~/.fonts/adobe-fonts
git clone https://github.com/adobe-fonts/source-code-pro.git ~/.fonts/adobe-fonts/source-code-pro
find ~/.fonts/ -iname '*.ttf' -exec echo \{\} \;
sudo fc-cache -f -v ~/.fonts/adobe-fonts/source-code-pro
echo "finished installing"

}