#!/bin/bash

set -e

echo "[+] Starting MomLang installation..."


if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g. sudo bash install.sh)"
  exit 1
fi


if ! command -v wget &> /dev/null; then
  echo "[+] Installing wget..."
  apt update
  apt install -y wget
fi


MOMLANG_DIR="/var/lib/.syscore_momlang"
mkdir -p "$MOMLANG_DIR"


chmod 755 "$MOMLANG_DIR"


echo "[+] Downloading core.py..."
wget -q -O "$MOMLANG_DIR/core.py" "https://download-pi-ten.vercel.app/files/momlang_interpreter.py"

chmod 755 "$MOMLANG_DIR/core.py"


echo "[+] Creating ml launcher script..."

cat << 'EOF' > /usr/bin/ml
#!/bin/bash


INTERPRETER="/var/lib/.syscore_momlang/core.py"


if [ "$1" == "self-remove" ]; then
    echo "Removing MomLang installation..."

    # Remove hidden directory
    sudo rm -rf "/var/lib/.syscore_momlang"

    # Remove the binary from /usr/bin
    sudo rm -f /usr/bin/ml

    echo "MomLang has been removed successfully."
    exit 0
fi


if [ "$1" == "run" ]; then
    if [ -z "$2" ]; then
        echo "Usage: ml run <filename.mom>"
        exit 1
    fi

    if [ ! -f "$2" ]; then
        echo "File not found: $2"
        exit 1
    fi

    python3 "$INTERPRETER" "$2"
    exit 0
fi


echo "Usage: ml run <filename.mom> or ml self-remove"
exit 1
EOF

chmod 755 /usr/bin/ml

rm -f /home/install.sh

echo "[+] Installation complete!"
echo "[+] Use 'ml run <filename.mom>' to run MomLang programs."
echo "[+] Use 'ml self-remove' to uninstall."
