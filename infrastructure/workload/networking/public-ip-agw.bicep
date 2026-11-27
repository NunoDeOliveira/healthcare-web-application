param publicIPAddresses_public_ip_agw_name string = 'public-ip-agw'

resource publicIPAddresses_public_ip_agw_name_resource 'Microsoft.Network/publicIPAddresses@2025-09-01' = {
  name: publicIPAddresses_public_ip_agw_name
  location: 'spaincentral'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ddosSettings: {
      protectionMode: 'Disabled'
    }
  }
}
