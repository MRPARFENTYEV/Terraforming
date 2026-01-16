### Где смотреть мои вм
https://console.yandex.cloud/folders/b1g60j7rdble619jl7vo/compute/instances

### Задание 1
**Изучите проект.**
в Terraform/ter-homeworks/03/src/main.tf вижу создание виртуальной машины. 
``` 
resource "yandex_vpc_network" "develop" {  
  name = var.vpc_name  
}  
resource "yandex_vpc_subnet" "develop" {  
  name           = var.vpc_name  
  zone           = var.default_zone  
  network_id     = yandex_vpc_network.develop.id  
  v4_cidr_blocks = var.default_cidr  
}
```

`yandex_vpc_network` - обозначениевиртуальной сети
`yandex_vpc_subnet` - подсеть внутри `yandex_vpc_network`
`network_id` — **в какой сети будет создана подсеть**
`v4_cidr_blocks` — диапазон IP-адресов (**Какие IP-адреса** она будет раздавать)

как мне это объяснила нейронка: 
```
## Мысленная модель (представь так)

- `network` — это **город**
    
- `subnet` — **район**
    
- `v4_cidr_blocks` — **улицы с номерами домов**
    
- `network_id` — «в каком городе находится район»
```

**Инициализируйте проект, выполните код.**
cd ~/Terraform/ter-homeworks/03/src
terraform init
![[terraform0301.png]]
Естественно запустился с ошибками - нет значений переменных 
создаю файл
ter-homeworks/03/src/personal.auto.tfvars копию personal.auto.tfvars_example в нем указываю переменные token,cloud_id,folder_id
переменные cloud_id и folder_id заполнил
переменую токен использовать не буду, в Terraform/ter-homeworks/03/src/providers.tf просто коменчу token и вставляю service_account_key_file = "authorized_key.json"

```
какая конструкция получилась в итоге 
provider "yandex" {  
#   token     = var.token 
  service_account_key_file = "authorized_key.json"  
  cloud_id  = var.cloud_id  
  folder_id = var.folder_id  
  zone      = var.default_zone  
}

```

проверяю terraform plan
![[terraform0302.png]]

![[terraform0303.png]]
`terraform apply`
 Quota limit vpc.networks.count exceeded
#### РЕШЕНИЕ ПРОБЛЕМЫ С КВОТОЙ
https://console.yandex.cloud/folders/b1g60j7rdble619jl7vo/vpc/networks
Тут удалить сети! Яндекс - самый отвратительный интерфейс в мире!

команда apply после удаления подсетей и сетей 
![[terraform0304.png]]

**Приложите скриншот входящих правил «Группы безопасности» в ЛК Yandex Cloud .**
![[terraform0305.png]]![[teraform0306.png]]

### Задание 2
count-vm.tf
Опишите в нём создание двух **одинаковых** ВМ web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**
![[pictures/terraform0306.png]]

копируем из main 
```
resource "yandex_vpc_network" "develop" {  
  name = var.vpc_name  
}  
resource "yandex_vpc_subnet" "develop" {  
  name           = var.vpc_name  
  zone           = var.default_zone  
  network_id     = yandex_vpc_network.develop.id  
  v4_cidr_blocks = var.default_cidr  
}
```

переделываю и получается такая штука: 
```
resource "yandex_compute_instance" "web" {  
  count = 2  
  
  name = "web-${count.index + 1}"  
  
  network_interface {  
    subnet_id = yandex_vpc_subnet.develop.id  
    nat       = true  
    security_group_ids = [  
      yandex_vpc_security_group.example.id  
    ]  
  }  
  
  resources {  
    cores  = 1  
    memory = 2  
  }  
}
```

Что происходит ? - в main создалась сеть develop. задача стояла - создание двух **одинаковых** ВМ web-1 и web-2 (не web-1 и web-2 - count.index изначально равен нулю, я прибавил единицу чтобы соответствовало заданию) с минимальными параметрами, используя мета-аргумент **count loop**
это сделано через  count = 2 , даны имена name = "web-${count.index + 1}"  (получится web-1 & web-2)
nat = true - говорит Yandex Cloud: Выдай ВМ **публичный IP** и разреши выход в интернет(вм получает внутренний ip и внешний)

subnet_id обозначаем через по сути аналог внешнего ключа из бд таблиц develop.id

- **Сеть** — где живут ресурсы
    
- **Подсеть** — конкретный сегмент сети
    
- **ВМ** — вычисления
    
- **NAT** — доступ в интернет
    
- **Security Group** — контроль трафика
  

**Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ для баз данных с именами "main" и "replica" разных по cpu/ram/disk_volume , используя мета-аргумент for_each loop**

разница между count & for_each:
`count` — когда ресурсы **одинаковые**  
`for_each` — когда ресурсы **логически разные**
`for_each` **НЕ работает напрямую с list**. Ему нужен `map` или `set`


В файле variables.tf создаю переменную :
```
variable "each_vm" {  
  type = list(object({  
    vm_name     = string  
    cpu         = number  
    ram         = number  
    disk_volume = number  
  }))  
  description = "Список ВМ для баз данных"  
}
```

### Схемы и разрисовки, потому что я запутался
![[terraform0307.png]]

```
                      ┌─────────────────────────┐
                      │   personal.auto.tfvars  │
                      │────────────────────────│
                      │ token = ""              │
                      │ cloud_id = "..."        │
                      │ folder_id = "..."       │
                      │ image_id = "..."        │
                      │ each_vm = [             │
                      │   {vm_name=main, ...},  │
                      │   {vm_name=replica,...} │
                      │ ]                       │
                      └─────────┬──────────────┘
                                │
                                ▼
                      ┌─────────────────────────┐
                      │     variables.tf        │
                      │────────────────────────│
                      │ variable "image_id" {}  │
                      │ variable "each_vm" {}   │
                      └─────────┬──────────────┘
                                │
         ┌──────────────────────┼────────────────────────┐
         ▼                      ▼                        ▼
┌─────────────────┐    ┌──────────────────┐     ┌─────────────────────┐
│ count-vm.tf     │    │ for_each-vm.tf   │     │ locals (optional)   │
│─────────────────│    │──────────────────│     │─────────────────────│
│ resource "web"  │    │ resource "db"    │     │ db_vms = {...}      │
│ count = 2       │    │ for_each = var.each_vm │ ssh_key = file(...) │
│ name = web-1/2  │    │ name = db-${each.value.vm_name} │             │
│ CPU=2, RAM=2    │    │ CPU, RAM, Disk from each_vm │             │
│ disk=10         │    │ boot_disk size from each_vm │             │
│ image_id = var.image_id │ image_id = var.image_id │             │
└─────────────────┘    └──────────────────┘     └─────────────────────┘

```

- **`personal.auto.tfvars`** – хранит реальные значения переменных (`image_id`, `each_vm`) и чувствительные данные (`token`, `cloud_id`).
    
    - Здесь **мы задаём конкретные “экземпляры” машин**: `main`, `replica`.
        
    - Без этого файла `terraform plan` просит “Enter a value” — потому что переменные без значений.
        
- **`variables.tf`** – объявляет переменные, которые используются в ресурсах:
    
    - `image_id`
        
    - `each_vm` (для базы данных)
        
- **`count-vm.tf`** – создаёт два одинаковых веб-сервера (`web-1`, `web-2`) с помощью `count`.
    
    - Все одинаковые, параметры берутся напрямую из кода + `var.image_id`.
        
- **`for_each-vm.tf`** – создаёт ВМ для баз данных (`main`, `replica`) с разными параметрами, используя `for_each = var.each_vm`.
    
    - Каждая ВМ индивидуальна.
        
    - CPU, RAM, диск берутся из списка объектов `each_vm`.
        
- **`locals` (опционально)** – можно хранить статические конфигурации внутри `.tf` файлов, но лучше использовать **переменные + `.tfvars`**, чтобы Terraform не спрашивал значения вручную.
  
#### ВМ базы данных + вм web1 & web2 созданы
![[terraform0309.png]]

![[terraform0310.png]]

#### ответственность файлов в проекте
| Файл                                             | Смысл                                                              | Влияние на `terraform apply`                                           |
| ------------------------------------------------ | ------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| `providers.tf`                                   | Объявление провайдера Yandex Cloud и токенов                       | Terraform знает, как подключаться к YC                                 |
| `variables.tf`                                   | Объявление переменных (`image_id`, `each_vm`)                      | Говорит Terraform, какие значения ожидаются                            |
| `personal.auto.tfvars`                           | Значения переменных (`token`, `image_id`, `each_vm`)               | Terraform автоматически их подхватывает, **без запроса в консоли**     |
| `main.tf`                                        | Основная “точка сборки”, часто создаются сети, группы безопасности | Тут обычно создаются VPC, подсети, SG — ресурсы, от которых зависят ВМ |
| `security.tf`                                    | Настройка групп безопасности (SG)                                  | ВМ ссылаются на SG, чтобы Terraform понял зависимость                  |
| `count-vm.tf`                                    | Создание одинаковых веб-серверов (`web-1`, `web-2`) с `count`      | Создаются экземпляры веб-серверов                                      |
| `for_each-vm.tf`                                 | Создание баз данных (`main`, `replica`) с `for_each`               | Создаются отдельные ВМ с разными параметрами                           |
| `authorized_key.json`                            | Файл сервисного аккаунта Yandex Cloud                              | Используется провайдером для аутентификации                            |
| `terraform.tfstate` / `terraform.tfstate.backup` | Хранит текущее состояние инфраструктуры                            | Terraform понимает, что уже создано, а что нужно создать               |
| `personal.auto.tfvars_example`                   | Пример `.tfvars` для других                                        | Не участвует напрямую                                                  |

###  Задание 3

![[terraform0311.png]]
![[teraform0312.png]]

### Задание 4

😭
![[terraform0312.png]]

![[teraform0313.png]]
![[teraform0314.png]]

