# 一键开启MacOS HIDPI

### 说明

此脚本的目的是为中低分辨率的屏幕开启HIDPI选项，并且具有原生的HIDPI设置，不需要RDM软件即可在系统显示器设置中设置

MacOS的dpi机制和win下不一样，比如1080p的屏幕在win下有125%、150%这样的缩放选项，而同样的屏幕在MacOS下，缩放选项里只是单纯的调节分辨率，这就使得在默认分辨率下字体和UI看起来很小，降低分辨率又显得模糊。

同时，此脚本也可以通过注入修补后的EDID修复闪屏，或者睡眠唤醒后的闪屏问题，当然这个修复因人而异

效果：

![HIDPI效果.png](https://i.loli.net/2017/10/26/59f199e85deb7.png)

### 使用方法

在终端输入以下命令回车即可

```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/xzhih/one-key-hidpi/master/hidpi.sh)"
```

