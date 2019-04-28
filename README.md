# Shell script to remove docker container files from Harbor

---

Our team has started using Harbor- which is an open source cloud native registry that stores, container images . It also signs, and scans container images for vulnerabilities.

As we are dealing with repositories and container images and there are many images for different stacks like development, staging and production. 
Storing them in Harbor without any deletion strategy results in no space left on harbor hosted machine. 

Harbor captures the documentation of deleting repositories and container images. 

It is a 2 step process
First you need to delete a container images from Harbor's UI. This is soft deletion. And then you need to run Garbage Collector which actually deletes the files from repository.

> Now the problem statement is removing the repository files or container images from Harbor's UI is a cumbersome process and requires manual intervention. 
Lets see how can we automate the process of deletion of repository container images using Harbor's REST API and Shell scripting without using UI

```
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
                                curl -v -u $harbor_user:$harbor_pswd -X DELETE  http://$harbor_host/api/myrepo/tsom-ecc/$repo/tags/$buildnum;
                        done
        done
}

TagsDelete $staging_tag
TagsDelete $prod_tag

```

