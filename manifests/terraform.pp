# terraform
#
class desktop::terraform(
  String $user = 'ec2-user',
  Boolean $install_terraform = true,
  String $terraform_version = '0.14.3',
) {
  if $install_terraform {
    exec { 'curl-terraform':
      command => "curl -LSso /usr/local/src/terraform_${terraform_version}_linux_amd64.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip",
      path    => '/usr/bin',
      creates =>  "/usr/local/src/terraform_${terraform_version}_linux_amd64.zip",
    }
    ~> exec { 'unzip-terraform':
      command     => "unzip /usr/local/src/terraform_${terraform_version}_linux_amd64.zip -d /usr/local/bin",
      path        => '/bin:/usr/bin',
      refreshonly =>  true,
    }
  }
}
