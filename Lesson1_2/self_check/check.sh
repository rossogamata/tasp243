#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   AWS Academy — Self-Assessment Script / Скрипт перевірки   ║
# ║   Cloud Technologies / Хмарні технології — 5th Year         ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Colors / Кольори ────────────────────────────────────────────
RED='\033[0;31m';    GREEN='\033[0;32m';  YELLOW='\033[1;33m'
BLUE='\033[0;34m';   CYAN='\033[0;36m';  MAGENTA='\033[0;35m'
BOLD='\033[1m';      DIM='\033[2m';      NC='\033[0m'

# ── Score counters / Лічильники балів ───────────────────────────
QUIZ_CORRECT=0;  QUIZ_TOTAL=0
INFRA_CORRECT=0; INFRA_TOTAL=0

# ── Helpers / Допоміжні функції ─────────────────────────────────
ok()    { echo -e "  ${GREEN}✅  $1${NC}"; }
fail()  { echo -e "  ${RED}❌  $1${NC}"; }
warn()  { echo -e "  ${YELLOW}⚠️   $1${NC}"; }
info()  { echo -e "  ${BLUE}ℹ️   $1${NC}"; }
hint()  { echo -e "  ${DIM}     💡 $1${NC}"; }

section() {
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

pause() {
  echo ""
  read -rp "$(echo -e "  ${MAGENTA}▶  Press Enter to continue / Натисніть Enter...${NC}")" _
}

# ── Multiple choice question / Запитання з варіантами ───────────
# Usage: mcq "question" correct_num "hint_text" "opt1" "opt2" ...
mcq() {
  local question="$1"; local correct="$2"; local hint_text="$3"
  shift 3; local opts=("$@")

  echo ""
  echo -e "${BOLD}${YELLOW}❓  $question${NC}"
  echo ""
  for i in "${!opts[@]}"; do
    echo -e "    ${BOLD}$((i+1)))${NC}  ${opts[$i]}"
  done
  echo ""
  read -rp "$(echo -e "  ${BOLD}Your answer / Ваша відповідь (1-${#opts[@]}): ${NC}")" ans

  QUIZ_TOTAL=$((QUIZ_TOTAL+1))
  if [[ "$ans" == "$correct" ]]; then
    ok "Correct / Правильно! 🎉"
    QUIZ_CORRECT=$((QUIZ_CORRECT+1))
  else
    fail "Wrong / Неправильно. Answer / Відповідь: ${BOLD}${correct}) ${opts[$((correct-1))]}${NC}"
    hint "$hint_text"
  fi
}

# ── AWS resource check / Перевірка AWS ресурсу ──────────────────
# Usage: chk_aws "label" "resource_id" "aws command that returns non-empty on success"
chk_aws() {
  local label="$1"; local rid="$2"; local cmd="$3"
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  echo -ne "  Checking / Перевіряю ${BOLD}${label}${NC}... "
  if [[ -z "$rid" || "$rid" == "None" || "$rid" == "null" ]]; then
    echo ""; fail "${label} — ID not provided / ID не введено"; return 1
  fi
  local result; result=$(eval "$cmd" 2>/dev/null)
  if [[ -n "$result" && "$result" != "None" ]]; then
    echo ""; ok "${label}: ${BOLD}${rid}${NC}"; INFRA_CORRECT=$((INFRA_CORRECT+1)); return 0
  else
    echo ""; fail "${label}: not found or error / не знайдено або помилка"; return 1
  fi
}

# ═══════════════════════════════════════════════════════════════
#                          START
# ═══════════════════════════════════════════════════════════════
clear
echo ""
echo -e "${BOLD}${MAGENTA}"
cat << 'BANNER'
  ╔══════════════════════════════════════════════════════════╗
  ║                                                          ║
  ║    AWS ACADEMY  ·  SELF-ASSESSMENT / САМОПЕРЕВІРКА       ║
  ║    VPC  ·  EC2  ·  Network ACL  ·  Elastic IP            ║
  ║                                                          ║
  ╚══════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"
echo -e "  ${CYAN}This script tests your ${BOLD}theory${CYAN} and verifies your ${BOLD}real AWS resources${CYAN}.${NC}"
echo -e "  ${CYAN}Скрипт перевіряє ${BOLD}теорію${CYAN} та реальні ${BOLD}AWS ресурси${CYAN}.${NC}"
echo ""
read -rp "  Full name / Ім'я та прізвище: " STUDENT_NAME
echo ""
echo -e "  ${GREEN}Hello / Привіт, ${BOLD}${STUDENT_NAME}${NC}${GREEN}! Let's go! / Починаємо! 🚀${NC}"

pause

# ═══════════════════════════════════════════════════════════════
#   PART 1 — THEORY QUIZ / ЧАСТИНА 1 — ТЕОРЕТИЧНИЙ КВІЗ
# ═══════════════════════════════════════════════════════════════

section "PART 1 / ЧАСТИНА 1 — Theory Quiz  (10 questions / запитань)"
echo -e "  1 correct answer = 1 point  /  1 правильна відповідь = 1 бал"

# ── Q1 ──────────────────────────────────────────────────────────
section "Question 1 / Запитання 1 of/з 10 — VPC"
mcq \
  "What does VPC stand for, and what is it? / Що таке VPC?" \
  "3" \
  "VPC = Virtual Private Cloud — your own isolated network inside AWS. / VPC = ізольована приватна мережа у хмарі AWS." \
  "Virtual Public Cloud — shared cloud storage / хмарне сховище спільного доступу" \
  "Virtual Private Connection — an encrypted VPN tunnel / зашифрований VPN-тунель" \
  "Virtual Private Cloud — isolated network in the cloud / ізольована мережа в хмарі" \
  "Virtual Processing Core — a compute resource / обчислювальний ресурс"

pause

# ── Q2 ──────────────────────────────────────────────────────────
section "Question 2 / Запитання 2 of/з 10 — CIDR"
mcq \
  "How many IP addresses does the block 10.0.0.0/16 contain? / Скільки IP-адрес у блоці 10.0.0.0/16?" \
  "3" \
  "/16 fixes 16 bits, leaving 16 free → 2¹⁶ = 65,536 addresses. / /16 = 16 фіксованих бітів → 2¹⁶ = 65 536 адрес." \
  "256 addresses / адреси" \
  "4,096 addresses / адреси" \
  "65,536 addresses / адрес" \
  "1,048,576 addresses / адрес"

pause

# ── Q3 ──────────────────────────────────────────────────────────
section "Question 3 / Запитання 3 of/з 10 — Internet Gateway"
mcq \
  "What is the role of an Internet Gateway in a VPC? / Яка роль Internet Gateway у VPC?" \
  "2" \
  "IGW is the bridge between your VPC and the public internet. / IGW — з'єднання між VPC та публічним інтернетом." \
  "It filters traffic between subnets / Фільтрує трафік між підмережами" \
  "It connects the VPC to the public internet / З'єднує VPC з публічним інтернетом" \
  "It distributes IPs to instances / Розподіляє IP між інстансами" \
  "It encrypts traffic between AZs / Шифрує трафік між зонами"

pause

# ── Q4 ──────────────────────────────────────────────────────────
section "Question 4 / Запитання 4 of/з 10 — NACL vs Security Group"
mcq \
  "What is the key difference between Network ACL and Security Group? / Ключова відмінність між NACL та Security Group?" \
  "1" \
  "NACL is stateless (each packet checked independently), SG is stateful (tracks connection state). / NACL — stateless, SG — stateful." \
  "NACL is stateless, SG is stateful — NACL cannot track connection state / NACL не відстежує стан з'єднання" \
  "NACL protects instances, SG protects subnets / NACL захищає інстанси, SG — підмережі" \
  "NACL supports only IPv6, SG only IPv4 / NACL тільки IPv6, SG тільки IPv4" \
  "NACL is a paid feature, SG is free / NACL платна, SG безкоштовна"

pause

# ── Q5 ──────────────────────────────────────────────────────────
section "Question 5 / Запитання 5 of/з 10 — Elastic IP"
mcq \
  "Why use Elastic IP instead of a regular public IP? / Навіщо Elastic IP замість звичайного публічного IP?" \
  "2" \
  "A regular public IP changes on instance restart. Elastic IP is static and stays yours until released. / Звичайний IP змінюється при перезапуску, EIP — статичний." \
  "Elastic IP has faster routing through AWS backbone / Швидша маршрутизація через AWS backbone" \
  "Elastic IP is persistent and can move between instances / Статичний та може переміщуватись між інстансами" \
  "Elastic IP provides automatic DDoS protection / Автоматичний захист від DDoS" \
  "Elastic IP is always free of charge / Завжди безкоштовний"

pause

# ── Q6 ──────────────────────────────────────────────────────────
section "Question 6 / Запитання 6 of/з 10 — Route Table"
mcq \
  "What happens if a subnet has no 0.0.0.0/0 route via IGW? / Що станеться якщо в підмережі немає маршруту 0.0.0.0/0 → IGW?" \
  "3" \
  "0.0.0.0/0 = default route = 'any destination'. Without it routed to IGW, instances have no internet access. / Без маршруту до IGW — немає інтернету." \
  "Instances in that subnet will be deleted / Інстанси будуть видалені" \
  "Instances will find an alternative route automatically / Знайдуть альтернативний маршрут" \
  "Instances in that subnet will have no internet access / Не матимуть доступу до інтернету" \
  "IGW will auto-add the route / IGW додасть маршрут автоматично"

pause

# ── Q7 ──────────────────────────────────────────────────────────
section "Question 7 / Запитання 7 of/з 10 — Availability Zones"
mcq \
  "Why do we place subnets in different Availability Zones? / Навіщо розміщувати підмережі у різних AZ?" \
  "4" \
  "AZs are physically isolated data centers. If one AZ fails, resources in another AZ keep running. / AZ — фізично ізольовані ДЦ, розподіл забезпечує відмовостійкість." \
  "To get lower inter-subnet traffic costs / Нижча вартість трафіку між ними" \
  "To have different CIDR blocks / Щоб мати різні CIDR" \
  "To make AWS CLI commands faster / Щоб CLI команди виконувались швидше" \
  "For fault tolerance — if one AZ fails, the other keeps running / Відмовостійкість"

pause

# ── Q8 ──────────────────────────────────────────────────────────
section "Question 8 / Запитання 8 of/з 10 — NACL rule processing"
mcq \
  "How does Network ACL process rules? / Як NACL обробляє правила?" \
  "1" \
  "Rules are evaluated in ascending rule-number order. The FIRST match is applied — remaining rules are skipped. / Перевіряються від меншого номера, перше співпадіння — застосовується." \
  "In ascending rule-number order — first match wins / У порядку зростання номера, перше співпадіння" \
  "All rules are checked, the most specific one applies / Всі перевіряються, найспецифічніше застосовується" \
  "In descending rule-number order / У порядку спадання номера" \
  "In alphabetical order of protocol name / В алфавітному порядку назви протоколу"

pause

# ── Q9 ──────────────────────────────────────────────────────────
section "Question 9 / Запитання 9 of/з 10 — ENI"
mcq \
  "What is ENI and why does Elastic IP bind to it? / Що таке ENI і навіщо EIP прив'язується до нього?" \
  "2" \
  "ENI = Elastic Network Interface — virtual network card. EIP binds to ENI (not instance directly), so ENI (with EIP) can be moved to any instance. / ENI = мережева карта, EIP прив'язується до ENI щоб його можна було переміщати." \
  "A type of block storage attached to EC2 / Тип блочного сховища для EC2" \
  "A virtual network card that can be attached to an instance / Віртуальна мережева карта" \
  "A network traffic monitoring service / Служба моніторингу трафіку" \
  "An encryption protocol between subnets / Протокол шифрування між підмережами"

pause

# ── Q10 ──────────────────────────────────────────────────────────
section "Question 10 / Запитання 10 of/з 10 — Ephemeral ports & NACL"
mcq \
  "Why did we add NACL rule 130 allowing ports 1024–65535 inbound? / Навіщо правило 130 для портів 1024–65535?" \
  "3" \
  "NACL is stateless: response packets from remote servers arrive on random ephemeral ports (1024–65535). Without this rule, all server responses are blocked. / NACL stateless — відповіді сервера приходять на ephemeral порти, без правила вони заблоковані." \
  "These ports are used by SSH for key exchange / Ці порти SSH використовує для обміну ключами" \
  "AWS reserves these ports for internal management traffic / AWS резервує ці порти для управління" \
  "Because NACL is stateless — TCP response packets arrive on ephemeral ports / NACL stateless — відповіді TCP приходять на ephemeral порти" \
  "These ports must be open for the Internet Gateway to function / IGW потребує цих портів"

pause

# ── Quiz summary / Підсумок квізу ───────────────────────────────
section "Quiz Results / Результати квізу"
echo ""
QUIZ_PCT=$((QUIZ_CORRECT * 100 / QUIZ_TOTAL))
echo -e "  Correct / Правильно:  ${BOLD}${QUIZ_CORRECT} / ${QUIZ_TOTAL}${NC}  (${QUIZ_PCT}%)"
echo -ne "  Grade / Оцінка:  "
if   [[ $QUIZ_PCT -ge 90 ]]; then echo -e "${BOLD}${GREEN}Excellent / Відмінно 🏆${NC}"
elif [[ $QUIZ_PCT -ge 70 ]]; then echo -e "${BOLD}${YELLOW}Good / Добре 👍${NC}"
elif [[ $QUIZ_PCT -ge 50 ]]; then echo -e "${BOLD}${YELLOW}Satisfactory / Задовільно 😐${NC}"
else                               echo -e "${BOLD}${RED}Review material / Повторіть матеріал 📖${NC}"; fi

pause

# ═══════════════════════════════════════════════════════════════
#   PART 2 — AWS INFRASTRUCTURE CHECK / ПЕРЕВІРКА РЕСУРСІВ
# ═══════════════════════════════════════════════════════════════

section "PART 2 / ЧАСТИНА 2 — AWS Infrastructure Verification"
echo ""
echo -e "  ${CYAN}Enter the resource IDs you created during the lab.${NC}"
echo -e "  ${CYAN}Введіть ID ресурсів створених під час заняття.${NC}"
echo -e "  ${DIM}  Tip: if your shell variables are still set, run: echo \$VPC_ID etc.${NC}"
echo -e "  ${DIM}  Підказка: якщо змінні ще є в сесії — виконайте: echo \$VPC_ID тощо${NC}"
echo ""

read -rp "  VPC ID                  (e.g. vpc-0abc1234):      " I_VPC
read -rp "  Subnet-A ID             (e.g. subnet-0abc):       " I_SUB_A
read -rp "  Subnet-B ID             (e.g. subnet-0def):       " I_SUB_B
read -rp "  Internet Gateway ID     (e.g. igw-0abc1234):      " I_IGW
read -rp "  Security Group ID       (e.g. sg-0abc1234):       " I_SG
read -rp "  EC2 WebServer ID        (e.g. i-0abc1234):        " I_INST_A
read -rp "  EC2 AppServer ID        (e.g. i-0def5678):        " I_INST_B
read -rp "  Elastic IP Alloc ID     (e.g. eipalloc-0abc):     " I_EIP

section "Running checks / Виконую перевірки..."
echo ""

# ── VPC ─────────────────────────────────────────────────────────
chk_aws "VPC exists / VPC існує" "$I_VPC" \
  "aws ec2 describe-vpcs --vpc-ids '$I_VPC' --query 'Vpcs[0].VpcId' --output text"

if [[ -n "$I_VPC" ]]; then
  VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids "$I_VPC" \
    --query 'Vpcs[0].CidrBlock' --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ "$VPC_CIDR" == "10.0.0.0/16" ]]; then
    ok "VPC CIDR is correct / правильний: ${BOLD}10.0.0.0/16${NC}"
    INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "VPC CIDR: expected/очікувалось 10.0.0.0/16, found/знайдено: ${BOLD}${VPC_CIDR:-not found}${NC}"
  fi

  VPC_DNS=$(aws ec2 describe-vpc-attribute --vpc-id "$I_VPC" \
    --attribute enableDnsHostnames \
    --query 'EnableDnsHostnames.Value' --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ "$VPC_DNS" == "True" || "$VPC_DNS" == "true" ]]; then
    ok "DNS hostnames enabled / увімкнено ✨"
    INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "DNS hostnames not enabled / не увімкнено on VPC"
  fi
fi

echo ""

# ── Subnets ──────────────────────────────────────────────────────
chk_aws "Subnet-A exists / існує" "$I_SUB_A" \
  "aws ec2 describe-subnets --subnet-ids '$I_SUB_A' --query 'Subnets[0].SubnetId' --output text"

if [[ -n "$I_SUB_A" ]]; then
  SA_CIDR=$(aws ec2 describe-subnets --subnet-ids "$I_SUB_A" \
    --query 'Subnets[0].CidrBlock' --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ "$SA_CIDR" == "10.0.1.0/24" ]]; then
    ok "Subnet-A CIDR correct: ${BOLD}10.0.1.0/24${NC}"; INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "Subnet-A CIDR: expected 10.0.1.0/24, found ${BOLD}${SA_CIDR:-n/a}${NC}"
  fi
fi

chk_aws "Subnet-B exists / існує" "$I_SUB_B" \
  "aws ec2 describe-subnets --subnet-ids '$I_SUB_B' --query 'Subnets[0].SubnetId' --output text"

if [[ -n "$I_SUB_B" ]]; then
  SB_CIDR=$(aws ec2 describe-subnets --subnet-ids "$I_SUB_B" \
    --query 'Subnets[0].CidrBlock' --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ "$SB_CIDR" == "10.0.2.0/24" ]]; then
    ok "Subnet-B CIDR correct: ${BOLD}10.0.2.0/24${NC}"; INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "Subnet-B CIDR: expected 10.0.2.0/24, found ${BOLD}${SB_CIDR:-n/a}${NC}"
  fi
fi

if [[ -n "$I_SUB_A" && -n "$I_SUB_B" ]]; then
  AZ_A=$(aws ec2 describe-subnets --subnet-ids "$I_SUB_A" \
    --query 'Subnets[0].AvailabilityZone' --output text 2>/dev/null)
  AZ_B=$(aws ec2 describe-subnets --subnet-ids "$I_SUB_B" \
    --query 'Subnets[0].AvailabilityZone' --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ -n "$AZ_A" && -n "$AZ_B" && "$AZ_A" != "$AZ_B" ]]; then
    ok "Subnets in different AZs / у різних AZ: ${BOLD}${AZ_A}${NC} + ${BOLD}${AZ_B}${NC} ✨"
    INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "Subnets must be in different AZs! / Підмережі повинні бути в різних AZ! (found: ${AZ_A} + ${AZ_B})"
  fi
fi

echo ""

# ── Internet Gateway ─────────────────────────────────────────────
chk_aws "Internet Gateway exists / існує" "$I_IGW" \
  "aws ec2 describe-internet-gateways --internet-gateway-ids '$I_IGW' --query 'InternetGateways[0].InternetGatewayId' --output text"

if [[ -n "$I_IGW" && -n "$I_VPC" ]]; then
  IGW_STATE=$(aws ec2 describe-internet-gateways \
    --internet-gateway-ids "$I_IGW" \
    --query "InternetGateways[0].Attachments[?VpcId=='${I_VPC}'].State" \
    --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ "$IGW_STATE" == "available" ]]; then
    ok "IGW attached to VPC / прикріплено до VPC ✨"; INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "IGW is NOT attached to VPC / НЕ прикріплено до VPC (state: ${IGW_STATE:-unknown})"
  fi
fi

echo ""

# ── Security Group ───────────────────────────────────────────────
chk_aws "Security Group exists / існує" "$I_SG" \
  "aws ec2 describe-security-groups --group-ids '$I_SG' --query 'SecurityGroups[0].GroupId' --output text"

if [[ -n "$I_SG" ]]; then
  for PORT in 22 80; do
    P_RULE=$(aws ec2 describe-security-groups --group-ids "$I_SG" \
      --query "SecurityGroups[0].IpPermissions[?FromPort==\`${PORT}\`].FromPort" \
      --output text 2>/dev/null)
    INFRA_TOTAL=$((INFRA_TOTAL+1))
    if [[ "$P_RULE" == "$PORT" ]]; then
      ok "SG: port ${PORT} inbound allowed / дозволено ✨"; INFRA_CORRECT=$((INFRA_CORRECT+1))
    else
      fail "SG: port ${PORT} inbound rule NOT FOUND / правило не знайдено"
    fi
  done

  ICMP_RULE=$(aws ec2 describe-security-groups --group-ids "$I_SG" \
    --query "SecurityGroups[0].IpPermissions[?IpProtocol==\`icmp\`].IpProtocol" \
    --output text 2>/dev/null)
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ "$ICMP_RULE" == "icmp" ]]; then
    ok "SG: ICMP (ping) allowed / дозволено ✨"; INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "SG: ICMP rule NOT FOUND / правило не знайдено"
  fi
fi

echo ""

# ── EC2 Instances ────────────────────────────────────────────────
for PAIR in "WebServer:$I_INST_A:$I_SUB_A" "AppServer:$I_INST_B:$I_SUB_B"; do
  NAME="${PAIR%%:*}"; REST="${PAIR#*:}"; IID="${REST%%:*}"; EXPECTED_SUB="${REST##*:}"

  chk_aws "${NAME} exists / існує" "$IID" \
    "aws ec2 describe-instances --instance-ids '$IID' --query 'Reservations[0].Instances[0].InstanceId' --output text"

  if [[ -n "$IID" ]]; then
    STATE=$(aws ec2 describe-instances --instance-ids "$IID" \
      --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null)
    ACTUAL_SUB=$(aws ec2 describe-instances --instance-ids "$IID" \
      --query 'Reservations[0].Instances[0].SubnetId' --output text 2>/dev/null)

    INFRA_TOTAL=$((INFRA_TOTAL+1))
    if [[ "$STATE" == "running" ]]; then
      ok "${NAME} state: ${BOLD}running${NC} ✨"; INFRA_CORRECT=$((INFRA_CORRECT+1))
    else
      warn "${NAME} state: ${BOLD}${STATE:-unknown}${NC} (expected: running)"
    fi

    if [[ -n "$EXPECTED_SUB" && "$ACTUAL_SUB" == "$EXPECTED_SUB" ]]; then
      ok "${NAME} is in the correct subnet / у правильній підмережі: ${BOLD}${ACTUAL_SUB}${NC} ✨"
      INFRA_TOTAL=$((INFRA_TOTAL+1)); INFRA_CORRECT=$((INFRA_CORRECT+1))
    elif [[ -n "$EXPECTED_SUB" ]]; then
      fail "${NAME} subnet mismatch: expected ${BOLD}${EXPECTED_SUB}${NC}, actual ${BOLD}${ACTUAL_SUB}${NC}"
      INFRA_TOTAL=$((INFRA_TOTAL+1))
    fi
  fi
done

echo ""

# ── Elastic IP ───────────────────────────────────────────────────
chk_aws "Elastic IP exists / існує" "$I_EIP" \
  "aws ec2 describe-addresses --allocation-ids '$I_EIP' --query 'Addresses[0].AllocationId' --output text"

if [[ -n "$I_EIP" ]]; then
  EIP_IP=$(aws ec2 describe-addresses --allocation-ids "$I_EIP" \
    --query 'Addresses[0].PublicIp' --output text 2>/dev/null)
  EIP_INST=$(aws ec2 describe-addresses --allocation-ids "$I_EIP" \
    --query 'Addresses[0].InstanceId' --output text 2>/dev/null)

  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ -n "$EIP_INST" && "$EIP_INST" != "None" && "$EIP_INST" != "null" ]]; then
    ok "EIP ${BOLD}${EIP_IP}${NC} is associated / прив'язаний → ${BOLD}${EIP_INST}${NC}"
    INFRA_CORRECT=$((INFRA_CORRECT+1))
  else
    fail "EIP ${BOLD}${EIP_IP}${NC} is NOT associated with any instance / не прив'язаний"
  fi

  # Did they complete the move to AppServer?
  INFRA_TOTAL=$((INFRA_TOTAL+1))
  if [[ -n "$I_INST_B" && "$EIP_INST" == "$I_INST_B" ]]; then
    ok "🎉 EIP moved to AppServer — migration task complete / завдання переміщення виконано!"
    INFRA_CORRECT=$((INFRA_CORRECT+1))
  elif [[ -n "$I_INST_A" && "$EIP_INST" == "$I_INST_A" ]]; then
    warn "EIP is still on WebServer / ще на WebServer — try moving it to AppServer / спробуйте перемістити"
  else
    warn "EIP is on an unrecognized instance / на невідомому інстансі"
  fi
fi

pause

# ═══════════════════════════════════════════════════════════════
#   PART 3 — LIVE DEMO: MOVE EIP NOW / ДЕМО В РЕАЛЬНОМУ ЧАСІ
# ═══════════════════════════════════════════════════════════════

section "PART 3 / ЧАСТИНА 3 — Live Demo: Move Elastic IP  🔄"
echo ""
echo -e "  ${CYAN}Demonstrate the EIP migration right now and we will verify it live.${NC}"
echo -e "  ${CYAN}Продемонструйте переміщення EIP прямо зараз — перевіримо в реальному часі.${NC}"
echo ""
echo -e "  Commands you'll need / Команди які знадобляться:"
echo -e "  ${YELLOW}  aws ec2 disassociate-address --association-id <ASSOC_ID>${NC}"
echo -e "  ${YELLOW}  aws ec2 associate-address --allocation-id <ALLOC_ID> --network-interface-id <ENI_B>${NC}"
echo ""
read -rp "  Ready to demo? / Готові до демонстрації? (yes/так): " DEMO_READY

if [[ "$DEMO_READY" =~ ^(yes|так|y|t)$ ]]; then
  echo ""
  echo -e "  ${YELLOW}⚡  Perform the migration now, then press Enter to verify.${NC}"
  echo -e "  ${YELLOW}⚡  Виконайте переміщення зараз, потім натисніть Enter для перевірки.${NC}"
  pause

  if [[ -n "$I_EIP" && -n "$I_INST_B" ]]; then
    LIVE_INST=$(aws ec2 describe-addresses --allocation-ids "$I_EIP" \
      --query 'Addresses[0].InstanceId' --output text 2>/dev/null)
    LIVE_IP=$(aws ec2 describe-addresses --allocation-ids "$I_EIP" \
      --query 'Addresses[0].PublicIp' --output text 2>/dev/null)
    INFRA_TOTAL=$((INFRA_TOTAL+1))
    if [[ "$LIVE_INST" == "$I_INST_B" ]]; then
      ok "${BOLD}BONUS:${NC} EIP ${BOLD}${LIVE_IP}${NC} is on AppServer — perfect! / відмінно! 🏆"
      INFRA_CORRECT=$((INFRA_CORRECT+1))
    else
      fail "EIP is not yet on AppServer (current: ${BOLD}${LIVE_INST:-unassociated}${NC})"
      hint "Check that you used the correct ASSOC_ID and ENI_B. / Перевірте правильність ASSOC_ID та ENI_B."
    fi
  else
    warn "Cannot verify — EIP Alloc ID or AppServer ID not provided. / Не можу перевірити — ID не введено."
  fi
fi

pause

# ═══════════════════════════════════════════════════════════════
#   PART 4 — FINAL SCORE / ФІНАЛЬНИЙ РЕЗУЛЬТАТ
# ═══════════════════════════════════════════════════════════════

clear
section "🏁  FINAL RESULTS / ФІНАЛЬНІ РЕЗУЛЬТАТИ"
echo ""

TOTAL_CORRECT=$((QUIZ_CORRECT + INFRA_CORRECT))
TOTAL_MAX=$((QUIZ_TOTAL + INFRA_TOTAL))
TOTAL_PCT=$((TOTAL_CORRECT * 100 / TOTAL_MAX))

echo -e "  ${BOLD}Student / Курсант:${NC}  ${STUDENT_NAME}"
echo -e "  ${BOLD}Date / Дата:${NC}        $(date '+%d.%m.%Y %H:%M')"
echo ""
echo -e "  ┌──────────────────────────────────────────────┐"
echo -e "  │  Theory quiz / Теоретичний квіз:             │"
echo -e "  │    ${BOLD}${QUIZ_CORRECT} / ${QUIZ_TOTAL}${NC} correct / правильно               │"
echo -e "  │                                              │"
echo -e "  │  AWS infra checks / Перевірка ресурсів:      │"
echo -e "  │    ${BOLD}${INFRA_CORRECT} / ${INFRA_TOTAL}${NC} passed / пройдено                │"
echo -e "  │  ──────────────────────────────────────────  │"
echo -e "  │  ${BOLD}TOTAL / РАЗОМ:  ${TOTAL_CORRECT} / ${TOTAL_MAX}  (${TOTAL_PCT}%)${NC}             │"
echo -e "  └──────────────────────────────────────────────┘"
echo ""

if   [[ $TOTAL_PCT -ge 90 ]]; then GRADE="Excellent / Відмінно 🏆";   COL=$GREEN
elif [[ $TOTAL_PCT -ge 75 ]]; then GRADE="Good / Добре 🥈";           COL=$CYAN
elif [[ $TOTAL_PCT -ge 60 ]]; then GRADE="Satisfactory / Задовільно 🥉"; COL=$YELLOW
else                                GRADE="Review needed / Повторіть матеріал 📖"; COL=$RED; fi

echo -e "  ${BOLD}${COL}${GRADE}${NC}"
echo ""

if [[ $TOTAL_PCT -lt 75 ]]; then
  echo -e "  ${DIM}Recommended reading / Рекомендовано повторити:${NC}"
  [[ $QUIZ_CORRECT -lt 7 ]] && \
    info "README.md — theory sections / теоретичні розділи"
  [[ $INFRA_CORRECT -lt $((INFRA_TOTAL * 3 / 4)) ]] && \
    info "Lab steps 5–9 (NACL, EC2, Elastic IP) in README.md"
fi

echo ""
echo -e "  ${BOLD}${CYAN}── Further learning / Для подальшого вивчення ───────────────${NC}"
echo -e "  ${DIM}📘 AWS VPC Docs:      https://docs.aws.amazon.com/vpc/${NC}"
echo -e "  ${DIM}📘 AWS CLI Reference: https://docs.aws.amazon.com/cli/latest/reference/${NC}"
echo -e "  ${DIM}📘 AWS Well-Arch:     https://aws.amazon.com/architecture/well-architected/${NC}"
echo ""

# Save result to file / Зберігаємо результат
RESULT_FILE="aws_result_$(echo "$STUDENT_NAME" | tr ' ' '_')_$(date +%Y%m%d_%H%M).txt"
cat << EOF > "$RESULT_FILE"
AWS Academy — Assessment Result / Результат перевірки
======================================================
Student / Курсант : $STUDENT_NAME
Date / Дата       : $(date '+%d.%m.%Y %H:%M')
Quiz score        : $QUIZ_CORRECT / $QUIZ_TOTAL
Infra checks      : $INFRA_CORRECT / $INFRA_TOTAL
Total / Разом     : $TOTAL_CORRECT / $TOTAL_MAX  (${TOTAL_PCT}%)
Grade / Оцінка    : $GRADE

Resources provided / Введені ресурси:
  VPC       : $I_VPC
  Subnet-A  : $I_SUB_A
  Subnet-B  : $I_SUB_B
  IGW       : $I_IGW
  SG        : $I_SG
  WebServer : $I_INST_A
  AppServer : $I_INST_B
  EIP       : $I_EIP
EOF

ok "Result saved / Результат збережено: ${BOLD}${RESULT_FILE}${NC}"
echo ""
echo -e "${BOLD}${MAGENTA}  Thank you! / Дякуємо за роботу!  Слава Україні! 🇺🇦${NC}"
echo ""
