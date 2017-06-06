#!/usr/bin/env bash

#Download and deploy django-project
#Attention:
#DATABASE name is hardcoded (name: project_x)
#Requirements:
#   -> PSQL install (9.6v)
#     --> DB: django_db
#     --> password: qwerty
#     --> user: django
#   -> Python3 (3.5.3v)

#Script options:
#Use -u  | --db_user        --> database username
#Use -p  | --db_passwd      --> database username password
#Use -f  | --frontend       --> git project name (app_django frontend part)
#Use -bb | --backend_branch --> backend deploy branch
#Use -fb | --frontend_branch--> frontend deploy branch

#----------------------------------------------------------------------------
#option parser
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -u|--db_user)
    DB_USERNAME="$2"
    shift ;;
    -p|--db_passwd)
    DB_PASSWORD="$2"
    shift ;;
    -f|--frontend)
    FRONTEND="$2"
    shift ;;
    -bb|--backend_branch)
    BACKEND_BRANCH="$2"
    shift ;;
    -fb|--frontend_branch)
    FRONTEND_BRANCH="$2"
    shift ;;
esac
shift
done


#----------------------------------------------------------------------------
#option validator
if [ -z ${DB_USERNAME} ] && [ -z ${DB_PASSWORD} ]; then
  echo "ERROR: DB user and user passwd are missed!"
  echo "--> use -u | -p options."
  exit
fi

if [ -z ${BACKEND_BRANCH} ]; then
    BACKEND_BRANCH="master"
fi

if [ -z ${FRONTEND_BRANCH} ]; then
    FRONTEND_BRANCH="master"
fi

if [ -z ${FRONTEND} ]; then
  echo "ERROR: Frontend project not defined!"
  echo "--> use -f option."
  exit
fi


#----------------------------------------------------------------------------
#initialize environment
echo 'Start deploy django'

echo '--> Create folders.'
mkdir -p $PWD/media/tag_group_icons $PWD/media/uploads
rm -rf $PWD/projectX && mkdir $PWD/projectX && cd "$_"
mkdir  $PWD/venv_django
echo '--> OK.'


#----------------------------------------------------------------------------
#initialize django
echo '--> Create && Activate venv.'

python3.5 -m venv $PWD/venv_django
source $PWD/venv_django/bin/activate
echo '--> OK.'

echo '--> Install django and additional libs.'
pip install django==1.9         &> /dev/null
pip install psycopg2==2.7.1     &> /dev/null
pip install django-ckeditor     &> /dev/null
pip install django-resized      &> /dev/null
pip install Pillow              &> /dev/null
pip3 install python3-memcached  &> /dev/null
echo '--> OK.'

echo '--> Create project.'
mkdir $PWD/app_django
django-admin startproject configuration $PWD/app_django && cd "$_"
echo '--> OK.'


#----------------------------------------------------------------------------
#configure django
echo '--> Configure settings.py.'
sed -i -e "s/'UTC'/'Europe\/Moscow'/g" ./configuration/settings.py &> /dev/null
sed -i -e "s/'en-us'/'ru-ru'/g"        ./configuration/settings.py &> /dev/null
sed -i -e '55,70d' ./configuration/settings.py &> /dev/null
sed -i -e '57,68d' ./configuration/settings.py &> /dev/null
sed -i -e '93d'    ./configuration/settings.py &> /dev/null
rm -rf settings.py-e

cat >> $PWD/configuration/settings.py << EOF
INSTALLED_APPS = [
  'django.contrib.admin',
  'django.contrib.auth',
  'django.contrib.contenttypes',
  'django.contrib.sessions',
  'django.contrib.messages',
  'django.contrib.staticfiles',
  'backend',
  'ckeditor',
  'ckeditor_uploader',
  'django.contrib.sitemaps',
]

DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.postgresql_psycopg2',
    'NAME': 'project_x',
    'USER': '${DB_USERNAME}',
    'PASSWORD': '${DB_PASSWORD}',
    'HOST': 'localhost',
    'PORT': '',
  }
}

TEMPLATES = [
{
  'BACKEND': 'django.template.backends.django.DjangoTemplates',
  'DIRS': [os.path.join(BASE_DIR, '${FRONTEND}/templates/')],
  'APP_DIRS': True,
  'OPTIONS': {
    'context_processors': [
      'django.template.context_processors.debug',
      'django.template.context_processors.request',
      'django.contrib.auth.context_processors.auth',
      'django.contrib.messages.context_processors.messages',
      ],
    },
  },
]

DATE_FORMAT = 'd E Y в G:i'

STATIC_URL  = '/static/'
STATICFILES_DIRS = (os.path.join(BASE_DIR, '${FRONTEND}/static/'),)

MEDIA_URL  = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, '../../media')
CKEDITOR_UPLOAD_PATH = 'uploads/'
CKEDITOR_CONFIGS = {
  "default": {
    "removePlugins": "stylesheetparser",
    'allowedContent': True,
    'width': '100%',
    'toolbar_Full': [
      ['Styles', 'Format', 'Bold', 'Italic', 'Underline', 'Strike',
       'Subscript', 'Superscript', '-', 'RemoveFormat'],
      ['Image', 'Flash', 'Table', 'HorizontalRule'],
      ['TextColor', 'BGColor'],
      ['Smiley', 'sourcearea', 'SpecialChar'],
      ['Link', 'Unlink', 'Anchor'],
      ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-',
       'Blockquote', 'CreateDiv', '-', 'JustifyLeft', 'JustifyCenter',
       'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl'],
      ['Templates'],
      ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-',
       'Undo', 'Redo'],
      ['Find', 'Replace', '-', 'Scayt'],
      ['ShowBlocks'],
      ['Source', 'Templates'],
    ],
  }
}

EOF
echo '--> OK.'

echo '--> Configure urls.py.'
rm -rf $PWD/configuration/urls.py && touch ./configuration/urls.py
cat >> $PWD/configuration/urls.py << EOF
# -*- coding: utf-8 -*-
from django.contrib import admin
from django.conf.urls import url, include

from django.conf import settings
from django.conf.urls.static import static

from backend.services.sitemap.sitemap import PostSitemap, HomeSitemap, FlowSitemap, GroupSitemap
sitemaps = {'articles': PostSitemap, 'home': HomeSitemap, 'flow': FlowSitemap, 'group': GroupSitemap}

urlpatterns = [
  url(r"^kmizar-admin-panel/", admin.site.urls),
  url(r"^ckeditor/", include("ckeditor_uploader.urls")),
  url(r"", include("backend.urls")),
  url(r'^sitemap.xml$', 'django.contrib.sitemaps.views.sitemap', {'sitemaps': sitemaps})
] + static(settings.MEDIA_URL,  document_root=settings.MEDIA_ROOT)

EOF
echo '--> OK.'


#----------------------------------------------------------------------------
#deploy frontend / backend
rm -rf .git && git init

echo "--> Download backend: ${BACKEND_BRANCH} branch"
git clone -b ${BACKEND_BRANCH} git@github.com:igoss/backend.git
mkdir ./backend/migrations && touch ./backend/migrations/__init__.py
echo '--> OK.'

echo "--> Download frontend: ${FRONTEND_BRANCH} branch"
git clone -b ${FRONTEND_BRANCH} git@github.com:igoss/${FRONTEND}.git
echo '--> OK.'


#----------------------------------------------------------------------------
#migrate database
echo '--> Make migrations'
python manage.py makemigrations  &> /dev/null
python manage.py migrate         &> /dev/null
echo '--> OK.'

echo 'FINISH.'
