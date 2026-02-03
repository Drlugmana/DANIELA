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