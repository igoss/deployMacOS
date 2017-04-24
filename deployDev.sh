#!/usr/bin/env bash

#Download and deploy django-project
#Requirements:
#   -> PSQL install (9.6v)
#     --> DB: django_db
#     --> password: qwerty
#     --> user: django
#   -> Python3 (3.5.3v)

frontend=$1
frontend_branch=$2
backend_branch=$3

if [ -z $frontend ]; then
  echo 'ERROR: Input frontend template'
  exit
fi

if [ -z $frontend_branch ] || [ -z $backend_branch ]; then
  echo 'ERROR: Inpunt frontend and backend branches'
  echo '---->  or input master maseter'
  exit
fi

echo 'Start deploy django'

echo '--> Create folders.'
rm -rf $PWD/projectX && mkdir $PWD/projectX && cd "$_"
mkdir  $PWD/venv_django
echo '--> OK.'

echo '--> Create && Activate venv.'
python3.5 -m venv $PWD/venv_django
source $PWD/venv_django/bin/activate
echo '--> OK.'

echo '--> Install django and additional libs.'
pip install django==1.9                                                               &> /dev/null
pip install psycopg2==2.7.1                                                           &> /dev/null
pip install django-ckeditor                                                           &> /dev/null
pip install django-resized                                                            &> /dev/null
pip install Pillow                                                                    &> /dev/null
echo '--> OK.'

echo '--> Create project.'
mkdir $PWD/app_django
django-admin startproject configuration $PWD/app_django && cd "$_"
echo '--> OK.'

echo '--> Configure settings.py.'
cd $PWD/configuration
sed -i -e "s/sqlite3/postgresql_psycopg2/g" ./settings.py
sed -i -e "s/'NAME': os.path.join(BASE_DIR, 'db.postgresql_psycopg2'),/'NAME': 'django_db', 'USER': 'django', 'PASSWORD': 'qwerty', 'HOST': 'localhost', 'PORT': '',/g" ./settings.py
sed -i -e "s/TIME_ZONE = 'UTC'/TIME_ZONE = 'Europe\/Moscow'; DATE_FORMAT = 'd E Y в G:i'/g"                                                                             ./settings.py
sed -i -e "s/    'django.contrib.staticfiles',/    'django.contrib.staticfiles','backend', 'ckeditor', 'ckeditor_uploader',/g"                                          ./settings.py
sed -i -e "s/        'DIRS': \\[\\],/'DIRS': [os.path.join(BASE_DIR, '$frontend\/templates\/')],/g"                                                                     ./settings.py
rm -rf settings.py-e
echo "STATIC_URL = '/static/'"                                                        >> settings.py
echo "STATIC_ROOT = os.path.join(BASE_DIR, '$frontend/static/root')"                  >> settings.py
echo "MEDIA_URL = '/media/'"                                                          >> settings.py
echo "MEDIA_ROOT = os.path.join(BASE_DIR, 'media')"                                   >> settings.py
echo "CKEDITOR_UPLOAD_PATH = 'uploads/'"                                              >> settings.py
echo "STATICFILES_DIRS = (os.path.join(BASE_DIR, '$frontend/static/'),)"              >> settings.py
echo '--> OK.'

echo '--> Configure urls.py.'
rm -rf urls.py && touch urls.py
echo '# -*- coding: utf-8 -*-'                                                        >> urls.py
echo 'from django.contrib import admin'                                               >> urls.py
echo 'from django.conf.urls import url, include'                                      >> urls.py
echo ''                                                                               >> urls.py
echo 'from django.conf import settings'                                               >> urls.py
echo 'from django.conf.urls.static import static'                                     >> urls.py
echo ''                                                                               >> urls.py
echo 'urlpatterns = ['                                                                >> urls.py
echo '    url(r"^admin/", admin.site.urls),'                                          >> urls.py
echo '    url(r"^ckeditor/", include("ckeditor_uploader.urls")),'                     >> urls.py
echo '    url(r"", include("backend.urls")),'                                         >> urls.py
echo ']'                                                                              >> urls.py
echo 'urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)' >> urls.py
echo 'urlpatterns += static(settings.MEDIA_URL,  document_root=settings.MEDIA_ROOT)'  >> urls.py
echo '--> OK.'

echo '--> Create media'
cd ..
mkdir ./media ./media/tag_group_icons ./media/uploads
echo '--> OK.'

rm -rf .git && git init                                                                &> /dev/null
if [ $backend_branch == "master" ]; then
  echo '--> Download backend: master branch'
  git clone git@github.com:igoss/backend.git                                           &> /dev/null
else
  echo "--> Download backend: $backend_branch branch"
  git clone -b $backend_branch git@github.com:igoss/backend.git                        &> /dev/null
fi
mkdir $PWD/backend/migrations && touch $PWD/backend/migrations/__init__.py
echo '--> OK.'

git init
if [ $frontend_branch == "master" ]; then
  echo '--> Download frontend: master branch'
  git clone git@github.com:igoss/$frontend.git                                         &> /dev/null
else
  echo "--> Download frontend: $frontend_branch branch"
  git clone -b $frontend_branch git@github.com:igoss/$frontend.git                     &> /dev/null
fi
echo '--> OK.'

echo '--> Make migrations'
python manage.py makemigrations                                                        &> /dev/null
python manage.py migrate                                                               &> /dev/null
echo '--> OK.'

echo 'FINISH.'
