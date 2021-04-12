echo '==> Setting time zone'

rm /etc/localtime
ln -s /usr/share/zoneinfo/Canada/Pacific /etc/localtime
zdump /etc/localtime

echo '==> Setting Centos 6.10 Yum repository'

# https://www.getpagespeed.com/server-setup/how-to-fix-yum-after-centos-6-went-eol
cp $VM_CONFIG_PATH/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
cp $VM_CONFIG_PATH/centos6-epel-eol.repo /etc/yum.repos.d/epel.repo
yum -q -y install centos-release-scl
cp $VM_CONFIG_PATH/centos6-scl-eol.repo /etc/yum.repos.d/CentOS-SCLo-scl.repo
cp $VM_CONFIG_PATH/centos6-scl-rh-eol.repo /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo

echo '==> Cleaning Yum cache'

yum -q -y clean all
rm -rf /var/cache/yum

echo '==> Installing Linux tools'

cp $VM_CONFIG_PATH/bashrc /home/vagrant/.bashrc
chown vagrant:vagrant /home/vagrant/.bashrc
yum -q -y install nano tree zip unzip whois
yum -q -y update openssl

echo '==> Setting Git 2.x repository'

rpm --import --quiet http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
yum -q -y install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm

echo '==> Installing Subversion and Git'

yum -q -y install svn git

echo '==> Installing Apache'

yum -q -y install httpd mod_ssl
usermod -a -G apache vagrant
chown -R root:apache /var/log/httpd
cp $VM_CONFIG_PATH/localhost.conf /etc/httpd/conf.d/localhost.conf
cp $VM_CONFIG_PATH/virtualhost.conf /etc/httpd/conf.d/virtualhost.conf
sed -i 's|GUEST_SYNCED_FOLDER|'$GUEST_SYNCED_FOLDER'|' /etc/httpd/conf.d/virtualhost.conf
sed -i 's|FORWARDED_PORT_80|'$FORWARDED_PORT_80'|' /etc/httpd/conf.d/virtualhost.conf

echo '==> Fixing httpd.conf'

if [ ! -f /etc/httpd/conf/httpd.conf.original ]; then
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
fi
while read line; do
    esc_line=$(sed 's:/:\\/:g' <<< $(printf '%q\n' "$line"))
    sed -i "/$esc_line/d" /etc/httpd/conf/httpd.conf
done < $VM_CONFIG_PATH/httpd.conf.fix
cat $VM_CONFIG_PATH/httpd.conf.fix >> /etc/httpd/conf/httpd.conf

echo '==> Installing MySQL'

yum -q -y install mysql mysql-server

echo '==> Installing PHP'

rpm --import --quiet http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
yum -q -y install php php-common \
    php-bcmath php-devel php-gd php-imap php-intl php-ldap \
    php-mbstring php-mysql php-mysqli php-mysqlnd php-odbc php-opcache \
    php-pdo_mysql php-pdo_odbc php-posix php-pdo php-pear php-pecl-mcrypt \
    php-pecl-xdebug php-pspell php-soap php-tidy php-xml php-xmlrpc
cp $VM_CONFIG_PATH/php.ini.htaccess /var/www/.htaccess

echo '==> Installing Adminer'

if [ ! -d /usr/share/adminer ]; then
    mkdir -p /usr/share/adminer/plugins
    curl -LsS https://www.adminer.org/latest-en.php -o /usr/share/adminer/adminer.php
    curl -LsS https://raw.githubusercontent.com/vrana/adminer/master/designs/nicu/adminer.css -o /usr/share/adminer/adminer.css
fi
cp $VM_CONFIG_PATH/adminer.conf /etc/httpd/conf.d/adminer.conf
sed -i 's|FORWARDED_PORT_80|'$FORWARDED_PORT_80'|' /etc/httpd/conf.d/adminer.conf
sed -i 's|login($we,$F){if($F=="")return|login($we,$F){if(true)|' /usr/share/adminer/adminer.php

echo '==> Starting Apache'

apachectl configtest
service httpd start
chkconfig httpd on

echo '==> Starting MySQL'

service mysqld start
chkconfig mysqld on
mysqladmin -u root password ""

echo '==> Versions:'

cat /etc/redhat-release
echo $(openssl version)
echo $(curl --version | head -n1)
echo $(svn --version | grep svn,)
echo $(git --version)
echo $(httpd -V | head -n1)
echo $(mysql -V)
echo $(php -v | head -n1)
echo $(python --version)
