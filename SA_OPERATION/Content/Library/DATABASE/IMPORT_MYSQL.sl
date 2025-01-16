########################################################################################################################
#!!
#! @input SilentCommand: Only required for EXE
#!!#
########################################################################################################################
namespace: DATABASE
flow:
  name: IMPORT_MYSQL
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
    - SASoftwarePolicyName: MySQL80
    - SoftwareMajorVersion: '8.0'
    - SoftwareName: MySQL
    - SilentCommand:
        required: false
    - LibraryPath: /Opsware/Database
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
          - success: Get_Software_Version
          - failure: FAILURE
    - Get_Software_Version:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'sudo curl --silent http://repo.nh2system.com/' + SoftwareName + '/server/'+ SoftwareMajorVersion + '/ | grep -oE \">[0-9.]+\" | cut -c 2-8 | sort -nr | head -n 1'}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - getSoftwareVersionResult: '${returnResult}'
        navigate:
          - success: Sleep
          - failure: FAILURE
    - Sleep:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '2'
        navigate:
          - success: Is_Get_Software_Version_Job_Completed
          - failure: FAILURE
    - Is_Get_Software_Version_Job_Completed:
        do_external:
          b9969b26-65f6-49a1-87aa-06d18f28e2ef:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobID: '${jobId}'
        publish:
          - status
        navigate:
          - running: Sleep
          - completed: Get_Software_Version_Result
          - failure: FAILURE
    - Get_Software_Version_Result:
        do_external:
          53605fd8-3656-47f7-8839-57580a0b791f:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobId: '${jobId}'
        publish:
          - fullSoftwareVersion: "${cs_replace(cs_replace(output,\"\\n\",\"\"),\" \",\"\")}"
        navigate:
          - success: Get_Installer
          - failure: FAILURE
    - Get_Installer:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'sudo curl --silent http://repo.nh2system.com/' + SoftwareName + '/server/'+ SoftwareMajorVersion + '/' + fullSoftwareVersion +  '/ | grep -ioE \">[a-zA-Z0-9\\./\\-]+.(msi|exe)\" | cut -c 2-50'}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - getInstallerResult: '${returnResult}'
        navigate:
          - success: Sleep_1
          - failure: FAILURE
    - Sleep_1:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '10'
        navigate:
          - success: Is_Get_Installer_Job_Completed
          - failure: FAILURE
    - Is_Get_Installer_Job_Completed:
        do_external:
          b9969b26-65f6-49a1-87aa-06d18f28e2ef:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobID: '${jobId}'
        publish:
          - status
        navigate:
          - running: Sleep_1
          - completed: Get_Installer_Result
          - failure: FAILURE
    - Get_Installer_Result:
        do_external:
          53605fd8-3656-47f7-8839-57580a0b791f:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobId: '${jobId}'
        publish:
          - softwareInstallerName: "${cs_replace(cs_replace(output,\"\\n\",\"\"),\" \",\"\")}"
        navigate:
          - success: Get_Software_Policy_Items
          - failure: FAILURE
    - Get_Unit_VOs:
        do_external:
          15aa115d-c0ed-4712-982d-eeb7365fe456:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - unitIDs: '${swItemId}'
        publish:
          - oldUnitName: '${name}'
          - oldUnitType: '${unitType}'
          - oldUnitFileName: '${unitFileName}'
          - oldUnitSoftwareVersion: '${unitSoftwareVersion}'
        navigate:
          - success: String_Comparator
          - failure: FAILURE
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${fullSoftwareVersion}'
            - matchTo: '${oldUnitSoftwareVersion}'
            - ignoreCase: 'false'
        navigate:
          - success: SUCCESS
          - failure: Download_Installer
    - Download_Installer:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'sudo curl --silent --create-dirs -o /var/opt/opsware/word/3rdPartySW/' + SoftwareName + '/' + softwareInstallerName + ' http://repo.nh2system.com/' + SoftwareName + '/server/'+ SoftwareMajorVersion + '/' + fullSoftwareVersion +  '/' + softwareInstallerName}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - downloadInstallerResult: '${returnResult}'
        navigate:
          - success: Sleep_2
          - failure: FAILURE
    - Sleep_2:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '10'
        navigate:
          - success: Is_Download_Installer_Job_Completed
          - failure: FAILURE
    - Is_Download_Installer_Job_Completed:
        do_external:
          b9969b26-65f6-49a1-87aa-06d18f28e2ef:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobID: '${jobId}'
        publish:
          - status
        navigate:
          - running: Sleep_2
          - completed: Download_Installer_Result
          - failure: FAILURE
    - Download_Installer_Result:
        do_external:
          53605fd8-3656-47f7-8839-57580a0b791f:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobId: '${jobId}'
        publish:
          - downloadInstallerResult: '${output}'
        navigate:
          - success: Rename_Software
          - failure: FAILURE
    - Import_Software:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'sudo /opt/opsware/software_import/software_import.sh ' + SoftwareName + ' ' + getSoftwareNameResult + ' ' + oldUnitType + '  ' + fullSoftwareVersion + ' ' + LibraryPath}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - importSoftwareResult: '${returnResult}'
        navigate:
          - success: Sleep_3
          - failure: FAILURE
    - Sleep_3:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '10'
        navigate:
          - success: Is_Import_Software_Job_Completed
          - failure: FAILURE
    - Is_Import_Software_Job_Completed:
        do_external:
          b9969b26-65f6-49a1-87aa-06d18f28e2ef:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobID: '${jobId}'
        publish:
          - status
        navigate:
          - running: Sleep_3
          - completed: SUCCESS
          - failure: FAILURE
    - Rename_Software:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'mv /var/opt/opsware/word/3rdPartySW/' + SoftwareName + '/' + softwareInstallerName + ' ' + '/var/opt/opsware/word/3rdPartySW/' + SoftwareName + '/' + SASoftwarePolicyName + '.msi'}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - downloadInstallerResult: '${returnResult}'
        navigate:
          - success: Sleep_6
          - failure: FAILURE
    - Sleep_6:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '10'
        navigate:
          - success: Is_Rename_Software_Job_Completed
          - failure: FAILURE
    - Is_Rename_Software_Job_Completed:
        do_external:
          b9969b26-65f6-49a1-87aa-06d18f28e2ef:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobID: '${jobId}'
        publish:
          - status
        navigate:
          - running: Sleep_6
          - completed: Rename_Software_Result
          - failure: FAILURE
    - Rename_Software_Result:
        do_external:
          53605fd8-3656-47f7-8839-57580a0b791f:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobId: '${jobId}'
        publish:
          - renameSoftwareResult: "${cs_replace(cs_replace(output,\"\\n\",\"\"),\" \",\"\")}"
        navigate:
          - success: Get_Software_Name
          - failure: FAILURE
    - Get_Software_Policy_Items:
        do_external:
          2b806bb7-5f63-4d98-a5f6-fd47703f7925:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - policyName: '${SASoftwarePolicyName}'
            - itemType: UNIT
        publish:
          - swItemId: '${itemId}'
          - swItemName: '${itemName}'
        navigate:
          - success: Get_Unit_VOs
          - failure: FAILURE
    - Get_Software_Name:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'ls /var/opt/opsware/word/3rdPartySW/' + SoftwareName + '/' +SASoftwarePolicyName + '.msi'}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - downloadInstallerResult: '${returnResult}'
        navigate:
          - success: Sleep_7
          - failure: FAILURE
    - Sleep_7:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '10'
        navigate:
          - success: Is_Get_Software_Name_Job_Completed
          - failure: FAILURE
    - Is_Get_Software_Name_Job_Completed:
        do_external:
          b9969b26-65f6-49a1-87aa-06d18f28e2ef:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobID: '${jobId}'
        publish:
          - status
        navigate:
          - running: Sleep_7
          - completed: Get_Software_Name_Result
          - failure: FAILURE
    - Get_Software_Name_Result:
        do_external:
          53605fd8-3656-47f7-8839-57580a0b791f:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - jobId: '${jobId}'
        publish:
          - getSoftwareNameResult: "${cs_replace(cs_replace(output,\"\\n\",\"\"),\" \",\"\")}"
        navigate:
          - success: Import_Software
          - failure: FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Import_Software:
        x: 1120
        'y': 1000
        navigate:
          57885a9a-a59a-a9a4-ecf1-80e9025bc822:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Software_Policy_Items:
        x: 520
        'y': 520
        navigate:
          b7539cde-baac-8539-6a6b-f4f46c4a6969:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Software_Name_Result:
        x: 920
        'y': 1000
        navigate:
          70cc03d5-d88e-db58-de7d-0d81a1bfe05a:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      String_Comparator:
        x: 920
        'y': 520
        navigate:
          b65eda8b-56d3-52d8-9b79-2670fd2a6c0e:
            targetId: 5abaa8e6-5e68-a601-33e0-ca459ef70f0f
            port: success
      Rename_Software:
        x: 1120
        'y': 680
        navigate:
          8222d493-61d3-fd4e-2d8e-cb2dcd60e95f:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Get_Software_Version_Job_Completed:
        x: 720
        'y': 200
        navigate:
          3efc7d2b-a204-946f-0331-95221d6d155d:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Unit_VOs:
        x: 720
        'y': 520
        navigate:
          ac062a78-5603-d41f-7bdb-5c79ecab88c4:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Software_Version:
        x: 240
        'y': 80
        navigate:
          8e67b0a4-b972-6f42-1c6c-af233474d4cf:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Sleep_1:
        x: 720
        'y': 360
        navigate:
          95032351-49d2-a0ec-dee5-b19672d50505:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Sleep_2:
        x: 520
        'y': 680
        navigate:
          d290cab8-b053-02d9-36e8-62ed94022cae:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Sleep_3:
        x: 520
        'y': 1160
        navigate:
          cd22709d-3ed6-2b79-c9ea-8535a6c6001b:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Download_Installer_Result:
        x: 920
        'y': 680
        navigate:
          0762a405-a7bd-c0ae-16d1-8684055cfa06:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Sleep_6:
        x: 520
        'y': 840
        navigate:
          44f2e0b1-2aa2-a902-ec97-b3a9cf00adc5:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Sleep_7:
        x: 520
        'y': 1000
        navigate:
          9ade36d9-dfdc-0271-2477-fc841233f79f:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Get_Software_Name_Job_Completed:
        x: 720
        'y': 1000
        navigate:
          587bf201-e584-8e08-2503-345997b15cf5:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_SA_Version:
        x: 40
        'y': 160
        navigate:
          9a37c43f-61f4-3853-9e0d-acd72d984464:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Download_Installer_Job_Completed:
        x: 720
        'y': 680
        navigate:
          8618fc49-d5bb-2909-a415-437b0a8883eb:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Download_Installer:
        x: 1120
        'y': 520
        navigate:
          d46a1a23-c651-9c3a-9b7b-8df4cdbbfe0d:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Software_Version_Result:
        x: 920
        'y': 200
        navigate:
          5fbc0eb5-0c81-9b95-2ab4-7e3ee63b014c:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Rename_Software_Result:
        x: 920
        'y': 840
        navigate:
          97bcbfdf-76df-68c1-b363-54c482e37089:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Get_Installer_Job_Completed:
        x: 920
        'y': 360
        navigate:
          c7d9fc77-1024-cacb-1a03-ad153601fc2b:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Import_Software_Job_Completed:
        x: 720
        'y': 1160
        navigate:
          7932f814-b39a-ec7e-9aea-5ca3841155eb:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
          6c477007-47c3-e627-177a-6f419e4475e6:
            targetId: 5abaa8e6-5e68-a601-33e0-ca459ef70f0f
            port: completed
      Sleep:
        x: 520
        'y': 200
        navigate:
          f6793e80-6561-abe9-7a1b-5e056a1d5634:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Software_Name:
        x: 1120
        'y': 840
        navigate:
          a4bb3af4-3f6a-a4f3-d8ad-65e881e630f8:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Rename_Software_Job_Completed:
        x: 720
        'y': 840
        navigate:
          a9162eba-e17b-a0f6-2864-9695346bb384:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Installer_Result:
        x: 1120
        'y': 360
        navigate:
          b3641cd0-b9d3-bf46-6d86-aef1b1ef12ef:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Installer:
        x: 520
        'y': 360
        navigate:
          07032648-10c5-5249-6b37-3e3934d45eb4:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
    results:
      FAILURE:
        2962e0db-83bf-42e3-ca86-7708a3f5875d:
          x: 240
          'y': 320
      SUCCESS:
        5abaa8e6-5e68-a601-33e0-ca459ef70f0f:
          x: 1360
          'y': 720
