param applicationGateways_app_gw_name string = 'app-gw'

param virtualNetworks_medicore_vnet_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-medicore-net/providers/Microsoft.Network/virtualNetworks/medicore-vnet'

param publicIPAddresses_ip_agw_medicore_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/rg-medicore-net/providers/Microsoft.Network/publicIPAddresses/public-ip-agw'

param frontendFqdn string
param backendFqdn string

var appGatewayId = resourceId('Microsoft.Network/applicationGateways', applicationGateways_app_gw_name)

resource applicationGateways_app_gw_name_resource 'Microsoft.Network/applicationGateways@2025-09-01' = {
  name: applicationGateways_app_gw_name
  location: 'spaincentral'

  zones: [
    '1'
    '2'
    '3'
  ]

  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_1'
    }

    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${appGatewayId}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_medicore_vnet_externalid}/subnets/app-gw-subnet'
          }
        }
      }
    ]

    sslCertificates: []
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []

    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        id: '${appGatewayId}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_ip_agw_medicore_externalid
          }
        }
      }
    ]

    frontendPorts: [
      {
        name: 'port_80'
        id: '${appGatewayId}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
    ]

    backendAddressPools: [
      {
        name: 'pool-frontend'
        id: '${appGatewayId}/backendAddressPools/pool-frontend'
        properties: {
          backendAddresses: [
            {
              fqdn: frontendFqdn
            }
          ]
        }
      }
      {
        name: 'pool-backend'
        id: '${appGatewayId}/backendAddressPools/pool-backend'
        properties: {
          backendAddresses: [
            {
              fqdn: backendFqdn
            }
          ]
        }
      }
    ]

    loadDistributionPolicies: []

    backendHttpSettingsCollection: [
      {
        name: 'settings-frontend'
        id: '${appGatewayId}/backendHttpSettingsCollection/settings-frontend'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: frontendFqdn
          pickHostNameFromBackendAddress: false
          dedicatedBackendConnection: false
          validateCertChainAndExpiry: true
          validateSNI: true
          requestTimeout: 20
          probe: {
            id: '${appGatewayId}/probes/probe-frontend'
          }
        }
      }
      {
        name: 'settings-backend'
        id: '${appGatewayId}/backendHttpSettingsCollection/settings-backend'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: backendFqdn
          pickHostNameFromBackendAddress: false
          dedicatedBackendConnection: false
          validateCertChainAndExpiry: true
          validateSNI: true
          requestTimeout: 20
          probe: {
            id: '${appGatewayId}/probes/probe-backend'
          }
        }
      }
    ]

    backendSettingsCollection: []

    httpListeners: [
      {
        name: 'listener-http'
        id: '${appGatewayId}/httpListeners/listener-http'
        properties: {
          frontendIPConfiguration: {
            id: '${appGatewayId}/frontendIPConfigurations/appGwPublicFrontendIpIPv4'
          }
          frontendPort: {
            id: '${appGatewayId}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]

    listeners: []

    urlPathMaps: [
      {
        name: 'rule-medicore'
        id: '${appGatewayId}/urlPathMaps/rule-medicore'
        properties: {
          defaultBackendAddressPool: {
            id: '${appGatewayId}/backendAddressPools/pool-frontend'
          }
          defaultBackendHttpSettings: {
            id: '${appGatewayId}/backendHttpSettingsCollection/settings-frontend'
          }
          pathRules: [
            {
              name: 'path-api'
              id: '${appGatewayId}/urlPathMaps/rule-medicore/pathRules/path-api'
              properties: {
                paths: [
                  '/api/*'
                ]
                backendAddressPool: {
                  id: '${appGatewayId}/backendAddressPools/pool-backend'
                }
                backendHttpSettings: {
                  id: '${appGatewayId}/backendHttpSettingsCollection/settings-backend'
                }
              }
            }
          ]
        }
      }
    ]

    requestRoutingRules: [
      {
        name: 'rule-medicore'
        id: '${appGatewayId}/requestRoutingRules/rule-medicore'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 100
          httpListener: {
            id: '${appGatewayId}/httpListeners/listener-http'
          }
          urlPathMap: {
            id: '${appGatewayId}/urlPathMaps/rule-medicore'
          }
        }
      }
    ]

    routingRules: []

    probes: [
      {
        name: 'probe-frontend'
        id: '${appGatewayId}/probes/probe-frontend'
        properties: {
          protocol: 'Https'
          host: frontendFqdn
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          enableProbeProxyProtocolHeader: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'probe-backend'
        id: '${appGatewayId}/probes/probe-backend'
        properties: {
          protocol: 'Https'
          host: backendFqdn
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          enableProbeProxyProtocolHeader: false
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]

    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    entraJWTValidationConfigs: []

    enableHttp2: true
    enableFips: false

    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 2
    }
  }
}
