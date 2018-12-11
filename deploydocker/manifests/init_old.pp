class deploydocker {

include docker

file {"/root/tomcatDockerImage/Dockerfile":
   require => Class["docker"],
    ensure=> file,
    content => template("deploydocker/Dockerfile.erb"),
    subscribe=> File["/root/tomcatDockerImage/addressbook.war"],
    notify => Docker::Image['addressbookimage'],	
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

$application_directory = '/root/tomcatDockerImage'

::docker::image { 'addressbookimage':
    docker_dir => $application_directory,
    require   => Class['docker'],
    notify =>Docker::Run['addressbookimage']
    }
  # run the container using the image above
 docker::run { 'addressbookimage':
    image   => 'addressbookimage',
    ports   => ['8080:8080'],
   require => Docker::Image['addressbookimage']
  }

}


