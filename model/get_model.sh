#!/bin/bash

function download () {
    curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=$1" > /dev/null
    CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"  
    curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=$1" -o $2
}

download 1FafpGBOXCKPNQnJtPJ5NIXRSQN1hgPwL imagenet-vgg-verydeep-19.mat

download 1C1xrc8Oo5f4W4IWok152ek77ITLMB8ik stage1/model-15000.data-00000-of-00001
download 1B1J4Tu9zN2tUgpAe-tecfVWzBkSVgI4R stage1/model-15000.index
download 1A3qZ-qdgXXSnBOfBLJQGDjfNqlKncjkq stage1/model-15000.meta

download 17G1l_eR7euMHKXS5jhh1d1qZuAlXCgw4 stage2/model-6000.data-00000-of-00001
download 1gMzJxgZPFVKs8-FXzx5j3wfJ4IyX4SeM stage2/model-6000.index
download 1V1rI0A91qFLf064OA7eVaBT_Vak27ZVL stage2/model-6000.meta

wget -nc --directory-prefix=./pose/_trained_COCO/ http://posefs1.perception.cs.cmu.edu/Users/ZheCao/pose_iter_440000.caffemodel
wget -nc --directory-prefix=./pose/_trained_MPI/ http://posefs1.perception.cs.cmu.edu/Users/ZheCao/pose_iter_146000.caffemodel

download 0BzvH3bSnp3E9eHMyVS1RbUVDems segment/attention+ssl.caffemodel
