# OpenCHAMI scans, collects, and power control on BMCs and PDUs demo

## Collect PDU information

```bash
# ./magellan-linux scan --subnet 10.254.1.0/17 -F json --include=pdus
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