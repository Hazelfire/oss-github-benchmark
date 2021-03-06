# syntax = docker/dockerfile:1.0-experimental
FROM python:3 as data
ENV PYTHONUNBUFFERED 1
WORKDIR /app
COPY requirements*.txt .
RUN pip install -r requirements.txt
COPY github_repos.json .
COPY OSS_github_benchmark.py .
RUN --mount=type=secret,id=BUILD_KEY GITHUBTOKEN=$(cat /run/secrets/BUILD_KEY) python ./OSS_github_benchmark.py

FROM node:lts as frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
COPY --from=data /app/oss-github-benchmark.* ./assets/
RUN npm run build

FROM nginx:alpine
COPY --from=frontend /app/dist/* /usr/share/nginx/html
COPY --from=data /app/oss-github-benchmark.* /usr/share/nginx/html
