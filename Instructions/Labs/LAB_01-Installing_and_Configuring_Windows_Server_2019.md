# Lab 1 - Installing and Configuring Windows Server 2019

Required VMs: DC1, DHCP, HV1, Router

## Exercise 1: Authoring an Unattend.xml File

### Introduction

In this exercise, you prepare an Unattend.xml file to automate the deployment of Windows Server 2019.

### Tasks

1. Author an Unattend.xml file using Windows System Image Manager

### Detailed Instructions

#### Task 1:  Install Windows System Image Manager

Perform these steps on **HV1**.

1. Open Windows Explorer
1. Navigate to **L:\ADK**
1. Launch **adksetup.exe**.
1. On the **Specify a location** page, click on **Next**.
1. On the **Windows Kits privacy** page, click on **Next**.
1. Click on **Accept**.
1. On the **Select the features you want to install** page, clear the checkboxes beside all components. Select the checkbox beside **Deployment tools**.
![Clear the checkboxes beside all components. Select the checkbox beside **Deployment tools**.][Select the features you want to install]
1. Click on **Install** and wait for the install to complete. Then, click on **Close**.

[Select the features you want to install]: images/figure01.png
