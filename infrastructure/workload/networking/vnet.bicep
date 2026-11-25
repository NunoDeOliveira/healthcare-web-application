param vnetName string = 'medicore-vnet'
param location string = 'spaincentral'

param nsgAppGwName string = 'nsg-app-gw'
param nsgAppIntName string = 'nsg-app-int'
param nsgPeName string = 'nsg-pe'
param nsgDiagName string = 'nsg-diag'

// Reference existing Network Security Groups
resource nsgAppGw 'Microsoft.Network/networkSecurityGroups@2025-09-01' existing = {
  name: nsgAppGwName
}

resource nsgAppInt 'Microsoft.Network/networkSecurityGroups@2025-09-01' existing = {
  name: nsgAppIntName
}

resource nsgPe 'Microsoft.Network/networkSecurityGroups@2025-09-01' existing = {
  name: nsgPeName
}

resource nsgDiag 'Microsoft.Network/networkSecurityGroups@2025-09-01' existing = {
  name: nsgDiagName
}

// Virtual Network
resource medicoreVnet 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: vnetName
  location: location

  tags: {
    Project: 'p01-web'
    Environment: 'Lab'
    Owner: 'IT'
    CostCenter: 'IT-001'
  }

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    encryption: {
      enabled: false
      enforcement: 'AllowUnencrypted'
    }

    privateEndpointVNetPolicies: 'Disabled'

    subnets: [
      {
        name: 'app-gw-subnet'
        properties: {
          addressPrefixes: [
            '10.0.0.0/24'
          ]
          networkSecurityGroup: {
            id: nsgAppGw.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
      {
        name: 'app-int-subnet'
        properties: {
          addressPrefixes: [
            '10.0.1.0/26'
          ]
          networkSecurityGroup: {
            id: nsgAppInt.id
          }
          delegations: [
            {
              name: 'app-service-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
              type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
      {
        name: 'pe-subnet'
        properties: {
          addressPrefixes: [
            '10.0.1.64/27'
          ]
          networkSecurityGroup: {
            id: nsgPe.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'NetworkSecurityGroupEnabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
      {
        name: 'diag-subnet'
        properties: {
          addressPrefixes: [
            '10.0.1.96/28'
          ]
          networkSecurityGroup: {
            id: nsgDiag.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          defaultOutboundAccess: false
        }
      }
    ]

    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
