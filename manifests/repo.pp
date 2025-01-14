# Wazuh App Copyright (C) 2019 Wazuh Inc. (License GPLv2)
# Wazuh repository installation
class wazuh::repo (
) {

  case $::osfamily {
    'Debian' : {
      if ! defined(Package['apt-transport-https']) {
        ensure_packages(['apt-transport-https'], {'ensure' => 'present'})
      }
      # apt-key added by issue #34
      apt::key { 'wazuh':
        id     => '0DCFCA5547B19D2A6099506096B3EE5F29111145',
        source => 'https://packages.wazuh.com/key/GPG-KEY-WAZUH',
        server => 'pgp.mit.edu'
      }
      case $::lsbdistcodename {
        /(jessie|wheezy|stretch|buster|sid|precise|trusty|vivid|wily|xenial|yakketi|bionic)/: {

          apt::source { 'wazuh':
            ensure   => present,
            comment  => 'This is the WAZUH Ubuntu repository',
            location => 'https://packages.wazuh.com/3.x/apt',
            release  => 'stable',
            repos    => 'main',
            include  => {
              'src' => false,
              'deb' => true,
            },
          }
        }
        default: { fail('This ossec module has not been tested on your distribution (or lsb package not installed)') }
      }
    }
    'Linux', 'Redhat' : {
        case $::os[name] {
          /^(CentOS|RedHat|OracleLinux|Fedora|Amazon)$/: {
            if ( $::operatingsystemrelease =~ /^5.*/ ) {
              $baseurl  = 'https://packages.wazuh.com/3.x/yum/5/'
              $gpgkey   = 'http://packages.wazuh.com/key/GPG-KEY-WAZUH-5'
            } else {
              $baseurl  = 'https://packages.wazuh.com/3.x/yum/'
              $gpgkey   = 'https://packages.wazuh.com/key/GPG-KEY-WAZUH'
            }
          }
          default: { fail('This ossec module has not been tested on your distribution.') }
        }
      # Set up OSSEC repo
      yumrepo { 'wazuh':
        descr    => 'WAZUH OSSEC Repository - www.wazuh.com',
        enabled  => true,
        gpgcheck => 1,
        gpgkey   => $gpgkey,
        baseurl  => $baseurl
      }

    }
    default: { fail('This ossec module has not been tested on your distribution') }
  }
}
