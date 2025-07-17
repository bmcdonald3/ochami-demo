# OpenCHAMI scans, collects, and power control on BMCs and PDUs demo

## Scan for PDUs

```bash
./magellan-linux scan --subnet 10.254.1.0/17 -F json --include=pdus
```
```json
[
  {
    "host": "https://10.254.1.26",
    "port": 443,
    "protocol": "tcp",
    "state": true,
    "timestamp": "2025-07-17T21:15:44.448877796Z",
    "service_type": "JAWS"
  },
  {
    "host": "https://10.254.1.32",
    "port": 443,
    "protocol": "tcp",
    "state": true,
    "timestamp": "2025-07-17T21:15:44.448253425Z",
    "service_type": "JAWS"
  },
  {
    "host": "https://10.254.1.23",
    "port": 443,
    "protocol": "tcp",
    "state": true,
    "timestamp": "2025-07-17T21:15:44.52532228Z",
    "service_type": "JAWS"
  },
  {
    "host": "https://10.254.1.5",
    "port": 443,
    "protocol": "tcp",
    "state": true,
    "timestamp": "2025-07-17T21:15:44.448178293Z",
    "service_type": "JAWS"
  },
  {
    "host": "https://10.254.1.13",
    "port": 443,
    "protocol": "tcp",
    "state": true,
    "timestamp": "2025-07-17T21:15:44.448205484Z",
    "service_type": "JAWS"
  },
  {
    "host": "https://10.254.1.19",
    "port": 443,
    "protocol": "tcp",
    "state": true,
    "timestamp": "2025-07-17T21:15:44.450450685Z",
    "service_type": "JAWS"
  }
]
```

## Collect PDU Inventory
```bash
./magellan-linux collect pdu x3000m0 --username admn --password admn -v
```
```json
[
  {
    "Enabled": true,
    "FQDN": "x3000m0",
    "Hostname": "x3000m0",
    "ID": "x3000m0",
    "PDUInventory": {
      "Outlets": [
        {
          "id_suffix": "p0v1",
          "name": "Master_Outlet_1",
          "original_id": "AA1",
          "socket_type": "C13",
          "state": "On"
        },
        {
          "id_suffix": "p0v2",
          "name": "Master_Outlet_2",
          "original_id": "AA2",
          "socket_type": "C13",
          "state": "On"
        },
        // ...
        {
          "id_suffix": "p1v35",
          "name": "Link1_Outlet_35",
          "original_id": "BA35",
          "socket_type": "Cx",
          "state": "On"
        },
        {
          "id_suffix": "p1v36",
          "name": "Link1_Outlet_36",
          "original_id": "BA36",
          "socket_type": "Cx",
          "state": "On"
        }
      ]
    },
    "RediscoverOnUpdate": false,
    "Type": "Node"
  }
]
```

## Store PDU Inventory in SMD
```bash
cat "./pdu-inventory.json" | magellan send http://localhost:27779
curl -sS http://localhost:27779/hsm/v2/Inventory/RedfishEndpoints | jq
```
```json
{
  "RedfishEndpoints": [
    {
      "ID": "x3000m0",
      "Type": "CabinetPDUController",
      "Hostname": "x3000m0",
      "Domain": "",
      "FQDN": "x3000m0",
      "Enabled": true,
      "User": "",
      "Password": "",
      "RediscoverOnUpdate": false,
      "DiscoveryInfo": {
        "LastDiscoveryStatus": "NotYetQueried"
      }
    }
  ]
}
```
```bash
curl -sS "http://localhost:27779/hsm/v2/Inventory/ComponentEndpoints" | jq
```
```json
    {
      "ID": "x3000m0p1v35",
      "Type": "CabinetPDUPowerConnector",
      "RedfishType": "Outlet",
      "RedfishSubtype": "Cx",
      "OdataID": "/jaws/monitor/outlets/BA35",
      "RedfishEndpointID": "x3000m0",
      "Enabled": true,
      "RedfishEndpointFQDN": "x3000m0",
      "RedfishURL": "x3000m0/jaws/monitor/outlets/BA35",
      "ComponentEndpointType": "ComponentEndpointOutlet",
      "RedfishOutletInfo": {
        "Name": "Link1_Outlet_35",
        "Actions": {
          "#Outlet.PowerControl": {
            "PowerState@Redfish.AllowableValues": [
              "On",
              "Off"
            ],
            "target": "/jaws/control/outlets/BA35"
          }
        }
      }
    },
    {
      "ID": "x3000m0p1v36",
      "Type": "CabinetPDUPowerConnector",
      "RedfishType": "Outlet",
      "RedfishSubtype": "Cx",
      "OdataID": "/jaws/monitor/outlets/BA36",
      "RedfishEndpointID": "x3000m0",
      "Enabled": true,
      "RedfishEndpointFQDN": "x3000m0",
      "RedfishURL": "x3000m0/jaws/monitor/outlets/BA36",
      "ComponentEndpointType": "ComponentEndpointOutlet",
      "RedfishOutletInfo": {
        "Name": "Link1_Outlet_36",
        "Actions": {
          "#Outlet.PowerControl": {
            "PowerState@Redfish.AllowableValues": [
              "On",
              "Off"
            ],
            "target": "/jaws/control/outlets/BA36"
          }
        }
      }
    }
```

## Collect BMC data
```bash
magellan collect "https://172.24.0.2" --username "root" --password "initial0" -v | magellan send http://localhost:27779
curl -sS http://localhost:27779/hsm/v2/Inventory/RedfishEndpoints | jq
```
```json
{
  "RedfishEndpoints": [
    {
      "ID": "x3000m0",
      "Type": "CabinetPDUController",
      "Hostname": "x3000m0",
      "Domain": "",
      "FQDN": "x3000m0",
      "Enabled": true,
      "User": "",
      "Password": "",
      "RediscoverOnUpdate": false,
      "DiscoveryInfo": {
        "LastDiscoveryStatus": "NotYetQueried"
      }
    },
    {
      "ID": "x1000c1s7b0",
      "Type": "NodeBMC",
      "Hostname": "172.24.0.3",
      "Domain": "",
      "FQDN": "172.24.0.3",
      "Enabled": true,
      "User": "root",
      "Password": "",
      "MACRequired": true,
      "MACAddr": "a4-bf-01-3f-6b-42",
      "IPAddress": "172.24.0.3",
      "RediscoverOnUpdate": false,
      "DiscoveryInfo": {
        "LastDiscoveryStatus": "NotYetQueried"
      }
    },
    {
      "ID": "x1000c1s7b1",
      "Type": "NodeBMC",
      "Hostname": "172.24.0.2",
      "Domain": "",
      "FQDN": "172.24.0.2",
      "Enabled": true,
      "User": "root",
      "Password": "",
      "MACRequired": true,
      "MACAddr": "a4-bf-01-3f-6e-e9",
      "IPAddress": "172.24.0.2",
      "RediscoverOnUpdate": false,
      "DiscoveryInfo": {
        "LastDiscoveryStatus": "NotYetQueried"
      }
    },
    {
      "ID": "x1000c1s7b2",
      "Type": "NodeBMC",
      "Hostname": "172.24.0.4",
      "Domain": "",
      "FQDN": "172.24.0.4",
      "Enabled": true,
      "User": "root",
      "Password": "",
      "MACRequired": true,
      "MACAddr": "a4-bf-01-3f-71-1e",
      "IPAddress": "172.24.0.4",
      "RediscoverOnUpdate": false,
      "DiscoveryInfo": {
        "LastDiscoveryStatus": "NotYetQueried"
      }
    }
  ]
}
```
```bash
curl -sS "http://localhost:27779/hsm/v2/Inventory/ComponentEndpoints/x1000c1s7b0n0" | jq
```
```json
{
  "ID": "x1000c1s7b0n0",
  "Type": "Node",
  "RedfishType": "ComputerSystem",
  "RedfishSubtype": "Physical",
  "UUID": "317091ec-8be6-11e8-ab21-a4bf013f6b40",
  "OdataID": "/redfish/v1/Systems/QSBP82909087",
  "RedfishEndpointID": "x1000c1s7b0",
  "Enabled": true,
  "RedfishEndpointFQDN": "172.24.0.3",
  "RedfishURL": "172.24.0.3/redfish/v1/Systems/QSBP82909087",
  "ComponentEndpointType": "ComponentEndpointComputerSystem",
  "RedfishSystemInfo": {
    "Name": "S2600BPB",
    "Actions": {
      "#ComputerSystem.Reset": {
        "ResetType@Redfish.AllowableValues": [
          "PushPowerButton",
          "On",
          "GracefulShutdown",
          "ForceRestart",
          "Nmi",
          "ForceOn",
          "ForceOff"
        ],
        "@Redfish.ActionInfo": "/redfish/v1/Systems/QSBP82909087/ResetActionInfo",
        "target": "/redfish/v1/Systems/QSBP82909087/Actions/ComputerSystem.Reset"
      }
    },
    "EthernetNICInfo": [
      {
        "RedfishId": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/1",
        "@odata.id": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/1",
        "Description": "System NIC 1",
        "InterfaceEnabled": true,
        "MACAddress": "a4-bf-01-3f-6b-40"
      },
      {
        "RedfishId": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/3",
        "@odata.id": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/3",
        "Description": "System NIC 3",
        "InterfaceEnabled": true,
        "MACAddress": "ff-ff-ff-ff-ff-ff"
      },
      {
        "RedfishId": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/2",
        "@odata.id": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/2",
        "Description": "System NIC 2",
        "InterfaceEnabled": true,
        "MACAddress": "a4-bf-01-3f-6b-41"
      },
      {
        "RedfishId": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/4",
        "@odata.id": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/4",
        "Description": "System NIC 4",
        "InterfaceEnabled": true,
        "MACAddress": "02-09-01-08-38-c5"
      },
      {
        "RedfishId": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/5",
        "@odata.id": "/redfish/v1/Systems/QSBP82909087/EthernetInterfaces/5",
        "Description": "System NIC 5",
        "InterfaceEnabled": true,
        "MACAddress": "02-09-01-08-46-9a"
      }
    ],
    "PowerURL": "/redfish/v1/Chassis/RackMount/Power",
    "PowerControl": [
      {
        "@odata.id": "/redfish/v1/Chassis/RackMount/Baseboard/Power#/PowerControl/0",
        "MemberId": "0",
        "Name": "System Power Control",
        "RelatedItem": [
          {
            "@odata.id": "/redfish/v1/Systems/QSBP82909087"
          },
          {
            "@odata.id": "/redfish/v1/Chassis/RackMount/Baseboard"
          }
        ]
      }
    ]
  }
}
```

## Query BMC and PDU power status with PCS
```bash
curl -sS -X GET http://localhost:28007/v1/power-status?xname=x1000c1s7b0n0 | jq '.'
```
```json
{
  "status": [
    {
      "xname": "x1000c1s7b0n0",
      "powerState": "off",
      "managementState": "available",
      "error": "",
      "supportedPowerTransitions": [
        "On",
        "Soft-Off",
        "Off",
        "Soft-Restart",
        "Force-Off",
        "Init",
        "Hard-Restart"
      ],
      "lastUpdated": "2025-07-17T21:33:35.268776574Z"
    }
  ]
}
```
```bash
curl -sS -X GET http://localhost:28007/v1/power-status?xname=x3000m0p0v17 | jq '.'
```
```json
TODO
```

## Query BMC power control on and off with PCS 
```bash
curl -sS -X POST -H "Content-Type: application/json" -d '{"operation": "Off", "location": [{"xname": "x1000c1s7b0n0"}]}' http://localhost:28007/v1/transitions
# Transition ID: e9450e52-a8ef-44d3-b9aa-5a491a7bd6a2
```
```json
TODO
```
```bash
curl -sS -X GET http://localhost:28007/v1/power-status?xname=x1000c1s7b0n0 | jq '.'
```
```json
{
  "status": [
    {
      "xname": "x1000c1s7b0n0",
      "powerState": "off",
      "managementState": "available",
      "error": "",
      "supportedPowerTransitions": [
        "On",
        "Soft-Off",
        "Off",
        "Soft-Restart",
        "Force-Off",
        "Init",
        "Hard-Restart"
      ],
      "lastUpdated": "2025-07-17T21:33:35.268776574Z"
    }
  ]
}
```
```bash
curl -sS -X POST -H "Content-Type: application/json" -d '{"operation": "On", "location": [{"xname": "x1000c1s7b0n0"}]}' http://localhost:28007/v1/transitions
# Transition ID: d3623770-aab1-452b-b9c6-501d6aaf62dc
```
```json
{
  "transitionID": "d3623770-aab1-452b-b9c6-501d6aaf62dc",
  "operation": "On",
  "createTime": "2025-07-17T21:40:26.932602184Z",
  "automaticExpirationTime": "2025-07-18T21:40:26.932602396Z",
  "transitionStatus": "in-progress",
  "taskCounts": {
    "total": 1,
    "new": 0,
    "in-progress": 1,
    "failed": 0,
    "succeeded": 0,
    "un-supported": 0
  },
  "tasks": [
    {
      "xname": "x1000c1s7b0n0",
      "taskStatus": "in-progress",
      "taskStatusDescription": "Confirming successful transition, on"
    }
  ]
}
```
```bash
curl -sS -X GET http://localhost:28007/v1/power-status?xname=x1000c1s7b0n0 | jq '.'
```
```json
{
  "status": [
    {
      "xname": "x1000c1s7b0n0",
      "powerState": "on",
      "managementState": "available",
      "error": "",
      "supportedPowerTransitions": [
        "On",
        "Soft-Off",
        "Off",
        "Soft-Restart",
        "Force-Off",
        "Init",
        "Hard-Restart"
      ],
      "lastUpdated": "2025-07-17T21:40:40.973240376Z"
    }
  ]
}
```

## Query PDU power control on and off with PCS
```bash
curl -sS -X POST -H "Content-Type: application/json" -d '{"operation": "Off", "location": [{"xname": "x3000m0p0v17"}]}' http://localhost:28007/v1/transitions
# Transition ID: b83dac77-8543-4e99-8386-53b7345c66ce
```
```bash
curl -sS -X GET http://localhost:28007/v1/transitions/b83dac77-8543-4e99-8386-53b7345c66ce | jq '.'
```
```json
{
  "transitionID": "b83dac77-8543-4e99-8386-53b7345c66ce",
  "operation": "Off",
  "createTime": "2025-07-17T21:41:58.412908129Z",
  "automaticExpirationTime": "2025-07-18T21:41:58.412908357Z",
  "transitionStatus": "in-progress",
  "taskCounts": {
    "total": 1,
    "new": 0,
    "in-progress": 1,
    "failed": 0,
    "succeeded": 0,
    "un-supported": 0
  },
  "tasks": [
    {
      "xname": "x3000m0p0v17",
      "taskStatus": "in-progress",
      "taskStatusDescription": "Confirming successful transition, gracefulshutdown"
    }
  ]
}
```
TODO: ADD STATUS CHECK ON THIS PDU TO MAKE SURE IT'S OFF
```bash
curl -sS -X POST -H "Content-Type: application/json" -d '{"operation": "On", "location": [{"xname": "x3000m0p0v17"}]}' http://localhost:28007/v1/transitions
# Transition ID: 0f7bdd6b-df5e-48b8-a554-aa6ca110098e
```
```bash
curl -sS -X GET http://localhost:28007/v1/transitions/0f7bdd6b-df5e-48b8-a554-aa6ca110098e | jq '.'
```
```json
{
  "transitionID": "0f7bdd6b-df5e-48b8-a554-aa6ca110098e",
  "operation": "On",
  "createTime": "2025-07-17T21:43:04.964160775Z",
  "automaticExpirationTime": "2025-07-18T21:43:04.964160982Z",
  "transitionStatus": "completed",
  "taskCounts": {
    "total": 1,
    "new": 0,
    "in-progress": 0,
    "failed": 0,
    "succeeded": 1,
    "un-supported": 0
  },
  "tasks": [
    {
      "xname": "x3000m0p0v17",
      "taskStatus": "succeeded",
      "taskStatusDescription": "Transition confirmed, on"
    }
  ]
}
```
```bash
curl -sS -X GET http://localhost:28007/v1/power-status?xname=x3000m0p0v17 | jq '.'
```
```json
{
  "status": [
    {
      "xname": "x3000m0p0v17",
      "powerState": "on",
      "managementState": "available",
      "error": "",
      "supportedPowerTransitions": [
        "On",
        "Soft-Off",
        "Off",
        "Init",
        "Hard-Restart",
        "Soft-Restart"
      ],
      "lastUpdated": "2025-07-17T21:43:18.269752126Z"
    }
  ]
}
```