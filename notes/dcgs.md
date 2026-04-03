# DCGS Background

[Air Force Fact Sheet](https://www.af.mil/About-Us/Fact-Sheets/Display/Article/104525/air-force-distributed-common-ground-system/)

Also known as AN/GSQ-272 SENTINEL. It is the Air Force's primary ISR analysis and exploitation system connecting intel units assigned to 16th Air Force Air Combat Command to multi-int platforms, sensors, and sites to produce and disseminate actionable intelligence.

# Robins Tech Day

Brian said:
- Non-technical audience
- Likes buzzwords

Ned working on:
- Timeslot
- Audience expectations

Other presenters:
- HashiCorp
- Chainguard
- Dell
- Elastic

Listed topic:
- Container orchestration within ABMS

## ABMS - Deployable Digital Infrastructure

"Advanced Battlefield Management System"

Leidos prime contractor
- <https://www.leidos.com/insights/us-air-force-selects-leidos-abms-digital-infrastructure-consortium>
- <https://www.leidos.com/insights/department-air-force-selects-leidos-oversee-its-advanced-battle-management-system-digital>

Associated SIs in Zendesk:
- Leidos
- L3Harris
- RTX
- NGC
- SAIC

## Meet w/ Chris

Frequent leadership changes

Contractors come and go

Funding gets lost

Daft Cloudworks
- Friction because they felt we were trying to supplant them

Were focused on zero trust then stopped caring

Interested in GitOps to manage cluster lifecycles

Interested in lifecycle management automation in general

Hybrid/cloud/self-hosted stuff similar to ABMS FDI/DDI

Figure out how to pitch without insulting other vendors

DO NOT use the word "consultant" because it has become a government dirty word, funding taking away from consulting engagements

Focus on engineering instead

[https://afresearchlab.com/cloudworks/](DAF Cloudworks)

## Proposed SOW from last May

### 2.1 Project Specific Goals and Activities

This engineering engagement will embed Rancher Government Solutions (RGS) engineers with the DCGS team to build a modernized platform, with a focus on encouraging innovation related to geospatial capabilities, Kubernetes, and containerization that directly affect OA DCGS integration efforts and mission support requirements. RGS will provide 1920 labor hours for each Level-2 RGS resource to support the following goals and objectives, at the direction of ACC and/or AF DCGS SPO staff.

#### Project Specific Goals

This section outlines the key objectives and desired outcomes for the modernization of the DCGS platform. The successful completion of this project will achieve the following:
- Modernize the DCGS Platform: Transform the existing DCGS platform into a contemporary, agile, and resilient infrastructure capable of supporting evolving operational requirements.
- Establish a Robust Rancher Government Solutions Stack: Implement a comprehensive and integrated technology stack, leveraging Harvester for hyperconverged infrastructure, Rancher for Kubernetes management, RKE2 for secure Kubernetes distribution, Longhorn for persistent storage, Fleet for GitOps at scale, and Neuvector for container security.
- Enable Hybrid and Disconnected Operations: Develop a platform architecture that seamlessly supports both connected and disconnected operational environments, extending capabilities across on-premise deployments and various cloud infrastructures.
- Facilitate Converged Workload Management: Create a unified platform that efficiently hosts and manages traditional virtual machine (VM) workloads alongside modern Kubernetes containerized applications, maximizing resource utilization and operational flexibility.
- Leverage Proven Architectural Patterns: Design and implement the platform by modeling it after the successful ABMS DDI (Dynamic Digital Infrastructure and FDI (Fixed Digital Infrastructure) harvester-based platforms, ensuring a robust, scalable, and secure foundation for future growth.


## Possible talking points

- [RGS HCI at the Edge Whitepaper](https://fcnit.com/wp-content/uploads/2024/07/RGS_HCI-at-the-Edge-Whitepaper_2024_Jet.pdf)
- [Modern Alternative to VMware Whitepaper](https://fcnit.com/wp-content/uploads/2024/07/A-Modern-Alternative-to-VMware-White-Paper.pdf)

Alignment between DOW/EO regarding container security, supply chain provenance, zero trust, and what we offer.

DCGS currently uses rke2 from RGS but nothing else from our suite.

Bringing Infrastructure as Code and automation to small form factor, unconventional computing hardware in DDIL environments. Kubernetes API enables using the exact same method to define and deploy both the platform and the applications that run on it.

Contrast API-driven cloud solutions, ease of scaling, ease of deployment, with tactical edge, frequently involving tight coupling between hardware and software and highly technical operator requirements. Our goal is to bring the former to the latter.

Ability to run AI inference at the edge, orchestrating GPU workloads without requiring external network connection.

Security features w/ subscription, including compliance operator, STIG profiles, Kubewarden/Neuvector. Traditional malware and vulnerability scanning tools rely upon heavyweight host agents that require frequent online updating and consume large amounts of host resources. These produce reams of false positives on hosts running containerized workloads, wasting platform engineer and security engineer time.

Emphasize that we have HCI at all, enabling the gradual transition from virtualized to containerized workloads, allowing them to run side-by-side on the same platform.

Full SBOM review of all subcomponents of HCI/MCM by DOW. Emphasize features of the SSF. Dynamic, static, and behavioral analysis passed. Talk about dangers of open source (xz) and importance of known provenance.

Immutable OS, revision history in Kubernetes, declarative API. Ease of recreating an environment and having visibility into it.

Tell a story.

DI2E, S2P, Pipeline-in-a-box, Big Bang.

## Zero Trust Architecture

[NIST SP 800-207](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-207.pdf)


## Narrative

### History

#### Challenges to address

Traditionally, software for defense and intelligence was proprietary, custom, and secret, purpose-built separately for each activity, usually by a single, large vendor. This presented many challenges:
- Little to no sharing or reuse of code
- Developers needed clearances and needed to live near a facility where classified development could take place
- Bespoke tooling, standards, and processes had to be learned as part of onboarding
- The traditional big five, Lockheed, Raytheon, Northrop Grumman, General Dynamics, and Boeing, had de facto monopolies in their areas of specialty

All of this meant development was slow and expensive, creating systems that were difficult to change or extend.

Meanwhile, startups of the late 90s that would become today's hyperscalers were taking a different approach. Google published all of its research. The Chrome web browser used the Chromium open core. Android used Linux as its kernel. Facebook was built on the LAMP stack that used to come included with an admin panel when renting a VPS. Amazon built AWS on top of Xen, an open source virtualization platform. With the death of proprietary Unixes, Linux become the dominant server operating system.

#### How to address

In 2018, the DODCIO sent out a memo directing the department to use open source and commercial off-the-shelf technologies as much as possible
