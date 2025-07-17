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