namespace: PATCHING
flow:
  name: GET_WINDOWS_PATCHES
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
    - SAPatchName:
        default: Edge
        required: false
  workflow:
    - Get_Windows_Patch_VOs:
        do_external:
          f424bf9d-dd6d-4341-9cac-2ce99844be71:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: sas241
            - patchName: '${SAPatchName}'
        publish:
          - createdDate
          - windowsPatchTitle
          - id
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - PatchId: '${PatchId}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_Windows_Patch_VOs:
        x: 160
        'y': 160
        navigate:
          9d7059e4-a93e-d1c8-29fb-ae8693e0f4e4:
            targetId: 31505d4d-60bd-3c44-5128-e587e3244492
            port: failure
          7f541b8c-dfa6-e314-ad8e-eb8c9a7b98c8:
            targetId: febd93c1-b28b-1710-e579-4bacbbf94934
            port: success
    results:
      FAILURE:
        31505d4d-60bd-3c44-5128-e587e3244492:
          x: 160
          'y': 360
      SUCCESS:
        febd93c1-b28b-1710-e579-4bacbbf94934:
          x: 400
          'y': 160
