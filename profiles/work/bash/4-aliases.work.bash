setupvcan() {
  bash ~/scripts/setupvcan.sh
}

bsh() {
  source ~/scripts/ssh.sh $*
}

scanips() {
  source ~/scripts/scanips.sh $*
}

sscp() {
  bash ~/scripts/scp.sh $*
}

# Other apps
alias qtc='~/Qt/Tools/QtCreator/bin/qtcreator . > /dev/null 2>&1 &'

# VPN management
VPN_CONFIG_FILE="${HOME}/Documents/important/sslvpn-bennett.moore@mrs-electronics.com-client-config.ovpn"
alias vpn='sudo openvpn3 session-start --config "${VPN_CONFIG_FILE}"'
alias stopvpn='sudo openvpn3 session-manage --config "${VPN_CONFIG_FILE}" --disconnect'

# MRS SDK Qt config
export MRS_SDK_QT_ROOT="${HOME}/mrs-sdk-qt"
[[ -d "${HMRS_SDK_QT_ROOT}/tools" ]] && add_to_path "${MRS_SDK_QT_ROOT}/tools"
