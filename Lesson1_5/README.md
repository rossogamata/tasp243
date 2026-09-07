# Групове заняття 2. Демонстрація сервісів AWS
### Змістовний модуль 1 · Технології хмарних обчислень

> **Тип заняття:** групове заняття.
>
> Викладач демонструє команди та пояснює параметри. Курсант спостерігає й занотовує алгоритм. Власне розгортання і проєктні рішення виконуються на практичному занятті 1.6.

## Мета демонстрації

Показати, як до VPC з Lesson1_3 додаються EC2, ALB, S3, CloudFront і Lambda.

## 1. Підготовка змінних

```bash
# AWS_REGION визначає регіон, у якому вже створена VPC з Lesson1_3.
export AWS_REGION="${AWS_REGION:-us-east-1}"

# Ці ID викладач бере зі стану попереднього заняття.
# Не можна підміняти їх ресурсами default VPC.
export VPC_ID="vpc-example"
export SUBNET_A_ID="subnet-example-a"
export SUBNET_B_ID="subnet-example-b"
export SG_ID="sg-example"

# Суфікс запобігає конфлікту назв між демонстраціями.
export LAB_ID="$(date +%s)"

# Назва Lambda, яку викладач створює в демонстраційному середовищі.
export FUNCTION_NAME="cloud-portal-status-${LAB_ID}"
```

## 2. EC2 через user data

```bash
# User data виконується один раз під час першого запуску інстансу.
# Він встановлює Apache і створює сторінку з іменем вузла.
cat > /tmp/user-data.sh <<'EOF'
#!/bin/bash
yum install -y httpd
systemctl enable --now httpd
echo "<h1>Cloud Portal: $(hostname)</h1>" > /var/www/html/index.html
EOF

# AMI береться з офіційного public параметра AWS, а не з випадкового ID.
AMI_ID=$(aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query 'Parameter.Value' \
  --output text)

# Запускаємо перший EC2 у subnet A.
# --associate-public-ip-address потрібен лише для навчальної демонстрації.
INSTANCE_A_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --subnet-id "$SUBNET_A_ID" \
  --security-group-ids "$SG_ID" \
  --associate-public-ip-address \
  --user-data file:///tmp/user-data.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=cloud-portal-web-a-${LAB_ID}}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "EC2 A: $INSTANCE_A_ID"
```

```bash
# Другий EC2 має такий самий образ і security group, але працює в іншій AZ.
# Це дає ALB дві незалежні цілі для перевірки відмовостійкості.
INSTANCE_B_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type t2.micro \
  --subnet-id "$SUBNET_B_ID" \
  --security-group-ids "$SG_ID" \
  --associate-public-ip-address \
  --user-data file:///tmp/user-data.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=cloud-portal-web-b-${LAB_ID}}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

# Чекаємо саме стан running, але пояснюємо курсантам,
# що Apache може стати готовим трохи пізніше через user data.
aws ec2 wait instance-running --instance-ids "$INSTANCE_A_ID" "$INSTANCE_B_ID"
echo "EC2 B: $INSTANCE_B_ID"
```

Викладач показує `describe-instances` і перевірку HTTP. Окремо пояснюється, що стан `running` ще не гарантує завершення `user-data`.

## 3. Target group і ALB

```bash
# Target group описує, на якому порту та шляху ALB перевіряє вебсервери.
TG_ARN=$(aws elbv2 create-target-group \
  --name "cloud-portal-tg-${LAB_ID}" \
  --protocol HTTP \
  --port 80 \
  --vpc-id "$VPC_ID" \
  --target-type instance \
  --health-check-path / \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# Додаємо EC2 до пулу цілей балансувальника.
aws elbv2 register-targets \
  --target-group-arn "$TG_ARN" \
  --targets Id="$INSTANCE_A_ID" Id="$INSTANCE_B_ID"

# ALB створюється у двох subnet, щоб мати мережеву присутність у двох AZ.
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name "cloud-portal-alb-${LAB_ID}" \
  --subnets "$SUBNET_A_ID" "$SUBNET_B_ID" \
  --security-groups "$SG_ID" \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

# Listener приймає HTTP на порту 80 і передає запит у target group.
aws elbv2 create-listener \
  --load-balancer-arn "$ALB_ARN" \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn="$TG_ARN"
```

```bash
# Показує, чи бачить ALB кожну ціль здоровою.
aws elbv2 describe-target-health \
  --target-group-arn "$TG_ARN" \
  --query 'TargetHealthDescriptions[].{Target:Target.Id,State:TargetHealth.State}' \
  --output table
```

## 4. S3 і CloudFront

```bash
# Назва bucket у S3 глобально унікальна, тому додаємо часовий суфікс.
export BUCKET_NAME="cloud-portal-${LAB_ID}"

# Створюємо bucket у поточному регіоні.
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" \
  $( [[ "$AWS_REGION" != "us-east-1" ]] && \
     echo "--create-bucket-configuration LocationConstraint=$AWS_REGION" )

# Завантажуємо статичні файли та явно вказуємо MIME-тип HTML.
aws s3 cp ./site/index.html "s3://$BUCKET_NAME/index.html" \
  --content-type text/html

# Перевіряємо, що об'єкт існує до створення distribution.
aws s3api head-object --bucket "$BUCKET_NAME" --key index.html
```

Викладач показує створення CloudFront distribution через консоль або JSON-конфігурацію. Потрібно пояснити `Origin`, `DefaultRootObject`, `ViewerProtocolPolicy`, `AllowedMethods` і час переходу distribution до `Deployed`.

## 5. Lambda і IAM

Викладач демонструє завантаження `index.html` до унікального bucket, а потім створення Lambda з мінімальним handler. Під час показу обов'язково пояснюються bucket policy, IAM execution role, runtime і формат відповіді.

```bash
# Функція повертає простий JSON, тому не потребує довгого процесу EC2.
cat > /tmp/handler.py <<'EOF'
import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps({"service": "cloud-operations-portal", "status": "ok"})
    }
EOF

# Архів містить handler і передається Lambda як deployment package.
cd /tmp
zip -q cloud-portal-function.zip handler.py

# У Learner Lab зазвичай використовується готова роль LabRole.
# Її ARN передається Lambda для виконання коду й запису логів.
LAMBDA_ROLE_ARN=$(aws iam get-role \
  --role-name LabRole \
  --query 'Role.Arn' \
  --output text)

# Створюємо функцію з фіксованим runtime і handler.
aws lambda create-function \
  --function-name "$FUNCTION_NAME" \
  --runtime python3.12 \
  --handler handler.lambda_handler \
  --role "$LAMBDA_ROLE_ARN" \
  --zip-file fileb:///tmp/cloud-portal-function.zip

# Виклик через CLI дозволяє перевірити функцію без API Gateway.
aws lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload '{"source":"group-demo"}' \
  /tmp/lambda-response.json
cat /tmp/lambda-response.json
```

## Межі демонстрації

- Викладач не виконує за курсантів фінальне проєктування.
- Курсант не копіює реальні ID ресурсів із демонстрації.
- CloudFront може бути продемонстрований як окремий ресурс; повна перевірка порталу виконується на Lesson1_6.
- Cleanup демонструється частково, повний cleanup є завданням практики.
