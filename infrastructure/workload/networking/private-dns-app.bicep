param privateDnsZones_privatelink_azurewebsites_net_name string = 'privatelink.azurewebsites.net'
param vnetName string = 'medicore-vnet'

// Existing Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' existing = {
  name: vnetName
}

// Private DNS Zone
resource privateDnsZones_privatelink_azurewebsites_net_name_resource 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZones_privatelink_azurewebsites_net_name
  location: 'global'
}

// Virtual Network Link
resource privateDnsZones_privatelink_azurewebsites_net_name_link_medicore_vnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZones_privatelink_azurewebsites_net_name_resource
  name: 'link-medicore-vnet'
  location: 'global'

  properties: {
    registrationEnabled: false
    resolutionPolicy: 'Default'
    virtualNetwork: {
      id: vnet.id
    }
  }
}
