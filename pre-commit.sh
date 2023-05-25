#!/bin/bash

# Define the folder path
data_folder="./data"

# Retrieve the content of the root YAML file
root_yaml_file="$data_folder/my-realm.yaml"
combined="./combined.yaml"
truncate -s 0 $combined
cat "$root_yaml_file" > $combined

# Define the subdirectories and their corresponding attributes
subdirectories=(
  "clients"
  "groups"
  "identityProviders"
)

# Iterate over the subdirectories and their attributes
for ((i=0; i<${#subdirectories[@]}; i+=2)); do
  subdirectory="${subdirectories[i]}"

  # Combine the content of each file in the subdirectory
  for file in "$data_folder/$subdirectory"/*; do
    file_content=$(cat "$file")

    new=$(yq ea '
    (
      (
        select(fi==0) ) as $item ireduce([]; . + $item
      )
    ) as $ma
    | select(fi == 1) | .'$subdirectory' += $ma ' $file $combined)

    echo "$new" > $combined
  done
done

git add $combined