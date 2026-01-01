#!/data/data/com.termux/files/usr/bin/bash

# Màu sắc cho output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Hàm hiển thị banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║           SCODE AUTO SETUP TERMUX            ║"
    echo "║         Automated Tool Installation          ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Hàm kiểm tra và cài đặt gói
install_package() {
    local pkg=$1
    if ! dpkg -s $pkg &>/dev/null; then
        echo -e "${YELLOW}[*] Installing $pkg...${NC}"
        pkg install -y $pkg
    else
        echo -e "${GREEN}[✓] $pkg already installed${NC}"
    fi
}

# Hàm cài đặt Python packages
install_pip_package() {
    local pkg=$1
    echo -e "${YELLOW}[*] Installing Python package: $pkg${NC}"
    pip install -q $pkg
}

# Hàm kiểm tra kết nối Internet
check_internet() {
    echo -e "${YELLOW}[*] Checking internet connection...${NC}"
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo -e "${GREEN}[✓] Internet connection OK${NC}"
        return 0
    else
        echo -e "${RED}[✗] No internet connection!${NC}"
        return 1
    fi
}

# Hàm cập nhật hệ thống
update_system() {
    echo -e "${YELLOW}[*] Updating system packages...${NC}"
    pkg update -y && pkg upgrade -y
    echo -e "${GREEN}[✓] System updated${NC}"
}

# Hàm cài đặt các dependencies chính
install_dependencies() {
    echo -e "${CYAN}[*] Installing main dependencies...${NC}"
    
    # Các gói hệ thống cần thiết
    install_package python
    install_package git
    install_package wget
    install_package curl
    install_package proot
    install_package termux-api
    
    # Cài đặt pip nếu chưa có
    if ! command -v pip &>/dev/null; then
        pkg install -y python-pip
    fi
    
    echo -e "${GREEN}[✓] Main dependencies installed${NC}"
}

# Hàm cài đặt Python dependencies
install_python_deps() {
    echo -e "${CYAN}[*] Installing Python dependencies...${NC}"
    
    # Cài đặt các package cần thiết từ pp8.py
    install_pip_package requests
    install_pip_package colorama
    install_pip_package pystyle
    install_pip_package pytz
    
    # Thử cài đặt các package khác nếu cần
    pip install -q "urllib3>=1.26.0"
    pip install -q "setuptools"
    
    echo -e "${GREEN}[✓] Python dependencies installed${NC}"
}

# Hàm tải tool từ GitHub
download_tool() {
    echo -e "${CYAN}[*] Downloading SCODE Tool...${NC}"
    
    # Tạo thư mục cho tool
    TOOL_DIR="$HOME/.scode_tool"
    mkdir -p $TOOL_DIR
    cd $TOOL_DIR
    
    # Kiểm tra xem đã có file pp8.py chưa
    if [ -f "pp8.py" ]; then
        echo -e "${YELLOW}[!] Tool already exists, updating...${NC}"
        rm -f pp8.py
    fi
    
    # Tải tool từ GitHub
    wget -q https://raw.githubusercontent.com/scode85/auto-setup-temux/main/pp8.py -O pp8.py
    
    if [ -f "pp8.py" ]; then
        echo -e "${GREEN}[✓] Tool downloaded successfully${NC}"
        chmod +x pp8.py
    else
        echo -e "${RED}[✗] Failed to download tool${NC}"
        return 1
    fi
}

# Hàm tạo alias và shortcut
create_shortcut() {
    echo -e "${CYAN}[*] Creating shortcut...${NC}"
    
    # Tạo file bashrc nếu chưa có
    if [ ! -f ~/.bashrc ]; then
        touch ~/.bashrc
    fi
    
    # Thêm alias vào .bashrc
    if ! grep -q "alias scode=" ~/.bashrc; then
        echo 'alias scode="cd ~/.scode_tool && python pp8.py"' >> ~/.bashrc
        echo -e "${GREEN}[✓] Alias 'scode' added to .bashrc${NC}"
    else
        echo -e "${YELLOW}[!] Alias 'scode' already exists${NC}"
    fi
    
    # Tạo file chạy trực tiếp
    echo '#!/data/data/com.termux/files/usr/bin/bash' > ~/scode
    echo 'cd ~/.scode_tool && python pp8.py' >> ~/scode
    chmod +x ~/scode
    
    echo -e "${GREEN}[✓] Shortcut created${NC}"
}

# Hàm kiểm tra và cài đặt storage permission
setup_storage() {
    echo -e "${CYAN}[*] Setting up storage permissions...${NC}"
    
    # Yêu cầu quyền storage
    termux-setup-storage
    
    echo -e "${YELLOW}[!] Please allow storage permission when prompted${NC}"
    sleep 2
}

# Hàm hiển thị hướng dẫn sử dụng
show_usage() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║               USAGE INSTRUCTIONS             ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}Tool has been installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}To run the tool, use one of these commands:${NC}"
    echo -e "${CYAN}1. ${GREEN}scode${NC} - Run with alias"
    echo -e "${CYAN}2. ${GREEN}cd ~/.scode_tool && python pp8.py${NC} - Manual run"
    echo -e "${CYAN}3. ${GREEN}~/scode${NC} - Run from home directory"
    echo ""
    echo -e "${YELLOW}First time setup:${NC}"
    echo -e "1. Restart Termux or run: ${CYAN}source ~/.bashrc${NC}"
    echo -e "2. Then type: ${CYAN}scode${NC}"
    echo ""
    echo -e "${RED}Note: Make sure you have stable internet connection!${NC}"
}

# Hàm clean up
cleanup() {
    echo -e "${YELLOW}[*] Cleaning up...${NC}"
    pkg clean
    echo -e "${GREEN}[✓] Cleanup completed${NC}"
}

# Hàm chính
main() {
    show_banner
    
    echo -e "${BLUE}Starting SCODE Auto Setup for Termux...${NC}"
    echo ""
    
    # Kiểm tra internet
    if ! check_internet; then
        echo -e "${RED}Please check your internet connection and try again!${NC}"
        exit 1
    fi
    
    # Cập nhật hệ thống
    update_system
    
    # Cài đặt dependencies
    install_dependencies
    
    # Cài đặt Python dependencies
    install_python_deps
    
    # Thiết lập storage
    setup_storage
    
    # Tải tool
    if ! download_tool; then
        echo -e "${RED}Failed to download tool. Exiting...${NC}"
        exit 1
    fi
    
    # Tạo shortcut
    create_shortcut
    
    # Clean up
    cleanup
    
    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}[✓] SETUP COMPLETED SUCCESSFULLY!${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo ""
    
    # Hiển thị hướng dẫn sử dụng
    show_usage
    
    # Hỏi người dùng có muốn chạy tool ngay không
    echo ""
    read -p "Do you want to run the tool now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Starting SCODE Tool...${NC}"
        cd ~/.scode_tool && python pp8.py
    else
        echo -e "${YELLOW}You can run the tool later using: ${GREEN}scode${NC}"
    fi
}

# Xử lý khi nhấn Ctrl+C
trap ctrl_c INT
ctrl_c() {
    echo -e "\n${RED}[!] Installation interrupted by user${NC}"
    exit 1
}

# Chạy hàm chính
main