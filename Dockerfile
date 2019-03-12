FROM ubuntu:16.04

# Application parameters and variables
ENV NODE_ENV=production
ENV PORT=3000
ENV Root_Dir /
ENV application_directory /usr/src/app
ENV font_directory /usr/share/fonts/noto

# Configuration for Chrome
ENV CONNECTION_TIMEOUT=60000
ENV CHROME_PATH=/usr/bin/google-chrome

RUN mkdir -p $application_directory
RUN mkdir -p $font_directory

# Dependencies needed for packages downstream
RUN apt-get update && apt-get install -y \
  apt-utils \
  unzip \
  fontconfig \
  locales \
  gconf-service \
  libasound2 \
  libatk1.0-0 \
  libc6 \
  libcairo2 \
  libcups2 \
  libdbus-1-3 \
  libexpat1 \
  libfontconfig1 \
  libgcc1 \
  libgconf-2-4 \
  libgdk-pixbuf2.0-0 \
  libglib2.0-0 \
  libgtk-3-0 \
  libnspr4 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libstdc++6 \
  libx11-6 \
  libx11-xcb1 \
  libxcb1 \
  libxcomposite1 \
  libxcursor1 \
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxi6 \
  libxrandr2 \
  libxrender1 \
  libxss1 \
  libxtst6 \
  ca-certificates \
  fonts-liberation \
  libappindicator1 \
  libnss3 \
  lsb-release \
  xdg-utils \
  wget

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Install Node.js
RUN apt-get install --yes curl &&\
  curl --silent --location https://deb.nodesource.com/setup_8.x | bash - &&\
  apt-get install --yes nodejs &&\
  apt-get install --yes build-essential

# Install emoji's
RUN cd $font_directory &&\
  wget https://github.com/emojione/emojione-assets/releases/download/3.1.2/emojione-android.ttf &&\
  wget https://github.com/googlei18n/noto-cjk/blob/master/NotoSansCJKsc-Medium.otf?raw=true && \
  fc-cache -f -v

RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install puppeteer so it's available in the container.
RUN npm i puppeteer

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
   && mkdir -p /home/pptruser/Downloads \
   && chown -R pptruser:pptruser /home/pptruser \
   && chown -R pptruser:pptruser /node_modules

RUN cd $application_directory

WORKDIR $application_directory

# Install app dependencies
COPY package.json .

# Bundle app source
COPY . .

# Build
RUN npm install

USER pptruser

# Expose the web-socket and HTTP ports
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["google-chrome-unstable", "npm", "start"]