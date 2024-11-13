#!/bin/bash

echo "pull go-admin"

if test -d "go-admin"; then
  cd go-admin
  git pull
  cd ..
else
  git clone git@github.com:yymagicer/go-admin.git
fi

echo "pull go-admin-ui"

if test -d "go-admin-ui"; then
  cd go-admin-ui
  git pull
  cd ..
else
  git clone git@github.com:yymagicer/go-admin-ui.git
fi

sudo docker build -t registry.cn-hangzhou.aliyuncs.com/server-tool/go-admin-all:v1 .
