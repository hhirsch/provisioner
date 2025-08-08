file {'/data/helloworld.txt':
  ensure  => present,
  content => "Hello World!",
}