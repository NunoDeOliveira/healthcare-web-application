param networkSecurityGroups_nsg_app_int_name string = 'nsg-app-int'

resource networkSecurityGroups_nsg_app_int_name_resource 'Microsoft.Network/networkSecurityGroups@2025-09-01' = {
  name: networkSecurityGroups_nsg_app_int_name
  location: 'spaincentral'
  properties: {
    securityRules: []
  }
}
