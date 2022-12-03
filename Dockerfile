FROM ruby:3.1.3

ENV LANG C.UTF-8

RUN wget -O /usr/share/keyrings/yarn-archive-keyring-armor.gpg https://dl.yarnpkg.com/debian/pubkey.gpg
RUN gpg -o /usr/share/keyrings/yarn-archive-keyring.gpg --dearmor /usr/share/keyrings/yarn-archive-keyring-armor.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list > /dev/null
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update -qq

RUN apt-get install default-mysql-client -y \
  && apt-get install apt-file -y && apt-file update && apt-get install vim graphviz -y

RUN apt-get install -y nodejs yarn

RUN apt-get install -y yarn

RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app
COPY . /app