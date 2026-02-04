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
    displayName: "Crear archivo YAML por ejecución"
    pool:
      vmImage: ubuntu-latest

    steps:
    - checkout: self

    # 1️⃣ Crear carpeta
    - script: |
        mkdir -p vars
      displayName: "Crear carpeta vars"

    # 2️⃣ Crear YAML ÚNICO por ejecución
    - script: |
        ARCHIVO="vars/vm_apagado_$(date +%Y%m%d_%H%M%S)_${{ parameters.VM_HOSTNAME }}.yml"

        cat <<EOF > $ARCHIVO
        vm:
          hostname: "${{ parameters.VM_HOSTNAME }}"
          justificacion: "${{ parameters.VM_JUSTIFICACION }}"
          origen: "PowerAutomate"
          pipeline_run: "$(Build.BuildNumber)"
          fecha: "$(date '+%Y-%m-%d %H:%M:%S')"
        EOF

        echo "Archivo generado:"
        echo $ARCHIVO
      displayName: "Generar YAML de apagado"

    # 3️⃣ Mostrar contenido
    - script: |
        echo "Contenido del YAML:"
        cat vars/*.yml
      displayName: "Mostrar YAML generado"

    # 4️⃣ Publicar como artefacto (CLAVE 🔑)
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: "vars"
        artifact: "vm_apagados"
      displayName: "Publicar YAML como Artifact"