// S
targetScope = 'subscription'

// Define region
param resourceGroupLocation string = 'spaincentral'

// Define resource group names
param resourceGroupNames array = [
  'rg-medicore-app'
  'rg-medicore-net'
  'rg-medicore-monitor'
]

// Define tags for each resource group
param tagResourceGroup object = {
  Project: 'p01-web'
  Environment: 'Lab'
  Owner: 'IT'
  CostCenter: 'IT-001'
}

//=======================================//
// Resource group creation
//=======================================//
resource resourceGroups 'Microsoft.Resources/resourceGroups@2025-04-01' = [
  for resourceGroupName in resourceGroupNames: {
    name: resourceGroupName
    location: resourceGroupLocation
    tags: tagResourceGroup  
  }
]





