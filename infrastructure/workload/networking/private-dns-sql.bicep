param privateDnsZones_privatelink_database_windows_net_name string = 'privatelink.database.windows.net'

param virtualNetworks_medicore_vnet_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-medicore-net/providers/Microsoft.Network/virtualNetworks/medicore-vnet'

resource privateDnsZones_privatelink_database_windows_net_name_resource 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDnsZones_privatelink_database_windows_net_name
  location: 'global'
  properties: {}
}

resource privateDnsZones_privatelink_database_windows_net_name_link_medicore_sql 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDnsZones_privatelink_database_windows_net_name_resource
  name: 'link-medicore-sql'
  location: 'global'
  properties: {
    registrationEnabled: false
    resolutionPolicy: 'Default'
    virtualNetwork: {
      id: virtualNetworks_medicore_vnet_externalid
    }
  }
}
