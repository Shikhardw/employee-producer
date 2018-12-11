class deploydocker {

include docker

file {"/root/tomcatDockerImage/Dockerfile":
   require => Class["docker"],
    ensure=> file,
    content => template("deploydocker/Dockerfile.erb"),
    subscribe=> File["/root/tomcatDockerImage/employee-producer-0.0.1-SNAPSHOT.jar"],
    notify => Docker::Image['employee-producer-0.0.1-SNAPSHOT'],	
}
file {"/root/tomcatDockerImage":
    ensure => 'directory',
    notify => File["/root/tomcatDockerImage/Dockerfile"],
  }

file {"/root/tomcatDockerImage/addressbook.war":
    ensure=> file,
    source => "puppet:///module_files/deploydocker/files/employee-producer-0.0.1-SNAPSHOT.jar",
    require =>Class["docker"],	
}

$application_directory = '/root/tomcatDockerImage'

::docker::image { 'employee-producer-0.0.1-SNAPSHOT':
    docker_dir => $application_directory,
    require   => Class['docker'],
    notify =>Docker::Run['employee-producer-0.0.1-SNAPSHOT']
    }
  # run the container using the image above
 docker::run { 'addressbookimage':
    image   => 'addressbookimage',
    ports   => ['8080:8080'],
   require => Docker::Image['employee-producer-0.0.1-SNAPSHOT']
  }

}


