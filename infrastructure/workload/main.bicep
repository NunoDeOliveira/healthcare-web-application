targetScope = 'subscription'

// Parameters
param resourceGroupLocation string = 'spaincentral'

param rgAppName string = 'rg-medicore-app'
param rgNetworkName string = 'rg-medicore-net'
param rgMonitorName string = 'rg-medicore-monitor'

// Sql parameter
@description('Enable Azure SQL deployment')
param deploySql bool = true

@secure()
@description('Azure SQL administrator password')
param sqlAdminPassword string = ''

// Tags parameters
param tagResourceGroup object = {
  Project: 'p01-web'
  Environment: 'Lab'
  Owner: 'IT'
  CostCenter: 'IT-001'
}


//=======================================//
// Resource Groups
//=======================================//

resource rgApp 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgAppName
  location: resourceGroupLocation
  tags: tagResourceGroup
}

resource rgNetwork 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgNetworkName
  location: resourceGroupLocation
  tags: tagResourceGroup
}

resource rgMonitor 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgMonitorName
  location: resourceGroupLocation
  tags: tagResourceGroup
}

//=======================================//
// Networking - Network Security Groups
//=======================================//

module nsgAppGw './networking/nsg-app-gw.bicep' = {
  name: 'deploy-nsg-app-gw'
  scope: rgNetwork
}

module nsgAppInt './networking/nsg-app-int.bicep' = {
  name: 'deploy-nsg-app-int'
  scope: rgNetwork
}

module nsgPe './networking/nsg-pe.bicep' = {
  name: 'deploy-nsg-pe'
  scope: rgNetwork
}

module nsgDiag './networking/nsg-diag.bicep' = {
  name: 'deploy-nsg-diag'
  scope: rgNetwork
}

//=======================================//
// Networking - Virtual Network
//=======================================//

module vnet './networking/vnet.bicep' = {
  name: 'deploy-medicore-vnet'
  scope: rgNetwork

  params: {
    location: resourceGroupLocation
  }

  dependsOn: [
    nsgAppGw
    nsgAppInt
    nsgPe
    nsgDiag
  ]
}

//=======================================//
// Networking - Private DNS Zone
//=======================================//

module privateDns './networking/private-dns-app.bicep' = {
  name: 'deploy-medicore-private-dns'
  scope: rgNetwork

  dependsOn: [
    vnet
  ]
}

module privateDnsSql './networking/private-dns-sql.bicep' = {
  name: 'deploy-medicore-private-dns-sql'
  scope: rgNetwork

  dependsOn: [
    vnet
  ]
}


//=======================================//
// Networking - Public IP
//=======================================//

module publicIpAgw './networking/public-ip-agw.bicep' = {
  name: 'deploy-public-ip-agw'
  scope: rgNetwork
}


//=======================================//
// Application - App Service Plan
//=======================================//

module appServicePlan './application/app-service-plan.bicep' = {
  name: 'deploy-app-service-plan'
  scope: rgApp

  params: {
    location: resourceGroupLocation
  }
}

//=======================================//
// Application - Frontend
//=======================================//

module frontend './application/app-service-frontend.bicep' = {
  name: 'deploy-medicore-frontend'
  scope: rgApp

  dependsOn: [
    appServicePlan
    vnet
  ]
}

//=======================================//
// Application - Backend
//=======================================//

module backend './application/app-service-backend.bicep' = {
  name: 'deploy-medicore-backend'
  scope: rgApp

  dependsOn: [
    appServicePlan
    vnet
  ]
}

//=======================================//
// Application - Azure SQL Database
//=======================================//

module azureSql './application/azure-sql.bicep' = if (deploySql) {
  name: 'deploy-medicore-sql'
  scope: rgApp

  params: {
    location: resourceGroupLocation
    administratorPassword: sqlAdminPassword
  }
}


//===========================================//
// Networking - Private endpoints
//============================================//

module peFrontend './networking/pe-frontend.bicep' = {
  name: 'deploy-pe-frontend'
  scope: rgNetwork
  dependsOn: [
    vnet
    frontend
    privateDns
  ]
}

module peBackend './networking/pe-backend.bicep' = {
  name: 'deploy-pe-backend'
  scope: rgNetwork
  dependsOn: [
    vnet
    backend
    privateDns
  ]
}

module peDb './networking/pe-db.bicep' = if (deploySql) {
  name: 'deploy-pe-db'
  scope: rgNetwork

  dependsOn: [
    vnet
    azureSql
    privateDnsSql
  ]
}


//=======================================//
// Networking - Application Gateway
//=======================================//

module applicationGateway './networking/app-gw.bicep' = {
  name: 'deploy-application-gateway'
  scope: rgNetwork
  
  params: {
    frontendFqdn: frontend.outputs.fqdn
    backendFqdn: backend.outputs.fqdn
  }

  dependsOn: [
    vnet
    publicIpAgw
    peFrontend
    peBackend
  ]
}






