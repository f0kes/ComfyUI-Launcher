FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-devel

WORKDIR /app

RUN apt-get update && apt-get install -y gcc g++ make wget curl git ffmpeg libsm6 libxext6 && \
    rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 20.14.0
RUN mkdir $NVM_DIR


# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH


# install node and npm

# Install Node.js and npm
RUN . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

RUN ln -sf NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/bin/nodejs
RUN ln -sf NVM_DIR/versions/node/v$NODE_VERSION/bin/node /usr/bin/node
RUN ln -sf NVM_DIR/versions/node/v$NODE_VERSION/bin/npm /usr/bin/npm
# confirm installation
RUN node -v
RUN npm -v

#RUN . "$NVM_DIR/nvm.sh" && nvm install 22
#RUN . "$NVM_DIR/nvm.sh" && nvm use v22
#RUN . "$NVM_DIR/nvm.sh" && nvm alias default v22
#ENV PATH="/root/.nvm/versions/node/v22/bin/:${PATH}"


RUN wget https://github.com/busyloop/envcat/releases/download/v1.1.0/envcat-1.1.0.linux-x86_64 \
    && chmod +x envcat-1.1.0.linux-x86_64 \
    && mv envcat-1.1.0.linux-x86_64 /usr/bin/envcat \
    && ln -sf /usr/bin/envcat /usr/bin/envtpl

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY web /app/web
RUN cd /app/web && npm install && npm run build

COPY server /app/server

# Copy the Nginx configuration file into the container
COPY nginx.conf /etc/nginx/nginx.conf.template

WORKDIR /app/server

CMD ["./entrypoint.sh"] 