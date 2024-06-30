#multi-stage build approach
FROM node:19.4-bullseye as build

WORKDIR /usr/src/app

COPY package*.json ./

# Use cache mount to speed up install of existing dependencies
RUN --mount=type=cache,target=/usr/src/app/.npm \
  npm set cache /usr/src/app/.npm && \
  npm install

COPY . .

#this will generate some static files, html, css, js then we will be able to serve
RUN npm run build

#new stage
FROM nginxinc/nginx-unprivileged:1.22-alpine

#copying nginx config files
COPY nginx.conf /etc/nginx/conf.d/defualt.conf

#we are going to use deafult nginx command
COPY --from=build usr/src/app/dist/ /usr/share/nginx/html
#specifying '--from=build' to copy files from the above stage, copt files from current dir to destination dir

EXPOSE 8080
