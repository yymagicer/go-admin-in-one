
# 使用多阶段构建
# 第一步: 构建 Go 项目
# 使用 Go 官方镜像作为构建阶段的基础镜像
FROM registry.cn-hangzhou.aliyuncs.com/server-tool/golang:1.21 AS backend

# 设置 Go 代理为国内镜像
ENV GOPROXY=https://goproxy.cn,direct

# 设置工作目录
WORKDIR /app/go-admin

# 拷贝 Go 项目文件
COPY go-admin/ .

# 下载 Go 依赖
RUN go mod tidy

# 编译 Go 项目
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# 第二步: 构建 Vue 3 项目
FROM node:lts as frontend

# 设置工作目录
WORKDIR /app/go-admin-ui

# 拷贝 package.json 和 yarn.lock 文件
COPY go-admin-ui/package*.json ./

RUN npm install --registry=https://registry.npmmirror.com  --force

COPY . .

RUN npm run build:prod


# 第三步: 最终部署
FROM registry.cn-hangzhou.aliyuncs.com/server-tool/nginx:alpine

# 更新 apk 包索引并安装 Node.js 和 npm
RUN apk update && \
    apk add --no-cache bash ca-certificates tzdata && \
    apk add --update gcc g++ libc6-compat

# 设置时区为上海
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 设置工作目录
WORKDIR /app

# 拷贝自定义的 Nginx 配置文件
COPY go-admin-ui/nginx.conf /etc/nginx/nginx.conf

# 拷贝前端静态文件到 Nginx 静态文件目录
COPY --from=frontend /app/go-admin-ui/dist /usr/share/nginx/html

# 拷贝编译好的 Go 可执行文件
COPY --from=backend /app/go-admin/main /app/go-admin/

COPY go-admin/config/settings.yml /app/go-admin/config/settings.yml

COPY go-admin/go-admin-db.db /app/go-admin/go-admin-db.db

# 暴露服务端口
EXPOSE 80

RUN  chmod +x /app/go-admin/main

# 启动 Go 后端服务并运行 Nginx
CMD ["sh", "-c", "cd /app/go-admin && ./main server -c /config/settings.yml & nginx -g 'daemon off;'"]


