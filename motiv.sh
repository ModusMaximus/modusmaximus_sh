#!/bin/bash

# Функция для создания файла .env
create_env_file() {
    echo "🖊️Создание файла .env..."
    read -p "Введите токен от телеграм бота " TOKEN
    read -p "Введите канал для проверки подписки" CHANNEL_ID
    read -p "Введите ссылку для подключения к базе данных" DB_PSQL
    read -p "Введите контакт поддержки" SUPPORT_CONTACT_TG
    read -p "Введите сумму вознаграждения для рефоводов" REWARD_FOR_REFERRAL

    # Запись в .env
    {
        echo "TOKEN=$TOKEN"
        echo "CHANNEL_ID=$CHANNEL_ID"
        echo "DB_PSQL=$DB_PSQL"
        echo "REDIS_HOST=127.0.0.1"
        echo "REDIS_PORT=6380"
        echo "SUPPORT_CONTACT_TG=$SUPPORT_CONTACT_TG"
        echo "REWARD_FOR_REFERRAL=$REWARD_FOR_REFERRAL"
    } > /app/backend/.env

    echo "Конфиг успешно создан."
}

# Функция для запуска docker-compose
start_docker() {
    echo "Запуск docker compose..."
    cd /app/backend
    docker compose up -d
}

# Установка Docker, если он не установлен
install_docker() {
  if ! command -v docker &> /dev/null; then
    echo "🐳 Обнаружено отсутствие Docker. Инициируем установку..."
    sh $HOME/modusmaximus_sh/get-docker.sh || handle_error "Установка Docker"
    echo "🐳 Установка Docker завершена успешно."
    sleep 2
  else
    echo "🐳 Проверка завершена: Docker уже установлен."
    sleep 2
  fi
}

# Функция для клонирования репозитория или обновления, если он уже существует
clone_or_update_repo() {
  local repo_path="/app/backend"
  local gitssh=git@github.com:ModusMaximus/motivtgbot.git

  echo "🔍 Проверка наличия репозитория по пути: $repo_path"
  if [ -d "$repo_path" ]; then
    echo "📁 Репозиторий уже существует. Попытка обновления..."
    cd "$repo_path" && git pull || handle_error "Обновление репозитория"
    echo "🔄 Репозиторий успешно обновлен."
    sleep 2
  else
    git clone -b postgre_version "$gitssh" "$repo_path" || handle_error "Клонирование репозитория"
    echo "🎉 Репозиторий успешно склонирован."
    sleep 2
  fi
}

# Cборка
install() {
  echo "🚀 Начинаем сборку проекта"
  install_docker
  clone_or_update_repo
  create_env_file
  start_docker
  echo "👷 Сборка проекта успешно завершена"
  sleep 2
}

# Вывод логов
show_logs() {
  echo "📜 Отображение логов работы ноды Allora..."
  docker compose -f /app/backend/docker-compose.yml logs -f || handle_error "Вывод логов"
}

# Главная функция для управления аргументами
main() {
  print_banner
  local action="$1"

  case "$action" in
    "install")
      install
      ;;
    "update")
      clone_or_update_repo
      ;;
    "show-logs")
      show_logs
      ;;
    *)
      echo "⚠️ Указано неверное действие: $action. Доступные опции: 'install', 'update', 'show-logs', "
      exit 2
      ;;
  esac
}

# Запускаем главную функцию с аргументами командной строки
main "$@"