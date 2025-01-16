namespace: SA_TESTING
flow:
  name: GET_SA_VERSION
  workflow:
    - Get_Unit_VOs:
        do_external:
          15aa115d-c0ed-4712-982d-eeb7365fe456:
            - coreHost: 10.102.21.72
            - coreUsername: admin
            - corePassword:
                value: 'BitA#48ZOhZpW01'
                sensitive: true
            - coreVersion: sas241
            - unitNames: MySQL Server 8.0
        publish:
          - unitFileName
          - unitSoftwareVersion
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Get_Unit_VOs:
        x: 360
        'y': 200
        navigate:
          797da656-bdc5-54c6-08aa-68555d425547:
            targetId: 3644bfaa-2f84-3a61-966d-4ca9714aee3c
            port: failure
          0b29637e-ab93-618a-9277-a6db1f9d389c:
            targetId: 2bb1f643-8f38-4cf2-fdc1-7efdf384b793
            port: success
    results:
      SUCCESS:
        2bb1f643-8f38-4cf2-fdc1-7efdf384b793:
          x: 680
          'y': 240
      FAILURE:
        3644bfaa-2f84-3a61-966d-4ca9714aee3c:
          x: 360
          'y': 360
