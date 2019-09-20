#!/bin/bash

SRC_PATH=$PWD
BUILD_ROOT="/var/jenkins_home/scripts"
BUILD_PATH="${BUILD_ROOT}/${JOB_NAME}" #不同的项目用不同的构建目录
SVN_TAG=${SVN_TAG}
TAG=${GIT_TAG}
((SVN_TAG=${BUILD_NUMBER}%50))
FLAG="Release"
echo "TAG=", $TAG
echo "FLAG=", $FLAG
RELEASE=0
if [[ $TAG == *$FLAG* ]]
then
  RELEASE=1
  fi
  REGISTRY='registry.cn-beijing.aliyuncs.com'
  PROJECT="/zhangpeng_test/${JOB_NAME}"
	if [ ! -d $BUILD_PATH ];then
		mkdir $BUILD_PATH
	else
		echo "项目文件存在"
		rm -rf $BUILD_PATH
		mkdir $BUILD_PATH
	fi
  mv $SRC_PATH/docker/* $BUILD_PATH

  # Rebuild the docker image
  cd $BUILD_PATH
  docker login --username=523631013@qq.com --password=***** $REGISTRY
  if [ $RELEASE -ne 0 ]; then
      docker build -t $REGISTRY$PROJECT:$SVN_TAG -t $REGISTRY$PROJECT:rel_latest .
  else
	  docker build -t $REGISTRY$PROJECT:$SVN_TAG -t $REGISTRY$PROJECT:latest .
  fi
  # Push the docker image to registry
  if [ $? -ne 0 ]; then
	    echo "Docker image build failed!"
	    exit 1
  else
		echo "Docker image build succeed!"
		docker push $REGISTRY$PROJECT:$SVN_TAG
		if [ $RELEASE -ne 0 ]; then
			echo "RELEASE image!"
			docker push $REGISTRY$PROJECT:rel_latest
		else
		   echo "TEST image!"
		  docker push $REGISTRY$PROJECT:latest
		fi
  fi
  rm -rf *