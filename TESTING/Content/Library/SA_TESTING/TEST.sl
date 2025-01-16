namespace: SA_TESTING
flow:
  name: TEST
  workflow:
    - Get_Windows_Patch_VOs:
        do_external:
          f424bf9d-dd6d-4341-9cac-2ce99844be71:
            - coreHost: 10.102.21.72
            - coreUsername: admin
            - corePassword:
                value: 'BitA#48ZOhZpW01'
                sensitive: true
            - coreVersion: sas241
            - patchID: '2267730001'
        publish:
          - createdDate
          - windowsPatchCreateDate
          - unitUploadDate
          - modifiedDate
          - patchPostInstallScriptID
          - unitExsitsOnWord
          - unitServerCount
          - unitVersion
          - patchUninstallScriptID
          - windowsPatchInfoFileName
          - unitSoftwarePolicyCount
          - patchInstallFlags
          - unitPlatformIds
          - windowsPatchRevisionNumber
          - unitPlatformNames
          - unitNotes
          - patchStatus
        navigate:
          - success: Get_Current_Date_and_Time
          - failure: FAILURE
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
    - Get_Current_Date_and_Time:
        do_external:
          237a5c37-ecbc-4ef1-af37-034e6f7e8f62: []
        publish:
          - currentDate: "${cs_regex(returnResult,\"[a-zA-Z]{3,}\\\\s.*?,\\\\s20\\\\d\\\\d\")}"
        navigate:
          - success: Time_Zone_Converter
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
          - success: SUCCESS
          - failure: FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Get_Windows_Patch_VOs:
        x: 140
        'y': 180
        navigate:
          d057d14e-a0d2-9ab5-c771-9cdabfe873dc:
            targetId: d5757e57-2923-d632-618d-51405bb9894d
            port: failure
      Time_Zone_Converter:
        x: 360
        'y': 360
        navigate:
          39ad1049-88c7-0432-581d-0a9df30abce0:
            targetId: d5757e57-2923-d632-618d-51405bb9894d
            port: failure
      Get_Current_Date_and_Time:
        x: 300
        'y': 180
        navigate:
          80af69de-54cb-8c2c-b946-22fe3a95de5c:
            targetId: d5757e57-2923-d632-618d-51405bb9894d
            port: failure
      String_Comparator:
        x: 400
        'y': 520
        navigate:
          fb2b4151-9694-45d2-4d2d-e12574ba5e3c:
            targetId: 400a85f3-592f-d035-92d6-1de4c12db317
            port: success
          0d83b33f-5491-f836-2467-ecc5ab48edbc:
            targetId: d5757e57-2923-d632-618d-51405bb9894d
            port: failure
    results:
      FAILURE:
        d5757e57-2923-d632-618d-51405bb9894d:
          x: 80
          'y': 360
      SUCCESS:
        400a85f3-592f-d035-92d6-1de4c12db317:
          x: 480
          'y': 200
