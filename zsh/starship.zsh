if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    export STARSHIP_DISTRO=""

    # Cache device type (only detect once)
    DEVICE_CACHE="$HOME/.cache/starship_device"
    if [[ ! -f "$DEVICE_CACHE" ]]; then
        mkdir -p "$(dirname "$DEVICE_CACHE")"
        _device=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3,$4,$5,$6,$7}')
        case $_device in
            *MacBook*)  echo "󰌢" > "$DEVICE_CACHE";;
            *mini*)     echo "󰇄" > "$DEVICE_CACHE";;
            *)          echo "" > "$DEVICE_CACHE";;
        esac
    fi
    export STARSHIP_DEVICE="$(cat "$DEVICE_CACHE")"

else
    # Linux - detect distribution
    if [[ -f /etc/os-release ]]; then
        _distro=$(awk -F'=' '/^ID=/ {print tolower($2)}' /etc/os-release)
    fi

    case $_distro in
      *kali*)                  ICON="ﴣ";;
      *arch*)                  ICON="";;
      *debian*)                ICON="";;
      *raspbian*)              ICON="";;
      *ubuntu*)                ICON="";;
      *elementary*)            ICON="";;
      *fedora*)                ICON="";;
      *coreos*)                ICON="";;
      *gentoo*)                ICON="";;
      *mageia*)                ICON="";;
      *centos*)                ICON="";;
      *opensuse*|*tumbleweed*) ICON="";;
      *sabayon*)               ICON="";;
      *slackware*)             ICON="";;
      *linuxmint*)             ICON="";;
      *alpine*)                ICON="";;
      *aosc*)                  ICON="";;
      *nixos*)                 ICON="";;
      *devuan*)                ICON="";;
      *manjaro*)               ICON="";;
      *rhel*)                  ICON="";;
      *macos*)                 ICON="󰀵";;
      *)                       ICON="";;
    esac

    export STARSHIP_DISTRO
fi
