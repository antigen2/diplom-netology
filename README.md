# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

> Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).
> 
> Особенности выполнения:
> 
> - Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
> - Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).
> 
> Предварительная подготовка к установке и запуску Kubernetes кластера.
> 
> 1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
> 2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
>    а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
>    б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
> 3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
>    а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
>    б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
> 4. Создайте VPC с подсетями в разных зонах доступности.
> 5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
> 6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.
> 
> Ожидаемые результаты:
> 
> 1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
> 2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

Инициализируем профиль `yc`:
```shell
antigen@deb11notepad:~/diplom$ yc init
Welcome! This command will take you through the configuration process.
Pick desired action:
 [1] Re-initialize this profile 'netology-diplom-folder' with new settings
 [2] Create a new profile
 [3] Switch to and re-initialize existing profile: 'default'
 [4] Switch to and re-initialize existing profile: 'netology-diplom'
Please enter your numeric choice: 3
Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx in order to obtain OAuth token.

Please enter OAuth token: [AQAAAAAAh*********************MXoQ8Nt9I] AQAAAAAAh*********************MXoQ8Nt9I
You have one cloud available: 'cloud-antigen2' (id = b1ghs08ptu2bcti61r3d). It is going to be used by default.
Please choose folder to use:
 [1] default (id = b1gebf7j46aqpmhmfucc)
 [2] netology-diplom (id = b1g7jq4ii6itii7aor67)
 [3] Create a new folder
Please enter your numeric choice: 3
Please enter a folder name: netology-diplom-folder
Your current folder has been set to 'netology-diplom-folder' (id = b1gp7o73uot437m5vlb2).
Do you want to configure a default Compute zone? [Y/n] y
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] Don't set default zone
Please enter your numeric choice: 3
Your profile default Compute zone has been set to 'ru-central1-c'.
```
Смотрим `id` нашего каталога и создаем для него сервисный аккаунт:
```shell
antigen@deb11notepad:~/diplom$ yc resource-manager folder list
+----------------------+------------------------+--------+----------+
|          ID          |          NAME          | LABELS |  STATUS  |
+----------------------+------------------------+--------+----------+
| b1gebf7j46aqpmhmfucc | default                |        | ACTIVE   |
| b1gp7o73uot437m5vlb2 | netology-diplom-folder |        | ACTIVE   |
+----------------------+------------------------+--------+----------+

antigen@deb11notepad:~/diplom$ yc iam service-account create --name netology-diplom-sa --folder-id b1gp7o73uot437m5vlb2 --description "service account for netology diplom"
id: ajevouvsv073vgg7im85
folder_id: b1gp7o73uot437m5vlb2
created_at: "2023-06-18T13:42:26.616958957Z"
name: netology-diplom-sa
description: service account for netology diplom
```
Смотрим `id` и даем права на каталог для сервисного аккаунта:
```shell
antigen@deb11notepad:~/diplom$ yc iam service-account list
+----------------------+--------------------+
|          ID          |        NAME        |
+----------------------+--------------------+
| ajevouvsv073vgg7im85 | netology-diplom-sa |
+----------------------+--------------------+

antigen@deb11notepad:~/diplom$ yc resource-manager folder add-access-binding netology-diplom-folder --role admin --subject serviceAccount:ajevouvsv073vgg7im85

done (6s)
effective_deltas:
  - action: ADD
    access_binding:
      role_id: admin
      subject:
        id: ajevouvsv073vgg7im85
        type: serviceAccount
```
Создаем `key.json`:
```shell
antigen@deb11notepad:~/diplom$ yc iam key create --service-account-name netology-diplom-sa --output key.json
id: ajelkb46i6h9rmbu244r
service_account_id: ajevouvsv073vgg7im85
created_at: "2023-06-18T13:44:14.495372238Z"
key_algorithm: RSA_2048
```
Создаем `bucker` в ЯО:
```shell
antigen@deb11notepad:~/diplom$ yc storage bucket create \
  --name netology-diplom-tf-bucket \
  --default-storage-class STANDARD \
  --max-size 1073741824 \
  --public-read \
  --public-list \
  --public-config-read
name: netology-diplom-tf-bucket
folder_id: b1gp7o73uot437m5vlb2
anonymous_access_flags:
  read: false
  list: false
default_storage_class: STANDARD
versioning: VERSIONING_DISABLED
max_size: "1073741824"
acl: {}
created_at: "2023-06-18T14:16:46.466060Z"
```
Конфигурационные файлы `terraform`: \
Листинг `vars.tf`:
```terraform
# Переменная окружения TF_VAR_yc_token
variable "yc_token" {
  type = string
}

# Переменная окружения TF_VAR_yc_cloud_id
variable "yc_cloud_id" {
  type = string
}

# Переменная окружения TF_VAR_yc_folder_id
variable "yc_folder_id" {
  type = string
}

# Переменная окружения TF_VAR_yc_sa_id
variable "yc_sa_id" {
  type = string
}

variable "yc_zone" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

variable "private_ip" {
  type = list(list(string))
  default = [
    ["192.168.10.0/24"],
    ["192.168.20.0/24"],
    ["192.168.30.0/24"]
  ]
}

variable "public_ip" {
  type = list(list(string))
  default = [
    ["192.168.110.0/24"],
    ["192.168.120.0/24"],
    ["192.168.130.0/24"]
  ]
}

variable "ssh_key_private" {
  default = "~/.ssh/id_ed25519"
}

variable "ssh_key_pub" {
  default = "~/.ssh/id_ed25519.pub"
}

locals {
  res = {
    cores = {
      stage = 2
      prod  = 4
    }
    memory = {
      stage = 2
      prod  = 4
    }
  }
}
```
Листинг `networks.tf`:
```terraform
resource "yandex_vpc_network" "netology-diplom-network" {
  name = "netology-diplom-network"
}

resource "yandex_vpc_subnet" "public" {
  name            = "public-subnet"
  network_id      = yandex_vpc_network.netology-diplom-network.id
  v4_cidr_blocks  = var.public_ip[0]
  zone = var.yc_zone[0]
}

resource "yandex_vpc_subnet" "private" {
  name            = "private-subnet-${count.index}"
  count           = length(var.yc_zone)
  network_id      = yandex_vpc_network.netology-diplom-network.id
  v4_cidr_blocks  = var.private_ip[count.index]
  route_table_id  = yandex_vpc_route_table.route-01.id
  zone            = var.yc_zone[count.index]
}

resource "yandex_vpc_route_table" "route-01" {
  name       = "nat-gateway"
  network_id = yandex_vpc_network.netology-diplom-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}
```
Листинг `main.tf`:
```terraform
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token		= var.yc_token
  cloud_id	= var.yc_cloud_id
  folder_id	= var.yc_folder_id
}

# Образ
data "yandex_compute_image" "u2004" {
  family = "ubuntu-2004-lts"
}
```
Листинг `instances.tf`:
```terraform
resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = var.yc_zone[0]

  resources {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.110.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_pub)}"
  }
}

resource "yandex_compute_instance_group" "node-group-01" {
  name = "node-group-01"
  folder_id = var.yc_folder_id
  service_account_id = var.yc_sa_id
  instance_template {
    platform_id   = "standard-v1"
    boot_disk {
      initialize_params {
        image_id  = data.yandex_compute_image.u2004.id
        type      = "network-nvme"
        size      = 20
      }
    }
    network_interface {
      nat = false
      subnet_ids = [
        yandex_vpc_subnet.private[0].id,
        yandex_vpc_subnet.private[1].id,
        yandex_vpc_subnet.private[2].id
      ]
    }
    resources {
      cores  = local.res.cores[terraform.workspace]
      memory = local.res.memory[terraform.workspace]
    }

    metadata = {
      ssh-keys = "ubuntu:${file(var.ssh_key_pub)}"
    }
  }
  # создаст группу с необходимым количеством ВМ
  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = var.yc_zone
  }

  deploy_policy {
    max_unavailable = 3
    max_creating    = 3
    max_expansion   = 3
    max_deleting    = 3
  }
}
```
Листинг `outputs.tf`:
```terraform
output "nat_instance_info" {
  value = {
    external_ip_address = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
    internal_ip_address = yandex_compute_instance.nat-instance.network_interface.0.ip_address
    name = yandex_compute_instance.nat-instance.name
  }
}

output "internal_ip" {
 value = {
   internal_ip_address = yandex_compute_instance_group.node-group-01.instances[*].network_interface[0].ip_address
   name = yandex_compute_instance_group.node-group-01.instances[*].name
 }
}
```
Инициализируем `terraform` и создадим воркспэйсы:
```shell
antigen@deb11notepad:~/diplom/01$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.94.0...
- Installed yandex-cloud/yandex v0.94.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
antigen@deb11notepad:~/diplom/01$ terraform workspace list
* default

antigen@deb11notepad:~/diplom/01$ terraform workspace new stage
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
antigen@deb11notepad:~/diplom/01$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
antigen@deb11notepad:~/diplom/01$ terraform workspace select stage
Switched to workspace "stage".
antigen@deb11notepad:~/diplom/01$ terraform workspace list
  default
  prod
* stage
```
Проверяю создание инфраструктуры терраформом:
```shell
antigen@deb11notepad:~/diplom/01$ terraform apply --auto-approve
...
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

internal_ip = {
  "internal_ip_address" = tolist([
    "192.168.20.19",
    "192.168.30.18",
    "192.168.10.20",
  ])
  "name" = tolist([
    "cl1ae327hm5b43veeo4f-izep",
    "cl1ae327hm5b43veeo4f-ivam",
    "cl1ae327hm5b43veeo4f-irez",
  ])
}
nat_instance_info = {
  "external_ip_address" = "62.84.116.159"
  "internal_ip_address" = "192.168.110.254"
  "name" = "nat-instance"
}
```
Чистим за собой:
```shell
antigen@deb11notepad:~/diplom/01$ terraform destroy --auto-approve
...
Destroy complete! Resources: 8 destroyed.
```
---
### Создание Kubernetes кластера

> На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.
> 
> Это можно сделать двумя способами:
> 
> 1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
>    а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
>    б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
>    в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
> 2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
>   а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
>   б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
>   
> Ожидаемый результат:
> 
> 1. Работоспособный Kubernetes кластер.
> 2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
> 3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.



---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистр с собранным docker image. В качестве регистра может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Рекомендуемый способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте в кластер [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры.

Альтернативный вариант:
1. Для организации конфигурации можно использовать [helm charts](https://helm.sh/)

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистр, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---
## Как правильно задавать вопросы дипломному руководителю?

Что поможет решить большинство частых проблем:

1. Попробовать найти ответ сначала самостоятельно в интернете или в 
  материалах курса и ДЗ и только после этого спрашивать у дипломного 
  руководителя. Навык поиска ответов пригодится вам в профессиональной 
  деятельности.
2. Если вопросов больше одного, присылайте их в виде нумерованного 
  списка. Так дипломному руководителю будет проще отвечать на каждый из 
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой 
  покажите, где не получается.

Что может стать источником проблем:

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». 
  Дипломный руководитель не сможет ответить на такой вопрос без 
  дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители - практикующие специалисты, которые занимаются, кроме преподавания, 
  своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)