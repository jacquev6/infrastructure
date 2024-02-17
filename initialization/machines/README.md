# Physical machines at home

## `doorman`

Raspberry PI 3

### Wifi

Mac: B8:27:EB:21:C9:E7

IP: 192.168.1.101 (static DHCP lease in Freebox)

### Ethernet

Mac: B8:27:EB:74:9C:B2

# Virtual machines on sam

## `v-doorman`

Virtual Box, 4 CPUs, 4096 MB of RAM

### Bridged interface

Mac: 08:00:27:1F:CE:56

IP: 192.168.1.102 (static DHCP lease in Freebox)

### Internal interface

Mac: 08:00:27:E5:98:53

IP: 10.20.30.1 (netplan configuration set in Ansible)

## `v-node-1`

Virtual Box, 4 CPUs, 4096 MB of RAM

### Internal interface

Mac: 08:00:27:02:5A:76

IP: 10.20.30.100 (static DHCP lease in doorman's Kea)

## `v-node-1`

Virtual Box, 4 CPUs, 4096 MB of RAM

### Internal interface

Mac: 08:00:27:CA:26:50

IP: 10.20.30.101 (static DHCP lease in doorman's Kea)
