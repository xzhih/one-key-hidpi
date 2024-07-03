#!/bin/bash

cat <<EEF
  _    _   _____   _____    _____    _____ 
 | |  | | |_   _| |  __ \  |  __ \  |_   _|
 | |__| |   | |   | |  | | | |__) |   | |  
 |  __  |   | |   | |  | | |  ___/    | |  
 | |  | |  _| |_  | |__| | | |       _| |_ 
 |_|  |_| |_____| |_____/  |_|      |_____|
                                           
============================================
EEF

currentDir="$(cd $(dirname -- $0) && pwd)"
systemLanguage=($(locale | grep LANG | sed s/'LANG='// | tr -d '"' | cut -d "." -f 1))
is_applesilicon=$([[ "$(uname -m)" == "arm64" ]] && echo true || echo false)

langDisplay="Display"
langMonitors="Monitors"
langIndex="Index"
langVendorID="VendorID"
langProductID="ProductID"
langMonitorName="MonitorName"
langChooseDis="Choose the display"
langInputChoice="Enter your choice"
langEnterError="Enter error, bye"
langBackingUp="Backing up..."
langEnabled="Enabled, please reboot."
langDisabled="Disabled, restart takes effect"
langEnabledLog="Rebooting the logo for the first time will become huge, then it will not be."
langCustomRes="Enter the HIDPI resolution, separated by a space，like this: 1680x945 1600x900 1440x810"

langChooseIcon="Display Icon"
langNotChange="Do not change"

langEnableHIDPI="(%d) Enable HIDPI"
langEnableHIDPIEDID="(%d) Enable HIDPI (with EDID)"
langDisableHIDPI="(%d) Disable HIDPI"

langDisableOpt1="(1) Disable HIDPI on this monitor"
langDisableOpt2="(2) Reset all settings to macOS default"

langChooseRes="resolution config"
langChooseResOp1="(1) 1920x1080 Display"
langChooseResOp2="(2) 1920x1080 Display (use 1424x802, fix underscaled after sleep)"
langChooseResOp3="(3) 1920x1200 Display"
langChooseResOp4="(4) 2560x1440 Display"
langChooseResOp5="(5) 3000x2000 Display"
langChooseResOp6="(6) 3440x1440 Display"
langChooseResOpCustom="(7) Manual input resolution"

langNoMonitFound="No monitors were found. Exiting..."
langMonitVIDPID="Your monitor VID:PID:"
if [[ "${systemLanguage}" == "zh_CN" ]]; then
    langDisplay="显示器"
    langMonitors="显示器"
    langIndex="序号"
    langVendorID="供应商ID"
    langProductID="产品ID"
    langMonitorName="显示器名称"
    langChooseDis="选择显示器"
    langInputChoice="输入你的选择"
    langEnterError="输入错误，再见了您嘞！"
    langBackingUp="正在备份(怎么还原请看说明)..."
    langEnabled="开启成功，重启生效"
    langDisabled="关闭成功，重启生效"
    langEnabledLog="首次重启开机logo会变得巨大，之后就不会了"
    langCustomRes="输入想要开启的 HIDPI 分辨率，用空格隔开，就像这样：1680x945 1600x900 1440x810"

    langChooseIcon="选择显示器ICON"
    langNotChange="保持原样"

    langEnableHIDPI="(%d) 开启HIDPI"
    langEnableHIDPIEDID="(%d) 开启HIDPI(同时注入EDID)"
    langDisableHIDPI="(%d) 关闭HIDPI"

    langDisableOpt1="(1) 在此显示器上禁用 HIDPI"
    langDisableOpt2="(2) 还原所有设置至 macOS 默认"

    langChooseRes="选择分辨率配置"
    langChooseResOp1="(1) 1920x1080 显示屏"
    langChooseResOp2="(2) 1920x1080 显示屏 (使用 1424x802 分辨率，修复睡眠唤醒后的屏幕缩小问题)"
    langChooseResOp3="(3) 1920x1200 显示屏"
    langChooseResOp4="(4) 2560x1440 显示屏"
    langChooseResOp5="(5) 3000x2000 显示屏"
    langChooseResOp6="(6) 3440x1440 显示屏"
    langChooseResOpCustom="(7) 手动输入分辨率"

    langNoMonitFound="没有找到监视器。 退出..."
    langMonitVIDPID="您的显示器 供应商ID:产品ID:"
elif [[ "${systemLanguage}" == "uk_UA" ]]; then
    langDisplay="Монітор"
    langMonitors="Монітор"
    langIndex="Номер"
    langVendorID="ID Виробника"
    langProductID="ID Продукту"
    langMonitorName="Імʼя пристрою"
    langChooseDis="Вибери монітор"
    langInputChoice="Введи свій вибір"
    langEnterError="Помилка вводу, бувай..."
    langBackingUp="Зберігаю..."
    langEnabled="Увімкнено! Перезавантаж компʼютер."
    langDisabled="Вимкнено. Перезавантаж компʼютер."
    langEnabledLog="Спочатку логотип виглядатиме великим, далі все виправиться"
    langCustomRes="Введи роздільну здатність HiDPI розділену комами, як на цьому прикладі: 1680x945 1600x900 1440x810"

    langChooseIcon="Вибери піктограму"
    langNotChange="Не змінювати піктограму"

    langEnableHIDPI="(%d) Увімкнути HIDPI"
    langEnableHIDPIEDID="(%d) Увімкнути HIDPI (спробувати увімкнути з використанням EDID)"
    langDisableHIDPI="(%d) Вимкнути HIDPI"

    langDisableOpt1="(1) Вимкнути HIDPI для цього монітору"
    langDisableOpt2="(2) Відновити заводські налаштування macOS"

    langChooseRes="Налаштувати роздільну здатність"
    langChooseResOp1="(1) 1920x1080 монітор"
    langChooseResOp2="(2) 1920x1080 монітор (використовувати 1424x802, виправлення заниженої роздільної здатності після сну)"
    langChooseResOp3="(3) 1920x1200 монітор"
    langChooseResOp4="(4) 2560x1440 монітор"
    langChooseResOp5="(5) 3000x2000 монітор"
    langChooseResOp6="(6) 3440x1440 монітор"
    langChooseResOpCustom="(7) Ввести роздільну здатність вручну"

    langNoMonitFound="Моніторів не знайдено. Завершую роботу..."
    langMonitVIDPID="ID Виробника:ID пристрою твого монітора:"
fi

function get_edid() {
    local index=0
    local selection=0

    gDisplayInf=($(ioreg -lw0 | grep -i "IODisplayEDID" | sed -e "/[^<]*</s///" -e "s/\>//"))

    if [[ "${#gDisplayInf[@]}" -ge 2 ]]; then

        # Multi monitors detected. Choose target monitor.
        echo ""
        echo "                      "${langMonitors}"                      "
        echo "--------------------------------------------------------"
        echo "   "${langIndex}"   |   "${langVendorID}"   |   "${langProductID}"   |   "${langMonitorName}"   "
        echo "--------------------------------------------------------"

        # Show monitors.
        for display in "${gDisplayInf[@]}"; do
            let index++
            MonitorName=("$(echo ${display:190:24} | xxd -p -r)")
            VendorID=${display:16:4}
            ProductID=${display:22:2}${display:20:2}

            if [[ ${VendorID} == 0610 ]]; then
                MonitorName="Apple Display"
            fi

            if [[ ${VendorID} == 1e6d ]]; then
                MonitorName="LG Display"
            fi

            printf "    %d    |    ${VendorID}    |     ${ProductID}    |  ${MonitorName}\n" ${index}
        done

        echo "--------------------------------------------------------"

        # Let user make a selection.

        read -p "${langChooseDis}: " selection
        case $selection in
        [[:digit:]]*)
            # Lower selection (arrays start at zero).
            if ((selection < 1 || selection > index)); then
                echo "${langEnterError}"
                exit 1
            fi
            let selection-=1
            gMonitor=${gDisplayInf[$selection]}
            ;;

        *)
            echo "${langEnterError}"
            exit 1
            ;;
        esac
    else
        gMonitor=${gDisplayInf}
    fi

    EDID=${gMonitor}
    VendorID=$((0x${gMonitor:16:4}))
    ProductID=$((0x${gMonitor:22:2}${gMonitor:20:2}))
    Vid=($(printf '%x\n' ${VendorID}))
    Pid=($(printf '%x\n' ${ProductID}))
    # echo ${Vid}
    # echo ${Pid}
    # echo $EDID
}

# For Apple silicon there is no EDID. Get VID/PID in other way
function get_vidpid_applesilicon() {
    local index=0
    local prodnamesindex=0
    local selection=0

    # Apple ioreg display class
    local appleDisplClass='AppleCLCD2'

    # XPath as key.val
    local value="/following-sibling::*[1]"
    local get="/text()"

    # XPath keys
    local displattr="/key[.='DisplayAttributes']"
    local prodattr="/key[.='ProductAttributes']"
    local vendid="/key[.='LegacyManufacturerID']"
    local prodid="/key[.='ProductID']"
    local prodname="/key[.='ProductName']"

    # VID/PID/Prodname
    local prodAttrsQuery="/$displattr$value$prodattr$value"
    local vendIDQuery="$prodAttrsQuery$vendid$value$get"
    local prodIDQuery="$prodAttrsQuery$prodid$value$get"
    local prodNameQuery="$prodAttrsQuery$prodname$value$get"

    # Get VIDs, PIDs, Prodnames
    # local vends=($(ioreg -arw0 -d1 -c $appleDisplClass | xpath -q -n -e "$vendIDQuery"))
    # local prods=($(ioreg -arw0 -d1 -c $appleDisplClass | xpath -q -n -e "$prodIDQuery"))

    local vends=($(ioreg -l | grep "DisplayAttributes" | sed -n 's/.*"LegacyManufacturerID"=\([0-9]*\).*/\1/p'))
    local prods=($(ioreg -l | grep "DisplayAttributes" | sed -n 's/.*"ProductID"=\([0-9]*\).*/\1/p'))

    set -o noglob
    # IFS=$'\n' prodnames=($(ioreg -arw0 -d1 -c $appleDisplClass | xpath -q -n -e "$prodNameQuery"))
    IFS=$'\n' prodnames=($(ioreg -l | grep "DisplayAttributes" | sed -n 's/.*"ProductName"="\([^"]*\)".*/\1/p'))
    set +o noglob

    if [[ "${#prods[@]}" -ge 2 ]]; then

        # Multi monitors detected. Choose target monitor.
        echo ""
        echo "                      "${langMonitors}"                      "
        echo "------------------------------------------------------------"
        echo "   "${langIndex}"   |   "${langVendorID}"   |   "${langProductID}"   |   "${langMonitorName}"  "
        echo "------------------------------------------------------------"

        # Show monitors.
        for prod in "${prods[@]}"; do
            MonitorName=${prodnames[$prodnamesindex]}
            VendorID=$(printf "%04x" ${vends[$index]})
            ProductID=$(printf "%04x" ${prods[$index]})

            let index++
            let prodnamesindex++

            if [[ ${VendorID} == 0610 ]]; then
                MonitorName="Apple Display"
                # No name in prodnames variable for internal display
                let prodnamesindex--
            fi

            if [[ ${VendorID} == 1e6d ]]; then
                MonitorName="LG Display"
            fi

            printf "    %-3d    |     ${VendorID}     |  %-12s |  ${MonitorName}\n" ${index} ${ProductID}
        done

        echo "------------------------------------------------------------"

        # Let user make a selection.

        read -p "${langChooseDis}: " selection
        case $selection in
        [[:digit:]]*)
            # Lower selection (arrays start at zero).
            if ((selection < 1 || selection > index)); then
                echo "${langEnterError}"
                exit 1
            fi
            let selection-=1
            dispid=$selection
            ;;

        *)
            echo "${langEnterError}"
            exit 1
            ;;
        esac
    else
        # One monitor detected
        dispid=0
    fi

    VendorID=${vends[$dispid]}
    ProductID=${prods[$dispid]}
    Vid=($(printf '%x\n' ${VendorID}))
    Pid=($(printf '%x\n' ${ProductID}))
}

# init
function init() {
    rm -rf ${currentDir}/tmp/
    mkdir -p ${currentDir}/tmp/

    libDisplaysDir="/Library/Displays"
    targetDir="${libDisplaysDir}/Contents/Resources/Overrides"
    sysDisplayDir="/System${targetDir}"
    Overrides="\/Library\/Displays\/Contents\/Resources\/Overrides"
    sysOverrides="\/System${Overrides}"

    if [[ ! -d "${targetDir}" ]]; then
        sudo mkdir -p "${targetDir}"
    fi

    downloadHost="https://raw.githubusercontent.com/xzhih/one-key-hidpi/master"
    if [ -d "${currentDir}/displayIcons" ]; then
        downloadHost="file://${currentDir}"
    fi

    DICON="com\.apple\.cinema-display"
    imacicon=${sysOverrides}"\/DisplayVendorID\-610\/DisplayProductID\-a032\.tiff"
    mbpicon=${sysOverrides}"\/DisplayVendorID\-610\/DisplayProductID\-a030\-e1e1df\.tiff"
    mbicon=${sysOverrides}"\/DisplayVendorID\-610\/DisplayProductID\-a028\-9d9da0\.tiff"
    lgicon=${sysOverrides}"\/DisplayVendorID\-1e6d\/DisplayProductID\-5b11\.tiff"
    proxdricon=${Overrides}"\/DisplayVendorID\-610\/DisplayProductID\-ae2f\_Landscape\.tiff"
    
    if [[ $is_applesilicon == true ]]; then
        get_vidpid_applesilicon
    else
        get_edid
    fi

    # Check if monitor was found
    if [[ -z $VendorID || -z $ProductID || $VendorID == 0 || $ProductID == 0 ]]; then
        echo "$langNoMonitFound"
        exit 2
    fi

    echo "$langMonitVIDPID $Vid:$Pid"

    # Finally generate restore command
    generate_restore_cmd
}

#
function generate_restore_cmd() {

    if [[ $is_applesilicon == true ]]; then
        cat >"$(cd && pwd)/.hidpi-disable" <<-\CCC
#!/bin/bash
function get_vidpid_applesilicon() {
    local index=0
    local prodnamesindex=0
    local selection=0

    # Apple ioreg display class
    local appleDisplClass='AppleCLCD2'

    # XPath as key.val
    local value="/following-sibling::*[1]"
    local get="/text()"

    # XPath keys
    local displattr="/key[.='DisplayAttributes']"
    local prodattr="/key[.='ProductAttributes']"
    local vendid="/key[.='LegacyManufacturerID']"
    local prodid="/key[.='ProductID']"
    local prodname="/key[.='ProductName']"

    # VID/PID/Prodname
    local prodAttrsQuery="/$displattr$value$prodattr$value"
    local vendIDQuery="$prodAttrsQuery$vendid$value$get"
    local prodIDQuery="$prodAttrsQuery$prodid$value$get"
    local prodNameQuery="$prodAttrsQuery$prodname$value$get"

    # Get VIDs, PIDs, Prodnames
    local vends=($(ioreg -arw0 -d1 -c $appleDisplClass | xpath -q -n -e "$vendIDQuery"))
    local prods=($(ioreg -arw0 -d1 -c $appleDisplClass | xpath -q -n -e "$prodIDQuery"))
    set -o noglob
    IFS=$'\n' prodnames=($(ioreg -arw0 -d1 -c $appleDisplClass | xpath -q -n -e "$prodNameQuery"))
    set +o noglob

    if [[ "${#prods[@]}" -ge 2 ]]; then
        echo '              Monitors              '
        echo '------------------------------------'
        echo '  Index  |  VendorID  |  ProductID  '
        echo '------------------------------------'
        # Show monitors.
        for prod in "${prods[@]}"; do
            MonitorName=${prodnames[$prodnamesindex]}
            VendorID=$(printf "%04x" ${vends[$index]})
            ProductID=$(printf "%04x" ${prods[$index]})
            let index++
            let prodnamesindex++
            if [[ ${VendorID} == 0610 ]]; then
                MonitorName="Apple Display"
                let prodnamesindex--
            fi
            printf "    %d    |    ${VendorID}    |     ${ProductID}    |  ${MonitorName}\n" ${index}
        done

        echo "------------------------------------"

        # Let user make a selection.

        read -p "Choose the display:" selection
        case $selection in
        [[:digit:]]*)
            if ((selection < 1 || selection > index)); then
                echo "Enter error, bye"
                exit 1
            fi
            let selection-=1
            dispid=$selection
            ;;

        *)
            echo "Enter error, bye"
            exit 1
            ;;
        esac
    else
        # One monitor detected
        dispid=0
    fi

    VendorID=${vends[$dispid]}
    ProductID=${prods[$dispid]}
    Vid=($(printf '%x\n' ${VendorID}))
    Pid=($(printf '%x\n' ${ProductID}))
}

get_vidpid_applesilicon

CCC
    else
        cat >"$(cd && pwd)/.hidpi-disable" <<-\CCC
#!/bin/sh
function get_edid() {
    local index=0
    local selection=0
    gDisplayInf=($(ioreg -lw0 | grep -i "IODisplayEDID" | sed -e "/[^<]*</s///" -e "s/\>//"))
    if [[ "${#gDisplayInf[@]}" -ge 2 ]]; then
        echo '              Monitors              '
        echo '------------------------------------'
        echo '  Index  |  VendorID  |  ProductID  '
        echo '------------------------------------'
        for display in "${gDisplayInf[@]}"; do
            let index++
            printf "    %d    |    ${display:16:4}    |    ${display:22:2}${display:20:2}\n" $index
        done
        echo '------------------------------------'
        read -p "Choose the display: " selection
        case $selection in
        [[:digit:]]*)
            if ((selection < 1 || selection > index)); then
                echo "Enter error, bye"
                exit 1
            fi
            let selection-=1
            gMonitor=${gDisplayInf[$selection]}
            ;;
        *)
            echo "Enter error, bye"
            exit 1
            ;;
        esac
    else
        gMonitor=${gDisplayInf}
    fi

    EDID=$gMonitor
    VendorID=$((0x${gMonitor:16:4}))
    ProductID=$((0x${gMonitor:22:2}${gMonitor:20:2}))
    Vid=($(printf '%x\n' ${VendorID}))
    Pid=($(printf '%x\n' ${ProductID}))
}

get_edid

CCC
    fi

    cat >>"$(cd && pwd)/.hidpi-disable" <<-\CCC
# Check if monitor was found
if [[ -z $VendorID || -z $ProductID || $VendorID == 0 || $ProductID == 0 ]]; then
    echo "No monitors found. Exiting..."
    exit 2
fi

echo "Your monitor VID/PID: $Vid:$Pid"

rootPath="../.."
restorePath="${rootPath}/Library/Displays/Contents/Resources/Overrides"

echo ""
echo "(1) Disable HIDPI on this monitor"
echo "(2) Reset all settings to macOS default"
echo ""

read -p "Enter your choice [1~2]: " input
case ${input} in
1)
    if [[ -f "${restorePath}/Icons.plist" ]]; then
        ${rootPath}/usr/libexec/plistbuddy -c "Delete :vendors:${Vid}:products:${Pid}" "${restorePath}/Icons.plist"
    fi
    if [[ -d "${restorePath}/DisplayVendorID-${Vid}" ]]; then
        rm -rf "${restorePath}/DisplayVendorID-${Vid}"
    fi
    ;;
2)
    rm -rf "${restorePath}"
    ;;
*)

    echo "Enter error, bye"
    exit 1
    ;;
esac

echo "HIDPI Disabled"
CCC

    chmod +x "$(cd && pwd)/.hidpi-disable"

}

# choose_icon
function choose_icon() {

    rm -rf ${currentDir}/tmp/
    mkdir -p ${currentDir}/tmp/
    mkdir -p ${currentDir}/tmp/DisplayVendorID-${Vid}
    curl -fsSL "${downloadHost}/Icons.plist" -o ${currentDir}/tmp/Icons.plist

    echo ""
    echo "-------------------------------------"
    echo "|********** ${langChooseIcon} ***********|"
    echo "-------------------------------------"
    echo ""
    echo "(1) iMac"
    echo "(2) MacBook"
    echo "(3) MacBook Pro"
    echo "(4) LG ${langDisplay}"
    echo "(5) Pro Display XDR"
    echo "(6) ${langNotChange}"
    echo ""

    read -p "${langInputChoice} [1~6]: " logo
    case ${logo} in
    1)
        Picon=${imacicon}
        RP=("33" "68" "160" "90")
        curl -fsSL "${downloadHost}/displayIcons/iMac.icns" -o ${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    2)
        Picon=${mbicon}
        RP=("52" "66" "122" "76")
        curl -fsSL "${downloadHost}/displayIcons/MacBook.icns" -o ${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    3)
        Picon=${mbpicon}
        RP=("40" "62" "147" "92")
        curl -fsSL "${downloadHost}/displayIcons/MacBookPro.icns" -o ${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    4)
        Picon=${lgicon}
        RP=("11" "47" "202" "114")
        cp ${sysDisplayDir}/DisplayVendorID-1e6d/DisplayProductID-5b11.icns ${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    5)
        Picon=${proxdricon}
        RP=("5" "45" "216" "121")
        curl -fsSL "${downloadHost}/displayIcons/ProDisplayXDR.icns" -o ${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        if [[ ! -f ${targetDir}/DisplayVendorID-610/DisplayProductID-ae2f_Landscape.tiff ]]; then
            curl -fsSL "${downloadHost}/displayIcons/ProDisplayXDR.tiff" -o ${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.tiff
            Picon=${Overrides}"\/DisplayVendorID\-${Vid}\/DisplayProductID\-${Pid}\.tiff"
        fi
        ;;
    6)
        rm -rf ${currentDir}/tmp/Icons.plist
        ;;
    *)

        echo "${langEnterError}"
        exit 1
        ;;
    esac

    if [[ ${Picon} ]]; then
        DICON=${Overrides}"\/DisplayVendorID\-${Vid}\/DisplayProductID\-${Pid}\.icns"
        /usr/bin/sed -i "" "s/VID/${Vid}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/PID/${Pid}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/RPX/${RP[0]}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/RPY/${RP[1]}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/RPW/${RP[2]}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/RPH/${RP[3]}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/PICON/${Picon}/g" ${currentDir}/tmp/Icons.plist
        /usr/bin/sed -i "" "s/DICON/${DICON}/g" ${currentDir}/tmp/Icons.plist
    fi

}

# main
function main() {
    sudo mkdir -p ${currentDir}/tmp/DisplayVendorID-${Vid}
    dpiFile=${currentDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}
    sudo chmod -R 777 ${currentDir}/tmp/

    cat >"${dpiFile}" <<-\CCC
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>DisplayProductID</key>
            <integer>PID</integer>
        <key>DisplayVendorID</key>
            <integer>VID</integer>
        <key>IODisplayEDID</key>
            <data>EDid</data>
        <key>scale-resolutions</key>
            <array>
CCC

    echo ""
    echo "------------------------------------------"
    echo "|********** "${langChooseRes}" ***********|"
    echo "------------------------------------------"
    echo ${langChooseResOp1}
    echo ${langChooseResOp2}
    echo ${langChooseResOp3}
    echo ${langChooseResOp4}
    echo ${langChooseResOp5}
    echo ${langChooseResOp6}
    echo ${langChooseResOpCustom}
    echo ""

    read -p "${langInputChoice}: " res
    case ${res} in
    1)
        create_res_1 1680x945 1440x810 1280x720 1024x576
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
        ;;
    2)
        create_res_1 1680x945 1424x802 1280x720 1024x576
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
        ;;
    3)
        create_res_1 1680x1050 1440x900 1280x800 1024x640
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x1050 1440x900 1280x800 1024x640 960x540 840x472 800x450 640x360
        ;;
    4)
        create_res_1 2560x1440 2048x1152 1920x1080 1760x990 1680x945 1440x810 1360x765 1280x720
        create_res_2 1360x765 1280x800 1280x720 1024x576 960x600 960x540 640x360
        create_res_3 960x540 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 2048x1152 1920x1080 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
        ;;
    5)
        create_res_1 3000x2000 2880x1920 2250x1500 1920x1280 1680x1050 1440x900 1280x800 1024x640
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1920x1280 1680x1050 1440x900 1280x800 1024x640 960x540 840x472 800x450 640x360
        ;;
    6)
        # Scale factors
        # res 1 scf: 1         1.25      1.3333    1.4545   1.7777   2
        create_res_1 3440x1440 2752x1152 2580x1080 2365x990 1935x810 1720x720
        # res 2 scf: 2        2.6666
        create_res_2 1720x720 1290x540
        # res 3 scf: 2.6666
        create_res_3 1290x540
        # res 4 scf: 1.25      1.3333    1.4545   1.7777   2        2.6666
        create_res_4 2752x1152 2580x1080 2365x990 1935x810 1720x720 1290x540
        ;;
    7)
        custom_res
        create_res_2 1360x765 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
        ;;
    *)
        echo "${langEnterError}"
        exit 1
        ;;
    esac

    cat >>"${dpiFile}" <<-\FFF
            </array>
        <key>target-default-ppmm</key>
            <real>10.0699301</real>
    </dict>
</plist>
FFF

    /usr/bin/sed -i "" "s/VID/$VendorID/g" ${dpiFile}
    /usr/bin/sed -i "" "s/PID/$ProductID/g" ${dpiFile}
}

# end
function end() {
    sudo chown -R root:wheel ${currentDir}/tmp/
    sudo chmod -R 0755 ${currentDir}/tmp/
    sudo chmod 0644 ${currentDir}/tmp/DisplayVendorID-${Vid}/*
    sudo cp -r ${currentDir}/tmp/* ${targetDir}/
    sudo rm -rf ${currentDir}/tmp
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool YES
    echo "${langEnabled}"
    echo "${langEnabledLog}"
}

# custom resolution
function custom_res() {
    echo "${langCustomRes}"
    read -p ":" input_resolutions
    
    # Split the input into an array
    IFS=' ' read -r -a resolution_array <<< "$input_resolutions"
    
    # Call the create_res function with the array elements
    create_res "${resolution_array[@]}"
}

# create resolution
function create_res() {
    for res in $@; do
        width=$(echo ${res} | cut -d x -f 1)
        height=$(echo ${res} | cut -d x -f 2)
        hidpi=$(printf '%08x %08x' $((${width} * 2)) $((${height} * 2)) | xxd -r -p | base64)
        #
        cat <<OOO >>${dpiFile}
                <data>${hidpi:0:11}AAAAB</data>
                <data>${hidpi:0:11}AAAABACAAAA==</data>
OOO
    done
}

function create_res_1() {
    for res in $@; do
        width=$(echo ${res} | cut -d x -f 1)
        height=$(echo ${res} | cut -d x -f 2)
        hidpi=$(printf '%08x %08x' $((${width} * 2)) $((${height} * 2)) | xxd -r -p | base64)
        #
        cat <<OOO >>${dpiFile}
                <data>${hidpi:0:11}A</data>
OOO
    done
}

function create_res_2() {
    for res in $@; do
        width=$(echo ${res} | cut -d x -f 1)
        height=$(echo ${res} | cut -d x -f 2)
        hidpi=$(printf '%08x %08x' $((${width} * 2)) $((${height} * 2)) | xxd -r -p | base64)
        #
        cat <<OOO >>${dpiFile}
                <data>${hidpi:0:11}AAAABACAAAA==</data>
OOO
    done
}

function create_res_3() {
    for res in $@; do
        width=$(echo ${res} | cut -d x -f 1)
        height=$(echo ${res} | cut -d x -f 2)
        hidpi=$(printf '%08x %08x' $((${width} * 2)) $((${height} * 2)) | xxd -r -p | base64)
        #
        cat <<OOO >>${dpiFile}
                <data>${hidpi:0:11}AAAAB</data>
OOO
    done
}

function create_res_4() {
    for res in $@; do
        width=$(echo ${res} | cut -d x -f 1)
        height=$(echo ${res} | cut -d x -f 2)
        hidpi=$(printf '%08x %08x' $((${width} * 2)) $((${height} * 2)) | xxd -r -p | base64)
        #
        cat <<OOO >>${dpiFile}
                <data>${hidpi:0:11}AAAAJAKAAAA==</data>
OOO
    done
}

# enable
function enable_hidpi() {
    choose_icon
    main
    sed -i "" "/.*IODisplayEDID/d" ${dpiFile}
    sed -i "" "/.*EDid/d" ${dpiFile}
    end
}

# patch
function enable_hidpi_with_patch() {
    choose_icon
    main

    version=${EDID:38:2}
    basicparams=${EDID:40:2}
    checksum=${EDID:254:2}
    newchecksum=$(printf '%x' $((0x${checksum} + 0x${version} + 0x${basicparams} - 0x04 - 0x90)) | tail -c 2)
    newedid=${EDID:0:38}0490${EDID:42:6}e6${EDID:50:204}${newchecksum}
    EDid=$(printf ${newedid} | xxd -r -p | base64)

    /usr/bin/sed -i "" "s:EDid:${EDid}:g" ${dpiFile}
    end
}

# disable
function disable() {
    echo ""
    echo "${langDisableOpt1}"
    echo "${langDisableOpt2}"
    echo ""

    read -p "${langInputChoice} [1~2]: " input
    case ${input} in
    1)
        if [[ -f "${targetDir}/Icons.plist" ]]; then
            sudo /usr/libexec/plistbuddy -c "Delete :vendors:${Vid}:products:${Pid}" "${targetDir}/Icons.plist"
        fi
        if [[ -d "${targetDir}/DisplayVendorID-${Vid}" ]]; then
            sudo rm -rf "${targetDir}/DisplayVendorID-${Vid}"
        fi
        ;;
    2)
        sudo rm -rf "${targetDir}"
        ;;
    *)

        echo "${langEnterError}"
        exit 1
        ;;
    esac

    echo "${langDisabled}"
}

#
function start() {
    init
    echo ""
    let opt++; printf "${langEnableHIDPI}\n" $opt
    if [[ $is_applesilicon == false ]]; then
        let opt++; printf "${langEnableHIDPIEDID}\n" $opt
    fi
    let opt++; printf "${langDisableHIDPI}\n" $opt
    echo ""

    read -p "${langInputChoice} [1~$opt]: " input
    if [[ $is_applesilicon == true ]]; then
        case ${input} in
        1)
            enable_hidpi
            ;;
        2)
            disable
            ;;
        *)
            echo "${langEnterError}"
            exit 1
            ;;
        esac
    else
        case ${input} in
        1)
            enable_hidpi
            ;;
        2)
            enable_hidpi_with_patch
            ;;
        3)
            disable
            ;;
        *)
            echo "${langEnterError}"
            exit 1
            ;;
        esac
    fi
}

start
