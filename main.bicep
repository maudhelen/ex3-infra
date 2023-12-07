// Main.bicep

// Parameters
param containerRegistryName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param location string
param keyVaultName string

param DOCKER_REGISTRY_SERVER_URL string
param kevVaultSecretNameACRUsername string
param kevVaultSecretNameACRPassword1 string 

//key vault reference
resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
 }


// Azure Container Registry module
module acr './ResourceModules-main/modules/container-registry/registry/main.bicep' = {
  name: containerRegistryName
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

// Azure Service Plan for Linux module
module servicePlan './ResourceModules-main/modules/web/serverfarm/main.bicep' = {
  name: appServicePlanName
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

// Azure Web App for Linux containers module
module webApp './ResourceModules-main/modules/web/site/main.bicep' = {
  name: webAppName
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: servicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
    }
    dockerRegistryServerUrl: DOCKER_REGISTRY_SERVER_URL
    dockerRegistryServerUserName: keyvault.getSecret(kevVaultSecretNameACRUsername)
    dockerRegistryServerPassword: keyvault.getSecret(kevVaultSecretNameACRPassword1)
  }
}


