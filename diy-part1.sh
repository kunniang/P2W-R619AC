#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# 当前 feeds 全部由 R619AC-25.12.feeds.conf.default 定义，这里不需要再加源。
# 如果临时要加其它 feed，取消下面的注释即可。
#

set -e

# 追加第三方 feed（示例）
# sed -i '$a src-git kiddin9 https://github.com/kiddin9/openwrt-packages.git' feeds.conf.default

echo "diy-part1: feeds 未做改动，沿用 R619AC-25.12.feeds.conf.default"
