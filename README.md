# WordPress install scripts

This bash script automatically installs and creates a fresh WordPress install using [WP-CLI](https://make.wordpress.org/cli/handbook/) and [Lando](https://docs.devwithlando.io/) for local development.

## How to install & use

- Download & install [Docker](https://docs.docker.com/install/) & start it.
- Download & install [Lando](https://docs.devwithlando.io/)

```bash
  # cd into this repo then run:
  lando start

  # this will start up lando and create the docker containers necessary for WordPress
```

- Once lando has been initialized you will see an output like the following:

```bash
BOOMSHAKALAKA!!!

Your app has started up correctly.
Here are some vitals:

 NAME            my-word-press-site
 LOCATION        /Users/robertguss/Projects/WP_Scripts
 SERVICES        appserver, database

 APPSERVER URLS  https://localhost:32786
                 http://localhost:32787
                 http://my-word-press-site.lndo.site:8000
                 https://my-word-press-site.lndo.site:444
```

```bash
  # you can easily find this info again by typing
  lando info
```

- Copy the 'APPSERVER URL' (usually the 3rd in the list) that looks similar to this: `http://my-word-press-site.lndo.site:8000`

- _You will need this url for the WordPress installation_

```bash
  # ssh into lando to run WP install script
  lando ssh
  bash install-wp.sh
```

- follow the prompts and enter in the required information.

- After the install is complete, install npm packages:

```bash
  # cd into the theme directory
  cd wp-content/themes/timber-starter-theme

  # install with npm
  npm install

  # or install with yarn
  yarn
```

### To enable browser sync

open `webpack.dev.js` and uncomment the first line at the top of the file

```javascript
  const BrowserSyncPlugin = require('browser-sync-webpack-plugin');
```

and also the following at the bottom of the file. Update the proxy: http://localhost:8080/ with the url of the lando dev server, ie http://my-word-press-site.lndo.site:8000:

```javascript
  new BrowserSyncPlugin(
    // BrowserSync options
    {
      host: 'localhost',
      port: 3000,
      proxy: 'http://my-word-press-site.lndo.site:8000'
    },
    {
      reload: false
    }
  )
```

start the dev server with:

```bash
  npm run start

  # or
  yarn start
```

### Production Build

In order to minify your scrips and css for production builds, run:

```bash
  npm run build

  # or
  yarn build
```