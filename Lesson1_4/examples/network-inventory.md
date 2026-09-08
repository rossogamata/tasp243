# Приклад: інвентар мережевих ресурсів

> Це шаблон оформлення. Замініть умовні значення на фактичні дані власного середовища.

| Тип ресурсу | Назва | ID | CIDR або порт | AZ | Призначення | Залежності |
|---|---|---|---|---|---|---|
| VPC | `cloud-portal-vpc` | `vpc-example` | `10.0.0.0/16` | Регіон | Ізольована мережа проєкту | Регіон AWS |
| Internet Gateway | `cloud-portal-igw` | `igw-example` | IPv4 | Регіон | Вихід public subnet до інтернету | VPC |
| Subnet | `cloud-portal-subnet-a` | `subnet-example-a` | `10.0.1.0/24` | `AZ-1` | Перша public subnet | VPC |
| Subnet | `cloud-portal-subnet-b` | `subnet-example-b` | `10.0.2.0/24` | `AZ-2` | Друга public subnet | VPC |
| Route table | `cloud-portal-public-rt` | `rtb-example` | `0.0.0.0/0` | Регіон | Маршрутизація зовнішнього трафіку | VPC, IGW |
| Network ACL | `cloud-portal-nacl` | `acl-example` | TCP `80`, `1024-65535` | Регіон | Фільтрація на рівні subnet | VPC |
| Security Group | `cloud-portal-sg` | `sg-example` | TCP `80` | Регіон | Stateful-доступ до web-сервісу | VPC |

## Правила заповнення

- ID копіюйте з AWS CLI або AWS Console після створення ресурсу.
- AZ беріть із фактичної властивості subnet, а не з плану.
- Для ресурсу без CIDR вкажіть релевантний порт, протокол або `N/A`.
- У колонці «Залежності» вкажіть ресурси, без яких цей компонент не може існувати.
- Не вносьте access key, secret key або інші секрети.
