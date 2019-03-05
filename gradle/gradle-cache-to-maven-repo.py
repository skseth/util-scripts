#!/usr/bin/python

# modified from : https://discuss.gradle.org/t/need-a-gradle-task-to-copy-all-dependencies-to-a-local-maven-repo/13397/10

import sys
import os
import subprocess
import glob
import shutil
from pathlib import Path

home = str(Path.home())

def main(argv):
    project_dir = os.path.dirname(os.path.realpath(__file__))
    repo_dir = os.path.join(project_dir, "repo")
    temp_home = os.path.join(home, ".gradle")
#    if not os.path.isdir(temp_home):
#        os.makedirs(temp_home)
    
#    if os.path.isdir(repo_dir):
#        shutil.rmtree(repo_dir)
    
    #subprocess.call(["gradle", "-g", temp_home, "-Dbuild.network_access=allow"])
    
    cache_files = os.path.join(temp_home, "caches/modules-*/files-*")
    for cache_dir in glob.glob(cache_files):
        for cache_group_id in os.listdir(cache_dir):
            cache_group_dir = os.path.join(cache_dir, cache_group_id)
            repo_group_dir = os.path.join(repo_dir, cache_group_id.replace('.', '/'))
            for cache_artifact_id in os.listdir(cache_group_dir):
                cache_artifact_dir = os.path.join(cache_group_dir, cache_artifact_id)
                repo_artifact_dir = os.path.join(repo_group_dir, cache_artifact_id)
                for cache_version_id in os.listdir(cache_artifact_dir):
                    cache_version_dir = os.path.join(cache_artifact_dir, cache_version_id)
                    repo_version_dir = os.path.join(repo_artifact_dir, cache_version_id)
                    if not os.path.isdir(repo_version_dir):
                        os.makedirs(repo_version_dir)
                    cache_items = os.path.join(cache_version_dir, "*/*")
                    for cache_item in glob.glob(cache_items):
                        cache_item_name = os.path.basename(cache_item)
                        repo_item_path = os.path.join(repo_version_dir, cache_item_name)
                        print("%s:%s:%s (%s)" % (cache_group_id, cache_artifact_id, cache_version_id, cache_item_name))
                        shutil.copyfile(cache_item, repo_item_path)
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
