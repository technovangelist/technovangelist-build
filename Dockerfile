FROM mhart/alpine-node:8

WORKDIR /app
RUN pwd
COPY package.json ./
RUN npm install --global gatsby-cli
RUN yarn install --production
RUN apk -Uuv add python curl && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"&& \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -b /usr/bin/aws && \
    rm awscli-bundle.zip && rm -r awscli-bundle


FROM mhart/alpine-node:base-8
WORKDIR /app
COPY --from=0 /app /backupmod
COPY --from=0 /usr/bin/ /usr/bin/
COPY --from=0 /usr/lib/ /usr/lib/
COPY --from=0 /root/.local /root/.local