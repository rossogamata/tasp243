# 🐳 Технології контейнеризації
### Змістовний модуль 2 · Заняття 1

> **Тема:** Ознайомлення з технологіями контейнеризації. Технологія контейнеризації Docker  
> **Тривалість:** ~120 хвилин  
> **Середовище:** Ubuntu Linux або Windows 10/11 з Docker Desktop  
> **Інструменти:** Docker Engine / Docker Desktop, термінал, Docker Hub

---

## 📋 План заняття

1. Ознайомлення з технологіями контейнеризації.
2. Технологія контейнеризації Docker.
3. Практичне створення образу та розгортання контейнера.
4. Огляд Docker Hub.
5. Самостійна робота: встановлення Docker, створення власного образу та публікація результату.

---

## 🎯 Мета заняття

Після заняття студент повинен:

- пояснювати, навіщо застосовують контейнеризацію;
- розрізняти віртуальну машину, образ, контейнер і registry;
- встановлювати та перевіряти Docker;
- запускати, зупиняти, переглядати й видаляти контейнери;
- створювати власний Docker image з `Dockerfile`;
- знаходити готові образи на Docker Hub і оцінювати їхню придатність.

---

## 1. Ознайомлення з технологіями контейнеризації

### 1.1 Що таке контейнеризація?

Контейнеризація — це спосіб пакування застосунку разом із його залежностями у відокремлене середовище запуску. Контейнер використовує ядро операційної системи хоста, але має власну файлову систему, мережевий простір, процеси та обмеження ресурсів.

Це вирішує типову проблему: "на моєму комп'ютері все працює". Замість ручного встановлення однакових версій Python, Node.js, бібліотек і системних пакетів ми описуємо середовище як код і запускаємо його однаково на ноутбуці, сервері або в хмарі.

### 1.2 Контейнер і віртуальна машина

| Ознака | Віртуальна машина | Контейнер |
|---|---|---|
| Що віртуалізується | Повна апаратна система | Процеси та середовище ОС |
| Гостьова ОС | Окрема ОС для кожної VM | Використовує ядро хоста |
| Розмір | Зазвичай гігабайти | Часто мегабайти або сотні мегабайтів |
| Запуск | Десятки секунд або хвилини | Зазвичай секунди або менше |
| Ізоляція | Сильніша апаратна ізоляція | Ізоляція на рівні ОС |
| Приклад | VMware, VirtualBox, EC2 | Docker, Podman, containerd |

Контейнер не є "маленькою віртуальною машиною": у ньому немає власного ядра Linux. На Windows Docker Desktop запускає Linux-контейнери через WSL 2 або легку віртуальну машину, тому користувач отримує Linux-сумісне середовище поверх Windows.

### 1.3 Переваги та обмеження

**Переваги:** відтворюваність, швидкий запуск, ізоляція залежностей, зручне масштабування, просте переміщення між середовищами.

**Обмеження:** контейнер не замінює повноцінну безпекову ізоляцію VM у всіх сценаріях; потрібно контролювати образи, секрети, права доступу та споживання ресурсів. Дані всередині контейнера зникають разом із контейнером, якщо їх не винести у volume або зовнішнє сховище.

---

## 2. Основні поняття Docker

Docker — платформа для створення, доставки та запуску контейнерів.

| Поняття | Пояснення |
|---|---|
| **Dockerfile** | Текстовий рецепт побудови образу |
| **Image / образ** | Незмінний шаблон із файловою системою та метаданими |
| **Container / контейнер** | Запущений екземпляр образу |
| **Registry** | Сховище образів; приклад — Docker Hub |
| **Tag** | Мітка версії образу, наприклад `nginx:1.27` |
| **Volume** | Кероване сховище даних поза життєвим циклом контейнера |
| **Port mapping** | Зв'язок порту хоста з портом контейнера |

Один образ може породити багато контейнерів. Образ не змінюється під час запуску: зміни у файловій системі контейнера належать конкретному контейнеру. Для передачі змін іншим машинам потрібно створити нову версію образу.

### 2.1 Як працює команда `docker run`

```text
docker run -d -p 8080:80 --name web nginx
             │  │    │           │
             │  │    │           └─ ім'я контейнера
             │  │    └───────────── порт хоста:порт контейнера
             │  └────────────────── detached: у фоновому режимі
             └───────────────────── створити та запустити контейнер
```

Якщо образу `nginx` немає локально, Docker спочатку завантажить його з registry, потім створить контейнер і запустить головний процес образу. Опція `-p 8080:80` означає: запити на `localhost:8080` хоста передати на порт `80` усередині контейнера.

---

## 3. Перевірка перед практикою

Відкрийте термінал.

### Ubuntu Linux

```bash
cat /etc/os-release | head
uname -m
```

### Windows PowerShell

```powershell
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
Get-Service com.docker.service
```

Потрібна 64-бітна система. Для Windows рекомендується Windows 10/11 із WSL 2 та Docker Desktop.

---

## 4. Встановлення Docker

### 4.1 Ubuntu Linux

Нижче наведено офіційний спосіб встановлення Docker Engine через Docker apt repository. Команди додають репозиторій, встановлюють Engine, CLI, containerd і плагіни Buildx та Compose.

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

Перевірка встановлення:

```bash
sudo docker version
sudo docker run --rm hello-world
```

Щоб виконувати Docker без `sudo`, додайте поточного користувача до групи `docker`. Зверніть увагу: членство в цій групі фактично дає права рівня root, тому на спільному сервері це потрібно погодити з адміністратором.

```bash
sudo usermod -aG docker "$USER"
newgrp docker
docker run --rm hello-world
```

### 4.2 Windows 10/11

1. Увімкніть віртуалізацію Intel VT-x або AMD-V у BIOS/UEFI, якщо вона вимкнена.
2. Встановіть і запустіть **Docker Desktop for Windows** з офіційного сайту Docker.
3. Під час інсталяції виберіть backend **Use WSL 2 instead of Hyper-V**, якщо ця опція доступна.
4. У PowerShell перевірте WSL:

```powershell
wsl --install
wsl --update
wsl --status
```

5. Перезапустіть Docker Desktop і дочекайтеся стану **Engine running**.
6. У PowerShell перевірте Docker:

```powershell
docker version
docker run --rm hello-world
```

Docker Desktop запускає Docker daemon у Linux-середовищі, а команда `docker` у PowerShell є клієнтом для цього daemon. Не плутайте Docker Desktop із Docker Engine: Desktop є зручним комплектом для Windows, який містить Engine, CLI та додаткові інструменти.

---

## 5. Практика: готовий образ і контейнер

### 5.1 Завантаження образу

```bash
docker pull nginx:1.27
docker image ls
```

`docker pull` завантажує образ із Docker Hub. Фіксований tag `1.27` кращий для навчального прикладу, ніж `latest`: результат буде більш передбачуваним. У production бажано додатково фіксувати digest образу.

### 5.2 Запуск вебсервера

```bash
docker run -d \
  --name lesson-web \
  --publish 8080:80 \
  nginx:1.27

docker ps
```

Відкрийте у браузері `http://localhost:8080`. Якщо сторінка NGINX відобразилася, контейнер працює, а port mapping налаштовано правильно.

### 5.3 Дослідження контейнера

```bash
docker ps -a
docker logs lesson-web
docker inspect lesson-web
docker exec lesson-web nginx -v
```

- `docker ps` показує запущені контейнери.
- `docker ps -a` показує також зупинені.
- `docker logs` показує stdout/stderr головного процесу.
- `docker inspect` показує мережу, mounts, змінні та конфігурацію.
- `docker exec` запускає додаткову команду всередині активного контейнера.

### 5.4 Зупинка та видалення

```bash
docker stop lesson-web
docker rm lesson-web
docker image rm nginx:1.27
```

Зупинка не видаляє контейнер, а `docker rm` видаляє його метадані та writable layer. Образ можна видалити лише після видалення контейнерів, які його використовують.

---

## 6. Створення власного образу

Створимо маленький вебзастосунок без зовнішніх бібліотек. `Dockerfile` описує повторювану збірку образу: базовий образ, робочу директорію, копіювання файлів, порт і команду запуску.

```bash
mkdir -p ~/lesson2_1/site
cd ~/lesson2_1

cat > site/index.html <<'EOF'
<!doctype html>
<html lang="uk">
<head><meta charset="utf-8"><title>Docker Lesson</title></head>
<body>
  <h1>Мій перший власний Docker image</h1>
  <p>Цю сторінку запущено в контейнері.</p>
</body>
</html>
EOF

cat > Dockerfile <<'EOF'
FROM nginx:1.27-alpine
LABEL org.opencontainers.image.title="lesson2-1-web"
WORKDIR /usr/share/nginx/html
COPY site/index.html ./index.html
EXPOSE 80
EOF
```

### 6.1 Пояснення `Dockerfile`

1. `FROM nginx:1.27-alpine` — беремо готовий мінімальний образ NGINX на Alpine Linux.
2. `LABEL` — додаємо метадані образу.
3. `WORKDIR` — задаємо робочу директорію для наступних інструкцій.
4. `COPY` — копіюємо HTML із build context у файлову систему образу.
5. `EXPOSE 80` документує порт, який слухає застосунок. Він не публікує порт автоматично.

### 6.2 Build і запуск

```bash
docker build --tag lesson2-1-web:1.0 .
docker image ls lesson2-1-web
docker run -d --name lesson2-1-web-container --publish 8080:80 lesson2-1-web:1.0
```

Перевірте результат:

```bash
curl http://localhost:8080
docker ps --filter name=lesson2-1-web-container
```

У Windows PowerShell замість `curl` можна відкрити URL у браузері або виконати:

```powershell
Invoke-WebRequest http://localhost:8080 | Select-Object -ExpandProperty Content
```

### 6.3 Build context і `.dockerignore`

Docker передає вміст поточної директорії як build context. Не слід копіювати в context секрети, `.git`, великі архіви або локальні залежності.

```bash
cat > .dockerignore <<'EOF'
.git
.env
*.log
node_modules
EOF
```

Після зміни `.dockerignore` перебудуйте образ із новим tag:

```bash
docker build --tag lesson2-1-web:1.1 .
```

Не додавайте паролі або API-ключі до `Dockerfile`: інструкції та шари образу можуть бути доступні іншим користувачам. Секрети передають через секрет-сховища або runtime-механізми оркестратора.

---

## 7. Огляд Docker Hub

**Docker Hub** — публічний registry, де можна шукати, завантажувати та публікувати образи. Репозиторій може містити багато tag-ів однієї програми.

1. Відкрийте [hub.docker.com](https://hub.docker.com/).
2. Знайдіть офіційний образ `nginx`, `ubuntu` або `python`.
3. Перевірте, хто є publisher/owner образу.
4. Прочитайте опис, supported tags, документацію та security information.
5. Зверніть увагу на дату оновлення та кількість завантажень.
6. Порівняйте повний образ і slim/alpine-варіант.

### 7.1 Утворення імені образу

```text
DOCKERHUB_USERNAME/REPOSITORY:TAG
```

Наприклад: `student123/lesson2-1-web:1.0`.

Для публікації потрібен власний обліковий запис Docker Hub:

```bash
docker login
docker tag lesson2-1-web:1.0 DOCKERHUB_USERNAME/lesson2-1-web:1.0
docker push DOCKERHUB_USERNAME/lesson2-1-web:1.0
```

Замість `DOCKERHUB_USERNAME` підставте власне ім'я користувача. Не вводьте пароль у командному рядку та не додавайте його до файлів; Docker рекомендує використовувати personal access token замість пароля.

Перевірка завантаження на іншій машині:

```bash
docker pull DOCKERHUB_USERNAME/lesson2-1-web:1.0
docker run --rm --publish 8080:80 DOCKERHUB_USERNAME/lesson2-1-web:1.0
```

### 7.2 Критичне оцінювання образу

Перед використанням чужого образу перевірте: офіційність джерела, актуальність tag, базовий образ, відкриті порти, необхідні права, наявність CVE та політику оновлень. Tag `latest` не гарантує незмінності, тому для відтворюваної збірки використовуйте версію або digest.

---

## 🧹 Очищення після практики

```bash
docker stop lesson2-1-web-container 2>/dev/null || true
docker rm lesson2-1-web-container 2>/dev/null || true
docker image rm lesson2-1-web:1.0 lesson2-1-web:1.1 2>/dev/null || true
docker system df
```

Не виконуйте `docker system prune -a` без перевірки: команда може видалити всі невикористані локальні образи, зокрема потрібні для інших проєктів.

---

## 🧑‍💻 Самостійна робота

### Завдання 1. Встановлення Docker

1. Встановіть Docker Engine на Ubuntu Linux або Docker Desktop на Windows.
2. Зробіть перевірку командами `docker version` і `docker run --rm hello-world`.
3. Зафіксуйте версію Docker та тип операційної системи.

### Завдання 2. Створення образу та розгортання контейнера

1. Створіть папку `self-work` і файл `index.html` зі своїм текстом.
2. Напишіть `Dockerfile` на базі `nginx:1.27-alpine`.
3. Побудуйте образ із tag `student-web:1.0`.
4. Запустіть контейнер із зовнішнім портом `8090`.
5. Перевірте сайт у браузері та командою `docker ps`.
6. Змініть HTML, створіть tag `student-web:2.0` і порівняйте версії контейнерів.

### Завдання 3. Огляд Docker Hub

1. Знайдіть офіційні образи `nginx`, `python` і `ubuntu`.
2. Для кожного запишіть: publisher, останній стабільний tag, базовий розмір або варіанти образу.
3. Поясніть, чому `latest` не є достатньою гарантією відтворюваної збірки.
4. Знайдіть у Docker Hub security information для одного образу та наведіть приклад вразливості або поясніть, що саме було перевірено.
5. Підготуйте коротке порівняння Docker Hub і приватного registry.

### Питання для обговорення

1. Чому контейнер зазвичай має один головний процес?
2. Чому дані в контейнері не варто зберігати без volume?
3. Чим `docker stop` відрізняється від `docker kill`?
4. Що станеться, якщо два контейнери спробують опублікувати один і той самий порт хоста?
5. Чому образ на базі Alpine не завжди автоматично кращий за Debian/Ubuntu?
6. Чи є контейнер достатнім захистом від шкідливого коду? Обґрунтуйте відповідь.
7. Які переваги дає опис інфраструктури у `Dockerfile`, порівняно з ручним налаштуванням сервера?

---

## ✅ Очікуваний результат

Студент має встановлений Docker, вміє запустити готовий образ, створити власний образ із `Dockerfile`, розгорнути контейнер із port mapping і знайти потрібний образ на Docker Hub. Також студент розуміє базові ризики: неперевірені образи, незакріплені версії, секрети в шарах і відсутність persistent storage.
