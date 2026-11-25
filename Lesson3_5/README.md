# Заняття 3.5. Змінні, блоки, умови, цикли, шаблони та ролі в Ansible
### Змістовний модуль 3 · Автоматизація конфігурації

> **Тип заняття:** групове заняття та самостійна робота.
>
> **Тривалість:** 120 хвилин.
>
> **Формат:** викладач пояснює й демонструє Ansible-елементи, курсанти самостійно виконують вправу з inventory, playbook, шаблоном і допоміжними модулями.

## Навчальні питання

1. Змінні в Ansible.
2. Блоки, умови, цикли та шаблони Jinja2 в Ansible.
3. Ролі в Ansible.
4. Допоміжні модулі `register`, `set_fact` і `debug`.

## Мета заняття

Після заняття курсант може:

- оголосити й перевизначити змінні на рівні play, host, inventory і fact;
- використовувати змінні у Jinja2-шаблонах;
- групувати задачі блоком і обробляти помилки через `rescue`;
- застосовувати `when` та цикли `loop`;
- створювати найпростіший шаблон і передавати його на managed node;
- описати структуру role та підключати role до play;
- отримувати результати модуля через `register`;
- створювати нові змінні через `set_fact`;
- виводити дані для налагодження через `debug`.

## План заняття

| Час | Етап |
|---:|---|
| 10 хв | Повторення inventory, play, task і підключення до вузла |
| 20 хв | Джерела й пріоритети змінних |
| 20 хв | Блоки, умови та цикли |
| 20 хв | Шаблони Jinja2 |
| 20 хв | Структура ролі та приклад role |
| 25 хв | Самостійна робота з `register`, `set_fact` і `debug` |
| 5 хв | Підсумок і контрольні питання |

## 1. Змінні в Ansible

Змінна — іменована пара назви й значення. Їх використовують для параметрів хоста, встановлюваних пакетів, назв служб, шляхів, користувачів і портів.

| Джерело | Приклад |
|---|---|
| Inventory host vars | `ansible_host`, `ansible_user`, власні параметри хоста |
| `group_vars` і `host_vars` | Значення за групою або окремим вузлом |
| Змінні play | Блок `vars:` всередині play |
| Extra vars | `-e "environment=lab"` або `-e @values.yaml` |
| Зібрані facts | Змінні модуля `setup`, наприклад `ansible_distribution` |
| Створені факти | Результат `set_fact` під час виконання |

Символи часто використовуються через Jinja2:

```yaml
- name: Print a variable
  ansible.builtin.debug:
    msg: "Host {{ inventory_hostname }} belongs to {{ environment }}"
```

Загальне правило пріоритету: локальні значення можуть перевизначати загальні, а extra vars мають найвищий звичайний приоритет. Не покладайтеся на складне перевизначення. Для кожного середовища створюйте зрозумілу inventory-групу або окремий vars-файл.

> Не зберігайте паролі, приватні ключі й токени у звичайних playbook або Git. Використовуйте захищені сховища або шифроване сховище Ansible Vault.

## 2. Блоки, умови та цикли

### 2.1. Блоки

Блок групує пов'язані tasks і дозволяє застосувати спільні параметри, наприклад `become`:

```yaml
- name: Configure packages
  become: true
  block:
    - name: Install a package
      ansible.builtin.apt:
        name: nginx
        state: present
  rescue:
    - name: Report package failure
      ansible.builtin.debug:
        msg: "Package installation failed on {{ inventory_hostname }}"
  always:
    - name: Record that configuration was attempted
      ansible.builtin.debug:
        msg: "Configuration attempt completed"
```

`rescue` працює як відновлення після невдалої задачі всередині блока. `always` запускається незалежно від успіху або помилки.

### 2.2. Умови

Модуль `when` пропускає task, коли вираз хибний:

```yaml
- name: Install Debian family packages
  ansible.builtin.apt:
    name: curl
    state: present
  when: ansible_os_family == "Debian"
```

Не треба писати порівняння як рядок Jinja2 у `when`; властивий синтаксис — вираз YAML:

```yaml
when:
  - ansible_os_family == "Debian"
  - app_enabled | bool
```

### 2.3. Цикли

`loop` запускає task для кожного елемента:

```yaml
- name: Create directories
  ansible.builtin.file:
    path: "{{ item }}"
    state: directory
    mode: "0755"
  loop:
    - /opt/lesson3-5
    - /opt/lesson3-5/logs
```

Для словників зручно використовувати іменовані змінні елемента:

```yaml
- name: Create application directories
  ansible.builtin.file:
    path: "{{ item.path }}"
    state: directory
    mode: "{{ item.mode }}"
  loop:
    - { path: "/opt/app", mode: "0755" }
    - { path: "/opt/app/config", mode: "0750" }
```

## 3. Шаблони Jinja2

Шаблон зберігає текст із змінними Jinja2 і передається модулем `template`:

```jinja2
# {{ ansible_managed }}
Environment={{ environment }}
Hostname={{ ansible_hostname }}
{% for directory in managed_directories %}
Directory={{ directory }}
{% endfor %}
```

Приклад задачі:

```yaml
- name: Render configuration
  ansible.builtin.template:
    src: lesson.conf.j2
    dest: /opt/lesson3-5/lesson.conf
    mode: "0644"
```

Jinja2 дозволяє змінні `{{ ... }}`, фільтри `{{ value | upper }}` і керуючі конструкції `{% if ... %}`, `{% for ... %}`.

## 4. Ролі в Ansible

**Role** — організований набір змінних, задач, handlers, шаблонів і файлів для певної функції.

```text
roles/
└── system_report/
    ├── defaults/main.yml
    ├── tasks/main.yml
    ├── handlers/main.yml
    ├── templates/report.j2
    └── vars/main.yml
```

| Каталог | Призначення |
|---|---|
| `tasks/` | Основні задачі ролі |
| `defaults/` | Змінні з найнижчим звичайним пріоритетом |
| `vars/` | Значення змінних ролі |
| `templates/` | Jinja2-шаблони |
| `files/` | Статичні файли для копіювання |
| `handlers/` | Обробники подій, наприклад перезапуск служби |

Role підключають у play:

```yaml
- name: Generate a system report
  hosts: lesson34
  become: true
  roles:
    - role: system_report
```

Роль не створюється лише для одного короткого фрагмента. Її доцільно виділяти для повторно використовуваного елемента конфігурації: базові налаштування ОС, web-сервер, firewall або моніторинг.

## 5. Допоміжні модулі

### 5.1. `register`

`register` зберігає повний результат виконаного task у змінній:

```yaml
- name: Check disk usage
  ansible.builtin.command: df -h /
  register: disk_check
  changed_when: false

- name: Show disk result
  ansible.builtin.debug:
    var: disk_check.stdout
```

`register` не гарантовано повертає поле `stdout`. Перевіряйте тип модуля та структура його результату.

### 5.2. `set_fact`

`set_fact` створює змінну під час виконання play:

```yaml
- name: Store a computed report name
  ansible.builtin.set_fact:
    report_name: "report-{{ inventory_hostname }}.txt"
```

На відміну від facts, які автоматично збираються fact gathering, set_fact факти створюються явно поточною задачею.

### 5.3. `debug`

`debug.msg` формує довільне повідомлення, а `debug.var` показує вміст конкретної змінної:

```yaml
- name: Show selected facts
  ansible.builtin.debug:
    msg:
      hostname: "{{ ansible_hostname }}"
      os_family: "{{ ansible_os_family }}"
```

Не виводьте у `debug` секрети або повні змінні, які можуть містити credentials.

## 6. Демонстраційний проєкт

Приклад у [`examples`](./examples) містить inventory, playbook, group vars і роль.

### Топологія демонстрації

| Вузол | IP-адреса | Призначення |
|---|---|---|
| Control plane | `10.243.2.99` | Тут встановлено Ansible і звідси запускається playbook. |
| Managed node | `10.243.2.100` | Цільовий Ubuntu-вузол з SSH-користувачем `ubuntu`. |

Control plane не додається до inventory: playbook керує лише managed node. Перед заняттям покладіть каталог `Lesson3_5` у робочу копію проєкту на control plane. Переконайтеся, що на `10.243.2.99` встановлено Ansible, а SSH-ключ користувача доступний через `ssh-agent` або стандартний SSH client config. Не додавайте приватний ключ до каталогу прикладу чи Git.

Playbook не встановлює пакети й працює лише з каталогами та файлами у `/tmp` на керованому вузлі. Команди нижче виконуйте на control plane `10.243.2.99` з кореня копії репозиторію:

```bash
cd Lesson3_5/examples
ansible --version
ansible-inventory -i inventory.yaml --list
ansible lesson34 -i inventory.yaml -m ansible.builtin.ping
ansible-playbook -i inventory.yaml site.yaml --syntax-check
ansible-playbook -i inventory.yaml site.yaml --check --diff
ansible-playbook -i inventory.yaml site.yaml --diff
ansible-playbook -i inventory.yaml site.yaml
ansible lesson34 -i inventory.yaml -m ansible.builtin.command -a "cat /tmp/lesson3-5-report/report.txt"
```

Перший запуск створює каталоги й звіт; наступний має показати `changed=0`. Перевірте вивід `cat`: у ньому будуть hostname, сімейство ОС, середовище, статус і список каталогів. Якщо SSH-користувач або ключ відрізняються, скоригуйте відповідні SSH-налаштування, не зберігаючи секрети в inventory.

### Демонстрація викладача

1. Показати, що команди запускаються на `10.243.2.99`, а inventory спрямовує їх на `10.243.2.100`.
2. Пояснити значення змінних з `group_vars/lesson34.yaml`.
3. Виконати playbook у check mode.
4. Переглянути task із `register` і структуру змінної.
5. Показати формування змінної через `set_fact`.
6. Пояснити `block`, `rescue`, `always` та умову `when`.
7. Пояснити цикл над каталогами.
8. Прочитати Jinja2-шаблон і результуючий звіт.
9. Виконати playbook повністю, перевірити `/tmp/lesson3-5-report/report.txt` і повторити запуск для перевірки ідемпотентності.

## Самостійна робота

### Завдання

Створіть playbook, який для вузла з inventory:

1. збирає facts і перевіряє, чи `ansible_os_family` дорівнює `Debian`;
2. перевіряє директорію `/tmp/lesson3-5-register` модулем `stat`;
3. зберігає результат у змінній через `register`;
4. створює змінну `report_status` через `set_fact` зі значенням `exists` або `missing`;
5. показує три ключові facts і статус через `debug`;
6. для двох шляхів створює каталоги через `loop`;
7. рендерить Jinja2-шаблон у `/tmp/lesson3-5-report/report.txt`;
8. повторно запускає playbook і перевіряє ідемпотентність.

### Вимоги до звіту

У репозиторії залиште:

- playbook;
- inventory або посилання на нього;
- шаблон Jinja2;
- скриншот або текст перевірки SSH-з'єднання;
- скриншот або текст завершення playbook;
- текстовий звіт із коротким описом кожного модуля.

Не публікуйте паролі, приватні ключі або вміст `~/.ssh`.

## Типові помилки

- **Плутають `register` із `set_fact`.** `register` отримує результат task, а `set_fact` явно створює або змінює fact.
- **Використовують `{{ }}` всередині `when`.** `when` уже є виразом Jinja2 без подвійних фігурних дужок.
- **Пишуть shell-команди замість модулів без потреби.** Для файлів, каталогів, пакетів і служб переважно використовуйте модулі.
- **Додають `ignore_errors` замість перевірки причини.** Відключення помилки приховує реальний стан вузла.
- **Перевизначають змінну у багатьох рівнях.** Залишайте один зрозумілий рівень і передавайте environment extra vars явно.
- **Вважають роль набором довільних tasks.** Роль має повторно використовувану структуру й межу відповідальності.
- **Виводять усі змінні у `debug`.** Результат може містити секрети або SSH-параметри.

## Контрольні питання

1. У чому різниця між змінною inventory і fact?
2. Як додати змінну через `set_fact`?
3. Для чого призначений модуль `register`?
4. Яку роль виконують `block`, `rescue` і `always`?
5. Коли варто використовувати `when` і `loop`?
6. Які Jinja2-конструкції передають змінні та цикли у шаблон?
7. Із яких каталогів складається типова role?
8. Чому role краще за простий набір копійованих task-файлів для повторного використання?
9. Яке значення у звіті змінюється через `set_fact`, і навіщо це потрібно?

## Критерії оцінювання

| Критерій | Частка |
|---|---:|
| Коректне inventory та підключення до хоста | 15% |
| Робочий playbook і умова | 20% |
| `register`, `set_fact` і `debug` | 20% |
| Цикл і Jinja2-шаблон | 20% |
| Роль та структура проєкту | 15% |
| Повторний запуск і звіт | 10% |

## Офіційна документація

- [Ansible variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)
- [Ansible conditionals](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
- [Ansible loops](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)
- [Ansible Jinja2 templates](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_templating.html)
- [Ansible roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html)
- [register and set_fact](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#registering-variables)
