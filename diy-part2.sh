#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# 注意：本文件请保存为「UTF-8 无 BOM」，带 BOM 时执行会在日志里多一轮
#      "#!/bin/bash: No such file or directory" 的报错。
#

set -e

# 为生成的固件镜像名称添加时间戳
sed -i 's/^IMG_PREFIX\:\=.*/IMG_PREFIX:=IM-$(shell TZ=UTC-8 date +"%Y.%m.%d-%H%M")-$(IMG_PREFIX_VERNUM)$(IMG_PREFIX_VERCODE)$(IMG_PREFIX_EXTRA)$(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))/g' include/image.mk

# 下载中文默认设置，失败时保留上游默认值
mkdir -p package/emortal/default-settings/files
if ! curl --retry 3 --retry-delay 5 -fsSL https://raw.githubusercontent.com/leesuncom/package/main/99-default-settings-chinese -o package/emortal/default-settings/files/99-default-settings-chinese; then
  echo "Warning: failed to download 99-default-settings-chinese, keeping upstream defaults"
fi

# 将默认 LuCI 主题从 Bootstrap 切换为 Argon
sed -i 's/[Bb]ootstrap/argon/g' ./feeds/luci/collections/luci/Makefile

# 设置默认路由器 IP 地址
sed -i 's/192.168.1.1/192.168.88.1/g' package/base-files/files/bin/config_generate

# ---------------------------------------------------------------------------
# 清理重复包
#
# 1) kenzok8 的 kenzo / small 两个源里都带 luci-app-passwall、luci-app-openclash、
#    sing-box、chinadns-ng、xray-core 等，和下面 clone 的官方版同名。同名包谁生效
#    取决于扫描顺序，不清理可能编进去的是旧版。
# 2) 官方 feeds 里 passwall 依赖的这批包是旧版本，也要一并移除，连同 package/feeds
#    下的软链（只删 feeds 目录会留下断链）。
#
# 注意：这里没有删除 luci-app-lucky 等第三方应用，需要用到 kenzo 源里的其它包时，
#     只删真正的重复项即可。
# ---------------------------------------------------------------------------
DUPS="luci-app-passwall luci-app-passwall2 luci-app-openclash sing-box chinadns-ng xray-core"
for p in $DUPS; do
  rm -rf "feeds/kenzo/$p" "feeds/small/$p" "package/feeds/kenzo/$p" "package/feeds/small/$p"
done
rm -rf package/openclash

DEPS="xray-core v2ray-geodata sing-box chinadns-ng dns2socks hysteria ipt2socks microsocks \
      naiveproxy shadowsocks-libev shadowsocks-rust shadowsocksr-libev simple-obfs tcping \
      trojan-plus tuic-client v2ray-plugin xray-plugin geoview shadow-tls"
for p in $DEPS; do
  rm -rf "feeds/packages/net/$p" "package/feeds/packages/$p"
done
rm -rf feeds/luci/applications/luci-app-passwall package/feeds/luci/luci-app-passwall

# ---------------------------------------------------------------------------
# 接入官方 PassWall（上游 README 方法 2）
# 主程序已在 2026 年从 xiaorouji 账号迁到 Openwrt-Passwall 组织，旧地址是 404
# ---------------------------------------------------------------------------
rm -rf package/passwall-packages package/passwall-luci
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

# 第三方插件（sirpdboy 那一套）默认不启用，config 里没有对应 =y，clone 了也是白占时间。
# 需要时取消注释，并在 R619AC-25.12.config 里加上同名 CONFIG_PACKAGE_xxx=y。
# rm -rf package/netwizard package/lucky package/luci-app-advanced package/taskplan package/timecontrol
# git clone --depth=1 https://github.com/sirpdboy/luci-app-netwizard package/netwizard
# git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky package/lucky
# git clone --depth=1 https://github.com/sirpdboy/luci-app-advanced package/luci-app-advanced
# git clone --depth=1 https://github.com/sirpdboy/luci-app-taskplan package/taskplan
# git clone --depth=1 https://github.com/sirpdboy/luci-app-timecontrol package/timecontrol

# ---------------------------------------------------------------------------
# WireGuard 部署工具：files/ 目录会被 prepare_rootfs 直接并入 rootfs，
# 这里只保证可执行权限（git 在 Windows 上容易丢 +x）
# ---------------------------------------------------------------------------
if [ -f files/usr/bin/wg-server-init ]; then
  chmod 755 files/usr/bin/wg-server-init
  echo "WireGuard 部署工具已就位: /usr/bin/wg-server-init"
else
  echo "Warning: files/usr/bin/wg-server-init 不存在，固件里将没有 wg-server-init"
fi

# ---------------------------------------------------------------------------
# 校验关键目录，上游改结构时尽早失败
# ---------------------------------------------------------------------------
for dir in \
  package/passwall-packages \
  package/passwall-luci/luci-app-passwall; do
  if [ ! -d "$dir" ]; then
    echo "Missing expected package directory: $dir"
    exit 1
  fi
done

# passwall 的分流数据依赖 v2ray-geodata，确认克隆到了
if [ ! -d package/passwall-packages/v2ray-geodata ]; then
  echo "Missing expected package directory: package/passwall-packages/v2ray-geodata"
  exit 1
fi
