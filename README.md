# Использование 
Deploy: `$ ./deployDev.sh <frontend_project> <frontent_branch> <beckend_branch>` <br>
<br>
Run: `$ source ./bin/activate` и `$ python manage.py runserver --insecure` <br>

**На вход скрипту передаются 3 параметра:**
* Название проекта части фронтенд
* Ветка фронтенд части
* Ветка бекенд части

Выполнится раскатка проекта в текущей директории. <br>
**Раскатка включает в себя:**
* Создание виртуального окружения python3 (venv)
* Установку библиотек:
  * _django==1.9_
  * _psycopg2==2.7.1_
  * _django-ckeditor_
  * _django-resized_
  * _pillow_
* Раскатку кода фронтенда
* Раскатку кода бекенда
* Конфигурацию проекта
  * _settings.py_
  * _urls.py_
  * _media_
* Миграцию БД

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
