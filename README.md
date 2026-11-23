# Azure Healthcare Web Application

**Cloud infrastructure**: App Service · Virtual Network · Azure SQL Database
**Monitoring and analisis**: Azure Monitor · Network Watcher · Log Analytics · Wireshark
**Automation**: Bicep · Azure CLI · GitHub Actions (CI/CD)


## 1. Project Context

MediCore Health is a private clinic with a web portal hosted on a local server, where patients can explore medical specialties and book appointments. To simplify updates, scale resources based on demand, and improve service monitoring, the clinic has decided to move its infrastructure to Microsoft Azure.

Booking an appointment involves multiple network connections, protocols, and services. Connectivity issues, security problems, or database access failures can interrupt this process. The IT team needs to analyze end-to-end communications, identify the root cause of incidents, and verify that the issues have been resolved.


## 2. Project Objectives

1. Deploy and manage the resources needed to host a web application and its database.
2. Configure and validate DNS and network connectivity, manage TLS certificates, implement network segmentation, and control access.
3. Analyze an end-to-end transaction by capturing network traffic with Wireshark and examining the protocols involved in the communication.
4. Implement logs, metrics, traces, and alerts, and reproduce incidents to investigate their causes.
5. Automate application updates using CI/CD pipelines. Export Azure configurations to Bicep templates to deploy and remove infrastructure automatically, reducing costs.
6. Simulate high-demand periods through load testing, monitor response times and resource usage, and identify potential bottlenecks.


## 3. Architecture & Network Flow

![MediCore Health - Azure Architecture](./screenshot/medicore-web.png)

> Design of architecture of MediCore Health in Microsoft Azure

The architecture uses a Virtual Network (VNet) with four separate subnets:

- **appgw-subnet:** Hosts Application Gateway and Web Application Firewall (WAF).
- **app-int-subnet:** Enables outbound connections from App Service to private resources.
- **pe-subnet:** Provides private access to App Services, Azure SQL Database, and Key Vault through Private Endpoints.
- **diag-subnet:** Hosts a Linux VM for network traffic analysis and troubleshooting.


## 4. Deploy code without shut down the service

Use GitHub Actions to build, test, and deploy application changes.


## 5. Network Analysis & Troubleshooting




## 6. Simulate high-demand and indentify potential bottlenecks

Simulate concurrent appointment bookings and collect p95 response times, error rates, throughput, resource usage, and database dependency times. Investigate bottlenecks and repeat the test after a corrective change.


## 7. 




## 8. Resources

- Dignitae. AZ-104T00-A Microsoft Knowledge and Skills with Challenge Labs. Training material.<br>

- Microsoft. Course AZ-104T00-A: Microsoft Azure Administrator. Microsoft Learn.<br>
https://learn.microsoft.com/en-us/training/courses/az-104t00

- Microsoft. Training for Administrators. Microsoft Learn.<br> 
https://learn.microsoft.com/en-us/plans/50nrtozg28d354

- Microsoft. Configuración de una aplicación de App Service Microsoft Learn.<br>
https://learn.microsoft.com/en-us/azure/app-service/configure-common

- Microsoft. Secure your Azure App Service deployment Microsoft Learn.<br>
https://learn.microsoft.com/en-us/azure/app-service/overview-security

