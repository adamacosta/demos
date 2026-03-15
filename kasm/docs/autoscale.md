# Harvester AutoScale

```{contents} Table of Contents
:depth: 3
:local:
```

This guide will walk you through configuring autoscaling for Kasm Workspaces on Harvester. Autoscaling in Kasm Workspaces automatically provisions and destroys agents based on user demand, ensuring optimized resource utilization and cost efficiency.

```{raw} html
<iframe src="https://www.youtube.com/embed/MOpXTFfQU4I?si=_Elq4EAQQ6HOZZYM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
```

## Prerequisites

* Access to Harvester: Ensure you have admin access to your Harvester environment
* Kasm Workspaces Installed: A basic setup of Kasm Workspaces must already exist
* Understand Key Concepts:
  * **Zones**: Logical groupings of Kasm services for geographical or organizational segmentation
  * **Pools**: Logical groupings of Kasm Docker Agents and Server Pools for load balancing
* Plan Your Configuration:
  * Understand your deployment zone requirements
* Configure your Harvester environment:
  * Create a namespace for your autoscale deployment
  * Create a VM network in the new namespace for your agents to use and attach it to a cluster network
  * Create template images in the new namespace for AutoScale to use


## Setup your Harvester Environment


### Download KubeConfig

The KubeConfig YAML file can be downloaded from the Support link on the Harvester dashboard and contains key information you will need to configure autoscaling on Kasm.
  ```{figure} /images/autoscaling/providers/harvester/harvester_download_kubeconfig.png
  :align: center
  **Download KubeConfig YAML file from Harvester**
  ```

### Create Namespace

Go to "Namespaces" -> "Create" to create a new namespace in Harvester. Give it a name like `kasm-autoscale`
```{figure} /images/autoscaling/providers/harvester/harvester_create_namespace.png
:align: center
**Create namespace in Harvester**
```

### Create Network

Go to "Virtual Machine Networks" -> "Create" to create a new VM network.
  - Make sure you select the right namespace
  - Give the network a name like `kasm-autoscale`
  - Choose the Type as `Untagged Network`
  - Choose the `mgmt` Cluster Network
  ```{figure} /images/autoscaling/providers/harvester/harvester_create_network.png
  :align: center
  **Create VM network in Harvester**
  ```

### Create VM template

```{eval-rst}
Create the appropriate VM template based on whether you are implementing Server AutoScaling or Docker AutoScaling on Proxmox.
  * For Windows AutoScaling, follow the :ref:`Windows Templating Guide<harvester-windows-templating>`
  * For Docker Agent AutoScaling, follow the :ref:`Linux Templating Guide<harvester-linux-templating>`
```

(harvester-linux-templating)=
#### Linux Templating

Creating a Linux template in Harvester is pretty straightforward. 
- Go to "Images" -> "Create"
- Choose the correct namespace that you created earlier.
- Choose a name for your image (e.g jammy-server-cloudimg-amd64.img). This name needs to be fed to Kasm later.
- Select "URL". You can also choose "File" if you want to upload an ISO file instead. You can either install your Linux distro (make sure you choose from the [supported list of operating systems](https://kasmweb.com/docs/latest/install/system_requirements.html#operating-system)) from scratch with an installation ISO or use a pre-configured ISO like a cloud image. In this demo, we'll use the later.
- Enter the URL from where you want Harvester to download the image (e.g https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img)
  ```{figure} /images/autoscaling/providers/harvester/harvester_upload_img.png
  :align: center
  **Upload Linux Image in Harvester**
  ```
- Click "Create". This will download the VM to Harvester from the provided URL
- Optionally, you can pre-load workspace images on your autoscaled agent VMs so that workspaces launch instantly after provisioning, without waiting for Kasm to pull the necessary Docker images. Read the {doc}`Pre-load Workspace Images on Agents guide <../preload_images_on_agents>` to learn more
- You also need to install the QEMU Guest Agent tools on the agent. Read the section titled "Updated Startup Scripts" on the page {doc}`Kasm Autoscale Startup Scripts <../../../guide/compute/vm_providers>` for more information; in the provided script, the lines that run the qemu installation will need to be uncommented


(harvester-windows-templating)=
#### Windows Templating

For an overview of Windows templating and its prerequisites, refer to the {doc}`Windows AutoScale Template Creation Guide <../windows_autoscale_templates>`.

Creating a Windows Template involves additional steps and is not as straightforward as Linux templating.
- Go to "Images" -> "Create"
- Choose the correct namespace that you created earlier.
- Choose a name for your image (e.g windows-server-2022)
- Choose "File" and click "Upload File" to upload the Windows ISO file. As an example, you can download Windows Server 2022 from [here](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022). You can also choose "URL" and input the URL from where the ISO file can be downloaded.
  ```{figure} /images/autoscaling/providers/harvester/harvester_upload_img_windows.png
  :align: center
  **Upload Windows Image in Harvester**
  ```
- Wait for the ISO file to be uploaded.
- Similarly, you also need to upload the VirtIO tools image. Go to "Images" -> "Create"
- Select "File" -> "Upload File" to upload the ISO file. You can download the VirtIO files from [here](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.266-1/)
- Go to "Virtual Machines" -> "Create"
- Select the correct namespace
- Give a name for your VM (e.g windows-server-2022-kasm-autoscale)
- Set the number of cores and memory.
  ```{figure} /images/autoscaling/providers/harvester/harvester_create_windows_vm1.png
  :align: center
  **Create a Windows VM in Harvester**
  ```
- Go to the "Volumes" tab and add the following volumes:
  * **Volume 1**
    * In the default volume, Set "Image" to the Windows ISO you uploaded earlier
    * Set "Type" to `cd-rom`
    * Set "Bus" to `SATA`
    ```{figure} /images/autoscaling/providers/harvester/harvester_windows_vm_volume1.png
    :align: center
    **Add Windows ISO disk**
    ```
  * **Volume 2**
    * Click "Add a Virtual Machine Image" 
    * Set the "Image" to the VirtIO ISO you uploaded earlier
    * Set "Type" to `cd-rom`
    * Set "Bus" to `SATA`
    ```{figure} /images/autoscaling/providers/harvester/harvester_windows_vm_volume2.png
    :align: center
    **Add VirtIO ISO disk**
    ```
  * **Volume 3**
    * Click "Add Volume"
    * Set "Type" to `disk`
    * Set "Storage Class" to `harvester-longhorn (Default)`
    * Set Size to anything more than 40GB. This will be your Windows boot disk. 
    * Set "Bus" to `VirtIO`
    ```{figure} /images/autoscaling/providers/harvester/harvester_windows_vm_volume3.png
    :align: center
    **Add Windows Boot Volume**
    ```
- Go to "Networks"
- Change the default network like this,
  * Name: You can let this be `default`
  * Model: Set this to `virtio`
  * Network: Set this to the network you created earlier
  * Type: Set to `bridge`
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_vm_network.png
  :align: center
  **Create VM network**
  ```
- Once the VM is provisioned, open it in WebVNC
- You will now see the Windows Installation screen. Proceed with the Installation.
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install1.png
  :align: center
  **Windows Installation screen**
  ```
- By default, you may not be able to see the list of available disks to install Windows. To fix this, you need to install the VirtIO SCSI controller. Click "Load driver" and install the appropriate driver.
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install2.png
  :align: center
  **Load Driver to install VirtIO tools**
  ```

  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install3.png
  :align: center
  **Install the appropriate VirtIO SCSI contoller**
  ```
- The available disks must now be listed and you can choose the Windows boot disk you created to install Windows. 
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install4.png
  :align: center
  **Install Windows**
  ```
- Once Windows is installed, you need to install the other VirtIO drivers like the Network driver. Simply navigate to your VirtIO disk from your File Explorer and install the drivers by running the installer.
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install5.png
  :align: center
  **Install VirtIO drivers**
  ```
- You also need to install the QEMU Guest Agent tools. These can be found in the same VirtIO drive in the `guest-agent` folder.
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install6.png
  :align: center
  **Install QEMU Guest Agent**
  ```
- [Cloudbase-Init](https://cloudbase.it/cloudbase-init/#download) is also required so Kasm can run the startup script when the Windows VM is provisioned. Simply download the [installer](https://cloudbase.it/cloudbase-init/#download) and run it to install Cloudbase-init. 
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install7.png
  :align: center
  **Install Cloudbase-Init**
  ```
- You can now install the tools/software you'd like to have on your VM (e.g Microsoft Office)
- Finally, you need to enable RDP on your VM. This is required so that Kasm can utilize RDP to create Windows Sessions. Simply search for "Remote Desktop Settings" and enable Remote Desktop
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_install8.png
  :align: center
  **Enable RDP**
  ```
- Shutdown the VM
- Edit the VM config, and go to "Volumes". Remove the attached Windows ISO and VirtIO ISO. 
- Now, go back to "Virtual Machines" and generate a template from the created VM.
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_generate_template1.png
  :align: center
  **Generate Template**
  ```
- Give your template a name (e.g windows-server-2022-kasm-template)
- Make sure you select "With Data" and click "Create"
  ```{figure} /images/autoscaling/providers/harvester/harvester_windows_generate_template2.png
  :align: center
  **Generate Template**
  ```
- This will generate the template from your Windows VM. 

For more details about Windows Templating, refer to the {doc}`Windows AutoScale Template Creation Guide <../windows_autoscale_templates>`

## Configure VM Provider Details on Kasm

```{eval-rst}
* Follow :ref:`autoscale_docker_config` or :ref:`autoscale_server_config` to create to create a new AutoScale config, or select **Create New** in **VM Provider Configs** if you already have one.
* Set Provider to Harvester
* Configure the following settings:
```

```{include} /guide/compute/vm_providers/harvester.md
```

  * Submit the Provider Config

(harvester-disk-image)=
### Disk Image

It is important to correctly specify the disk image name so that Kasm can instruct Harvester to provision a VM based on that image.
- If you are not using a custom template and want to use a pre-configured Cloud image directly (typically for Linux VMs), go to "Images" and copy the image name listed under the correct namespace.
  ```{figure} /images/autoscaling/providers/harvester/harvester_disk_image1.png
  :align: center
  **Get Disk Image Name from Images**
  ```
- If you are using a custom template (such as the Windows VM template we created earlier), you need to correctly identify the disk image associated with that template.
Go to "Advanced" -> "Templates" -> Select the template you want to use, then navigate go to the "Volumes" tab. Here, you can find the image name of the template (no need to include the namespace name). In the screenshot below, the correct disk image to input in Kasm is `templateversion-windows-server-2022-template-new-6l846-image-0`
  ```{figure} /images/autoscaling/providers/harvester/harvester_disk_image2.png
  :align: center
  **Get Template Disk Image**
  ```

## Test your Harvester Autoscaling setup

If you have configured non-zero Standby/Minimum Available Session values agents should start provisioning immediately. Otherwise, try launching multiple workspaces to increase resource utilization, prompting Kasm to autoscale new agents.
* Provision a Workspace
  * Go to Workspaces > Registry
  * Make multiple workspaces available
* Go to the Workspaces dashboard and launch sufficient workspace sessions to exceed your resource standby thresholds
* Monitor the provisioning of new agents by going to "Infrastructure" -> "Agents"
* Verify new VM instances in Proxmox
* Check Downscaling
  * Terminate sessions to reduce resource usage
  * Confirm that Kasm removes agents after the back-off period