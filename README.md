# WordPress install scripts

This bash script automatically installs and creates a fresh WordPress install using [WP-CLI](https://make.wordpress.org/cli/handbook/) and [Lando](https://docs.devwithlando.io/) for local development.

By default, this starter kit uses [Timber](https://www.upstatement.com/timber/) & [My Webpack Starter Kit](https://github.com/robertguss/WordPress-Starter-Kit) for custom theme development.

Feel free to fork and customize this starter kit to your liking 😎

## How to install & use

- Download & install [Docker](https://docs.docker.com/install/)
- Download & install [Lando](https://docs.devwithlando.io/)
- Start docker & make sure it is running

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

> You will need this url for the WordPress installation

```bash
  # ssh into lando to run WP install script
  lando ssh
  bash install-wp.sh
```

- follow the prompts and enter in the required information.

## Configuring Composer

per [Timber's Docs](https://timber.github.io/docs/getting-started/setup/) we need to setup our WP install and let it autoload our Composer packages, in particular the Timber plugin. Inside of the `functions.php` file add the following to the top of the file:

```php
<?php
require_once( __DIR__ . '/vendor/autoload.php' );
$timber = new Timber\Timber();
```

## Install npm packages

```bash
  # cd into the theme directory
  cd wp-content/themes/timber-starter-theme

  # install with npm
  npm install

  # or install with yarn
  yarn
```

## To enable browser sync

open `wp-content/themes/timber-starter-theme/webpack.dev.js` and uncomment the first line at the top of the file

```javascript
  const BrowserSyncPlugin = require('browser-sync-webpack-plugin');
```

and also uncomment the following at the bottom of the file.

Update the proxy: `http://localhost:8080/` with the url of the lando dev server, ie `http://my-word-press-site.lndo.site:8000`

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
  yarn start
```

## Production Build

In order to minify your scrips and css for production builds, run:

```bash
  yarn build
```