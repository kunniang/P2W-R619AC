# P2W-R619AC ImmortalWrt 自用固件编译

**原始的编译脚本来自[https://github.com/vbskycn/P2W-R619AC](https://github.com/vbskycn/P2W-R619AC)，根据自己需求做了一些调整。**

本项目用于通过 GitHub Actions 自动化编译 **竞斗云2.0 R619AC (P2W-R619AC)** 路由器的 ImmortalWrt 固件。这是一个为自用量身打造的优化项目，并同步支持最新的 ImmortalWrt 主分支（Master）、24.10.2 稳定分支和 25.12 分支。

![image-20260425222841540](assets/image-20260425222841540.png)



## 🏮 固件默认配置

刷入固件后，请参考以下默认配置进行路由器的初始化设置：

- **后台地址**: [192.168.88.1](http://192.168.88.1)
- **管理账号**: `root`
- **管理密码**: 无密码 *(为了安全，请在初次直接登入后自行设定密码)*

  

## 🚀 编译策略

   - **手动触发**: `Master`、`24.10.2` 与 `25.12` 工作流都支持在 `Actions` 页面手动运行，且支持勾选 tmate 进入 SSH debug 模式。
   - **目前只测试了`25.12`分支，确定可以直接用。**




> **致谢 & 声明**:
> 大量编译脚本逻辑源自于 [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt) 项目。
> 源码底包基于 [ImmortalWrt](https://github.com/immortalwrt/immortalwrt) 团队的贡献。




## 📚 资源链接

- 最新 opboot: [opboot-p2w-r619ac-nor-v1.1.2-3d5736d.img](https://github.com/vbskycn/immortalwrt-src/releases/download/P2W-R619AC/opboot-p2w-r619ac-nor-v1.1.2-3d5736d.img)
- 128M 底包: [openwrt-ipq40xx-p2w_r619ac-128m-squashfs-nand-factory.ubi](https://github.com/vbskycn/immortalwrt-src/releases/download/P2W-R619AC/openwrt-ipq40xx-p2w_r619ac-128m-squashfs-nand-factory.ubi)
