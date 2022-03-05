#!/bin/bash

#VERSION=$1

#echo "doc.sh"
#echo "------"

#if [ ! -z "$VERSION" ]; then
#        echo "Setting the τDio version"
#        gsed -i  "s/^TAU_VERSION:.*/TAU_VERSION: $VERSION/"                                     doc/_config.yml
#        gsed -i  "s/^\( *version: \).*/\1$VERSION/"                                             doc/_data/sidebars/mydoc_sidebar.yml
#fi

cp README.md doc/README.md

rm -rf doc/pages/waa-doc
rm -rf doc/pages/rtc-doc
rm -rf doc/pages/editor-doc
rm -rf doc/pages/media-doc

mkdir -p doc/pages/waa-doc
mkdir -p doc/pages/rtc-doc
mkdir -p doc/pages/editor-doc
mkdir -p doc/pages/media-doc

cp -a taudio_waa/doc/* doc/pages/waa-doc
cp -a taudio_rtc/doc/* doc/pages/rtc-doc
cp -a taudio_editor/doc/* doc/pages/editor-doc
cp -a taudio_media/doc/* doc/pages/media-doc

cp -a taudio_waa/doc/waa_sidebar.yml doc/_data/sidebars
cp -a taudio_rtc/doc/rtc_sidebar.yml doc/_data/sidebars
cp -a taudio_editor/doc/editor_sidebar.yml doc/_data/sidebars
cp -a taudio_media/doc/media_sidebar.yml doc/_data/sidebars

#cp taudio_waa/README.md doc/pages/waa-doc
#cp taudio_waa/CHANGELOG_doc/pages/waa-doc



echo "dart doc"
cd taudio_waa/waa_flutter
rm -rf doc 2>/dev/null
export PATH="$PATH:/opt/flutter/bin"
export FLUTTER_ROOT=/opt/flutter
flutter clean
flutter pub get
flutter pub global activate dartdoc
flutter pub global run dartdoc .
cd ../..


cd doc
echo "patch css for Jekyll compatibility"
gsed -i  "0,/^  overflow: hidden;$/s//overflow: auto;/"  pages/taudio-flutter-waa-api/static-assets/styles.css
gsed -i  "s/^  background-color: inherit;$/  background-color: #2196F3;/" pages/taudio-flutter-waa-api/static-assets/styles.css

echo "Add Front matter on top of dartdoc pages"
for f in $(find pages/taudio-flutter-waa-api -name '*.html' )
do
        gsed -i  "1i ---" $f
        gsed -i  "1i ---" $f
        gsed -i  "/^<script src=\"https:\/\/ajax\.googleapis\.com\/ajax\/libs\/jquery\/3\.2\.1\/jquery\.min\.js\"><\/script>$/d" $f
done
cd ..



cd doc
echo "Building Jekyll doc"
rm -rf _site  2>/dev/null
rm home.md 2>/dev/null
bundle config set --local path '~/vendor/bundle'
bundle install > /dev/null
bundle exec jekyll build
if [ $? -ne 0 ]; then
    echo "Error"
    exit -1
fi
#cd _site
#ln -s readme.html index.html

cd ..



cd doc/_site
echo "patch css for Jekyll compatibility"
gsed -i  "0,/^  overflow: hidden;$/s//overflow: auto;/"  pages/taudio-flutter-waa-api/static-assets/styles.css
gsed -i  "s/^  background-color: inherit;$/  background-color: #2196F3;/" pages/taudio-flutter-waa-api/static-assets/styles.css
cd ../..



echo "Symbolic links"
cd doc/_site
for dir in $(find pages/taudio-flutter-waa-api -type d)
do
        rel=`realpath --relative-to=$dir .`
        for d in */ ; do
            ln -s $rel/$d $dir
        done
done
cd ../..

rm -rf /tmp/toto.tgz 2>/dev/null
cd doc/_site
tar czf /tmp/toto.tgz *
scp -P7822 /tmp/toto.tgz canardoux@canardoux.xyz:/tmp/toto.tgz
ssh -p7822 canardoux@canardoux.xyz "rm -rf /var/www/vhosts/canardoux.xyz/taudio.canardoux.xyz/*; cd /var/www/vhosts/canardoux.xyz/taudio.canardoux.xyz; tar xzf /tmp/toto.tgz"
