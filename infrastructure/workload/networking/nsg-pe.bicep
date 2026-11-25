param networkSecurityGroups_nsg_pe_name string = 'nsg-pe'

resource networkSecurityGroups_nsg_pe_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_pe_name
  location: 'spaincentral'
  properties: {
    securityRules: [
      {
        name: 'Allow-Gateway-HTTPS'
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.1.64/27'
          destinationAddressPrefix: '*'
          priority: 100
          description: 'allowed HTTPS to private endpoint '
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-Backend-HTTPS'
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.1.64/27'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'backend private endpoint allowed HTTPS traffic'
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-database-HTTPS'
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '10.0.1.64/27'
          destinationAddressPrefix: '*'
          priority: 120
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-Backend-KeyVault'
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.0.1.64/27'
          destinationAddressPrefix: '*'
          priority: 130
          description: 'Allow secure backend access to Azure Key Vault'
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}
