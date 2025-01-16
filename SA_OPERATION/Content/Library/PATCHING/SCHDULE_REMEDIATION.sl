namespace: PATCHING
flow:
  name: SCHDULE_REMEDIATION
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
        default: Edge
        required: false
    - SADeviceGroupName:
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
          - success: Get_Patches_in_Patch_Policy
          - failure: FAILURE
    - Get_Patches_in_Patch_Policy:
        do_external:
          f70c56bf-d595-4100-96e3-c4c0a52ff6a4:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - patchPolicyName: '${SAPatchPolicyName}'
        publish:
          - patchResult: "${'[PATCH FOUND]' + returnResult}"
        navigate:
          - success: String_Comparator
          - failure: String_Comparator
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contains
            - toMatch: '${patchResult}'
            - matchTo: No patches found
            - ignoreCase: 'false'
        navigate:
          - success: SUCCESS
          - failure: Remediate_Device_Group_For_Patch_Policies
    - Remediate_Device_Group_For_Patch_Policies:
        do_external:
          beecb6ae-cef9-42b3-9e50-82a243b1ecca:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - deviceGroupName: '${SADeviceGroupName}'
            - patchPolicies: '${SAPatchPolicyName}'
            - rebootOption: suppress
            - ticketID: "${'MS Edge Patching For ' + SADeviceGroupName}"
        publish:
          - scheduleResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - PatchId: '${PatchId}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Get_SA_Version:
        x: 120
        'y': 120
        navigate:
          4178f086-d386-28b1-1993-b05328b22485:
            targetId: 1b1a0d1e-362a-ed75-a157-67bc734ba707
            port: failure
      Get_Patches_in_Patch_Policy:
        x: 360
        'y': 120
      String_Comparator:
        x: 480
        'y': 240
        navigate:
          24679673-4d3a-e7a0-78c2-c3877916e9b9:
            targetId: 0f77c0b2-7791-267e-19cc-87cc38ea997c
            port: success
      Remediate_Device_Group_For_Patch_Policies:
        x: 480
        'y': 400
        navigate:
          986629a4-0f11-38c0-1303-06ebfdfd2cd9:
            targetId: 0f77c0b2-7791-267e-19cc-87cc38ea997c
            port: success
          37f35d38-2a67-0512-41a7-dd65be9d18a9:
            targetId: 1b1a0d1e-362a-ed75-a157-67bc734ba707
            port: failure
    results:
      SUCCESS:
        0f77c0b2-7791-267e-19cc-87cc38ea997c:
          x: 640
          'y': 240
      FAILURE:
        1b1a0d1e-362a-ed75-a157-67bc734ba707:
          x: 120
          'y': 400
