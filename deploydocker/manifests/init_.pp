class deploydocker {

class { 'docker':
  use_upstream_package_source => false,
  service_overrides_template  => false,
#  ensure => 'absent',
  require=> File["/root/tomcatDockerImage"],
}
file {"/root/tomcatDockerImage/Dockerfile":
   require => Class["docker"],
    ensure=> file,
    content => template("deploydocker/Dockerfile.erb"),
    subscribe=> File["/root/tomcatDockerImage/addressbook.war"],
    #notify => Docker::Image['addressBookImage'],	
}
file {"/root/tomcatDockerImage":
    ensure => 'directory',
    notify => File["/root/tomcatDockerImage/Dockerfile"],
  }

file {"/root/tomcatDockerImage/addressbook.war":
    ensure=> file,
    source => "puppet:///module_files/deploydocker/files/addressbook.war",
    require =>Class["docker"],	
}
 docker::image { 'addressBookImage':
    ensure        => 'present',
    docker_file   => '/root/tomcatDockerImage/Dockerfile',
    require   => Class['docker'],
    subscribe =>Docker::Run['addressBookImage']
    }
  # run the container using the image above
  docker::run { 'addressBookImage':
    image   => 'addressBookImage',
    ports   => ['8080:80'],
    require => Docker::Image['addressBookImage'],
  }
}
