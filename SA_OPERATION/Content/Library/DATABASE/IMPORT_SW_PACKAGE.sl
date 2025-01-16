########################################################################################################################
#!!
#! @input SilentCommand: Only required for EXE
#!!#
########################################################################################################################
namespace: DATABASE
flow:
  name: IMPORT_SW_PACKAGE
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
    - SASoftwarePolicyName: Wireshark
    - SoftwareName: wireshark
    - SilentCommand:
        default: /S
        required: false
    - LibraryPath: /Package Repository/All Windows
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
          - success: Get_MajorSoftware_Version
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
            - sourceCode: "${'sudo curl --silent http://repo.nh2system.com/' + SoftwareName + '/server/'+ majorSoftwareVersion + '/ | grep -oE \">[0-9.]+\" | cut -c 2-8 | sort -nr | head -n 1'}"
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
            - sourceCode: "${'sudo curl --silent http://repo.nh2system.com/' + SoftwareName + '/server/'+ majorSoftwareVersion + '/' + fullSoftwareVersion +  '/ | grep -ioE \">[a-zA-Z0-9\\./\\-]+.(msi|exe)\" | cut -c 2-50'}"
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
          - success: Get_Software_Policy_Items_1
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
          - oldUnitType: '${cs_regex(unitType,"^(.*?)(?=,)")}'
          - oldUnitFileName: '${unitFileName}'
        navigate:
          - success: String_Comparator
          - failure: FAILURE
    - String_Comparator:
        loop:
          do_external:
            f1dafb35-6463-4a1b-8f87-8aa748497bed:
              - matchType: Exact Match
              - toMatch: '${softwareInstallerName}'
              - matchTo: '${getOldUnitName}'
              - ignoreCase: 'false'
          for: getOldUnitName in oldUnitName
          break:
            - success
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
            - sourceCode: "${'sudo curl --silent --create-dirs -o /var/opt/opsware/word/3rdPartySW/' + SoftwareName + '/' + softwareInstallerName + ' http://repo.nh2system.com/' + SoftwareName + '/server/'+ majorSoftwareVersion + '/' + fullSoftwareVersion +  '/' + softwareInstallerName}"
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
          - success: Import_Software
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
            - sourceCode: "${'sudo /opt/opsware/software_import/software_import.sh \"' + SoftwareName + '\" \"/var/opt/opsware/word/3rdPartySW/' + SoftwareName + '/' + softwareInstallerName + '\" \"' + oldUnitType + '\" \"' + fullSoftwareVersion + '\" \"' + LibraryPath + '\"'}"
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
          - completed: Compare_UnitType
          - failure: FAILURE
    - Get_Unit_VOs_1:
        do_external:
          15aa115d-c0ed-4712-982d-eeb7365fe456:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - unitNames: '${softwareInstallerName}'
        publish:
          - importedUnitFileNames: '${unitFileName}'
          - newUnitType: '${unitType}'
          - newUnitName: '${name}'
          - newUnitFileName: '${unitFileName}'
        navigate:
          - success: Change_InstallFlags
          - failure: FAILURE
    - Compare_UnitType:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contains
            - toMatch: '${oldUnitType}'
            - matchTo: EXE
            - ignoreCase: 'true'
        publish:
          - compareUnitTypeResult: '${returnResult}'
        navigate:
          - success: Get_Unit_VOs_1
          - failure: Get_Unit_VOs_1_1
    - Change_InstallFlags:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: |-
                import sys
                from pytwist import *
                from pytwist.com.opsware.search import Filter
                from pytwist.com.opsware.pkg import ExecutableVO
                from pytwist.com.opsware.pkg import InstallInfo

                # Check for the command-line argument.
                if len(sys.argv) < 2:
                        print("You must specify package name as the search target.")
                #       print("Example: " + sys.argv[0] + " " + ".exe")
                        sys.exit(2)

                # Construct a search filter.
                filter = Filter()
                filter.expression = 'name = "%s" ' % (sys.argv[1])

                # Create a TwistServer object.
                ts = twistserver.TwistServer()

                # Get a reference to ServerService.
                packageService = ts.pkg.ExecutableService

                # Perform the search, returning a tuple of references.
                packages = packageService.findExecutableRefs(filter)

                if len(packages) < 1:
                        print("No matching package found")
                        sys.exit(3)

                # For each server found, get the server’s value object (VO)
                # and print some of the VO’s attributes.
                #desc = 'change this 2222'
                command = sys.argv[2]
                vo = ExecutableVO()
                vo.installInfo = InstallInfo()
                #vo.description = desc
                vo.installInfo.installFlags = command

                for package in packages:
                        packageService.update(package, vo, 1, 0)
                        unit = packageService.getExecutableVO(package)
                        installflags = unit.installInfo.installFlags
                        #print("Name : " + unit.name)
                        print("InstallInfo :" + installflags)
                        #print("FileType :" + unit.fileType)
            - sourceCodeType: PY2
            - scriptArguments: "${softwareInstallerName + ' \\'start /wait \"' + SoftwareName + '\" \\\"%EXE_FULL_NAME%\\\" '+ SilentCommand + '\\''}"
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - changeInstallFlagsResult: '${returnResult}'
        navigate:
          - success: Sleep_4
          - failure: FAILURE
    - Sleep_4:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '2'
        navigate:
          - success: Is_Import_Software_Job_Completed_1
          - failure: FAILURE
    - Is_Import_Software_Job_Completed_1:
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
          - running: Sleep_4
          - completed: Change_InstallFlags_Result
          - failure: FAILURE
    - Change_InstallFlags_Result:
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
          - changeInstallFlagsResult: '${output}'
        navigate:
          - success: Add_Item_to_Software_Policy
          - failure: FAILURE
    - Add_Item_to_Software_Policy:
        do_external:
          3d1bbd20-d90c-4cfc-9151-e0cd56b63477:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - policyName: '${SASoftwarePolicyName}'
            - itemName: '${newUnitName}'
            - itemType: UNIT
        publish:
          - addItemResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
    - Get_Software_Policy_Items_1:
        do_external:
          2b806bb7-5f63-4d98-a5f6-fd47703f7925:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - policyName: '${SASoftwarePolicyName}'
            - itemType: UNIT
        publish:
          - swItemId: '${itemId}'
          - swItemName: '${itemName}'
        navigate:
          - success: Get_Unit_VOs
          - failure: FAILURE
    - Get_Unit_VOs_1_1:
        do_external:
          15aa115d-c0ed-4712-982d-eeb7365fe456:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - unitNames: '${SoftwareName}'
        publish:
          - importedUnitFileNames: '${unitFileName}'
          - newUnitType: '${unitType}'
          - importedNewUnitNames: '${name}'
          - newUnitFileName: '${unitFileName}'
        navigate:
          - success: GET_NEW_UNIT
          - failure: FAILURE
    - Get_MajorSoftware_Version:
        do_external:
          006298d0-cf5b-4f5a-87d6-c88727b795fb:
            - coreHost: '${SACoreHost}'
            - coreUsername: '${SACoreUsername}'
            - corePassword:
                value: '${SACorePassword}'
                sensitive: true
            - coreVersion: '${saCoreVersion}'
            - sourceCode: "${'sudo curl --silent http://repo.nh2system.com/' + SoftwareName + '/server/ | grep -oE \">[0-9.]+\" | cut -c 2-8 | sort -nr | head -n 1'}"
            - sourceCodeType: SH
            - serverNames: PTAWSG-1DCAAP01.PETRONAS.PETRONET.DIR
        publish:
          - jobId
          - getMajorSoftwareVersionResult: '${returnResult}'
        navigate:
          - success: Sleep_5
          - failure: FAILURE
    - Sleep_5:
        do_external:
          d1bbf441-824a-450e-afae-2ddec0e0f35e:
            - seconds: '2'
        navigate:
          - success: Is_Get_Software_Version_Job_Completed_1
          - failure: FAILURE
    - Is_Get_Software_Version_Job_Completed_1:
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
          - running: Sleep_5
          - completed: Get_Software_Version_Result_1
          - failure: FAILURE
    - Get_Software_Version_Result_1:
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
          - majorSoftwareVersion: "${cs_replace(cs_replace(output,\"\\n\",\"\"),\" \",\"\")}"
        navigate:
          - success: Get_Software_Version
          - failure: FAILURE
    - GET_NEW_UNIT:
        loop:
          for: importedUnitName in importedNewUnitNames
          do:
            DATABASE.GET_NEW_UNIT:
              - SACoreHost: '${SACoreHost}'
              - SACoreUsername: '${SACoreUsername}'
              - SACorePassword:
                  value: '${SACorePassword}'
                  sensitive: true
              - SACoreVersion: '${saCoreVersion}'
              - UnitNames: '${importedUnitName}'
              - SoftwareInstallerName: '${softwareInstallerName}'
          break:
            - SUCCESS
          publish:
            - newUnitName
            - compareUnitNameResult
        navigate:
          - SUCCESS: Add_Item_to_Software_Policy
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Import_Software:
        x: 1120
        'y': 680
        navigate:
          57885a9a-a59a-a9a4-ecf1-80e9025bc822:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Change_InstallFlags_Result:
        x: 520
        'y': 1160
        navigate:
          a925c1b8-95cb-a1f4-48f5-7928a0d47023:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      String_Comparator:
        x: 920
        'y': 520
        navigate:
          b65eda8b-56d3-52d8-9b79-2670fd2a6c0e:
            targetId: 5abaa8e6-5e68-a601-33e0-ca459ef70f0f
            port: success
      Get_Software_Version_Result_1:
        x: 840
        'y': 40
        navigate:
          0d56a731-8598-a789-9c0e-1dcfe29456d9:
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
      Is_Import_Software_Job_Completed_1:
        x: 1120
        'y': 1000
        navigate:
          5da9374e-82ed-ec4e-3ee3-685742a24ed2:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Software_Version:
        x: 1040
        'y': 40
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
        'y': 840
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
      Sleep_4:
        x: 920
        'y': 1000
        navigate:
          a58e1e00-b0f3-6b97-e9f4-b6acfb871eae:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Get_Unit_VOs_1_1:
        x: 520
        'y': 1000
        navigate:
          2dc75d4e-646e-aff8-9e21-a9842551767f:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      GET_NEW_UNIT:
        x: 360
        'y': 1040
      Sleep_5:
        x: 440
        'y': 40
        navigate:
          e8b5de59-451b-c0dc-0649-67993f2f9b4b:
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
      Get_MajorSoftware_Version:
        x: 240
        'y': 40
        navigate:
          2b859144-5a77-d124-5ddb-ba8546505e97:
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
      Get_Software_Policy_Items_1:
        x: 520
        'y': 520
        navigate:
          99b4a42a-1f45-4e63-7820-ae1935306898:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Add_Item_to_Software_Policy:
        x: 920
        'y': 1160
        navigate:
          067d3e63-7c4a-df2a-2d20-295715308585:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
          00667011-197b-a0de-5d2a-825f5b7df93e:
            targetId: 5abaa8e6-5e68-a601-33e0-ca459ef70f0f
            port: success
      Is_Get_Installer_Job_Completed:
        x: 920
        'y': 360
        navigate:
          c7d9fc77-1024-cacb-1a03-ad153601fc2b:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Import_Software_Job_Completed:
        x: 720
        'y': 840
        navigate:
          7932f814-b39a-ec7e-9aea-5ca3841155eb:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Sleep:
        x: 520
        'y': 200
        navigate:
          f6793e80-6561-abe9-7a1b-5e056a1d5634:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Compare_UnitType:
        x: 920
        'y': 840
      Get_Unit_VOs_1:
        x: 1120
        'y': 840
        navigate:
          38582ae0-5512-0dd9-2449-9c650f2256a5:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Is_Get_Software_Version_Job_Completed_1:
        x: 640
        'y': 40
        navigate:
          b442c08a-c32c-7f01-8561-b604fef8abe5:
            targetId: 2962e0db-83bf-42e3-ca86-7708a3f5875d
            port: failure
      Change_InstallFlags:
        x: 720
        'y': 1000
        navigate:
          f6a172a9-30c2-4e3d-4043-4ae95fcc53ae:
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
