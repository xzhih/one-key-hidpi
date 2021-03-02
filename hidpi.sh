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

langEnableOp1="(1) Enable HIDPI"
langEnableOp2="(2) Enable HIDPI (with EDID)"
langEnableOp3="(3) Disable HIDPI"

langDisableOpt1="(1) Disable HIDPI on this monitor"
langDisableOpt2="(2) Reset all settings to macOS default"

langChooseRes="resolution config"
langChooseResOp1="(1) 1920x1080 Display"
langChooseResOp2="(2) 1920x1080 Display (use 1424x802, fix underscaled after sleep)"
langChooseResOp3="(3) 1920x1200 Display"
langChooseResOp4="(4) 2560x1440 Display"
langChooseResOp5="(5) 3000x2000 Display"
langChooseResOpCustom="(6) Manual input resolution"

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

    langEnableOp1="(1) 开启HIDPI"
    langEnableOp2="(2) 开启HIDPI(同时注入EDID)"
    langEnableOp3="(3) 关闭HIDPI"

    langDisableOpt1="(1) 在此显示器上禁用 HIDPI"
    langDisableOpt2="(2) 还原所有设置至 macOS 默认"

    langChooseRes="选择分辨率配置"
    langChooseResOp1="(1) 1920x1080 显示屏"
    langChooseResOp2="(2) 1920x1080 显示屏 (使用 1424x802 分辨率，修复睡眠唤醒后的屏幕缩小问题)"
    langChooseResOp3="(3) 1920x1200 显示屏"
    langChooseResOp4="(4) 2560x1440 显示屏"
    langChooseResOp5="(5) 3000x2000 显示屏"
    langChooseResOpCustom="(6) 手动输入分辨率"
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
    
    get_edid
    generate_restore_cmd
}

#
function generate_restore_cmd() {

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
    read -p ":" res
    create_res ${res}
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
    echo ${langEnableOp1}
    echo ${langEnableOp2}
    echo ${langEnableOp3}
    echo ""

    #
    read -p "${langInputChoice} [1~3]: " input
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
}

start
