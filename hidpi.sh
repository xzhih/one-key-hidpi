#!/bin/sh
# 
# 初始化
function init()
{
#
cat << EEF
----------------------------------------
|*************** HIDPI ****************|
----------------------------------------
EEF
    #
    VendorID=$(ioreg -l | grep "DisplayVendorID" | awk '{print $8}')
    ProductID=$(ioreg -l | grep "DisplayProductID" | awk '{print $8}')
    EDID=$(ioreg -l | grep "IODisplayEDID" | awk '{print $8}' | sed -e 's/.$//' -e 's/^.//')

    Vid=$(echo "obase=16;$VendorID" | bc | tr 'A-Z' 'a-z')
    Pid=$(echo "obase=16;$ProductID" | bc | tr 'A-Z' 'a-z')

    edID=$(echo $EDID | sed 's/../b5/21')

    EDid=$(echo $edID | xxd -r -p | base64)
    thisDir=$(dirname $0)
    thatDir="/System/Library/Displays/Contents/Resources/Overrides"

    Overrides="\/System\/Library\/Displays\/Contents\/Resources\/Overrides\/"

    DICON="com\.apple\.cinema-display"

    imacicon=${Overrides}"DisplayVendorID-610\/DisplayProductID-a032.tiff"

    mbpicon=${Overrides}"DisplayVendorID-610\/DisplayProductID-a030-e1e1df.tiff"

    mbicon=${Overrides}"DisplayVendorID-610\/DisplayProductID-a028-9d9da0.tiff"

    lgicon=${Overrides}"DisplayVendorID-1e6d\/DisplayProductID-5b11.tiff"

    if [[ ! -d $thatDir/backup ]]; then
        echo "正在备份"
        sudo mkdir -p $thatDir/backup
        sudo cp $thatDir/Icons.plist $thatDir/backup/
        if [[ -d $thatDir/DisplayVendorID-$Vid ]]; then
            sudo cp -r $thatDir/DisplayVendorID-$Vid $thatDir/backup/
        fi
    fi
}

# 选择ICON
function choose_icon()
{
    #
    mkdir $thisDir/tmp/
    curl -fsSL https://raw.githubusercontent.com/xzhih/one-key-hidpi/master/Icons.plist -o $thisDir/tmp/Icons.plist
    # curl -fsSL http://127.0.0.1:8080/Icons.plist -o $thisDir/tmp/Icons.plist

#
cat << EOF
----------------------------------------
|********** 选择要显示的ICON ***********|
----------------------------------------
(1) iMac
(2) MacBook
(3) MacBook Pro
(4) LG 显示器
(5) 保持原样

EOF
read -p "输入你的选择[1~5]: " logo
case $logo in
    1) Picon=$imacicon
RP=("33" "68" "160" "90")
;;
2) Picon=$mbicon
RP=("52" "66" "122" "76")
;;
3) Picon=$mbpicon
RP=("40" "62" "147" "92")
;;
4) Picon=$lgicon
RP=("11" "47" "202" "114")
DICON=${Overrides}"DisplayVendorID-1e6d\/DisplayProductID-5b11.icns"
;;
5) rm -rf $thisDir/tmp/Icons.plist
;;
*) echo "输入错误，拜拜";
exit 0
;;
esac 

if [[ $Picon ]]; then
    sed -i '' "s/VID/$Vid/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/PID/$Pid/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/RPX/${RP[0]}/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/RPY/${RP[1]}/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/RPW/${RP[2]}/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/RPH/${RP[3]}/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/PICON/$Picon/g" $thisDir/tmp/Icons.plist
    sed -i '' "s/DICON/$DICON/g" $thisDir/tmp/Icons.plist
fi

}

# 主函数
function main()
{
    sudo mkdir -p $thisDir/tmp/DisplayVendorID-$Vid
    dpiFile=$thisDir/tmp/DisplayVendorID-$Vid/DisplayProductID-$Pid
    sudo chmod -R 777 $thisDir/tmp/

# 
cat > "$dpiFile" <<-\HIDPI
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>DisplayProductID</key>
            <integer>PID</integer>
        <key>DisplayVendorID</key>
            <integer>VID</integer>
        <key>DisplayProductName</key>
            <string>Color LCD</string>
        <key>IODisplayEDID</key>
            <data>EDid</data>
        <key>scale-resolutions</key>
            <array>
                <data>
                AAAPAAAACHAA
                </data>
                <data>
                AAAMgAAABkAA
                </data>
                <data>
                AAAMgAAABwgA
                </data>
                <data>
                AAALQAAABlQA
                </data>
            </array>
        <key>target-default-ppmm</key>
            <real>10.1510574</real>
    </dict>
</plist>
HIDPI

    sed -i '' "s/VID/$VendorID/g" $dpiFile
    sed -i '' "s/PID/$ProductID/g" $dpiFile
}

# 擦屁股
function end()
{
    sudo cp -r $thisDir/tmp/* $thatDir/
    sudo rm -rf $thisDir/tmp
    echo "开启成功，重启生效"
    echo "首次重启开机logo会变得巨大，之后就不会了"
}

# 开
function enable_hidpi()
{
    choose_icon
    main
    sed -i "" "/.*IODisplayEDID/d" $dpiFile
    sed -i "" "/.*EDid/d" $dpiFile
    end
}

# 开挂
function enable_hidpi_with_patch()
{
    choose_icon
    main
    sed -i '' "s:EDid:${EDid}:g" $dpiFile
    end
}

# 关
function disable()
{
    sudo rm -rf $thatDir/DisplayVendorID-$Vid 
    sudo rm -rf $thatDir/Icons.plist

    sudo cp -r $thatDir/backup/* $thatDir/

    sudo rm -rf $thatDir/backup
    echo "已关闭，重启生效"
}

function start()
{
    init
# 
cat << EOF

(1) 开启HIDPI
(2) 开启HIDPI（同时注入花屏补丁）
(3) 关闭HIDPI

EOF
read -p "输入你的选择[1~3]: " input
case $input in
    1) enable_hidpi
;;
2) enable_hidpi_with_patch
;;
3) disable
;;
*) echo "输入错误，拜拜";
exit 0
;;
esac 
}

start
