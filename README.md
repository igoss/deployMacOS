# Использование 
`$ ./deploy_MacOS.sh`

Выполниться раскатка проекта в текущей директории. <br>
Раскатка включает в себя:
* Создание виртуального окружения python3 (venv)
* Установка библиотек:
  * _django==1.9_
  * _psycopg2==2.7.1_
  * _django-ckeditor_
  * _django-resized_
  * _pillow_
* Раскатка кода project_x
* Конфигурация проекта
  * _settings.py_
  * _urls.py_
  * _media_
* Миграция БД

# Перед использованием необходимо установить:
* Python 3.5.3
* PostgreSQL 9.6

## Python (macOS)
https://www.python.org/downloads/release/python-353/ <br>
убедиться в наличии pip(3) для python 3.5.3 <br>
`$ which pip`

## PostgreSQL
http://postgresapp.com/

После установки необходимо:
* Создать БД: django_db
* Создать пользователя: django _с паролем: qwerty_
* Пользоваелю django выдать гранты на БД django_db

Выполнение действий в bash:
```bash
sudo -u postgres psql postgres -c "CREATE DATABASE django_db;"
sudo -u postgres psql postgres -c "CREATE USER django WITH PASSWORD 'qwerty';"
sudo -u postgres psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE django_db TO django;"
```

или, запустив psql выполнить sql запросы:
```sql
CREATE DATABASE django_db;
CREATE USER django WITH PASSWORD 'qwerty';
GRANT ALL PRIVILEGES ON DATABASE django_db TO django;
```

Для проверки в pqsl: `\connect django_db` <br>
Для просмотра таблиц: `\td`

