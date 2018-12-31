# Although this has a .sh filetype, it is intended to be followed as a guide rather than run as a script
# Replace all instances of the following: "mydomain.tld" "ICINGAPASSWORD" "ADMINPASSWORD" "APIPASSWORD"
# By Greg Rowe (October 2018)

Install Icinga2 Server on CentOS 7:

# Set DHCP
Change line in /etc/sysconfig/network-scripts/ifcfg-eth0
    From: ONBOOT=no
    To: ONBOOT=yes
systemctl restart network

# Set hostname
hostnamectl set-hostname monitor.mydomain.tld

yum upgrade -y
yum install -y https://packages.icinga.com/epel/icinga-rpm-release-7-latest.noarch.rpm
yum install -y epel-release centos-release-scl
yum update
yum install -y icinga2 icingaweb2 icingacli httpd icinga2-selinux icinga2-ido-mysql nagios-plugins-all mariadb-server sclo-php71-php-peclimagick vim vim-icinga2

systemctl enable icinga2
systemctl start icinga2
icinga2 node wizard

systemctl enable mariadb
systemctl start mariadb
mysql_secure_installation

# Create icinga database, user, & schema
password=ICINGAPASSWORD
echo "CREATE DATABASE icinga;
 USE icinga;
 GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX,
 EXECUTE ON icinga.* TO 'icinga'@'localhost';
 SET PASSWORD for 'icinga'@'localhost' = PASSWORD('$password');
 source /usr/share/icinga2-ido-mysql/schema/mysql.sql" |
mysql -uroot -p$password

# Create database account
echo "USE icinga;
 GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE VIEW, INDEX,
 EXECUTE ON icinga.* TO 'icinga';
 SET PASSWORD FOR 'icinga' = PASSWORD('$password');" |
mysql -uroot -p$password

# Create a root database account to be able to create new databases:
echo "GRANT ALL ON *.* TO 'root'
 WITH GRANT OPTION;
 SET PASSWORD FOR 'root' = PASSWORD('$password');" |
mysql -uroot -p$password

# Optional tests:
## Test db connection
echo "SHOW TABLES;" |
mysql -uicinga -p$password icinga
## Test master's root access
echo "SHOW DATABASES;" |
mysql -uroot -p$password

# Set PHP Timezone
Update the following line in /etc/opt/rh/rh-php71/php.ini
    From: ;date.timezone =  
    To: date.timezone = "America/Boise"

# Enable web features
systemctl enable rh-php71-php-fpm.service
systemctl start rh-php71-php-fpm.service
systemctl enable httpd
systemctl start httpd

# Add the following to /etc/icinga2/conf.d/api-users.conf
object ApiUser "icingaweb2" {
  password = "APIPASSWORD"
  permissions = [ "status/query", "actions/*", "objects/modify/*", "objects/query/*" ]
}

# Uncomment and fill in the following in /etc/icinga2/features-enabled/ido-mysql.conf
object IdoMysqlConnection "ido-mysql" {
  user = "icinga"
  password = "ICINGAPASSWORD"
  host = "localhost"
  database = "icinga"
}

# Allow Firewall & restart Icinga
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --add-service=https
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload
systemctl restart icinga2

# Create a setup token
icingacli setup token create

# Set up Icinga Web
Navigate to http://monitor.mydomain.tld/icingaweb2/setup
    Authentication
        Authentication Type: Database
    Database Resource
        Resource Name: icingaweb_db
        Database Type: MySQL
        Host: localhost
        Database Name: icingaweb
        Username: root
        Password: ICINGAPASSWORD
    Authentication Backend
        Backend Name: icingaweb2
    Administration:
        Username: icingaadmin
        Password: ADMINPASSWORD
    Application Configuration
        Show Stacktraces: Checked
        Show App State: Checked
        User Preference Storage Type: INI Files
        Other default values are fine
    Monitoring Backend
        Default values
    Monitoring IDO Resource
        Resource Name: icinga2_ido
        Database Type: MySQL
        Host: localhost
        Database Name: icinga
        Username: icinga
        Password: ICINGAPASSWORD
    Command Transport
        Transport Name: icinga2
        Transport Type: Icinga 2 API
        Host: localhost
        Port: 5665
        API Username: icingaweb2
        API Password: APIPASSWORD
    Monitoring Security
        Default values

# AD Authentication
Add to the following config files:

/etc/icingaweb2/resources.ini
[agri-ad]
type = ldap
hostname = mydomain.tld
port = 389
root_dn = "OU=IT,DC=DOMAIN,DC=TLD"
bind_dn = "CN=adicingauser,CN=Managed Service Accounts,DC=DOMAIN,DC=TLD"
bind_pw = ICINGAPASSWORD

/etc/icingaweb2/authentication.ini
[auth_ad]
backend = msldap
resource = agri-ad
base_dn = "OU=IT,DC=DOMAIN,DC=TLD"

# Restart Icinga
systemctl restart icinga2

# Set Admin Permissions
Add desired users to the admin group in Configuration > Authentication > User Groups > Administrators > Add New Member
