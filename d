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