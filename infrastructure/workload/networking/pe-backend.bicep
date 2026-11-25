param privateEndpoints_pe_backend_name string = 'pe-backend'
param location string = 'spaincentral'

param backendName string = 'medicore-backend'
param appResourceGroupName string = 'rg-medicore-app'

param vnetName string = 'medicore-vnet'
param subnetName string = 'pe-subnet'

param privateDnsZoneName string = 'privatelink.azurewebsites.net'

// Existing App Service
resource backend 'Microsoft.Web/sites@2024-11-01' existing = {
  name: backendName
  scope: resourceGroup(appResourceGroupName)
}

// Existing Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' existing = {
  name: vnetName
}

// Existing Private DNS Zone
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: privateDnsZoneName
}

// Private Endpoint
resource privateEndpoints_pe_backend_name_resource 'Microsoft.Network/privateEndpoints@2025-09-01' = {
  name: privateEndpoints_pe_backend_name
  location: location

  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoints_pe_backend_name
        properties: {
          privateLinkServiceId: backend.id
          groupIds: [
            'sites'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${privateEndpoints_pe_backend_name}-nic'
    subnet: {
      id: '${vnet.id}/subnets/${subnetName}'
    }
    ipConfigurations: []
    customDnsConfigs: []
    ipVersionType: 'IPv4'
  }
}

// Private DNS Integration
resource privateEndpoints_pe_backend_name_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-09-01' = {
  parent: privateEndpoints_pe_backend_name_resource
  name: 'default'

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
