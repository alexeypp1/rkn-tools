# rkn-tools
# Набор утилит для работы (парсинга и ресолвинга) с файлом дампа доменных имен и ip-адресов, доступ к которым запрещен Роскомнадзором

**$VERSION = 1.0**

Набор утилит для работы с файлом выгрузки данных о ресурсах, доступ к которым должен быть ограничен провайдерами РФ.  
Предназначен для подготовки данных о блокируемых адресах в системах небольщимх провайдеров, которые не могут позволить себе покупку и установку полноценного DPI.  
Причиной создания набора была необходимость вернуть время обработки файла выгрзки обратно к разумному (минуты) 
т.к. в середине 2022 года время обработки файла другими, известными мне, бесплатными утилитами достигло нескольких часов.

#### Содержимое
**dump.xml.example** - образец файла выгруженных РКН данных для дампа  
**rkn_tools.sql** - дамп структуры базы данных MySQL для работы утилит  
**config.pl.example** - образец конфигурационного файла  
**parser.pl** - утилита разбора данных из файла выгрузки и внемение их в таблицы базы. Время работы зависит от производительности оборудования (обычно 2-5 минут).  
**resolver.pl** - утилита ресолвинга списка доменов полученного из файла дампа. Время работы зависит от производительности DNS-сервера к которому обращается система с запущенным на ней скриптом (100-2000 доменых имен в секунду).  

#### Установка  
1. Создайте базу данных rkn_tools и, применив к ней rkn_tools.sql создайте в ней необходимые для работы утилит таблицы
2. Переименуйте config.pl.example в config.pl и заполните вашими данными для доступа к базе данных. 
Та же укажите вместо 'dump.xml.example' имя файла с дампом данных Роскомнадзора используемое вами.

#### Использование  
Прямой запуск parser.pl для разбора файла дампа.  
Далее, при необходимости, запуск resolver.pl для собственного ресолвинга доменных имен из файла дампа.  






