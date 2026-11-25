param networkSecurityGroups_nsg_app_gw_name string = 'nsg-app-gw'

resource networkSecurityGroups_nsg_app_gw_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_app_gw_name
  location: 'spaincentral'
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          priority: 100
          description: 'Allow HTTPS client traffic'
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
        name: 'Allow-GatewayManager'
        properties: {
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          priority: 110
          description: 'Allow Azure gateway management'
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
