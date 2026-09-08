# Приклад: мережева архітектура

> Це навчальний зразок оформлення. Значення ресурсів ідентифіковані як умовні та не є результатом роботи курсанта.

## Схема

```mermaid
flowchart TB
    Internet[Інтернет] --> IGW[Internet Gateway]

    subgraph VPC[VPC: 10.0.0.0/16]
        RT[Public route table\n0.0.0.0/0 -> IGW]
        NACL[Network ACL]

        subgraph AZ1[Availability Zone 1]
            SubnetA[Subnet A\n10.0.1.0/24]
            WebA[Майбутній EC2 web-a]
        end

        subgraph AZ2[Availability Zone 2]
            SubnetB[Subnet B\n10.0.2.0/24]
            WebB[Майбутній EC2 web-b]
        end

        SG[Security Group\nHTTP 80]
        RT --> SubnetA
        RT --> SubnetB
        NACL --> SubnetA
        NACL --> SubnetB
        SubnetA --> WebA
        SubnetB --> WebB
        SG -. застосовується до .-> WebA
        SG -. застосовується до .-> WebB
    end

    IGW --> RT
```

## Опис компонентів

| Компонент | CIDR або порт | Призначення |
|---|---|---|
| VPC | `10.0.0.0/16` | Адресний простір проєкту |
| Subnet A | `10.0.1.0/24`, AZ-1 | Майбутній web-вузол A |
| Subnet B | `10.0.2.0/24`, AZ-2 | Майбутній web-вузол B |
| Route table | `0.0.0.0/0` | Маршрут до Internet Gateway |
| Security Group | TCP `80` | Доступ до HTTP-сервісу |
| Network ACL | За таблицею правил | Контроль трафіку на рівні subnet |

## Потік трафіку

1. Пакет з інтернету потрапляє до Internet Gateway.
2. Route table визначає маршрут до потрібної subnet.
3. Network ACL перевіряє трафік на рівні subnet.
4. Security Group перевіряє доступ до мережевого інтерфейсу EC2.
5. Після додавання ALB він стане точкою входу для HTTP-запитів.
