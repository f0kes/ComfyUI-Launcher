FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-devel

WORKDIR /app
SHELL ["/bin/bash", "-l", "-euxo", "pipefail", "-c"]


RUN apt-get update && apt-get install -y gcc g++ make wget curl && \
    rm -rf /var/lib/apt/lists/*

#RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
#ENV NVM_DIR="/root/.nvm"
ENV NVM_DIR /usr/local/nvm

RUN mkdir -p "$NVM_DIR"; \
    curl -o- \
        "https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh" | \
        bash \
    ; \
    source $NVM_DIR/nvm.sh; \
    nvm install --lts --latest-npm

RUN which nvm \
    && which node \
    && node --version \
    && which npm  \
    && npm --version


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