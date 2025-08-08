# Provisioner
> [!WARNING]
> This tool is designed to be run either on a brand new system or a VM.
> It is not tested to be production ready.
> It will make your system unstable and insecure and will delete and/or expose your data.
> Use it at your own risk. You are responsible for everything you do with the provided software.

Provisioner is a simple tool to deploy a payload to your server and run it.
You can switch the payload with your own code. 

Copyright © 2025 Henry Hirsch  
This program is licensed under the GNU General Public License v3.  
See http://www.gnu.org/licenses/gpl-3.0.html for details.  

> [!IMPORTANT]
> The default payload is created for Debian 12 specifically the apt commands called in this script
> will not work on most systems.

The default payload will install puppet and git on the server, create a control repository for the root user and create a git hook that will run puppet on every file in the manifest directory in the repository whenever code is pushed.

When you run the provision script it will prompt you to enter a server name to deploy the payload to.
There is no confirmation step in the provision script, it will try to deploy and run immediately.

# Why You Would Want To Use The Payload?
It is just a simple way to bootstrap puppet standalone with a git based worflow either on a server or a vagrant VM.
# Why You Would Want To Use The Provisioner With A Custom Payload?
The provision script combined with your custom payload will add value to your workflow if for now you have been maintaining your server
exclusively over ssh without any special tooling. 
You'll go from 0 reproducability to some reproduceability without a steep learning curve.

# Usage
If the provision script is not executable, make it executable with
```
chmod +x provision
```

First you deploy the payload and run it.
Type on the client:
```
./provision
```
You will be promted for the server host name or IP.
Confirm with enter.

Clone the repository with:
```
git clone root@<server name>:/root/control.git
```

Add hello.pp to the manifests directory with the following content:
```
file {'/data/helloworld.txt':
  ensure  => present,
  content => "Hello World!",
}
```

Push and you should see 1 success in green under events in the generated report.
```
git push origin main
```

# Automatic Testing With Vagrant
> [!IMPORTANT]
> When prompted for a password use the password "vagrant".
> Vagrant might also prompt you for your current users password.
> If you don't want to enter the password create an RSA key.

Bring Vagrant Up With
```
./setup-vagrant
```

Run
```
./test
```
And follow the instructions on screen.

# Manual Testing With Vagrant
You can start a vagrant VM to test the included payload with:
```
vagrant up
```

To get the IP of the VM type:
```
vagrant ssh-config
```

When you clone the repository as instructed above you will be prompted for a password.
Use the password "vagrant" to clone the repository.
Push the example (put the hello.pp into the manifests directory) to the repository to have it run by puppet on the VM system.
