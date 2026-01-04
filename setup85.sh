#!/data/data/com.termux/files/usr/bin/bash

# Màu sắc cho output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Hàm hiển thị thông báo
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

# Hàm kiểm tra và cài đặt dependencies
install_dependencies() {
    print_status "Đang cập nhật và nâng cấp packages..."
    pkg upgrade -y
    
    print_status "Đang cài đặt các package cần thiết..."
    pkg install -y python python-pip tsu libexpat openssl git wget curl
    
    print_status "Đang thiết lập storage..."
    termux-setup-storage <<< "y"
    
    print_status "Đang cài đặt các thư viện Python..."
    pip install --upgrade pip
    pip install requests Flask colorama aiohttp pycryptodome prettytable loguru rich pytz tqdm PyJWT pystyle cloudscraper
}

# Hàm tải tool từ GitHub
download_tool() {
    print_status "Đang tải tool từ GitHub..."
    
    # URL raw của file pp8.py trên GitHub
    TOOL_URL="https://raw.githubusercontent.com/nhacnen/setup/refs/heads/main/Scode85.py"
    
    # Tải file về thư mục hiện tại
    if curl -fsSL "$TOOL_URL" -o "pp8.py"; then
        print_status "Đã tải tool thành công!"
        
        # Kiểm tra file có tồn tại không
        if [ -f "pp8.py" ]; then
            # Cấp quyền thực thi
            chmod +x "pp8.py"
            
            # Kiểm tra nội dung file
            if grep -q "import" "pp8.py"; then
                print_status "File tool hợp lệ!"
                return 0
            else
                print_error "File tool không hợp lệ!"
                return 1
            fi
        else
            print_error "Không tìm thấy file tool sau khi tải!"
            return 1
        fi
    else
        print_error "Không thể tải tool từ GitHub!"
        return 1
    fi
}

# Hàm chạy tool
run_tool() {
    print_status "Đang kiểm tra môi trường Python..."
    
    # Kiểm tra Python version
    python_version=$(python --version 2>&1 | awk '{print $2}')
    print_info "Python version: $python_version"
    
    # Kiểm tra các thư viện đã cài đặt
    print_status "Kiểm tra các thư viện Python..."
    pip list | grep -E "(requests|colorama|pystyle|pycryptodome)"
    
    print_status "Đang khởi chạy tool..."
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}          SCODE TOOL LAUNCHER          ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    
    # Chạy tool với Python
    if python pp8.py; then
        print_status "Tool đã chạy thành công!"
    else
        print_error "Có lỗi khi chạy tool!"
        print_info "Đang thử với Python3..."
        python3 pp8.py || {
            print_error "Không thể chạy tool!"
            exit 1
        }
    fi
}

# Hàm hiển thị menu
show_menu() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}        SCODE AUTO SETUP TOOL          ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
    echo -e "${CYAN}1. Cài đặt đầy đủ và chạy tool${NC}"
    echo -e "${CYAN}2. Chỉ cài đặt dependencies${NC}"
    echo -e "${CYAN}3. Chỉ tải và chạy tool${NC}"
    echo -e "${CYAN}4. Kiểm tra môi trường${NC}"
    echo -e "${CYAN}5. Thoát${NC}"
    echo ""
    echo -e "${BLUE}=========================================${NC}"
}

# Hàm kiểm tra môi trường
check_environment() {
    print_status "Đang kiểm tra môi trường..."
    
    # Kiểm tra Termux
    if [ -d "/data/data/com.termux" ]; then
        print_status "Đang chạy trong Termux"
    else
        print_warning "Không phải môi trường Termux"
    fi
    
    # Kiểm tra các command
    commands=("python" "pip" "git" "curl" "wget")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_info "$cmd: Đã cài đặt"
        else
            print_warning "$cmd: Chưa cài đặt"
        fi
    done
    
    # Kiểm tra Python packages
    print_status "Kiểm tra Python packages..."
    python -c "
import sys
packages = ['requests', 'colorama', 'pystyle', 'Crypto', 'prettytable', 'rich', 'pytz']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'{pkg}: OK')
    except ImportError:
        print(f'{pkg}: MISSING')
" 2>/dev/null || echo "Không thể kiểm tra Python packages"
}

# Hàm chính
main() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}    SCODE AUTO INSTALLATION SCRIPT     ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
    
    while true; do
        show_menu
        echo -n -e "${YELLOW}Chọn option (1-5): ${NC}"
        read choice
        
        case $choice in
            1)
                print_status "Bắt đầu cài đặt đầy đủ..."
                install_dependencies
                if download_tool; then
                    run_tool
                fi
                ;;
            2)
                print_status "Chỉ cài đặt dependencies..."
                install_dependencies
                print_status "Hoàn thành cài đặt dependencies!"
                ;;
            3)
                print_status "Chỉ tải và chạy tool..."
                if download_tool; then
                    run_tool
                fi
                ;;
            4)
                check_environment
                ;;
            5)
                print_status "Thoát..."
                exit 0
                ;;
            *)
                print_error "Lựa chọn không hợp lệ!"
                ;;
        esac
        
        echo ""
        echo -n -e "${YELLOW}Nhấn Enter để tiếp tục...${NC}"
        read
    done
}

# Hàm chạy nhanh (tự động cài đặt và chạy)
quick_setup() {
    print_status "Bắt đầu cài đặt nhanh..."
    install_dependencies
    if download_tool; then
        run_tool
    fi
}

# Kiểm tra nếu có tham số
if [ "$1" = "--quick" ] || [ "$1" = "-q" ]; then
    quick_setup
else
    main
fi