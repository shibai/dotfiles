#!/bin/zsh
dir=$1

unitTestDate=$(stat -f '%m' $dir/build/brazil-unit-tests)
echo $unitTestDate

pushd $dir 1>/dev/null
commitCreationDate=$(git show -s --format=%ct HEAD)
commitTitle=$(git log -n1 --oneline --no-color)
popd 1>/dev/null
echo $commitCreationDate

if [[ $commitCreationDate -ge $unitTestDate ]]; then
  echo "Commit $commitTitle was created after the latest Unit test run - are you sure this passes?";
else
  echo "Good, you ran the Unit Tests after creating this commit. Nice.";
fi
