param location string
param subnetId string
param vmName string
param vmSize string
param vmPublisher string
param vmOffer string
param vmSku string
param vmVersion string
param vmStorageAccountType string
param adminUsername string
@secure()
param adminPassword string

// Create the virtual machine's public IP address
resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')
    }
  }
}

// Create the virtual machine's NIC and associate it with the applicable public IP address and subnet
resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

// Deploy the virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration:{
        timeZone:'GMT Standard Time'
      }
    }
    storageProfile: {
      imageReference: {
        publisher: vmPublisher
        offer: vmOffer
        sku: vmSku
        version: vmVersion
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: vmStorageAccountType
        }
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }

 
    }
    resource dcinstall 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
      name: 'dc/install'
      location:location
      properties:{
        publisher:'Microsoft.Compute'
        typeHandlerVersion:'1.10'
        autoUpgradeMinorVersion:true
        settings:{
          fileUris:[
            'https://github.com/qprjack86/Az-Bicep-Demo/blob/main/scripts/DCSetup.ps1'
          ]
        }
      protectedSettings: {
        commandToExecute: 'powershell.exe -ExecutionPolicy Bypass -File DCSetup.ps1' 
      }
    
      }
    }
 
output privateIpAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output fqdn string = pip.properties.dnsSettings.fqdn
