#!/bin/bash -e
clear

echo "================================================================="
echo "Awesome WordPress Installer!!"
echo "================================================================="


# accept the name of the WP Admin User
echo "WP Admin Username: (if left blank, defaults to: 'dnl-admin')"
read -e wpuser

# if the admin name is blank then default name is 'dnl-admin'
if [ "$wpuser" == '' ] ; then
wpuser='dnl-admin'
fi

# accept the email of the WP Admin User
echo "WP Admin Email Address: "
read -e adminemail

# accept the URL of the dev server from Lando
echo "Lando Development Server URL: "
read -e devurl

# accept the name of our website
echo "Site Name: "
read -e sitename

# accept a comma separated list of pages
echo "If you already know the names of the pages you would like to create, this script can create them automatically for you"
echo "Would you like to create your pages now? (y/n)"
read -e createpages

if [ "$createpages" == y ] ; then
	echo "A page called Home will automatically be created for you, so you don't need to add it here"
	echo "Add all of your page names separated by comma. Ex: about,contact us,portfolio"
	echo "Notice: there are no spaces between commas"
	read -e allpages
fi

# ask the user to confirm the entered information is correct?
clear
echo "The WP Admin Username is: $wpuser"
echo "The WP Admin Email Address is: $adminemail"
echo "The Site Name is: $sitename"

if [ "$allpages" ] ; then
	echo "You are creating the following pages: $allpages"
fi

echo "Note: The WP Admin Password will be automatically generated, and printed later for you to copy"
echo "If this is all correct, would you like to continue with the install? (y/n)"
read -e run

# if the user didn't say no, then go ahead an install
if [ "$run" == n ] ; then
exit
else

# download the WordPress core files
echo "Downloading the latest version of WordPress..."
wp core download

# create the wp-config file with our standard setup
echo "Creating wp-config.php with debug settings enabled for development..."
wp config create --dbname=wordpress --dbuser=wordpress --dbpass=wordpress --dbhost=database --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
define( 'DISALLOW_FILE_EDIT', true );
PHP

# generate random 14 character password
echo "Generating a random 14 digit strong password..."
password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 14)

echo "Installing WordPress..."
wp core install --url="$devurl" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="$adminemail"

# discourage search engines
echo "Disabling search engine indexing, remember to enable this when you go live!"
wp option update blog_public 0

# show only 6 posts on an archive page
wp option update posts_per_page 6

# delete sample page, and create homepage
wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID)

wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $wpuser --field=ID)

# set homepage as front page
wp option update show_on_front 'page'

# set homepage to be the new page
wp option update page_on_front $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=Home --field=ID)

# create all of the pages
export IFS=","
for page in $allpages; do
	wp post create --post_type=page --post_status=publish --post_author=$(wp user get $wpuser --field=ID) --post_title="$(echo $page | sed -e 's/^ *//' -e 's/ *$//')"
done

# set pretty urls
wp rewrite structure '/%postname%/' --hard
wp rewrite flush --hard

# delete akismet and hello dolly
echo "Deleting default plugins..."
wp plugin delete akismet
wp plugin delete hello

# delete default themes
echo "Deleting all default themes..."
wp theme delete twentyfifteen
wp theme delete twentysixteen

# install WordPress Plugins
echo "Installing WordPress plugins..."
WPPLUGINS=( custom-post-type-ui post-types-order svg-support timber-library advanced-custom-fields )
wp plugin install ${WPPLUGINS[@]} --activate

# Copy timber starter theme from plugin directory into themes directory and activate it
echo "Installing & Activating Timber Starter Theme..."
cp -r wp-content/plugins/timber-library/timber-starter-theme wp-content/themes/

# install & activate the timber starter theme
wp theme activate timber-starter-theme
wp theme delete twentyseventeen

# create a navigation bar
wp menu create "Main Navigation"

# add pages to navigation
export IFS=" "
for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids); do
	wp menu item add-post main-navigation $pageid
done

# assign navigation to primary location
# wp menu location assign main-navigation primary


# install TeamDNL Webpack Starter Kit
echo "Cloning DNL 2017 Webpack Starter Kit into timber-starter-theme/"
cd wp-content/themes/timber-starter-theme
git clone https://dnlrobertguss@bitbucket.org/dnlomnimedia/dnl-2017-webpack-starter-kit-js-only.git 
cp -r dnl-2017-webpack-starter-kit-js-only/* .
rm -rf dnl-2017-webpack-starter-kit-js-only

# NPM Install - check if yarn is installed if so use that, if not use NPM

# run webpack dev server



echo "================================================================="
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "================================================================="



fi