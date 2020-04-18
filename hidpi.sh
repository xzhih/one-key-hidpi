#!/bin/bash

sipInfo=("$(csrutil status)")
systemVersion=($(sw_vers -productVersion | cut -d "." -f 2))
systemLanguage=($(locale | grep LANG | sed s/'LANG='// | tr -d '"' | cut -d "." -f 1))

disableSIP="Need to disable SIP"
langRemoteMode="Remote Mode"
langLocalMode="Local Mode"
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

langChooseRes="resolution config"
langChooseResOp1="(1) 1920x1080 Display"
langChooseResOp2="(2) 1920x1080 Display (use 1424x802, fix underscaled after sleep)"
langChooseResOp3="(3) 1920x1200 Display"
langChooseResOp4="(4) 2560x1440 Display"
langChooseResOp5="(5) 3000x2000 Display"
langChooseResOpCustom="(6) Manual input resolution"

if [[ "${systemLanguage}" == "zh_CN" ]]; then 
    disableSIP="需要关闭 SIP"
    langRemoteMode="远程模式"
    langLocalMode="本地模式"
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

    langChooseRes="选择分辨率配置"
    langChooseResOp1="(1) 1920x1080 显示屏"
    langChooseResOp2="(2) 1920x1080 显示屏 (使用 1424x802 分辨率，修复睡眠唤醒后的屏幕缩小问题)"
    langChooseResOp3="(3) 1920x1200 显示屏"
    langChooseResOp4="(4) 2560x1440 显示屏"
    langChooseResOp5="(5) 3000x2000 显示屏"
    langChooseResOpCustom="(6) 手动输入分辨率"
fi

downloadHost="https://raw.githubusercontent.com/xzhih/one-key-hidpi/master"
# downloadHost="https://raw.githubusercontent.com/xzhih/one-key-hidpi/dev"
# downloadHost="http://127.0.0.1:8080"

shellDir="$(dirname $0)"

if [ -d "${shellDir}/displayIcons" ];then
    echo $langLocalMode
    downloadHost="file://${shellDir}"
else
    echo $langRemoteMode
fi

if [[ "${sipInfo}" == *"Filesystem Protections: disabled"* ]] || [[ "$(awk '{print $5}' <<< "${sipInfo}")" == "disabled." ]] || [[ "$(awk '{print $5}' <<< "${sipInfo}")" == "disabled" ]]; then
    :
else
    echo "${disableSIP}";
    exit 0
fi

if [[ "${systemVersion}" -ge "15" ]]; then
    sudo mount -uw / && killall Finder
fi

function get_edid()
{
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
        for display in "${gDisplayInf[@]}"
        do
            let index++
            MonitorName=("$(echo ${display:190:24} | xxd -p -r)") 
            VendorID=${display:16:4}
            ProductID=${gMonitor:22:2}${gMonitor:20:2}

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
            [[:digit:]]* ) 
                # Lower selection (arrays start at zero).
                if ((selection < 1 || selection > index)); then
                    echo "${langEnterError}";
                    exit 0
                fi
                let selection-=1
                gMonitor=${gDisplayInf[$selection]}
                ;;

            * ) 
                echo "${langEnterError}";
                exit 0
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
function init()
{
#
cat << EEF
  _    _   _____   _____    _____    _____ 
 | |  | | |_   _| |  __ \  |  __ \  |_   _|
 | |__| |   | |   | |  | | | |__) |   | |  
 |  __  |   | |   | |  | | |  ___/    | |  
 | |  | |  _| |_  | |__| | | |       _| |_ 
 |_|  |_| |_____| |_____/  |_|      |_____|
                                           
============================================
EEF
    #
    get_edid

    thisDir=$(dirname $0)
    thatDir="/System/Library/Displays/Contents/Resources/Overrides"
    Overrides="\/System\/Library\/Displays\/Contents\/Resources\/Overrides"
    
    DICON="com\.apple\.cinema-display"
    imacicon=${Overrides}"\/DisplayVendorID\-610\/DisplayProductID\-a032\.tiff"
    mbpicon=${Overrides}"\/DisplayVendorID\-610\/DisplayProductID\-a030\-e1e1df\.tiff"
    mbicon=${Overrides}"\/DisplayVendorID\-610\/DisplayProductID\-a028\-9d9da0\.tiff"
    lgicon=${Overrides}"\/DisplayVendorID\-1e6d\/DisplayProductID\-5b11\.tiff"
    proxdricon=${Overrides}"\/DisplayVendorID\-610\/DisplayProductID\-ae2f\_Landscape\.tiff"

    if [[ ! -d ${thatDir}/HIDPI/backup ]]; then
        echo "${langBackingUp}"
        sudo mkdir -p ${thatDir}/HIDPI/backup
        sudo cp ${thatDir}/Icons.plist ${thatDir}/HIDPI/backup/
        if [[ -d ${thatDir}/DisplayVendorID-${Vid} ]]; then
            sudo cp -r ${thatDir}/DisplayVendorID-${Vid} ${thatDir}/HIDPI/backup/
        fi
    fi
    
    generate_restore_cmd
}

#
function generate_restore_cmd()
{
#
rm -rf ${thisDir}/tmp/
mkdir -p ${thisDir}/tmp/
cat > "${thisDir}/tmp/disable" <<-\CCC
#!/bin/sh

function get_edid()
{
    local index=0
    local selection=0
    gDisplayInf=($(ioreg -lw0 | grep -i "IODisplayEDID" | sed -e "/[^<]*</s///" -e "s/\>//"))
    if [[ "${#gDisplayInf[@]}" -ge 2 ]]; then
        echo '              Monitors              '
        echo '------------------------------------'
        echo '  Index  |  VendorID  |  ProductID  '
        echo '------------------------------------'
        for display in "${gDisplayInf[@]}"
        do
            let index++
            printf "    %d    |    ${display:16:4}    |    ${gMonitor:22:2}${gMonitor:20:2}\n" $index
        done
        echo '------------------------------------'
        read -p "Choose the display: " selection
        case $selection in
            [[:digit:]]* ) 
                if ((selection < 1 || selection > index)); then
                    echo "Enter error, bye";
                    exit 0
                fi
                let selection-=1
                gMonitor=${gDisplayInf[$selection]}
                ;;
            * ) 
                echo "Enter error, bye";
                exit 0
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

if [[ -d ../DisplayVendorID-${Vid} ]]; then
    rm -rf ../DisplayVendorID-${Vid} 
fi

rm -rf ../Icons.plist
cp -r ./backup/* ../
rm -rf ./disable
echo "HIDPI Disabled"
CCC

sudo mv ${thisDir}/tmp/disable ${thatDir}/HIDPI/
sudo chmod +x ${thatDir}/HIDPI/disable

}

# choose_icon
function choose_icon()
{
    #
    rm -rf ${thisDir}/tmp/
    mkdir -p ${thisDir}/tmp/
    mkdir -p ${thisDir}/tmp/DisplayVendorID-${Vid}
    curl -fsSL "${downloadHost}/Icons.plist" -o ${thisDir}/tmp/Icons.plist

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
#
read -p "${langInputChoice} [1~6]: " logo
case ${logo} in
    1) Picon=${imacicon}
        RP=("33" "68" "160" "90")
        curl -fsSL "${downloadHost}/displayIcons/iMac.icns" -o ${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    2) Picon=${mbicon}
        RP=("52" "66" "122" "76")
        curl -fsSL "${downloadHost}/displayIcons/MacBook.icns" -o ${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    3) Picon=${mbpicon}
        RP=("40" "62" "147" "92")
        curl -fsSL "${downloadHost}/displayIcons/MacBookPro.icns" -o ${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    4) Picon=${lgicon}
        RP=("11" "47" "202" "114")
        cp ${thatDir}/DisplayVendorID-1e6d/DisplayProductID-5b11.icns ${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        ;;
    5) Picon=${proxdricon}
        RP=("5" "45" "216" "121")
        curl -fsSL "${downloadHost}/displayIcons/ProDisplayXDR.icns" -o ${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.icns
        if [[ ! -f ${thatDir}/DisplayVendorID-610/DisplayProductID-ae2f_Landscape.tiff ]]; then
            curl -fsSL "${downloadHost}/displayIcons/ProDisplayXDR.tiff" -o ${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}.tiff
            Picon=${Overrides}"\/DisplayVendorID\-${Vid}\/DisplayProductID\-${Pid}\.tiff"
        fi
        ;;
    6) rm -rf ${thisDir}/tmp/Icons.plist
        ;;
    *)

    echo "${langEnterError}";
    exit 0
    ;;
esac 

if [[ ${Picon} ]]; then
    DICON=${Overrides}"\/DisplayVendorID\-${Vid}\/DisplayProductID\-${Pid}\.icns"
    /usr/bin/sed -i "" "s/VID/${Vid}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/PID/${Pid}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPX/${RP[0]}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPY/${RP[1]}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPW/${RP[2]}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPH/${RP[3]}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/PICON/${Picon}/g" ${thisDir}/tmp/Icons.plist
    /usr/bin/sed -i "" "s/DICON/${DICON}/g" ${thisDir}/tmp/Icons.plist
fi

}

# main
function main()
{
    sudo mkdir -p ${thisDir}/tmp/DisplayVendorID-${Vid}
    dpiFile=${thisDir}/tmp/DisplayVendorID-${Vid}/DisplayProductID-${Pid}
    sudo chmod -R 777 ${thisDir}/tmp/

# 
cat > "${dpiFile}" <<-\CCC
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

#
read -p "${langInputChoice}: " res
case ${res} in
    1 ) create_res_1 1680x945 1440x810 1280x720 1024x576
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
    ;;
    2 ) create_res_1 1680x945 1424x802 1280x720 1024x576
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
    ;;
    3 ) create_res_1 1680x1050 1440x900 1280x800 1024x640
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x1050 1440x900 1280x800 1024x640 960x540 840x472 800x450 640x360
    ;;
    4 ) create_res_1 2560x1440 2048x1152 1920x1080 1760x990 1680x945 1440x810 1360x765 1280x720
        create_res_2 1360x765 1280x800 1280x720 1024x576 960x600 960x540 640x360
        create_res_3 960x540 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 2048x1152 1920x1080 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
    ;;
    5 ) create_res_1 3000x2000 2880x1920 2250x1500 1920x1280 1680x1050 1440x900 1280x800 1024x640
        create_res_2 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1920x1280 1680x1050 1440x900 1280x800 1024x640 960x540 840x472 800x450 640x360
    ;;
    6 ) custom_res
        create_res_2 1360x765 1280x800 1280x720 960x600 960x540 640x360
        create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
        create_res_4 1680x945 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360
    ;;
    *)
    echo "${langEnterError}";
    exit 0
    ;;
esac

cat >> "${dpiFile}" <<-\FFF
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
function end()
{
    sudo chown -R root:wheel ${thisDir}/tmp/
    sudo chmod -R 0755 ${thisDir}/tmp/
    sudo chmod 0644 ${thisDir}/tmp/DisplayVendorID-${Vid}/*
    sudo cp -r ${thisDir}/tmp/* ${thatDir}/
    sudo rm -rf ${thisDir}/tmp
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool YES
    echo "${langEnabled}"
    echo "${langEnabledLog}"
}

# custom resolution
function custom_res()
{
    echo "${langCustomRes}"
    read -p ":" res
    create_res ${res}
}

# create resolution
function create_res()
{
    for res in $@; do
    width=$(echo ${res} | cut -d x -f 1)
    height=$(echo ${res} | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $((${width}*2)) $((${height}*2)) | xxd -r -p | base64)
#
cat << OOO >> ${dpiFile}
                <data>${hidpi:0:11}AAAAB</data>
                <data>${hidpi:0:11}AAAABACAAAA==</data>
OOO
done
}

function create_res_1()
{
    for res in $@; do
    width=$(echo ${res} | cut -d x -f 1)
    height=$(echo ${res} | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $((${width}*2)) $((${height}*2)) | xxd -r -p | base64)
#
cat << OOO >> ${dpiFile}
                <data>${hidpi:0:11}A</data>
OOO
done
}

function create_res_2()
{
    for res in $@; do
    width=$(echo ${res} | cut -d x -f 1)
    height=$(echo ${res} | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $((${width}*2)) $((${height}*2)) | xxd -r -p | base64)
#
cat << OOO >> ${dpiFile}
                <data>${hidpi:0:11}AAAABACAAAA==</data>
OOO
done
}

function create_res_3()
{
    for res in $@; do
    width=$(echo ${res} | cut -d x -f 1)
    height=$(echo ${res} | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $((${width}*2)) $((${height}*2)) | xxd -r -p | base64)
#
cat << OOO >> ${dpiFile}
                <data>${hidpi:0:11}AAAAB</data>
OOO
done
}

function create_res_4()
{
    for res in $@; do
    width=$(echo ${res} | cut -d x -f 1)
    height=$(echo ${res} | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $((${width}*2)) $((${height}*2)) | xxd -r -p | base64)
#
cat << OOO >> ${dpiFile}
                <data>${hidpi:0:11}AAAAJAKAAAA==</data>
OOO
done
}

# enable
function enable_hidpi()
{
    choose_icon
    main
    sed -i "" "/.*IODisplayEDID/d" ${dpiFile}
    sed -i "" "/.*EDid/d" ${dpiFile}
    end
}

# patch
function enable_hidpi_with_patch()
{
    choose_icon
    main

    version=${EDID:38:2}
    basicparams=${EDID:40:2}
    checksum=${EDID:254:2}
    newchecksum=$(printf '%x' $((0x${checksum} + 0x${version} +0x${basicparams} - 0x04 - 0x90)) | tail -c 2)
    newedid=${EDID:0:38}0490${EDID:42:6}e6${EDID:50:204}${newchecksum}
    EDid=$(printf ${newedid} | xxd -r -p | base64)

    /usr/bin/sed -i "" "s:EDid:${EDid}:g" ${dpiFile}
    end
}

# disable
function disable()
{
    if [[ -d ${thatDir}/DisplayVendorID-${Vid} ]]; then
        sudo rm -rf ${thatDir}/DisplayVendorID-${Vid} 
    fi

    sudo rm -rf ${thatDir}/Icons.plist
    sudo cp -r ${thatDir}/HIDPI/backup/* ${thatDir}/
    sudo rm -rf ${thatDir}/HIDPI/disable
    echo "${langDisabled}"
}

#
function start()
{
    init
    echo ""
    echo ${langEnableOp1}
    echo ${langEnableOp2}
    echo ${langEnableOp3}
    echo ""

#
read -p "${langInputChoice} [1~3]: " input
case ${input} in
    1) enable_hidpi
    ;;
    2) enable_hidpi_with_patch
    ;;
    3) disable
    ;;
    *) 

    echo "${langEnterError}";
    exit 0
    ;;
esac 
}

start
