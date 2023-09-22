#!/bin/bash

bli_version="$1"

branch="release"

# sanity check
if [[ -z "$bli_version" ]];
    then
        echo "Usage: release.sh <version>"
        exit 0
fi

#setting up environment variables
if [[ -z $BLIMAN_NAMESPACE ]];
    then
        BLIMAN_NAMESPACE=${BLIMAN_NAMESPACE:-"Be-Secure"}        
fi

# prepare branch
cd $HOME/BLIman || return 1
git checkout issue#4
#git checkout dev
git branch -D $branch
git checkout -b $branch

file="$HOME/BLIman/scripts/get.bliman.io.tmpl"

#copy the tmpl file to /scripts
echo "*Making a copy of the templ file"
cp "$HOME/BLIman/scripts/tmpl/get.bliman.io.tmpl" "$HOME/BLIman/scripts"
# replacing @xxx@ variables with acutal values.

echo "* Replacing @XXX@ variables with actual values"
sed -i "s/@BLIMAN_VERSION@/$bli_version/g" "$file"
sed -i "s/@BLIMAN_NAMESPACE@/$BLIMAN_NAMESPACE/g" "$file"
# renaming to remove .tmpl extension
echo "Renaming to remove .tmpl extension"
mv "$file" "${file//.tmpl/}"


[[ -d "$HOME/BLIman/website" ]] && rm -rf "$HOME/BLIman/website"
[[ -d "$HOME/BLIman/docs" ]] && rm -rf "$HOME/BLIman/docs"
[[ -f "$HOME/BLIman/mkdocs.yml" ]] && rm "$HOME/BLIman/mkdocs.yml"
mkdocs new website
mv "$HOME"/BLIman/website/* "$HOME/BLIman/"
[[ -f "$HOME/BLIman/docs/index.md" ]] && rm "$HOME/BLIman/docs/index.md"
touch "$HOME/BLIman/docs/index.md"
echo "Welcome to BLIMAN" >> "$HOME/BLIman/docs/index.md"

echo "Listing scripts"
ls "$HOME/BLIman/scripts"
echo "Moving to docs"
mv "$HOME/BLIman/scripts/get.bliman.io" "$HOME/BLIman/docs/"


# committing the changes
git add "$HOME"/BLIman/*
git commit -m "Updating version of $branch to $bli_version"

#push release branch
git push -f -u origin $branch



#Push tag
echo "Deploying mkdocs"
mkdocs gh-deploy
git tag -a "$bli_version" -m "Releasing version $bli_version"
git push origin "$bli_version"


#checkout to issue#4
git checkout issue#4
#git checkout dev