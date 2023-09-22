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
cd $HOME/BLIman
git checkout issue#4
#git checkout dev
git branch -D $branch
git checkout -b $branch


#copy the tmpl file to /scripts
cp $HOME/BLIman/scripts/tmpl/*.tmpl $HOME/BLIman/scripts/
# replacing @xxx@ variables with acutal values.
for file in $HOME/BLIman/scripts/*.tmpl;
do
    sed -i "s/@BLIMAN_VERSION@/$bli_version/g" $file
    sed -i "s/@BLIMAN_NAMESPACE@/$BLIMAN_NAMESPACE/g" $file
    # renaming to remove .tmpl extension
    mv "$file" "${file//.tmpl/}"
done

mv "$HOME/BLIMAN/scripts/get.bliman.io" "$HOME/BLIMAN/docs/"

# committing the changes
git add $HOME/BLIman/scripts/*.* 
git commit -m "Updating version of $branch to $bli_version"

#push release branch
git push -f -u origin $branch

#Push tag
git tag -a $bli_version -m "Releasing version $bli_version"
git push origin $bli_version

mkdocs gh-deploy

#checkout to issue#4
git checkout issue#4
#git checkout dev