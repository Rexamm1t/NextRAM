#!/system/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

print_banner() {
  printf "${BLUE}   \  |               |     _ \      \      \  |${NC}\n"
  printf "${CYAN}    \ |   _ \ \ \  /  __|  |   |    _ \    |\/ |${NC}\n"
  printf "${MAGENTA}  |\  |   __/  \  <   |    __ <    ___ \   |   |${NC}\n"
  printf "${RED} _| \_| \___|  _/\_\ \__| _| \_\ _/    _\ _|  _|${NC}\n"
  printf "${YELLOW}          by @rexamm1t, @matrix_5858${NC}\n"
  printf "${GREEN}         tg channel: @rexamm1t_channel${NC}\n"
  printf "\n"
}

spinner() {
    local pid=$1
    local delay=0.08
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while ps -p $pid > /dev/null 2>&1; do
        printf " ${frames[i]} "
        i=$(( (i+1) % 10 ))
        sleep $delay
        printf "\b\b\b"
    done
}

print_separator() {
    printf "${WHITE}══════════════════════════════════════════════${NC}\n"
}

print_header() {
    printf "\n${WHITE}█ ${1} █${NC}\n"
}

print_banner
print_separator

if ! command -v zip > /dev/null 2>&1; then
    print_header "ERROR"
    printf "${RED}Zip utility not found!${NC}\n"
    printf "${YELLOW}Please install zip package${NC}\n"
    print_separator
    exit 1
fi

if [ -z "$(ls -A)" ]; then
    print_header "ERROR"
    printf "${RED}Directory is empty!${NC}\n"
    printf "${YELLOW}No files to compress${NC}\n"
    print_separator
    exit 1
fi

print_header "BUILDING NEXTRAM MAGISK MODULE"
printf "${CYAN}Starting module compilation...${NC}\n\n"

ZIP_VERSION=$(zip -v 2>/dev/null | head -n 1 | grep -o "Zip [0-9.]*" || printf "unknown")
printf "${YELLOW}Zip version: ${ZIP_VERSION}${NC}\n"

printf "${MAGENTA}Creating archive...${NC}"
(zip -r -0 NextRAM.zip * > /dev/null 2>&1) &
ZIP_PID=$!
spinner $ZIP_PID
wait $ZIP_PID
ZIP_RESULT=$?

printf "\n\n"
print_separator

if [ $ZIP_RESULT -eq 0 ]; then
    print_header "SUCCESS"
    ARCHIVE_SIZE=$(du -sh NextRAM.zip | cut -f1)
    FILE_COUNT=$(unzip -l NextRAM.zip | wc -l)
    FILE_COUNT=$((FILE_COUNT - 3))
    
    printf "${GREEN}✓ Build completed successfully!${NC}\n\n"
    printf "${CYAN}Archive size: ${WHITE}${ARCHIVE_SIZE}${NC}\n"
    printf "${CYAN}Files included: ${WHITE}${FILE_COUNT}${NC}\n"
    printf "${CYAN}Output file: ${WHITE}NextRAM-de-build.zip${NC}\n"
else
    print_header "FAILED"
    printf "${RED}✗ Build failed with error code: ${ZIP_RESULT}${NC}\n"
    printf "${YELLOW}Please check your files and try again${NC}\n"
    exit 1
fi

print_separator
printf "${GREEN}- build end!${NC}\n"
print_separator