# RFC0001 - Resource Naming #
Comments Due - 6/16/2017

## Resource Naming in OMS DSC High Quality Resource Module (HQRM) ##
For any PSDSC resource module that we develop, resource naming is one of the most important factors. One of the reasons being discover-ability of the resources in PowerShell Gallery.

The OMSDsc resource module will include resources for the following services.

1. Insights & Analytics
1. Automation & Control
1. Protection & Recovery

Within each of these service categories, there are several resources that are planned. For example: 

- Insights & Analytics
    - OMS Agent Install
    - OMS Workspace registration (Direct monitoring)
    - OMS Agent Proxy configuration (Direct Monitoring)
    - OMS Agent SCOM on-boarding
    - OMS Gateway Install
    - OMS Gateway Proxy Configuration
    - OMS HTTP Log Collector
- Automation & Control
    - AA DSC on-prem onboarding
    - Hybrid Runbook Worker Configuration
- Protection & Recovery
    - Recovery Services Agent Install
    - Recovery Services Agent Registration
    - Recovery Services Agent Proxy Configuration
    - Backup Schedule Configuration
    - Microsoft Azure Backup Server install
    - Microsoft Azure Backup Server registration
    - Microsoft Azure Backup Server Proxy Configuration
    - Microsoft Azure Backup Server Storage Configuration
    - Microsoft Azure Backup Server Agent Install
    - Microsoft Azure Backup Server Agent Configuration
    - Site Recovery Unified Server Install
    - Site Recovery Configuration Server Install
    - Site Recovery Process Server Install
    - Site Recovery Server Registration
    - Site Recovery Server Proxy Configuration
    - Site Recovery Provider install
    - Site Recovery Provider Registration
    - Site Recovery Provider Proxy

This is just the initial list that I have been working on and there are several other possibilities. 

***NOTE: This RFC is not about a wish list of resources in this module.***

Now, for each of these above configuration items, we need proper naming.

## Resource Naming Proposal ##
Since there are three categories of resources, here is what I am proposing.

### Insights & Analytics ###
For all resources in the Insights & Analytics category, use **LA** as the resource prefix. This refers to Log Analytics.

1. LAAgentInstall
1. LAAgentRegistration
1. LAAgentProxy
1. LAAgentSCOMConnection
1. LAGatewayInstall
1. LAGatewayProxyConfiguration
1. LAHTTPLogCollector

### Automation & Control ###
For all resources in the Automation & Control category, use **AA** as the resource prefix. This refers to Azure Automation.

1. AADSCRegistration
1. AAHybridRunbookWorkerConfiguration

### Protection & Recovery ###
For all resources in the protection category of Protection & Recovery, use **RS** as the prefix. This refers to Recovery Services.

1. RSAgentInstall
1. RSAgentRegistration
1. RSAgentProxy
1. RSBackupSchedule

For all resources related to Microsoft Azure Backup Server in the protection category of Protection & Recovery, use **MABS** as the prefix.

1. MABSInstall
1. MABSRegistration
1. MABSProxy
1. MABSStorage
1. MABSAgentInstall
1. MABSAgentConfiguration

For all resources in the recovery category of Protection & Recovery, use **SR** as the prefix. This refers to Site Recovery.

1. SRUnifiedServerInstall
1. SRConfigurationServerInstall
1. SRProcessServerInstall
1. SRServerRegistration
1. SRServerProxy
1. SRProviderInstall
1. SRProviderRegistration
1. SRProviderProxy

For all comments and feedback, use the issue #1.