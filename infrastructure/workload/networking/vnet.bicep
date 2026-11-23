// =====================================================================
// MediCore Health - Virtual Network
// Resource Group: rg-medicore-net
// Region: Spain Central
// =====================================================================

param vnetName string = 'medicore-vnet'
param location string = resourceGroup().location

param resourceTags object = {
  Project: 'p01-web'
  Environment: 'Lab'
  Owner: 'IT'
  CostCenter: 'IT-001'
}

// ==============================================================
// 1. Virtual network
// ==============================================================

resource vnet 'Microsoft.Network/virtualNetworks@2025-09-01' = {
  name: vnetName
  location: location
  tags: resourceTags

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
    enableDdosProtection: false
  }
}

// =============================================================================
// 2. Application gateway subnet
// =============================================================================

resource appGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  parent: vnet
  name: 'app-gw-subnet'

  properties: {
    addressPrefixes: [
      '10.0.0.0/24'
    ]

    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
}

// ==============================================================================
// 3. App Service VNet integration subnet
// ==============================================================================

resource appIntSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  parent: vnet
  name: 'app-int-subnet'

  properties: {
    addressPrefixes: [
      '10.0.1.0/26'
    ]

    delegations: [
      {
        name: 'app-service-delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]

    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
}

// ==========================================================================
// 4. Private Endpoints Subnet
// ==========================================================================

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  parent: vnet
  name: 'pe-subnet'

  properties: {
    addressPrefixes: [
      '10.0.1.64/27'
    ]

    privateEndpointNetworkPolicies: 'NetworkSecurityGroupEnabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
}

// ============================================================================
// 5. Diagnostic Subnet
// ==============================================================================

resource diagSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-09-01' = {
  parent: vnet
  name: 'diag-subnet'

  properties: {
    addressPrefixes: [
      '10.0.1.96/28'
    ]

    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    defaultOutboundAccess: false
  }
}

// ==========================================================
// 6. Outputs
// ==========================================================

output vnetId string = vnet.id
output appGwSubnetId string = appGwSubnet.id
output appIntSubnetId string = appIntSubnet.id
output peSubnetId string = peSubnet.id
output diagSubnetId string = diagSubnet.id
