# Dust_Zephyr_HPMicro_Tree（本地目录 `sdk_glue_user`）— HPM 用户自研层

> **SELF-MAINTAINED — Rookie002-start**
> 这是与 sdk_glue / sdk_env 同级的用户自研层（`<workspace>/sdk_glue_user`，workspace 如 `E:\Zephyr_HPMicro`），
> 结构镜像 sdk_glue（`boards/`、`soc/`、`dts/`…），只包含用户自研/移植的**独立新增文件**，**独立 git 仓库管理**。
>
> **不污染官方 sdk**：sdk_glue / sdk_env 官方仓库保持干净，这里只放"新增独立文件"。
> **修改官方文件的部分**（底层 bug 修复等）走 patch（归档在 `zephyr-patches/`），apply 到官方仓库。

## 结构

```
sdk_glue_user/
├── boards/         用户自研板卡（boards/<vendor>/<name>/）
├── boards/openocd/ CMSIS-DAP 等调试器配置
├── include/        生成的时钟等 DT binding 头文件
├── soc/            用户自研 SoC 支持（soc/<vendor>/<family>/）
├── dts/            用户自研 devicetree 与 binding
├── zephyr-patches/ 社区上游补丁与历史归档
└── README.md
```

## 内容清单

| 内容 | 位置 | 说明 |
| --- | --- | --- |
| hpm5361icb 板卡 | `boards/hpmicro/hpm5361icb/` | HPM5361 自制核心板（HPM5300 系列） |
| hpm5e3y 板卡 | `boards/hpmicro/hpm5e3y/` | HPM5E3Y 板卡（HPM5E00 系列，默认 UART0 串口控制台） |
| HPM5300 SoC 支持 | `soc/hpmicro/HPM5300/` | soc.c/soc.h/start.S/linker.ld/Kconfig* |
| HPM5E00 SoC 支持 | `soc/hpmicro/HPM5E00/` | soc.c/soc.h/start.S/linker.ld/Kconfig*（HPM5E3Y） |
| PLLv2 binding | `dts/bindings/clock/hpmicro,hpm-pllv2.yaml` | 自研 binding |

## 引用机制

应用工程 CMakeLists 通过 `BOARD_ROOT` / `SOC_ROOT` / `DTS_ROOT` 引用本目录：

```cmake
list(APPEND BOARD_ROOT "<workspace>/sdk_glue_user")
list(APPEND SOC_ROOT   "<workspace>/sdk_glue_user")
list(APPEND DTS_ROOT   "<workspace>/sdk_glue_user")
list(APPEND DTS_ROOT   "<workspace>/sdk_glue_user/dts")
```

之后 `west build -b hpm5361icb` 可直接按板名找到。

默认开发目录：

```text
~/Zephyr_HPMicro/
├── sdk_env/
├── sdk_glue/
└── sdk_glue_user/
```

`sdk_env` 与 `sdk_glue` 使用社区远程，本地修改由本仓库的补丁统一管理。

## 管理方式

- 本目录是**独立 git 仓库**（`sdk_glue_user/.git`）。
- 新增板卡/SoC/binding 在本目录内 `git add` / `git commit`，`git push` 到用户自己的远端仓库。
- 与 sdk_glue / sdk_env 完全独立，官方仓库 git 不受影响。

## 底层修改 patch 机制

修改官方仓库的部分（不污染官方 sdk）归档在 `zephyr-patches/`，构建时 apply：

- `zephyr/`   → 历史归档；当前完整 Zephyr 补丁由同级 `Dust_Zephyr_Tree` 管理
- `sdk_env/`  → HPM sdk_env（hpm_misc.h DLM/ILM 地址换算）
- `sdk_glue/` → 当前 HPM sdk_glue 完整增量（驱动、DTS、SoC、看门狗）
- `cherryusb/`→ CherryUSB（usb_osal_zephyr.c ARRAY_SIZE 宏冲突）

当前补丁基线：

- `sdk_env`: `v1.11.0`, `7b8cb8bb2f04f52353a6429bffb024f0a2867876`
- `zephyr_sdk_glue`: `v0.7.0`, `1756cb8fbef2334d9ad89aef08a01233f8502919`

Linux / CI 默认按同级目录应用，也可以显式指定路径：

```bash
./apply-patches.sh
./apply-patches.sh --sdk-env <sdk_env> --sdk-glue <sdk_glue>
./apply-patches.sh --check
```

Windows：

```powershell
.\apply-patches.ps1
.\apply-patches.ps1 -Check
```

脚本会检查补丁是否已应用，可重复执行。`legacy/` 中保留的是旧碎片补丁，
它们存在重叠，不能用于干净 v0.7.0 检出；当前只应用各目录根层的活动补丁。

Zephyr 补丁不在这里重复维护，请运行：

```bash
<path-to-Dust_Zephyr_Tree>/patches/apply-zephyr-patches.sh \
  --zephyr ~/zephyrproject/zephyr
```

## 备注

- 底层 bug 修复（如 hpm_sdk `hpm_misc.h` 的 DLM/ILM 地址转换、drivers 修改、dtsi 修改）**必须改官方文件**，以 patch 形式管理（见 `zephyr-patches/`）。
- 本层保存板卡、SoC、DTS 和驱动适配；社区文件修改保存在 `zephyr-patches/`。
