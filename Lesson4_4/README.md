# Заняття 4.4. Модулі та змінні в Terraform
### Змістовний модуль 4 · Infrastructure as Code

> **Тип заняття:** групове.
>
> **Тривалість:** 120 хвилин.
>
> **Формат:** викладач пояснює структуру модулів і передачу змінних, демонструє приклад AWS-модуля та формування плану. Курсанти читають код, прогнозують результат і виконують короткі вправи разом із викладачем.

## Навчальні питання

1. Структура модуля в Terraform.
2. Файли змінних у Terraform.

## Мета заняття

Після заняття курсант може:

- пояснити, що коренева конфігурація Terraform також є модулем;
- розрізняти root module і child module та визначати їхні межі;
- знаходити інтерфейс модуля у вхідних змінних і outputs;
- передавати значення з root module у child module та читати outputs модуля;
- пояснити призначення файлів `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars` і `.tfvars.example`;
- визначати джерело та пріоритет вхідних значень;
- застосовувати типи, значення за замовчуванням, валідацію та позначку `sensitive`;
- розуміти, чому `sensitive` приховує значення у звичайному виводі, але не є шифруванням state.

## План заняття

| Час | Етап |
|---:|---|
| 10 хв | Організаційний момент і повторення структури Terraform-проєкту з заняття 4.3 |
| 20 хв | Root module, child module та призначення модулів |
| 25 хв | Файли й інтерфейс модуля: variables, resources, outputs |
| 20 хв | Джерела змінних, `.tfvars` і пріоритет значень |
| 25 хв | Демонстрація локального AWS-модуля та читання плану |
| 15 хв | Групові вправи й обговорення типових помилок |
| 5 хв | Підсумок і контрольні питання |

## Необхідні умови

- Terraform CLI, встановлений і перевірений на занятті 4.3.
- Базове розуміння HCL, provider, resource, `terraform init`, `validate` і `plan`.
- Для виконання AWS-прикладу — лише навчальний AWS-акаунт і доступи, надані викладачем. Без доступу можна виконати структурний розбір і `validate`, але справжній AWS `plan` потребує облікових даних та звернення до AWS API.
- Демонстраційний приклад не потребує Proxmox. Він використовує AWS S3 для показу повторного використання модуля.

> **Безпека та витрати:** під час заняття не виконуйте `terraform apply` або `terraform destroy`. План може взаємодіяти з AWS API, але не створює ресурси. Не додавайте credentials або локальний `terraform.tfvars` до Git.

## 1. Модулі Terraform

**Модуль** — сукупність Terraform-конфігураційних файлів в одному каталозі. Terraform завжди запускається в контексті модуля:

- **Root module** — конфігурація в робочому каталозі, де курсант запускає Terraform CLI.
- **Child module** — модуль, який викликає root або інший модуль через блок `module`.
- **Reusable module** — child module, який має зрозумілий інтерфейс і може використовуватися в кількох конфігураціях.

```text
examples/aws/                 ← root module
├── main.tf                   ← provider і виклик module
├── variables.tf              ← вхідні значення root module
├── outputs.tf                ← результати root module
├── terraform.tfvars.example  ← приклад значень, не автоматичний файл
└── modules/
    └── s3_bucket/            ← child module
        ├── main.tf           ← ресурс AWS S3
        ├── variables.tf      ← інтерфейс child module
        └── outputs.tf        ← дані, які child повертає root
```

Поділ на окремі `.tf` файли є домовленістю для читабельності. Усі файли `.tf` у межах одного каталогу разом становлять конфігурацію цього модуля. Каталог `modules/s3_bucket` — окремий модуль із власним набором конфігураційних файлів.

### 1.1. Вхідні змінні та outputs як інтерфейс

Вхідні змінні передають налаштування **в** модуль. Outputs передають корисні результати **з** модуля. Root module викликає child через `module` і передає аргументи, які відповідають його змінним.

```text
root variable
     │
     ▼
module "bucket" { bucket_prefix = var.bucket_prefix }
     │
     ▼
child variable.bucket_prefix → ресурс S3
     │
     ▼
child output.bucket_name → root output
```

У цьому занятті child module створює один S3 bucket. Його інтерфейс — префікс і набір тегів. Сам модуль повертає назву й ARN створеного ресурсу.

## 2. Структура прикладу

Навчальний приклад розташовано в [`examples/aws`](./examples/aws). Файли демонструють виклик локального модуля, типізовані змінні й outputs. У кореневому модулі не задаються AWS access keys: провайдер отримує доступ через стандартний ланцюжок credentials AWS.

### 2.1. Root module викликає child module

У `main.tf` root module визначає версію Terraform, provider та виклик локального модуля:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "bucket" {
  source        = "./modules/s3_bucket"
  bucket_prefix = var.bucket_prefix

  tags = {
    Environment = var.environment
    Lesson      = "4-4"
  }
}
```

`source = "./modules/s3_bucket"` вказує на локальний каталог child module. Root module передає значення `var.bucket_prefix` та аргумент `tags`. Child module оголошує адресу й сумісну версію провайдера у власному `required_providers`; конфігурацію провайдера задає root module, а child module отримує її через стандартне успадкування.

### 2.2. Вхідні змінні child module

У `modules/s3_bucket/variables.tf` змінні визначають типізований інтерфейс модуля:

```hcl
variable "bucket_prefix" {
  description = "Prefix used to generate a unique S3 bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.bucket_prefix))
    error_message = "Use lowercase letters, digits, and hyphens; the prefix must start with a lowercase letter or digit."
  }
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default     = {}
}
```

Тип `string` забороняє передати число замість тексту, а `map(string)` описує набір пар «ключ — текстове значення». `default = {}` робить змінну тегів необов'язковою. Валідація перевіряє частину вимог до формату префікса, але не замінює повну перевірку правил іменування S3.

### 2.3. Ресурс і outputs child module

У `modules/s3_bucket/main.tf` child module використовує вхідні змінні:

```hcl
resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
  tags           = var.tags
}
```

У `modules/s3_bucket/outputs.tf` модуль надає root module атрибути ресурсу:

```hcl
output "bucket_name" {
  description = "Name of the created bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the created bucket."
  value       = aws_s3_bucket.this.arn
}
```

Root module може відобразити їх у власних `outputs.tf`:

```hcl
output "bucket_name" {
  description = "Name of the lesson bucket."
  value       = module.bucket.bucket_name
}
```

Синтаксис `module.bucket.bucket_name` означає: output `bucket_name` з виклику child module, який названо `bucket`. Output не створює ресурс і не є секретним сховищем.

## 3. Файли змінних Terraform

Оголошення змінних і значення змінних — різні речі:

- `variable` у `.tf` описує назву, тип, опис, default, валідацію та чутливість.
- файл значень надає значення оголошеним змінним для конкретного запуску або середовища.
- значення також можна передати через змінні середовища чи CLI.

### 3.1. Файли й джерела значень

| Спосіб | Приклад | Особливість |
|---|---|---|
| Значення за замовчуванням | `default = "dev"` у `variable` | Використовується, якщо інше джерело значення не задане. |
| Автоматичний файл | `terraform.tfvars` або `terraform.tfvars.json` | Автоматично читається з робочого каталогу. |
| Автоматичні файли | `*.auto.tfvars` або `*.auto.tfvars.json` | Читаються автоматично; якщо їх кілька, обробляються за алфавітом. |
| Явний файл | `terraform plan -var-file="dev.tfvars"` | Файл передається явно для конкретної команди. |
| Змінна середовища | `TF_VAR_environment=dev` | Зручно для автоматизації; секрети мають отримуватися із захищеного механізму. |
| Аргумент CLI | `terraform plan -var="environment=dev"` | Підходить для несекретних коротких значень; аргументи можуть потрапляти в історію shell або список процесів. |

Для типових конфігурацій пріоритет зростає знизу догори: default → `TF_VAR_*` → `terraform.tfvars`/JSON → `*.auto.tfvars`/JSON → `-var-file` та `-var`. Коли для однієї змінної задано кілька значень, використовується значення з вищим пріоритетом; не покладайтеся на неоднозначні дублікати — задавайте кожну змінну з одного очікуваного джерела.

Файл `terraform.tfvars.example` є шаблоном для людини: Terraform не завантажує його автоматично. Курсант копіює його до `terraform.tfvars` або передає приклад іншим погодженим способом. Реальний `terraform.tfvars` зазвичай додають у `.gitignore`, якщо він може містити середовищні значення чи секрети.

### 3.2. Значення за замовчуванням, типи та validation

В `examples/aws/variables.tf` root module оголошує `aws_region`, `bucket_prefix` і `environment`. Зразок значень лежить у `terraform.tfvars.example`.

- Додавайте тип до змінної, щоб Terraform міг перевірити форму значення.
- Задавайте `default`, якщо значення безпечне й однакове для типового використання; не задавайте default для обов'язкових і середовищно-залежних параметрів без причини.
- Використовуйте `validation` для обмежень, які можна перевірити на рівні значення.
- Текст `description` має пояснювати призначення й одиниці виміру, якщо це актуально.
- Не передавайте в змінних секрети, якщо для цього є кращий механізм провайдера або secret manager.

### 3.3. Sensitive values і state

`sensitive = true` позначає значення як чутливе й приховує його в типових CLI-виводах. Це **не** шифрує значення у Terraform state, plan-файлі або зовнішніх системах. Захищайте state відповідно до чутливості даних, обмежуйте доступ, використовуйте захищений backend і не публікуйте файли планів.

## 4. Демонстрація викладача

1. Показати дерево `examples/aws`; визначити root module та child module.
2. Прочитати `source` у блоці `module` й простежити передачу `bucket_prefix` від root variable до ресурсу.
3. Порівняти оголошення `variable` у `variables.tf` зі значеннями в `terraform.tfvars.example`.
4. Простежити output від ресурсу child module до root output.
5. Пояснити, чому дочірній модуль не містить AWS credentials, а провайдер конфігурується на рівні root module.
6. Перевірити, що локальний `terraform.tfvars` не потрапляє у Git.
7. Виконати перевірки та план лише з дозволеним навчальним AWS-профілем:

```bash
cd Lesson4_4/examples/aws
cp terraform.tfvars.example terraform.tfvars
aws sts get-caller-identity
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
```

Під час читання плану викладач просить курсантів пояснити, звідки взялися регіон, префікс і теги. Після демонстрації не виконувати `terraform apply`.

## Групові вправи

### Вправа 1. Передача значення через модуль

Простежте шлях `bucket_prefix` від значення у `terraform.tfvars.example` до `aws_s3_bucket.this`. Назвіть файл і рядок на кожному етапі та поясніть, що зміниться, якщо значення не передати.

### Вправа 2. Файл змінних

Викладач показує несекретні значення змінної `environment`, задані у default, `terraform.tfvars` і через `-var-file`. До виконання команд аудиторія визначає, яке значення матиме найвищий пріоритет і чому. Не використовуйте справжні секрети у вправах із CLI.

### Вправа 3. Зміна інтерфейсу модуля

Запропонуйте, які файли треба змінити, щоб додати обов'язкову змінну `department` типу `string` і передати її як тег ресурсу. Визначте, чи варто задати default, і обґрунтуйте відповідь. Зміни можна спершу описати словами або внести у власну копію прикладу після дозволу викладача.

## Типові помилки

- **Модуль плутають із файлом.** Модуль — каталог конфігурації, а не один `main.tf`.
- **Значення `variable` вписують у child module напряму.** Child module оголошує інтерфейс, root module передає аргументи.
- **`terraform.tfvars.example` очікують завантаженим автоматично.** Автоматично читаються визначені Terraform імена, а не довільний суфікс `.example`.
- **Одна змінна має кілька неузгоджених значень.** Перевіряйте джерела та пріоритет; уникайте прихованого перевизначення.
- **Вважають `sensitive` шифруванням.** State та файли плану все одно потребують захисту.
- **Створюють provider-блок у reusable child module без потреби.** Зазвичай конфігурацію провайдера задає root module та передає її модулю.
- **Виконують `apply`, щоб “перевірити” модуль.** Для перевірки синтаксису та очікуваних змін використовуйте `fmt`, `validate` і `plan`; `apply` змінює реальну інфраструктуру.

## Контрольні питання

1. Чому root module теж є Terraform-модулем?
2. Яку роль відіграють `source`, `variable` та `output` у виклику child module?
3. Яка різниця між `variables.tf` та `terraform.tfvars`?
4. Чи читає Terraform файл `terraform.tfvars.example` автоматично?
5. Яке джерело значення має вищий пріоритет: default чи явний `-var`?
6. Що дають типи та блок `validation`?
7. Чому `sensitive = true` не означає, що state зашифрований?
8. Чому provider credentials не слід записувати в модуль чи `.tfvars`, закомічений до Git?

## Підсумок заняття

Модуль упорядковує конфігурацію та надає повторно використовуваний інтерфейс. Вхідні variables параметризують його, а outputs повертають потрібні результати батьківському модулю. Файли змінних дозволяють відокремити код від значень середовища, але не є автоматичним захищеним сховищем секретів. Будь-який план треба читати до застосування змін.

## Офіційна документація

- [Створення Terraform-модулів](https://developer.hashicorp.com/terraform/language/modules/develop)
- [Вхідні змінні](https://developer.hashicorp.com/terraform/language/values/variables)
- [Файли змінних](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files)
- [Outputs](https://developer.hashicorp.com/terraform/language/values/outputs)
