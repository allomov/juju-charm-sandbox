group { "puppet":
  ensure => "present",
}

#file { '/home/vagrant/jenkins.yaml':
#  content => "jenkins:
#  plugins: git
#  username: vagrant
#  password: vagrant\n"
#}

File { owner => 0, group => 0, mode => 0644 }

file { '/etc/motd':
  content => "Welcome to your Vagrant-built virtual machine!
              Managed by Puppet.\n"
}

class juju {
exec { "install-juju-repo":
  path => '/usr/bin:/usr/sbin:/bin',
  command => "add-apt-repository ppa:juju/devel && apt-get update",
}

# juju packages

package { "juju-local":
  ensure => installed,
  require  => Exec["install-juju-repo"],
  before => Exec["juju-init"],
}
package { "python-pip":
  ensure => installed,
}
package { "git":
  ensure => installed,
}
package { "charm-tools":
  ensure => installed,
  require  => Package["juju-local"],
}
  exec { "juju-init":
    path => '/usr/bin:/usr/sbin:/bin',
    cwd  => "/home/vagrant",
    environment => ["JUJU_HOME=/home/vagrant/.juju"],
    command => "juju generate-config",
    require  => Package["juju-local"],
    user => 'vagrant',
  }

  exec { "juju-switch":
    path => '/usr/bin:/usr/sbin:/bin',
    cwd  => "/home/vagrant",
    environment => ["JUJU_HOME=/home/vagrant/.juju"],
    command => "juju switch local",
    require  => Exec["juju-init"],
    user => 'vagrant',
  }

  exec { "juju-bootstrap":
    path => '/usr/bin:/usr/sbin:/bin',
    cwd  => "/home/vagrant",
    environment => ["JUJU_HOME=/home/vagrant/.juju"],
    command => "juju bootstrap",
    require  => Exec["juju-switch"],
    user => 'vagrant',
  }
}
include juju
