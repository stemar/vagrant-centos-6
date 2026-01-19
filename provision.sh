rm /etc/localtime
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

echo '==> Setting time zone: '$TIMEZONE

echo '==> Setting Centos 6 Yum repository'

# https://www.getpagespeed.com/server-setup/how-to-fix-yum-after-centos-6-went-eol
cp /vagrant/config/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
cp /vagrant/config/centos6-epel-eol.repo /etc/yum.repos.d/epel.repo
yum -q -y install centos-release-scl
cp /vagrant/config/centos6-scl-eol.repo /etc/yum.repos.d/CentOS-SCLo-scl.repo
cp /vagrant/config/centos6-scl-rh-eol.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

echo '==> Cleaning Yum cache'

yum -q -y clean all
rm -rf /var/cache/yum

echo '==> Installing Linux tools'

cp /vagrant/config/bashrc /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc
yum -q -y install nano tree zip unzip whois &>/dev/null

echo '==> Setting Git 2.x repository'

rpm --import --quiet http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
yum -q -y install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm

echo '==> Installing Git and Subversion'

yum -q -y install git svn &>/dev/null

echo '==> Installing Apache'

yum -q -y install httpd &>/dev/null
usermod -a -G apache vagrant
chown -R root:apache /var/log/httpd
cp /vagrant/config/localhost.conf /etc/httpd/conf.d/localhost.conf
cp /vagrant/config/virtualhost.conf /etc/httpd/conf.d/virtualhost.conf
sed -i 's|GUEST_SYNCED_FOLDER|'$GUEST_SYNCED_FOLDER'|' /etc/httpd/conf.d/virtualhost.conf
sed -i 's|HOST_HTTP_PORT|'$HOST_HTTP_PORT'|' /etc/httpd/conf.d/virtualhost.conf

echo '==> Fixing httpd.conf'

if [ ! -f /etc/httpd/conf/httpd.conf.original ]; then
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
fi
while read line; do
    esc_line=$(sed 's:/:\\/:g' <<< $(printf '%q\n' "$line"))
    sed -i "/$esc_line/d" /etc/httpd/conf/httpd.conf
done < /vagrant/config/httpd.conf.fix
cat /vagrant/config/httpd.conf.fix >> /etc/httpd/conf/httpd.conf

echo '==> Installing MySQL'

yum -q -y install mysql mysql-server &>/dev/null

echo '==> Installing PHP'

rpm --import --quiet https://archive.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
yum -q -y install php php-common \
    php-bcmath php-devel php-gd php-imap php-intl php-ldap \
    php-mbstring php-mysql php-mysqli php-mysqlnd php-odbc php-opcache \
    php-pdo_mysql php-pdo_odbc php-posix php-pdo php-pear php-pecl-mcrypt \
    php-pecl-xdebug php-pspell php-soap php-tidy php-xml php-xmlrpc &>/dev/null
cp /vagrant/config/php.ini.htaccess /var/www/.htaccess
PHP_ERROR_REPORTING_INT=$(php -r 'echo '"$PHP_ERROR_REPORTING"';')
sed -i 's|PHP_ERROR_REPORTING_INT|'$PHP_ERROR_REPORTING_INT'|' /var/www/.htaccess

echo '==> Installing Adminer'

if [ ! -d /usr/share/adminer ]; then
    mkdir -p /usr/share/adminer/adminer-plugins
    curl -LsS https://www.adminer.org/latest-en.php -o /usr/share/adminer/latest-en.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/plugins/login-password-less.php -o /usr/share/adminer/adminer-plugins/login-password-less.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/plugins/dump-json.php -o /usr/share/adminer/adminer-plugins/dump-json.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/plugins/pretty-json-column.php -o /usr/share/adminer/adminer-plugins/pretty-json-column.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/designs/lavender-light/adminer.css -o /usr/share/adminer/adminer.css
fi
cp /vagrant/config/adminer.php /usr/share/adminer/adminer.php
cp /vagrant/config/adminer-plugins.php /usr/share/adminer/adminer-plugins.php
cp /vagrant/config/adminer.conf /etc/httpd/conf.d/adminer.conf
sed -i 's|HOST_HTTP_PORT|'$HOST_HTTP_PORT'|' /etc/httpd/conf.d/adminer.conf

echo '==> Starting Apache'

apachectl configtest
service httpd restart >/dev/null
chkconfig httpd on

echo '==> Starting MySQL'

service mysqld restart >/dev/null
chkconfig mysqld on
mysqladmin -u root password ""

echo
echo '==> Stack versions <=='

cat /etc/redhat-release
openssl version
curl --version | head -n1
svn --version | grep svn,
git --version
httpd -V | head -n1 | cut -d ' ' -f 3-
mysql -V
php -v | head -n1
python --version
