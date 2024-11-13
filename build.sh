#!/bin/bash

echo "pull go-admin"

git clone git@github.com:yymagicer/go-admin.git

echo "pull go-admin-ui"

git clone git@github.com:yymagicer/go-admin-ui.git


sudo docker build -t registry.cn-hangzhou.aliyuncs.com/server-tool/go-admin-all:v1 .


