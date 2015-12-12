FROM phusion/baseimage:latest

MAINTAINER desero <desero@desero.com>

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN apt-get update && apt-get install -y curl git acl nginx php5-fpm php5-cli php5-xdebug php5-gd php5-mcrypt php5-mysql php5-curl nodejs npm unzip
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN sed -i.bak "s@;cgi.fix_pathinfo=1@cgi.fix_pathinfo=0@g" /etc/php5/fpm/php.ini
RUN sed -i".bak" "s/^\;date\.timezone.*$/date\.timezone = \"Europe\/Kiev\" /g" /etc/php5/fpm/php.ini

# RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

COPY vhost/default /etc/nginx/sites-enabled/default

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d

# MySQL Installation
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN apt-get install -y mysql-server

ADD mysql/my.cnf    /etc/mysql/my.cnf

RUN mkdir           /etc/service/mysql
ADD mysql/mysql.sh  /etc/service/mysql/run
RUN chmod +x        /etc/service/mysql/run

RUN mkdir -p        /var/lib/mysql/
RUN chmod -R 755    /var/lib/mysql/

ADD etc/my_init.d/99_mysql_setup.sh /etc/my_init.d/99_mysql_setup.sh
RUN chmod +x /etc/my_init.d/99_mysql_setup.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/var/www", "/var/log/nginx/"]

RUN usermod -u 1000 www-data
# RUN chown -R www-data:www-data /var/www/app/cache
# RUN chown -R www-data:www-data /var/www/app/logs

CMD ["nginx", "-g", "daemon off;"]
CMD ["/sbin/my_init"]

EXPOSE 80
EXPOSE 443
EXPOSE 3306
