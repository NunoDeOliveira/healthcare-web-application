param networkSecurityGroups_nsg_diag_name string = 'nsg-diag'

resource networkSecurityGroups_nsg_diag_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_diag_name
  location: 'spaincentral'
  properties: {
    securityRules: []
  }
}
