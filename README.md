# Folgende Abhängigkeiten werden derzeit nicht erfüllt:

* torf

# README zur Zentrale

Kurzer Guide zur Zentrale

## Systemvoraussetzungen

* Ruby 2.1
* InfluxDB http://influxdb.org/
* DNS-SD
  * OS X
  * The dns-sd library on other operating systems
  * avahi 0.6.25+ (plus libavahi-compat-libdnssd-dev on debian)

## Gems installieren / DB migrieren

Nötige Gems installieren.

```
bundle
```

Datenbank-Tabellen erzeugen und Testdaten erzeugen: Die Datenbank-Seeds dienen Testzwecken und müssen für Produktiv-Installationen nicht durchgeführt werden.

```
NODAEMON=1 RACK_ENV="production" rake db:migrate
NODAEMON=1 RACK_ENV="production" rake db:seed
```

## InfluxDB konfigurieren

Zum Speichern der Messdaten wird InfluxDB verwendet. Unter `config/config.yml` müssen dafür die Verbindungsdaten zu einer InfluxDB-Instanz angegeben werden.
Idealerweise sollte diese lokal laufen, um möglichst schnelle Antwortzeiten zu gewährleisten.

InfluxDB kann unter http://influxdb.org/download/ runtergeladen werden.

## Zentrale starten

Zentrale:

```
RACK_ENV="production" rackup
```
Die Datenbank-Seeds erzeugen einen User `hodor` mit dem Passwort `hodor123`
Die API ist dann auf Port 3001 zu erreichen

## DNS-SD

Die Zentrale macht IP und Port via dns-sd in folgender Domaine bekannt:

```
_gobi._tcp
```

## API

[Dokumentation](docs/api-definition.md)
