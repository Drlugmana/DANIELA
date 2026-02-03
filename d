
trigger: none

parameters:
  - name: VM_HOSTNAME
    type: string
    displayName: VM_HOSTNAME

  - name: VM_JUSTIFICACION
    type: string
    displayName: VM_JUSTIFICACION

stages:
- stage: ApagarVM
  displayName: "Apagado de VM por Hostname"
  jobs:
  - job: EjecutarAnsible
    displayName: "Apagar VM"
    pool:
      name: Self-Hosted   # mismo agente donde corre Ansible
    steps:

    - checkout: self

    - script: |
        echo "Apagando VM con hostname:"
        echo "HOSTNAME: ${{ parameters.VM_HOSTNAME }}"
        echo "JUSTIFICACION: ${{ parameters.VM_JUSTIFICACION }}"
      displayName: "Debug parámetros"

    - script: |
        ansible-playbook ansible/apagar_vm.yml \
          -e vm_hostname='${{ parameters.VM_HOSTNAME }}' \
          -e justificacion='${{ parameters.VM_JUSTIFICACION }}'
      displayName: "Ejecutar Ansible (hostname)"
