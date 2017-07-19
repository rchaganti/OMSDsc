[![Stories in Ready](https://badge.waffle.io/rchaganti/OMSDsc.png?label=ready&title=Ready)](https://waffle.io/rchaganti/OMSDsc?utm_source=badge)
# OMSDsc #
PowerShell Desired State Configuration resource module for managing Microsoft Operations Management Suite service configuration on Windows Endpoints.

Microsoft OMS includes the following four offerings:
- [Insight & Analytics](https://www.microsoft.com/en-in/cloud-platform/insight-and-analytics)
- [Automation & Control](https://www.microsoft.com/en-in/cloud-platform/automation-and-control) 
- [Protection & Recovery](https://www.microsoft.com/en-in/cloud-platform/protection-and-recovery)
- [Security & Compliance](https://www.microsoft.com/en-in/cloud-platform/security-and-compliance)

These offerings in Microsoft OMS enable hybrid cloud management and extend Azure services such as data protection and disaster recovery, Azure Automation Runbooks and DSC, and Log & event collection and analysis.

This soon-to-be-released PowerShell DSC resource module includes resource modules that enable automated configuration on-premises integration with OMS.

Here is a list of resources that I have been working on.

| Resource Name  | Description | Status in the repository |
| -------------   | ------------- | ------- |
|LAAgent| Install and upgrade Log Analytics Agent| [Available without tests](https://github.com/rchaganti/OMSDsc/tree/dev/DSCResources/LAAgent)|
|LAAgentConfiguration| Helps enable/disable AD integration and/or local collection. | [Available without tests.](https://github.com/rchaganti/OMSDsc/tree/dev/DSCResources/LAAgentConfiguration)| 
|LAAgentRegistration| Helps register LA agent with OMS workspace(s).|[Available without tests.](https://github.com/rchaganti/OMSDsc/tree/dev/DSCResources/LAAgentRegistration)|
|LAAgentProxy| Helps configure proxy for the LA agent. | [Available without tests](https://github.com/rchaganti/OMSDsc/tree/dev/DSCResources/LAAgentProxy)|
