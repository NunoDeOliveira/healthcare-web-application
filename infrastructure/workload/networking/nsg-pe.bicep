param networkSecurityGroups_nsg_pe_name string = 'nsg-pe'

resource networkSecurityGroups_nsg_pe_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_pe_name
  location: 'spaincentral'

  properties: {
    securityRules: [
      {
        name: 'Allow-Gateway-HTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.0.0/24'
          destinationAddressPrefix: '*'
          description: 'Allow Application Gateway to access App Service private endpoints'
        }
      }
      {
        name: 'Allow-Backend-SQL'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.1.0/26'
          destinationAddressPrefix: '*'
          description: 'Allow backend subnet to access Azure SQL private endpoint'
        }
      }
    ]
  }
}
