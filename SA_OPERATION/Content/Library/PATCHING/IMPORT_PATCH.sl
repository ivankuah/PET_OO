namespace: PATCHING
flow:
  name: IMPORT_PATCH
  inputs:
    - SACoreHost:
        required: false
    - SACoreUsername:
        required: false
    - SACorePassword:
        required: false
        sensitive: true
    - SACoreVersion:
        required: false
    - SAPatchID:
        required: false
    - SAPatchPolicyName:
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
            - coreVersion: '${SACoreVersion}'
            - patchID: '${SAPatchID}'
        publish:
          - createdDate
        navigate:
          - success: Get_Current_Date_and_Time
          - failure: FAILURE
    - Get_Current_Date_and_Time:
        do_external:
          237a5c37-ecbc-4ef1-af37-034e6f7e8f62: []
        publish:
          - currentDate: "${cs_regex(returnResult,\"[a-zA-Z]{3,}\\\\s.*?,\\\\s20\\\\d\\\\d\")}"
        navigate:
          - success: Time_Zone_Converter
          - failure: FAILURE
    - Add_Patches_to_Patch_Policy:
        do_external:
          1b7e29d8-c348-4b0d-911a-7adb4c9d50c2:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${SACoreVersion}'
            - patchPolicyName: '${SAPatchPolicyName}'
            - patchID: '${SAPatchID}'
        publish:
          - addPatchResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${patchCreatedDate}'
            - matchTo: '${currentDate}'
            - ignoreCase: 'false'
        publish:
          - compareDateResult: '${returnResult}'
        navigate:
          - success: Add_Patches_to_Patch_Policy
          - failure: SUCCESS
    - Time_Zone_Converter:
        do_external:
          7955d9b8-a184-457d-8450-8e196e943045:
            - date: '${createdDate}'
            - dateTimeZone: UTC
            - outTimeZone: Asia/Kuala_Lumpur
        publish:
          - patchCreatedDate: "${cs_regex(returnResult,\"[a-zA-Z]{3,}\\\\s.*?,\\\\s20\\\\d\\\\d\")}"
        navigate:
          - success: String_Comparator
          - failure: FAILURE
  outputs:
    - patchCreatedDate: '${patchCreatedDate}'
    - compareDateResult: '${compareDateResult}'
    - addPatchResult: '${addPatchResult}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_Windows_Patch_VOs:
        x: 120
        'y': 160
        navigate:
          9d7059e4-a93e-d1c8-29fb-ae8693e0f4e4:
            targetId: 31505d4d-60bd-3c44-5128-e587e3244492
            port: failure
      Get_Current_Date_and_Time:
        x: 280
        'y': 160
        navigate:
          8e580f02-125f-ce01-ec54-d58cd3254d32:
            targetId: 31505d4d-60bd-3c44-5128-e587e3244492
            port: failure
      Add_Patches_to_Patch_Policy:
        x: 600
        'y': 360
        navigate:
          b983da02-477b-7a15-b1b7-366aa169b6b9:
            targetId: febd93c1-b28b-1710-e579-4bacbbf94934
            port: success
          c676681b-54ab-ecc6-cd02-46a7add93fc8:
            targetId: 31505d4d-60bd-3c44-5128-e587e3244492
            port: failure
      String_Comparator:
        x: 560
        'y': 160
        navigate:
          9fc66f0d-d411-682e-3dac-9d02c289e254:
            targetId: febd93c1-b28b-1710-e579-4bacbbf94934
            port: failure
      Time_Zone_Converter:
        x: 440
        'y': 160
        navigate:
          98b9ce06-b25e-eb1e-38f9-b0bd438224e3:
            targetId: 31505d4d-60bd-3c44-5128-e587e3244492
            port: failure
    results:
      FAILURE:
        31505d4d-60bd-3c44-5128-e587e3244492:
          x: 160
          'y': 360
      SUCCESS:
        febd93c1-b28b-1710-e579-4bacbbf94934:
          x: 680
          'y': 160
