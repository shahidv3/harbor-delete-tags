#!/bin/bash

## ##############################################################################################################################
##  Author : Sahid Shaik                                                                                                        #                            
## Usage: ./tags_delete.sh                                                                                                      #
## Harbor images deletion is 2 step process                                                                                     #
## 1. Soft delete image using this script                                                                                       #
## 2. Run garbage collector                                                                                                     #                            
## ##############################################################################################################################

source config.ini
folder=$(date +"%m-%d-%Y_%H.%M.%S")
mkdir ${folder}
staging_tag=stage
prod_tag=prod


TagsDelete() {
        for repo in `cat repos.txt`;
          do
                echo $repo;
                curl -u $harbor_user:$harbor_pswd -X GET http://$harbor_host/api/repositories/myrepo/$repo/tags > $folder/$repo.json;
                awk '/name/ {print $2}' $folder/$repo.json | tr -d '",' | sort > $folder/$repo.txt;
                if [ $1 == "stage" ]
                then
                     awk '/Staging/{print}'  $folder/$repo.txt | sort -Vr | sed -n '3,$p' > $folder/$1_$repo.ini;
                else
                     awk '!/Staging/{print}'  $folder/$repo.txt | sort -Vr | sed -n '2,$p' > $folder/$1_$repo.ini;
                fi
                for buildnum in `cat $folder/$1_$repo.ini`;
                        do
                                echo $buildnum;
                                curl -v -u $harbor_user:$harbor_pswd -X DELETE  http://$harbor_host/api/repositories/myrepo/$repo/tags/$buildnum;
                        done
        done
}

TagsDelete $staging_tag
TagsDelete $prod_tag
~
