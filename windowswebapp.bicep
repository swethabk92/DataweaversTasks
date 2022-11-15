param webAppName1 string = uniqueString(resourceGroup().id) // Generate unique Strings for webapps
param webAppName2 string = uniqueString(resourceGroup().id)
param webAppName3 string = uniqueString(resourceGroup().id)

param sku string = 'S1' // The SKU of App Service Plan 

param language string = 'php' // The Language stack of the web app
param windowsFxVersion string = 'php|7.4' // The runtime stack of web app
param location string = resourceGroup().location // Location for all resources

var appServicePlanPool = toLower('AppServicePlanPool')

var webSiteName1 = toLower('wapp-${webAppName1}')
var webSiteName2 = toLower('wapp-${webAppName2}')
var webSiteName3 = toLower('wapp-${webAppName3}')

resource appServicePlan 'Microsoft.Web/serverfarms@2022-11-15' = {
  name: appServicePlanPool
  location: location
  sku: {
    name: sku
  }
  kind: 'windows'
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2022-11-15' = {
  name: webSiteName1
  location: location // generic location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      windowsFxVersion: windowsFxVersion
    }
  }
}
resource appService 'Microsoft.Web/sites@2022-11-15' = {
  name: webSiteName2
  location: location // generic location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      windowsFxVersion: windowsFxVersion
    }
  }
}
resource appService 'Microsoft.Web/sites@2022-11-15' = {
  name: webSiteName3
  location: 'Australia/Brisbane' // static location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      windowsFxVersion: windowsFxVersion
    }
  }
}
