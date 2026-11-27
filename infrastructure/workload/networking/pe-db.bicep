param privateEndpoints_pe_db_name string = 'pe-db'

param servers_sql_medicore_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-medicore-app/providers/Microsoft.Sql/servers/sql-medicore'

param virtualNetworks_medicore_vnet_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-medicore-net/providers/Microsoft.Network/virtualNetworks/medicore-vnet'

param privateDnsZones_privatelink_database_windows_net_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-medicore-net/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net'

resource privateEndpoints_pe_db_name_resource 'Microsoft.Network/privateEndpoints@2025-09-01' = {
  name: privateEndpoints_pe_db_name
  location: 'spaincentral'
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpoints_pe_db_name
        properties: {
          privateLinkServiceId: servers_sql_medicore_externalid
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${privateEndpoints_pe_db_name}-nic'
    subnet: {
      id: '${virtualNetworks_medicore_vnet_externalid}/subnets/pe-subnet'
    }
    ipConfigurations: []
    customDnsConfigs: []
    ipVersionType: 'IPv4'
  }
}

resource privateEndpoints_pe_db_name_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-09-01' = {
  name: '${privateEndpoints_pe_db_name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZones_privatelink_database_windows_net_externalid
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints_pe_db_name_resource
  ]
}
