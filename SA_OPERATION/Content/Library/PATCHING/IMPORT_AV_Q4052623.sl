namespace: PATCHING
flow:
  name: IMPORT_AV_Q4052623
  inputs:
    - SACoreHost:
        default: 10.102.21.72
        required: false
    - SACoreUsername:
        default: admin
        required: false
    - SACorePassword:
        default: 'BitA#48ZOhZpW01'
        required: false
        sensitive: true
    - SAPatchPolicyName:
        default: '[Daily] Microsoft Edge Patch Policy'
        required: false
    - SAPatchName:
        default: Q4052623
        required: false
  workflow:
    - Get_SA_Version:
        do_external:
          ad34fe78-8d93-44ef-aa79-dfd37b70e83c:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
        publish:
          - saCoreVersion: '${coreVersion}'
        navigate:
          - success: Get_Windows_Patch_VOs
          - failure: FAILURE
    - IMPORT_PATCH:
        loop:
          for: add_patch in saPatchId
          do:
            PATCHING.IMPORT_PATCH:
              - SACoreHost: '${SACoreHost}'
              - SACoreUsername: '${SACoreUsername}'
              - SACorePassword:
                  value: '${SACorePassword}'
                  sensitive: true
              - SACoreVersion: '${saCoreVersion}'
              - SAPatchID: '${add_patch}'
              - SAPatchPolicyName: '${SAPatchPolicyName}'
          break:
            - FAILURE
          publish:
            - patchCreatedDate
            - compareDateResult
            - addPatchResult
        navigate:
          - FAILURE: FAILURE
          - SUCCESS: SUCCESS
    - Get_Windows_Patch_VOs:
        do_external:
          f424bf9d-dd6d-4341-9cac-2ce99844be71:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - patchName: '${SAPatchName}'
        publish:
          - saPatchId: '${id}'
        navigate:
          - success: IMPORT_PATCH
          - failure: FAILURE
  outputs:
    - PatchId: '${PatchId}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_SA_Version:
        x: 120
        'y': 120
        navigate:
          704839a5-aa5c-4297-7c66-cee4fcf4fe2b:
            targetId: eba0d44b-def3-8fc7-c8d7-e06f2fc8bfe1
            port: failure
      Get_Windows_Patch_VOs:
        x: 400
        'y': 120
        navigate:
          beca87b4-e984-f6e3-56d2-50d49b2e9052:
            targetId: eba0d44b-def3-8fc7-c8d7-e06f2fc8bfe1
            port: failure
      IMPORT_PATCH:
        x: 400
        'y': 280
        navigate:
          92c26197-a895-134e-78b5-e30d38d8d80d:
            targetId: 3626b0c7-2ad1-9ace-75cf-c1f66b847882
            port: SUCCESS
          34b79627-73c1-e68b-ff53-5dfb1b3c4dca:
            targetId: eba0d44b-def3-8fc7-c8d7-e06f2fc8bfe1
            port: FAILURE
    results:
      FAILURE:
        eba0d44b-def3-8fc7-c8d7-e06f2fc8bfe1:
          x: 120
          'y': 280
      SUCCESS:
        3626b0c7-2ad1-9ace-75cf-c1f66b847882:
          x: 600
          'y': 280
