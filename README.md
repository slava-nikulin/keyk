# API for YAPM password manager

***TODO***
  * Cron job to clean expired auth tokens, unconfirmed accounts
  * Clean devops config mess
  * CI/CD
  * Monitoring tools (Yabeda, prometheus, ELK)
  * Refresh token
  * Refactor fields encryption

MY_GID=$(id -g) MY_UID=$(id -u) docker-compose build web

if errors after modifying Gemfile
sudo chown -R 1000:1000 /var/lib/docker/volumes/keyk_bundle_cache/_data (path to bundler volume)

docker-compose run --rm --no-deps --user $(id -u) web bundle exec rails g mailer UserMailer
