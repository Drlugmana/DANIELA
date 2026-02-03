trigger: none

parameters:
- name: VM_HOSTNAME
  type: string
- name: VM_JUSTIFICACION
  type: string

stages:
- stage: RecibirDatos
  displayName: "Recibir datos desde Power Automate"
  jobs:
  - job: CrearYAML
    displayName: "Crear archivo YAML con variables"
    pool:
      name: Self-Hosted
    steps:
    - checkout: self

    - script: |
        mkdir -p vars
        cat <<EOF > vars/vm_apagado_vars.yml
        vm:
          hostname: "${{ parameters.VM_HOSTNAME }}"
          justificacion: "${{ parameters.VM_JUSTIFICACION }}"
          origen: "PowerAutomate"
          fecha: "$(date '+%Y-%m-%d %H:%M:%S')"
        EOF
      displayName: "Generar YAML de variables"

    - script: |
        echo "Contenido del YAML generado:"
        cat vars/vm_apagado_vars.yml
      displayName: "Mostrar YAML"

-----

vm_apagado_vars.yml


{
  "resources": {
    "repositories": {
      "self": {
        "refName": "refs/heads/feature/apagado_vm"
      }
    }
  },
  "templateParameters": {
    "VM_HOSTNAME": "@{triggerOutputs()?['body/Hostname']}",
    "VM_JUSTIFICACION": "@{triggerOutputs()?['body/Justificacion']}"
  }
}

/BancoPichinchaEC/iac-hypervisors/_apis/pipelines/16222/runs?api-version=7.0