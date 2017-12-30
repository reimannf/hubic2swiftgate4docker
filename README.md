# hubic2swiftgate4docker

Provides the functionality from https://github.com/oderwat/hubic2swiftgate
in dockerized fashion. Inspired by https://github.com/jkaberg/docker-hubic2swiftgate.

All configuration can be passed via a docker volume. That volume is also used to store the cache file. So a restart of the docker container image does not require a new registration.

## Patched hubic2swiftgate
The original `hubic2swiftgate` code is pathched to read the `config.php` and get the `cache` folder from the docker volume. It should always be mounted to `/config`.

## Config structure
The Repo contains a [config-sample](config-sample) folder, which can be used as copy template. The structure is as follows:

* `apache`: Contains the vhost conf for apache. The file `001-hubic2swiftgate.conf` will be linked to `/etc/apache2/sites-enabled`. If you are using ssl ensure proper certificates in folder `ssl`, otherwise apache will not start.
* `cache`: Folder where `hubic2swiftgate` will store access token and endpoint url.
* `ssl`: Put your `server.crt` and `server.key` here. Check that the vhost conf `001-hubic2swiftgate.conf` will use it accordingly.
* `config.php`: Put you HubiC `client_id`, `client_secret` and `password` here. The password is bound to the fixed user `hubic` which is used from `hubic2swiftgate`.

## Setup
The main documentation can be found on [hubic2swiftgate](https://github.com/oderwat/hubic2swiftgate/blob/master/README.md)
* [Setup HubiC]( https://github.com/oderwat/hubic2swiftgate#setting-things-up-in-you-hubic-account)
* [Setup hubic2swiftgate](https://github.com/oderwat/hubic2swiftgate#configuring-the-gateway)

   Put the values to `/path/to/config/config.php`
* Starting the container image

   `docker run -d --restart always -p 8080:80 -p 8443:443 -v /path/to/config:/config reimannf/hubic2swiftgate4docker`
* [Register client]( https://github.com/oderwat/hubic2swiftgate#registering-the-client-with-your-hubic-account)

   http[s]://yourserver.com:80|443/register/?client=hubic&password=pwd_from_config.php
5. Check Usage

   http[s]://yourserver.com:80|443/usage

## Info
* Why a docker volume?

   I prefer to have such configurations not baked into the docker image. Now the docker container image can run multiple configurations and the externalised `cache` folder allows that the app registrations on HubiC survives a restart.
* Why Apache?

   nginx with php-fhm would require additional orchestration effort to run more than 1 process in one container.
