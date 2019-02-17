#!/bin/sh

function get_edid()
{
    local index=0
    local selection=0

    gDisplayInf=($(ioreg -lw0 | grep -i "IODisplayEDID" | sed -e "/[^<]*</s///" -e "s/\>//"))

    if [[ "${#gDisplayInf[@]}" -ge 2 ]]; then

        # Multi monitors detected. Choose target monitor.
        echo ''
        echo '              Monitors          '
        echo '------------------------------------'
        echo '  Index  |  VendorID  |  ProductID  '
        echo '------------------------------------'

        # Show monitors.
        for display in "${gDisplayInf[@]}"
        do
            let index++
            printf "    %d    |    ${display:16:4}    |    ${display:20:4}\n" $index
        done

        echo '------------------------------------'

        # Let user make a selection.

        read -p "Choose the display: " selection
        case $selection in
            [[:digit:]]* ) 
                # Lower selection (arrays start at zero).
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
    
    if [[ ${gMonitor:16:1} == 0 ]]; then
        # get rid of the prefix 0
        gDisplayVendorID_RAW=${gMonitor:17:3}
    else
        gDisplayVendorID_RAW=${gMonitor:16:4}
    fi

    # convert from hex to dec
    gDisplayVendorID=$((0x$gDisplayVendorID_RAW))
    gDisplayProductID_RAW=${gMonitor:20:4}
    
    # Exchange two bytes
    # Fix an issue that will cause wrong name of DisplayProductID
    
    if [[ ${gDisplayProductID_RAW:2:1} == 0 ]]; then
        # get rid of the prefix 0
        gDisplayProduct_pr=${gDisplayProductID_RAW:3:1}
    else
        gDisplayProduct_pr=${gDisplayProductID_RAW:2:2}
    fi
    gDisplayProduct_st=${gDisplayProductID_RAW:0:2}
    gDisplayProductID_reverse="${gDisplayProduct_pr}${gDisplayProduct_st}"
    gDisplayProductID=$((0x$gDisplayProduct_pr$gDisplayProduct_st))

    EDID=$gMonitor
    VendorID=$gDisplayVendorID
    ProductID=$gDisplayProductID 
    Vid=$gDisplayVendorID_RAW
    Pid=$gDisplayProductID_reverse 
    # echo $Vid
    # echo $Pid
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
    Overrides="\/System\/Library\/Displays\/Contents\/Resources\/Overrides\/"

    DICON="com\.apple\.cinema-display"
    imacicon=${Overrides}"DisplayVendorID-610\/DisplayProductID-a032.tiff"
    mbpicon=${Overrides}"DisplayVendorID-610\/DisplayProductID-a030-e1e1df.tiff"
    mbicon=${Overrides}"DisplayVendorID-610\/DisplayProductID-a028-9d9da0.tiff"
    lgicon=${Overrides}"DisplayVendorID-1e6d\/DisplayProductID-5b11.tiff"

    if [[ ! -d $thatDir/HIDPI/backup ]]; then
        echo "Backing up..."
        sudo mkdir -p $thatDir/HIDPI/backup
        sudo cp $thatDir/Icons.plist $thatDir/HIDPI/backup/
        if [[ -d $thatDir/DisplayVendorID-$Vid ]]; then
            sudo cp -r $thatDir/DisplayVendorID-$Vid $thatDir/HIDPI/backup/
        fi
    fi
    
    if [[ ! -f $thatDir/HIDPI/disable ]]; then
        generate_restore_cmd
    fi
}

#
function generate_restore_cmd()
{
#
rm -rf $thisDir/tmp/
mkdir -p $thisDir/tmp/
cat > "$thisDir/tmp/disable" <<-\CCC
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
            printf "    %d    |    ${display:16:4}    |    ${display:20:4}\n" $index
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
    
    if [[ ${gMonitor:16:1} == 0 ]]; then
        gDisplayVendorID_RAW=${gMonitor:17:3}
    else
        gDisplayVendorID_RAW=${gMonitor:16:4}
    fi

    gDisplayVendorID=$((0x$gDisplayVendorID_RAW))
    gDisplayProductID_RAW=${gMonitor:20:4}

    if [[ ${gDisplayProductID_RAW:2:1} == 0 ]]; then
        gDisplayProduct_pr=${gDisplayProductID_RAW:3:1}
    else
        gDisplayProduct_pr=${gDisplayProductID_RAW:2:2}
    fi

    gDisplayProduct_st=${gDisplayProductID_RAW:0:2}
    gDisplayProductID_reverse="${gDisplayProduct_pr}${gDisplayProduct_st}"
    gDisplayProductID=$((0x$gDisplayProduct_pr$gDisplayProduct_st))

    EDID=$gMonitor
    Vid=$gDisplayVendorID_RAW
    Pid=$gDisplayProductID_reverse 
    # echo $Vid
    # echo $Pid
    # echo $EDID
}

get_edid

if [[ -d ../DisplayVendorID-$Vid ]]; then
    rm -rf ../DisplayVendorID-$Vid 
fi

rm -rf ../Icons.plist
cp -r ./backup/* ../
rm -rf ./disable
echo "HIDPI Disabled"
CCC

sudo mv $thisDir/tmp/disable $thatDir/HIDPI/
sudo chmod +x $thatDir/HIDPI/disable

}

# choose_icon
function choose_icon()
{
    #
    rm -rf $thisDir/tmp/
    mkdir -p $thisDir/tmp/
    curl -fsSL https://raw.githubusercontent.com/xzhih/one-key-hidpi/master/Icons.plist -o $thisDir/tmp/Icons.plist
    # curl -fsSL http://127.0.0.1:8080/Icons.plist -o $thisDir/tmp/Icons.plist

#
cat << EOF
------------------------------------
|********** Choose Icon ***********|
------------------------------------
(1) iMac
(2) MacBook
(3) MacBook Pro
(4) LG Display
(5) Remain as it is

EOF

read -p "Enter your choice [1~5]: " logo
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
    *)

    echo "Enter error, bye";
    exit 0
    ;;
esac 

if [[ $Picon ]]; then
    /usr/bin/sed -i "" "s/VID/$Vid/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/PID/$Pid/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPX/${RP[0]}/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPY/${RP[1]}/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPW/${RP[2]}/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/RPH/${RP[3]}/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/PICON/$Picon/g" $thisDir/tmp/Icons.plist
    /usr/bin/sed -i "" "s/DICON/$DICON/g" $thisDir/tmp/Icons.plist
fi

}

# main
function main()
{
    sudo mkdir -p $thisDir/tmp/DisplayVendorID-$Vid
    dpiFile=$thisDir/tmp/DisplayVendorID-$Vid/DisplayProductID-$Pid
    sudo chmod -R 777 $thisDir/tmp/

# 
cat > "$dpiFile" <<-\CCC
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

cat << EOF
------------------------------------------
|********** resolution config ***********|
------------------------------------------
(1) 1080P Display
(2) 2K Display
(3) Manual input resolution

EOF

read -p "Enter your choice: " res
case $res in
    1 ) create_res_1 1680x944 1440x810 1280x720 1024x576
    ;;
    2 ) create_res_1 2048x1152 1920x1080 1680x944 1440x810 1280x720
    create_res_2 1024x576
    create_res_3 960x540
    create_res_4 2048x1152 1920x1080
    ;;
    3 ) custom_res;;
esac

create_res_2 1280x800 1280x720 960x600 960x540 640x360
create_res_3 840x472 800x450 720x405 640x360 576x324 512x288 420x234 400x225 320x180
create_res_4 1680x944 1440x810 1280x720 1024x576 960x540 840x472 800x450 640x360

cat >> "$dpiFile" <<-\FFF
            </array>
        <key>target-default-ppmm</key>
            <real>10.0699301</real>
    </dict>
</plist>
FFF

    /usr/bin/sed -i "" "s/VID/$VendorID/g" $dpiFile
    /usr/bin/sed -i "" "s/PID/$ProductID/g" $dpiFile
}

# end
function end()
{
    sudo cp -r $thisDir/tmp/* $thatDir/
    sudo rm -rf $thisDir/tmp
    echo "Enabled, please reboot."
    echo "Rebooting the logo for the first time will become huge, then it will not be."
}

# custom resolution
function custom_res()
{
    echo "Enter the HIDPI resolution, separated by a space，like this: 1680x945 1600x900 1440x810"
    read -p ":" res
    create_res $res
}

# create resolution
function create_res()
{
    for res in $@; do
    width=$(echo $res | cut -d x -f 1)
    height=$(echo $res | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $(($width*2)) $(($height*2)) | xxd -r -p | base64)
#
cat << OOO >> $dpiFile
                <data>${hidpi:0:11}AAAAB</data>
                <data>${hidpi:0:11}AAAABACAAAA==</data>
OOO
done
}

function create_res_1()
{
    for res in $@; do
    width=$(echo $res | cut -d x -f 1)
    height=$(echo $res | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $(($width*2)) $(($height*2)) | xxd -r -p | base64)
#
cat << OOO >> $dpiFile
                <data>${hidpi:0:11}A</data>
OOO
done
}

function create_res_2()
{
    for res in $@; do
    width=$(echo $res | cut -d x -f 1)
    height=$(echo $res | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $(($width*2)) $(($height*2)) | xxd -r -p | base64)
#
cat << OOO >> $dpiFile
                <data>${hidpi:0:11}AAAABACAAAA==</data>
OOO
done
}

function create_res_3()
{
    for res in $@; do
    width=$(echo $res | cut -d x -f 1)
    height=$(echo $res | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $(($width*2)) $(($height*2)) | xxd -r -p | base64)
#
cat << OOO >> $dpiFile
                <data>${hidpi:0:11}AAAAB</data>
OOO
done
}

function create_res_4()
{
    for res in $@; do
    width=$(echo $res | cut -d x -f 1)
    height=$(echo $res | cut -d x -f 2)
    hidpi=$(printf '%08x %08x' $(($width*2)) $(($height*2)) | xxd -r -p | base64)
#
cat << OOO >> $dpiFile
                <data>${hidpi:0:11}AAAAJAKAAAA==</data>
OOO
done
}

# enable
function enable_hidpi()
{
    choose_icon
    main
    sed -i "" "/.*IODisplayEDID/d" $dpiFile
    sed -i "" "/.*EDid/d" $dpiFile
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
    newchecksum=$(printf '%x' $((0x$checksum + 0x$version +0x$basicparams - 0x04 - 0x90)) | tail -c 2)
    newedid=${EDID:0:38}0490${EDID:42:212}${newchecksum}
    EDid=$(printf $newedid | xxd -r -p | base64)

    /usr/bin/sed -i "" "s:EDid:${EDid}:g" $dpiFile
    end
}

# disable
function disable()
{
    if [[ -d $thatDir/DisplayVendorID-$Vid ]]; then
        sudo rm -rf $thatDir/DisplayVendorID-$Vid 
    fi

    sudo rm -rf $thatDir/Icons.plist
    sudo cp -r $thatDir/HIDPI/backup/* $thatDir/
    sudo rm -rf $thatDir/HIDPI/disable
    echo "Disabled, restart takes effect"
}

#
function start()
{
    init
# 
cat << EOF

(1) Enable HIDPI
(2) Enable HIDPI (with EDID)
(3) Disable HIDPI

EOF

read -p "Enter your choice [1~3]: " input
case $input in
    1) enable_hidpi
    ;;
    2) enable_hidpi_with_patch
    ;;
    3) disable
    ;;
    *) 

    echo "Enter error, bye";
    exit 0
    ;;
esac 
}

start
