namespace: DATABASE
flow:
  name: GET_NEW_UNIT
  inputs:
    - SACoreHost
    - SACoreUsername
    - SACorePassword:
        sensitive: true
    - SACoreVersion
    - UnitNames
    - SoftwareInstallerName
  workflow:
    - Get_Unit_VOs:
        do_external:
          15aa115d-c0ed-4712-982d-eeb7365fe456:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${SACoreVersion}'
            - unitNames: "${'\"'+UnitNames+'\"'}"
        publish:
          - newUnitName: '${name}'
          - returnResult
          - newUnitFileName: '${unitFileName}'
        navigate:
          - success: String_Comparator
          - failure: FAILURE
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contains
            - toMatch: '${newUnitFileName}'
            - matchTo: '${SoftwareInstallerName}'
            - ignoreCase: 'false'
        publish:
          - compareUnitNameResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - newUnitName: '${newUnitName}'
    - compareUnitNameResult: '${compareUnitNameResult}'
    - returnResult: '${returnResult}'
    - newUnitFileName: '${newUnitFileName}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Get_Unit_VOs:
        x: 320
        'y': 160
        navigate:
          2dc5d221-187a-caca-d940-c8a6d70b2535:
            targetId: ade4d3a0-c40c-e4a4-1e88-6a9b9e1d2d44
            port: failure
      String_Comparator:
        x: 520
        'y': 160
        navigate:
          4b74d85c-84e2-1b8d-dba9-49f63559e42c:
            targetId: ade4d3a0-c40c-e4a4-1e88-6a9b9e1d2d44
            port: failure
          93d41641-aa89-b31c-32d2-351b59c3b5f5:
            targetId: 1ae6a5eb-af07-d56f-c026-7109e9676d20
            port: success
    results:
      SUCCESS:
        1ae6a5eb-af07-d56f-c026-7109e9676d20:
          x: 720
          'y': 160
      FAILURE:
        ade4d3a0-c40c-e4a4-1e88-6a9b9e1d2d44:
          x: 520
          'y': 400
