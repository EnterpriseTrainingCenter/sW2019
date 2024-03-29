# Lab: Deploying Containers

## Required VMs

* CL1
* DC1
* DHCP
* Router
* K8SMaster
* K8SNode
* SRV2

## Exercises

1. [Deploy Docker Images](#exercise-1-deploy-docker-images)
1. [Working with dockerfile](#exercise-2-working-with-dockerfile)
1. [Linux Containers](#exercise-3-linux-containers)
1. [Kubernetes](#exercise-4-kubernetes)

## Exercise 1: Deploy Docker images

### Introduction

In this exercise, first, you will enable nested virtualization and install docker on the VM DOCKER. Then, you will pull the nanoserver 1809 image from the docker repository, import the Windows Server LTSC 2019 image from c:\images\winsrvcoreltsc2019 and create a transparent network called smartnet. Next, you will run the nanoserver image. Then, you will start the Windows Server LTSC image and attach it to the smartnet network. You will install IIS in this image, customize the web site and save it as custom image into the local repository. Finally, you will run the custom image in process and Hyper-V isolation mode and compare the memory usage.

#### Tasks

1. [Enable nested virtualization](#task-1-enable-nested-virtualization)
1. [Install Docker](#task-2-install-docker)
1. [Prepare docker images and networking](#task-3-prepare-docker-images-and-networking)
1. [Working with docker images](#task-4-working-with-docker-images)
1. [Install a web server within a container](#task-5-install-a-web-server-within-a-container)
1. [Validate the web server](#task-6-validate-the-web-server)
1. [Deploy a web site in the container](#task-7-deploy-a-web-site-in-the-container)
1. [Save the custom container as new image to the repository](#task-9-save-the-custom-container-as-new-image-to-the-repository)
1. [Run a container in Hyper-V isolation mode](#task-10-run-a-container-in-hyper-v-isolation-mode)

### Task 1: Enable nested virtualization

Perform these steps on the host computer.

1. In **Hyper-V Manager**, make sure the VM **DOCKER** is not running.
1. Run **Windows PowerShell** as Administrator.
1. Enable Nested Virtualization for the VM DOCKER.

   ````powershell
   $vmName = 'DOCKER'
   C:\HostFiles\Enable-NestedVM.ps1 $vmName
   ````

1. Start the VM DOCKER.

   ````powershell
   Start-VM $vmName
   ````

### Task 2: Install Docker

#### PowerShell

Perform these steps on DOCKER.

1. Logon as Administrator
1. Run **Windows PowerShell as Administrator**.
1. Install the Docker-Microsoft PackageManagement Provider from the PowerShell Gallery.

   ````powershell
   $providerName = 'DockerMsftProvider'
   Install-Module -Name $providerName -Repository PSGallery –Force
   ````

1. Use the PackageManagement PowerShell module to install the latest version of Docker.

   ````powershell
   Install-Package -Name 'Docker' -ProviderName $providerName
   ````

1. Set Docker service to start automatically.

   ````powershell
   Set-Service Docker -Startuptype Automatic
   ````

1. Install Hyper-V and reboot the VM.

   ````powershell
   Install-WindowsFeature 'Hyper-V' -Restart
   ````

#### Windows Admin Center

Perform these steps on CL1.

1. Logon as **smart\administrator**
1. Start Google Chrome.
1. In Google Chrome, navigate to <https://admincenter.smart.etc>.
1. In **Windows Admin Center**, on the top-right, click the gear icon to open settings.
1. In **Settings**, on the left, click **Extensions**.
1. In **Extensions**, click **Containers**, then click **Install**. Wait for the installation to complete.
1. Return to the home page of **Windows Admin Center**.
1. Add a server connection to server **Docker**.
1. Connect to to server **Docker.smart.etc**.
1. Conntected to **Docker.smart.etc**, on the left, click **Containers**.
1. Click **Install** and wait for the installation to complete. This will take a minute or two. After installation completes, the server will restart and you will be taken to the home page of **Windows Admin Center**. Wait for the server to reboot and reconnect to **Docker.smart.etc**.
1. Connected to **Docker.smart.etc**, click **Roles & Features**.
1. In **Roles and features**, activate **Hyper-V** and click **+ Install**.
1. On the pane **Install Roles and Features**, activate **Reboot the server automatically if required** and click **Yes**. Wait for the installation to complete. This may take a minute or two.

### Task 3: Prepare docker images and networking

*Note:*
Although Windows Admin Center provides some basic functionality for containers, it is limited in a way, which will not allow you to complete all steps in this task or make it over-complicated.

Perform these steps on DOCKER.

1. Run **Command Prompt** as Administrator.
1. Display the current Docker version.

   ````shell
   docker --version
   ````

1. Display the client and engine version.

   ````shell
   docker version
   ````

1. Download Nano Server 1809 from the public repository.

   ````shell
   docker pull mcr.microsoft.com/windows/nanoserver:1809
   ````

1. Import the pre-created Windows Server Core Container OS Image.

   ````shell
   docker load -i c:\images\winsrvcoreltsc2019
   ````

1. List the installed OS base images. You see two images, one does not have a repository and tag. Take a note of this image's **IMAGE ID** ([figure 1]).

   ````shell
   docker images
   ````

1. After the import, you should rename the image. The command uses the image ID, you took note of in the previous step (8b79).

   ````shell
   docker tag 8b79 mcr.microsoft.com/windows/servercore:ltsc2019
   ````

1. List the installed OS base images again. The previously unnamed image should now have values for **REPOSITORY** and **TAG** ([figure 2]).

   ````shell
   docker images
   ````

1. Display the current network configuration.

   ````shell
   docker network ls
   ````

1. Create a transparent network for containers.

   ````shell
   docker network create -d transparent smartnet
   ````

1. Display the current network configuration again. It should look like in [figure 3],

   ````shell
   docker network ls
   ````

### Task 4: Working with docker images

1. Start a Windows container based on Nano Server 1809.

   ````shell
   docker run -it mcr.microsoft.com/windows/nanoserver:1809 cmd
   ````

1. Display the hostname of the container.

   ````shell
   hostname
   ````

1. Exit the running container

   ````shell
   exit
   ````

1. List all containers. Take a note of the **CONTAINER ID** ([figure 4]).

   ````shell
   docker ps -a
   ````

   > Is the container still running?

1. Start the container again. Replace ````<container id>```` with the value, you took note of in the previous step.

   ````shell
   docker start <container id>
   ````

1. Attach to the container. Press ENTER again after executing the command.

   ````shell
   docker attach <container id>
   ````

1. Within the running container validate the NAT IP configuration and try to ping DC1.

   ````shell
   ipconfig /all
   ping DC1.smart.etc
   ````

1. Exit the container without stopping it by pressing CTRL+P and CTRL+Q.
1. List all containers.

   ````shell
   docker ps -a
   ````

   > Is the container running?

1. Stop the container.

   ```shell
   docker stop <container id>
   ````

1. List all containers.

   ````shell
   docker ps -a
   ````

   > Is the container running now?

1. Delete the container.

   ````shell
   docker rm <container id>
   ````

### Task 5: Install a web server within a container

1. Start a new Windows Server Core 2019 Container with transparent networking.

   ````shell
   docker run --net=smartnet –it mcr.microsoft.com/windows/servercore:ltsc2019 cmd
   ````

1. Display the current IP address of the container. Take a note of the IP address.

   ````shell
   ipconfig
   ````

1. Try to ping DC1.

   ````shell
   ping DC1.smart.etc
   ````

1. Start Windows PowerShell.

   ````shell
   powershell
   ````

1. Install a web server within the container and exit Windows PowerShell.

   ````powershell
   Install-WindowsFeature Web-Server
   exit
   ````

### Task 6: Validate the web server

Perform these steps on CL1.

1. Logon as **smart\Administrator**.
1. Open **Google Chrome**.
1. In the web browser, navigate to the IP address of the container you took note of in the previous task.

   > Do you see a valid web page?

### Task 7: Deploy a web site in the container

Perform these steps on DOCKER.

1. In the running container, create a new default HTML page.

   ````shell
   echo Test Homepage > C:\inetpub\wwwroot\default.htm
   ````

### Task 8: Validate the web site deployment

Perform these steps on CL1.

1. In the open web browser, refresh the web site.

   > Did the web site change?

### Task 9: Save the custom container as new image to the repository

Perform these steps on DOCKER.

1. Press CTRL+P, CTRL+Q to exit the container.
1. List the running containers, take note of the **CONTAINER ID** and stop the container.

   ````shell
   docker ps –a
   docker stop <container id>
   ````

1. Commit the changes in the container to a new image named iisdemo.

   ````shell
   docker commit <container id> iisdemo
   ````

1. List the images in the repository.

   ````shell
   docker images
   ````

1. Display the base images of iisdemo.

   ````shell
   docker history iisdemo
   ````

### Task 10: Run a container in Hyper-V isolation mode

1. Open a separate PowerShell windows.

   ````shell
   start powershell
   ````

1. In **Windows PowerShell**, capture the processes currently running.

   ````powershell
   $processes = Get-Process
   ````

1. In the command prompt window, start the container **iisdemo** as process isolated container.

   ````shell
   docker run --rm --isolation=hyperv -it iisdemo cmd
   ````

1. In **Windows PowerShell**, list the processes, the container launched.

   ````powershell
   Get-Process | 
   Where-Object { $PSItem.Id -notin $processes.id }
   ````

1. Calculate the memory usage of the processes in the container. Take a note of the sum.

   ````powershell
   Get-Process | 
   Where-Object { $PSItem.Id -notin $processes.id } | 
   Measure-Object -Property WorkingSet -Sum
   ````

1. In the command prompt window, exit the container and stop it.

   ````shell
   exit
   ````

1. In the command prompt window, start the container **iisdemo** in Hyper-V isolation mode.

   ````shell
   docker run --rm --isolation=hyperv -it iisdemo cmd
   ````

1. In **Windows PowerShell**, list the processes, the container launched. Notice the process **vmmem**.

   ````powershell
   Get-Process | 
   Where-Object { $PSItem.Id -notin $processes.id }
   ````

1. Calculate the memory usage of the processes in the container. Compare the sum to the sum you took note earlier in the task.

   ````powershell
   Get-Process | 
   Where-Object { $PSItem.Id -notin $processes.id } | 
   Measure-Object -Property WorkingSet -Sum
   ````

   > Which isolation mode takes up more memory? How much is the difference?

1. In the command prompt window, exit the container and stop it.

   ````shell
   exit
   ````

## Exercise 2: Working with dockerfile

### Introduction

In this exercise, you will build a dockerfile, which create a new image from Windows Server 2019 Core LTSC, installs IIS, creates a custom index.html in wwwroot and sends a permanent ping to localhost. Then you create a new image from the dockerfile, run and test it.

#### Tasks

1. [Use dockerfile to create an image](#task-1-use-dockerfile-to-create-an-image)
2. [Validate the new image](#task-2-validate-the-new-image)
3. [Stop the container](#task-3-stop-the-container)

### Task 1: Use dockerfile to create an image

Perform these steps on DOCKER.

1. Create a new folder **C:\Build**.

   ````shell
   md c:\build
   ````

1. Open Notepad.

   ````shell
   notepad
   ````

1. Create a Docker file based on the server core image. Save the file as **dockerfile.** in **C:\Build**. (include the dot at the end of the filename) selecting **All Files** in **Save as type**. The dot at the end makes sure, the file does not automatically get a file extension  attached.

   ````dockerfile
   FROM mcr.microsoft.com/windows/servercore:ltsc2019
   RUN dism /online /enable-feature /all /featurename:iis-webserver /NoRestart
   RUN echo "Hello World - Dockerfile" > C:\Inetpub\wwwroot\index.html
   CMD ["ping", "localhost", "-t" ]
   ````

1. Create a new docker image using dockerfile.

   ````shell
   docker build -t myiis c:\Build
   ````

1. List the available images.

   ````shell
   docker images
   ````

   > What is the name of the new image?

1. Start a new container based on this image using the NAT network and port forwarding.

   ````shell
   docker run -d –p 80:80 myiis
   ````

1. Get the IP address of the VM docker and take a note of it.

   ````shell
   ipconfig
   ````

### Task 2: Validate the new image

Perform these steps on CL1.

1. Open a web browser.
1. Navigate to the IP address of Docker, you took note of in the previous task.

   > Do you see a custom web page?

### Task 3: Stop the container

Perform these steps on DOCKER.

1. Find the **CONTAINER ID** of the running container and take a note of it.

   ````shell
   docker ps
   ````

1. Stop the container.

   ````shell
   docker stop <container id>
   ````

## Exercise 3: Linux Containers

### Introduction

In this exercise, you will activate support for Linux Container, pull and run the hello-world image, and disable the support again. Next, you will use LinuxKit to run a Windows container (the container from the previous exercise) and a Linux container (nginx) in parallel.

#### Tasks

1. Activate and run a Linux Container
1. Coexistence between Windows and Linux containers

### Task 1: Activate and run a Linux Container

Perform these steps on DOCKER.

1. In **Windows PowerShell**, activate Linux Container support.

   ````powershell
   <#
   [System.Environment] is a .NET class for persistent environment variables
   SetEnvironmentVariable is static method of the [System.Environment]
   The [Class]::Method syntax must be used to call a static method
   For more information about the SetEnvironmentVariable method,
   see https://docs.microsoft.com/en-us/dotnet/api/system.environment.setenvironmentvariable?view=net-5.0#System_Environment_SetEnvironmentVariable_System_String_System_String_System_EnvironmentVariableTarget_
   #>
   [System.Environment]::SetEnvironmentVariable("LCOW_SUPPORTED", "1", "Machine")
   Restart-Service Docker
   ````

1. In **Command Prompt**, pull and run the Linux based **Hello World!** image from Docker Hub (figure 5)

   ````shell
   docker run hello-world
   ````

![Linux-based hello-world image pulling and running in a container][figure 5]

Figure 5

### Task 2: Coexistence between Windows and Linux containers

Perform these steps on DOCKER.

1. In **Windows PowerShell**, remove the environment variable from the previous task.

   ````powershell
   [System.Environment]::SetEnvironmentVariable("LCOW_SUPPORTED", $null, "Machine")
   ````

1. LinuxKit images allow to start Windows and Linux container simultaneously. LinuxKit is available as an experimental project on GitHub. Use **Windows PowerShell** to install LinuxKit.

   ````powershell
   Expand-Archive c:\images\release.zip -DestinationPath "$Env:ProgramFiles\Linux Containers\."
   ````

1. In **Command Prompt**, stop the **Docker** service.

   ````shell
   Net Stop Docker
   ````

1. Start the docker daemon with the experimental parameter.

   ````shell
   cd "C:\Program Files\Docker"
   .\dockerd.exe --experimental
   ````

1. Leave **Command Prompt** open, and open a second instance using **Task Manager**.
1. Download a Linux based image.

   ````shell
   docker pull --platform=linux nginx
   ````

1. Start a Windows and a Linux container.

   ````shell
   docker run -d –p 80:80 myiis
   docker run -d –p 88:80 nginx
   ````

1. List the running containers.

   ````shell
   docker ps
   ````

## Exercise 4: Kubernetes

### Introduction

In this exercise you will use a Kubernetes cluster to deploy two replicas of a pod. In the first task you will use imperative commands and in the second task you will use a yml-file to see a declarative management.

Since the setup of a Kubernetes cluster is not as easy as a Windows administrator would expect, the cluster is already set up for you. The master must run on Linux (here Ubuntu 18.04) and the single node is running on Windows Server 2019. In Microsoft's documentation you can find more information how to configure a Kubernetes cluster with Windows Server 2019 nodes/agents (<https://docs.microsoft.com/en-us/virtualization/windowscontainers/kubernetes/getting-started-kubernetes-windows>).

#### Tasks

1. [Prepare the Kubernetes cluster](#task-1-prepare-the-kubernetes-cluster)
1. [Create a deployment imperatively](#task-2-create-a-deployment-imperatively)
1. [Use a yml file for a declarative deployment](#task-3-use-a-yml-file-for-a-declarative-deployment)

### Task 1: Prepare the Kubernetes cluster

Perform these steps on K8SNode

1. Logon as "Administrator".
1. Open a **Windows PowerShell** console.
1. Change to directory **c:\k**

   ````powershell
   # cd is an alias for Set-Location
   cd c:\k
   ````

1. Start the Kubernetes agent.

   ````powershell
   # The back tick ` can be used to split long command lines and make them more readable
   .\start.ps1 `
       -ManagementIP 10.1.1.96 `
       -ClusterCIDR 10.244.0.0/16 `
       -ServiceCIDR 10.96.0.0/12 `
       -KubeDnsServiceIP 10.96.0.10
   ````

1. Leave Windows PowerShell open and proceed with the next task.

### Task 2: Create a deployment imperatively

Perform these steps on K8SMaster.

1. Drag the logon screen up and logon as **k8sadmin** with the password **Pa$$w0rd**.
1. Click on **Activities** and open a **Terminal**.
1. Check the cluster state.

   ````shell
   kubeadm config view
   ````

1. List all configured and available nodes.

   ````shell
   kubectl get node
   ````

   Note: Windows Server 2019 nodes do not report as agent. You could do it manually.

1. To create a container in a pod, create a deployment.

   ````shell
   kubectl create deployment smartweb --image=smartiis:201902
   ````

1. Show the progress of downloading the image and starting the container in the pod.

   ````shell
   kubectl get deployment
   ````

1. Show details about the deployment.

   ````shell
   kubectl describe deployment
   ````

1. After a few minutes, check the pod:

   ````shell
   kubectl get pod
   ````

1. Show more details about the pod

   ````shell
   kubectl describe pod
   ````

   Note: If you see the state of the pod as 'ContainterCreating'. Repeat the command several time until the state changes to 'Running'.

1. Make the web site externally available.

   ````shell
   kubectl expose deployment smartweb --type=NodePort --port=80 --target-port=80
   ````

1. Get the created port on the nodes/agents.

   ````shell
   kubectl get service
   ````

1. Get detailed information about the node's ports. Take note of tThe attributes NodePort and Endpoints.

   ````shell
   kubectl describe service smartweb
   ````

1. Open a web browser.
1. In the web browser, navigate <http://10.1.1.96:xyz>, where xyz is the port number you took note of in the previous step, and 10.1.1.96 is the IP address of your node. You should see the default page of IIS.
1. Open a new tab in the browser an navigate to http://\<Endpoints-IP\>, you noted in the previous step. Again, you should see the default page of IIS.
1. Clean up your environment.

   ````shell
   kubectl delete service smartweb
   kubectl delete deployment smartweb
   ````

### Task 3: Use a yml file for a declarative deployment

1. Ensure that the yml file exists.

   ````shell
   ls smart.yml
   ````

1. Open the ymal file in a text editor.

   ````shell
   nano smart.yml
   ````

1. Change the replicaset setting in the yml file to 2. Search for the entry **replicas** and set the value to **2**.
1. Press CTRL+X, Y, ENTER to save the file and exit.
1. Create the deployment.

   ````shell
   kubectl create -f smart.yml
   ````

1. Check the current state of the deployment and pod.

   ````shell
   kubectl get deployment
   kubectl get pod
   ````

   Note: The pod should start very quickly since the image is already downloaded.

1. Get a list of your replica sets. Note the name.

   ````shell
   kubectl get rs
   ````

1. Change the number of replicas in your deployment.

   ````shell
   kubectl scale -–current-replicas=2 -–replicas=3 deployment/smartiis
   ````

1. Clean up your environment.

   ````shell
   kubectl delete deployment smartiis
   ````

[figure 1]: images/docker-images-id.png
[figure 2]: images/docker-images-tagged.png
[figure 3]: images/docker-network.png
[figure 4]: images/docker-ps-container-id.png
[figure 5]: images/docker-run-hello-world.png
