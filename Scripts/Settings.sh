#!/bin/bash

#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
# sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
#修改WIFI名称
sed -i "s/ImmortalWrt/$WRT_SSID/g" $WIFI_FILE
#修改WIFI加密
sed -i "s/encryption=.*/encryption='psk2+ccmp'/g" $WIFI_FILE
#修改WIFI密码
sed -i "/set wireless.default_\${dev}.encryption='psk2+ccmp'/a \\\t\t\t\t\t\set wireless.default_\${dev}.key='$WRT_WORD'" $WIFI_FILE

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

# 内核支持的额外添加 
for conf in target/linux/mediatek/filogic/config-*; do
cat >> $conf << 'EOF'

# =========================================================
# CPU 调度优化
# =========================================================

CONFIG_PREEMPT_VOLUNTARY=y
CONFIG_HZ_250=y
CONFIG_SCHED_AUTOGROUP=y

# =========================================================
# Cgroup v2 完整支持
# =========================================================

CONFIG_CGROUPS=y
CONFIG_CGROUP_BPF=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_SCHED=y

CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y

CONFIG_SOCK_CGROUP_DATA=y

# =========================================================
# eBPF / Daed 核心
# =========================================================

CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_BPF_UNPRIV_DEFAULT_OFF=y

# =========================================================
# eBPF 网络调度
# =========================================================

CONFIG_NET_SCHED=y
CONFIG_NET_CLS=y
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_BPF=m
CONFIG_NET_CLS_BPF=m

# =========================================================
# XDP / 高速数据路径
# =========================================================

CONFIG_XDP_SOCKETS=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_NET_SOCK_MSG=y

# =========================================================
# 网络命名空间
# =========================================================

CONFIG_NET_NS=y

# =========================================================
# 诊断接口
# =========================================================

CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_PACKET_DIAG=y

# =========================================================
# 网络性能增强
# =========================================================

CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y
CONFIG_TCP_FASTOPEN=y

# =========================================================
# TCP 优化
# =========================================================

CONFIG_TCP_CONG_BBR=y
CONFIG_DEFAULT_BBR=y
CONFIG_DEFAULT_TCP_CONG="bbr"

# =========================================================
# 高速包处理
# =========================================================

CONFIG_GRO_CELLS=y

EOF
done
