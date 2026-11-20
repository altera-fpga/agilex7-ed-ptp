#! /bin/bash
set -e
PTP_DESIGN="${1:-25G_ANLT}"
BOOT_SOURCE=$2
export PTP_DESIGN
echo "Yocto Linux Build Script"
echo "PTP_DESIGN: $PTP_DESIGN"
echo "Boot Source: $BOOT_SOURCE"
case "$PTP_DESIGN" in
  ALL|PTP_ALL) PTP_DESIGN=PTP_ALL; export PTP_DESIGN ;;
esac
case "$PTP_DESIGN" in
  10G|25G|50G|100G|10G_ANLT|25G_ANLT|50G_ANLT|100G_ANLT|DR|PTP_ALL) ;;
  *)
    echo "Error: unsupported PTP_DESIGN='$PTP_DESIGN'"
    echo "Usage: $0 <PTP_DESIGN> <BOOT_SOURCE>"
    echo "  PTP_DESIGN: 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR PTP_ALL"
    echo "  BOOT_SOURCE: 'sd', 'qspi', 'emmc', or 'nand'"
    exit 1
    ;;
esac
if [ "$BOOT_SOURCE" != "sd" ] && [ "$BOOT_SOURCE" != "qspi" ] && [ "$BOOT_SOURCE" != "emmc" ] && [ "$BOOT_SOURCE" != "nand" ]; then
    echo "Error: Boot source must be 'sd', 'qspi', 'emmc', or 'nand'"
    echo "Usage: $0 <PTP_DESIGN> <BOOT_SOURCE>"
    echo "  PTP_DESIGN: 10G 25G 50G 100G 10G_ANLT 25G_ANLT 50G_ANLT 100G_ANLT DR PTP_ALL"
    echo "  BOOT_SOURCE: 'sd', 'qspi', 'emmc', or 'nand'"
    exit 1
fi
# Create a variable for the PIP proxy if http_proxy is set
if [ -n "$http_proxy" ]; then
    PIP_PROXY="--proxy $http_proxy"
else
    PIP_PROXY=""
fi

download_get_pip() {
    # Prefer curl/wget; fall back to Python (no curl on some ARC hosts)
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
    else
        python3 - <<'PY'
import os, urllib.request
url = "https://bootstrap.pypa.io/get-pip.py"
proxy = os.environ.get("https_proxy") or os.environ.get("http_proxy") or os.environ.get("HTTPS_PROXY") or os.environ.get("HTTP_PROXY")
handlers = []
if proxy:
    handlers.append(urllib.request.ProxyHandler({"http": proxy, "https": proxy}))
urllib.request.install_opener(urllib.request.build_opener(*handlers))
urllib.request.urlretrieve(url, "/tmp/get-pip.py")
print("Downloaded get-pip.py via urllib")
PY
    fi
}

if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    # Some CI images lack ensurepip/python3-venv; fall back to --without-pip + get-pip
    if ! python3 -m venv --system-site-packages venv; then
        echo "venv with ensurepip failed; retrying --without-pip"
        rm -rf venv
        python3 -m venv --system-site-packages --without-pip venv
        download_get_pip
        venv/bin/python /tmp/get-pip.py $PIP_PROXY
    fi
    venv/bin/pip install $PIP_PROXY --no-cache-dir --timeout 90 --trusted-host pypi.org --trusted-host files.pythonhosted.org --upgrade pip
    venv/bin/pip install $PIP_PROXY --no-cache-dir --timeout 90 --trusted-host pypi.org --trusted-host files.pythonhosted.org kas
    venv/bin/pip install $PIP_PROXY --no-cache-dir --timeout 90 --trusted-host pypi.org --trusted-host files.pythonhosted.org kconfiglib
fi
echo "Activating virtual environment..."
source venv/bin/activate
# Set the umask to ensure files are created with the correct permissions
umask 022
# Clean design-sensitive recipes when switching PTP_DESIGN
CLEAN_CMD='bitbake -c cleansstate linux-socfpga-lts fpga-bitstream console-image-minimal'
if [ "$BOOT_SOURCE" = "sd" ] || [ "$BOOT_SOURCE" = "emmc" ]; then
    echo "Preparing to sync layers and parse recipes"
    kas shell kas.yml -c "bitbake -p"
    echo "Preparing to build PTP_DESIGN=$PTP_DESIGN"
    kas shell kas.yml -c "$CLEAN_CMD && bitbake console-image-minimal gsrd-console-image"
elif [ "$BOOT_SOURCE" = "nand" ]; then
    echo "Preparing to sync layers and parse recipes"
    kas shell kas.yml -c "bitbake -p"
    echo "Preparing to build PTP_DESIGN=$PTP_DESIGN"
    kas shell kas.yml -c "$CLEAN_CMD && bitbake console-image-minimal"
elif [ "$BOOT_SOURCE" = "qspi" ]; then
    echo "Preparing to sync layers and parse recipes"
    kas shell kas.yml:qspi_boot_src.yml -c "bitbake -p"
    echo "Preparing to build PTP_DESIGN=$PTP_DESIGN"
    kas shell kas.yml:qspi_boot_src.yml -c "$CLEAN_CMD && bitbake console-image-minimal"
fi

echo "Build completed successfully."
