
# trigger:
#   paths:
#     include:
#       - 'terraform/0-dev/*'
#   branches:
#     include:
#     - master
#     - feature/*
parameters:
  - name: VM_ROL
    type: string
    displayName: VM_ROL
  - name: VM_TEMPLATE
    type: string
    displayName: VM_TEMPLATE
  - name: VM_SO
    displayName: VM_SO
    values:
    - L
    - W
  - name: VM_ENVIRONMENT
    displayName: VM_ENVIRONMENT
    type: string
  - name: VM_TYPE
    displayName: VM_TYPE
    default: SMALL
    values:
    - SMALL
    - MEDIUM
    - LARGE
    - NA
  - name: VM_GRANJA
    type: string
    displayName: VM_GRANJA
  - name: VM_HOSTNAME  # Nombre del parámetro
    type: string  # Tipo del parámetro
  - name: VM_IP  # Nombre del parámetro
    type: string  # Tipo del parámetro
  - name: VM_NETMASK # Nombre del parámetro
    type: string # Tipo del parámetro
  - name: VM_GATEWAY  # Nombre del parámetro
    type: string  # Tipo del parámetro
  - name: VM_VLAN  # Nombre del parámetro
    type: string  # Tipo del parámetro
    displayName: VLAN
  - name: VM_DISK_D
    type: string
    displayName: Disco # Disco D
  - name: VM_DISK_F
    type: string
    displayName: Disco # Disco F - Base Datos
  - name: VM_DISK_G
    type: string
    displayName: Disco # Disco G - Base Datos
  - name: VM_DISK_H
    type: string
    displayName: Disco # Disco H - Base Datos
  - name: VM_MEM
    type: string
  - name: VM_CPU
    type: string
  - name: VM_JUSTIFICATION
    type: string
  - name: VM_PROJECNAME
    type: string
  - name: VM_DATASTORE
    type: string
  - name: VM_NOM_APL
    type: string
  - name: VM_LID_INI
    type: string
  - name: VM_OWNER
    type: string
  - name: VM_GRUPO_SOP
    type: string
  - name: VM_TRIBU
    type: string
  - name: VM_SOPORTE
    type: string
  - name: VM_FIRMWARE
    type: string
  - name: VM_VCENTER
    type: string

trigger: none

resources:
  repositories:
    - repository: self
    - repository: dvp-tpl-iac
      type: git
      name: BP-DevOps-Infrastructure/dvp-tpl-iac
      # ref: refs/heads/feature/vsphereTemplate
      # ref: refs/heads/master
      ref: refs/heads/feature/vsphere

variables:
  - group: vsp-cross-vsphere
  - group: vsp-dev-vsphere
  - group: vsp-prod-vsphere

extends:
  template: terraform/vsphere/initConfig.yml@dvp-tpl-iac
  parameters:
    #---------- VARS FOR SCRIPT IAC----------
    VM_ROL : '${{ parameters.VM_ROL }}'
    VM_TEMPLATE: '${{ parameters.VM_TEMPLATE }}'
    VM_SO: '${{ parameters.VM_SO }}'
    VM_ENVIRONMENT: '${{ parameters.VM_ENVIRONMENT }}'
    VM_TYPE: '${{ parameters.VM_TYPE }}'
    VM_GRANJA: '${{ parameters.VM_GRANJA }}'
    VM_HOSTNAME: '${{ parameters.VM_HOSTNAME }}'
    VM_IP: '${{ parameters.VM_IP }}'
    VM_NETMASK: '${{ parameters.VM_NETMASK }}'
    VM_GATEWAY: '${{ parameters.VM_GATEWAY }}'
    VM_VLAN: '${{ parameters.VM_VLAN }}'
    VM_DISK_D: '${{ parameters.VM_DISK_D }}'
    VM_DISK_F: '${{ parameters.VM_DISK_F }}'
    VM_DISK_G: '${{ parameters.VM_DISK_G }}'
    VM_DISK_H: '${{ parameters.VM_DISK_H }}'
    VM_MEM: '${{ parameters.VM_MEM }}'
    VM_CPU: '${{ parameters.VM_CPU }}'
    VM_JUSTIFICATION: '${{ parameters.VM_JUSTIFICATION }}'
    VM_PROJECNAME: '${{ parameters.VM_JUSTIFICATION }}'
    VM_DATASTORE: '${{ parameters.VM_DATASTORE }}'
    VM_NOM_APL: '${{ parameters.VM_NOM_APL }}'
    VM_LID_INI: '${{ parameters.VM_LID_INI }}'
    VM_OWNER: '${{ parameters.VM_OWNER }}'
    VM_GRUPO_SOP: '${{ parameters.VM_GRUPO_SOP }}'
    VM_TRIBU: '${{ parameters.VM_TRIBU }}'


------



parameters:
  - name: VM_HOSTNAME
    type: string
    displayName: VM_HOSTNAME
  - name: VM_SO
    type: string
    displayName: VM_SO
   - name: VM_IP
     type: string
     displayName: VM_IP
    - name: VM_ENVIRONMENT
    type: string
    displayName: VM_ENVIRONMENT
    - name: VM_JUSTIFICACION
    type: string
    displayName: VM_JUSTIFICACION

trigger: none    
