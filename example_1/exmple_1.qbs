import qbs
import qbs.FileInfo
import qbs.ModUtils

CppApplication {

    name: "example_1"
    type: [
        "application",
        "bin",
        "hex"
    ]

    Depends {
        name: "cpp"
    }

    consoleApplication: true
    cpp.positionIndependentCode: false
    cpp.executableSuffix: ".elf"

    property string Home: path
    property string FreeRTOS: Home + "/Middlewares/Third_Party/FreeRTOS"
    property string CMSIS_RTOS: FreeRTOS + "/Source/CMSIS_RTOS"
    property string HAL: Home + "/Drivers/STM32F7xx_HAL_Driver"
    property string CMSIS: Home + "/Drivers/CMSIS"
    property string Inc: Home + "/Inc"
    property string Src: Home + "/Src"
    property string Startup: Home
    property string LD: Home
    property string LwIP: Home + "/Middlewares/Third_Party/LwIP"
    property string BSP: Home + "/Drivers/BSP/STM32746G-Discovery"
    property string Utilities: Home + "/Utilities"
    property string chargen: Home + "/chargen"

    Group {
        name: "chargen"
        prefix: chargen
        files: [
            "/*.c",
            "/*.h"
        ]
    }

    Group {
        name: "BSP"
        prefix: BSP
        files: [
            "/*.c",
            "/*.h"
        ]
    }

    Group {
        name: "Utilities"
        prefix: Utilities
        files: [
            "/Fonts/*.h",
            "/Log/*.h",
            "/Log/*.c"
        ]
        excludeFiles : [
            "/Log/lcd_log_conf_template.h"
        ]
    }

    Group {
        name: "LwIP"
        prefix: LwIP
        files: [
            "/src/include/*/*.h",
            "/src/include/*/*/*.h",
            "/src/netif/*.c",
            "/system/*.h",
            "/system/OS/*.h",
            "/src/api/*.c",
            "/src/core/*.c",
            "/src/api/*.c",
            "/src/core/ipv4/*.c",
            "/system/OS/*.c",
            "/src/apps/httpd/*.c",
            "/src/apps/httpd/*.h"
        ]
        excludeFiles: [
            "/src/apps/httpd/fsdata.c",
        ]
    }

    Group {
        name: "FreRTOS"
        prefix: FreeRTOS
        files: [
            "/Source/*.c",
            "/Source/include/*.h",
            "/Source/portable/GCC/ARM_CM7/r0p1/*.h",
            "/Source/portable/GCC/ARM_CM7/r0p1/*.c",
            "/Source/portable/Common/mpu_wrappers.c",
            "/Source/portable/MemMang/heap_4.c"
        ]
    }

    Group {
        name: "CMSIS_RTOS"
        prefix: CMSIS_RTOS
        files: [
            "/*.c",
            "/*.h"
        ]
    }

    Group {
        name: "HAL"
        prefix: HAL
        files: [
            "/Src/*.c",
            "/Inc/*.h",
            "/Inc/Legacy/*.h",
        ]
        excludeFiles: [
            "/Src/stm32f7xx_hal_timebase_rtc_alarm_template.c",
            "/Src/stm32f7xx_hal_timebase_rtc_wakeup_template.c",
            "/Src/stm32f7xx_hal_timebase_tim_template.c"
        ]
    }

    Group {
        name: "CMSIS"
        prefix: CMSIS
        files: [
            "/Include/*.h",
            "/Device/ST/STM32F7xx/Source/Templates/*",
            "/Device/ST/STM32F7xx/Include/*.h"
        ]
        excludeFiles: [
            "/Device/ST/STM32F7xx/Source/Templates/system_stm32f7xx.c"
        ]
    }

    Group {
        name: "Inc"
        files: [
            Inc + "/*.h",
        ]
    }

    Group {
        name: "Src"
        prefix: Src
        files: [
            "/*.c",
            "/*.cpp"
        ]
    }

    Group {
        name: "Startup"
        prefix: Startup
        files: [
            "/*.s"
        ]
    }

    Group {
        name: "LD"
        prefix: LD
        files: [
            "/*.ld",
        ]
    }

    cpp.includePaths: [
        BSP,
        Utilities + "/Fonts",
        Utilities + "/Log",

        CMSIS + "/Include",
        CMSIS + "/Device/ST/STM32F7xx/Include",

        Src,

        Inc,

        FreeRTOS + "/Source/include",
        FreeRTOS + "/Source/portable/GCC/ARM_CM7/r0p1",
        chargen,

        CMSIS_RTOS,

        HAL + "/Inc",
        HAL + "/Inc/Legacy",

        LwIP + "/src/include",
        LwIP + "/system",
        LwIP + "/system/OS",
        LwIP + "/src/apps/httpd",
        LwIP + "/src/apps"

    ]

    cpp.defines: [
        "USE_HAL_DRIVER",
        "HTTPD_USE_CUSTOM_FSDATA",
        "STM32F746xx",
        "USE_STM32746G_DISCOVERY",
        "__weak=__attribute__((weak))",
        "__packed=__attribute__((__packed__))",

    ]

    cpp.commonCompilerFlags: [
        "-mcpu=cortex-m7",
        "-mfloat-abi=hard",
        "-mfpu=fpv5-d16",
        "-mthumb",
    ]

    cpp.driverFlags: [
        "-mcpu=cortex-m7",
        "-mfloat-abi=hard",
        "-mfpu=fpv5-d16",
        "-mthumb",
        "-Xlinker",
        "--gc-sections",
        "-specs=nosys.specs",
        "-specs=nano.specs",
        "-Wl,-Map=" + path + "/../QT-STM32746G-Discovery.map",
    ]

    cpp.linkerFlags: [
        "--start-group",
        "-T" + path + "/STM32F746NGHx_FLASH.ld",
    ]


    Properties {
        condition: qbs.buildVariant === "debug"
        cpp.debugInformation: true
        cpp.optimization: "none"
    }

    Properties {
        condition: cpp.debugInformation
        cpp.defines: outer.concat("DEBUG")
    }

    Group {
        fileTagsFilter: product.type
        qbs.install: true
    }

    Rule {
        id: binDebugFrmw
        condition: qbs.buildVariant === "debug"
        inputs: ["application"]

        Artifact {
            fileTags: ["bin"]
            filePath: input.baseDir + "/" + input.baseName + ".bin"
        }

        prepare: {
            var objCopyPath = "arm-none-eabi-objcopy"
            var argsConv = ["-O", "binary", input.filePath, output.filePath]
            var cmd = new Command(objCopyPath, argsConv)
            cmd.description = "converting to BIN: " + FileInfo.fileName(
                        input.filePath) + " -> " + input.baseName + ".bin"
            return [cmd]
        }
    }
}
