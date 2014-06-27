**Version:** v1

**Root URI:** /api/:version

# HTTP-Methoden
* GET       Ressource laden
* POST      Ressource erstellen
* PATCH     Ressource (parziell) ändern
* PUT       Ressource (er)setzen
* DELETE    Ressource löschen

# Authentifizierung

## Query-String

* Session-Token an URL anhaengen

```
URL?session=SESSIONTOKEN
```

## Request Header

* Session-Token im Request Header mitschicken

```
Session: SESSIONTOKEN
```

# Objekte

```
USER := { "id":ID, "username":"USERNAME", "email":"EMAIL" }

ID = 1
USERNAME = hodor
EMAIL = hodor@winterfell.de
```

```
SESSION := { "session":"SESSIONTOKEN" }

SESSIONTOKEN = [a-zA-Z0-9]{32}
```

```
DEVICE := {"id": ID, "name":"NAME","address":"ADDRESS", "resources":[RESOURCE], "status":"STATUS" }

ID = 1
NAME = Temperatur-Zentrale
ADDRESS = fe80::2000:aff:fea7:f7a
STATUS = initialize | active | inactive | rescan
```

```
RESOURCE := { "id":ID, "device_id":DEVICEID, "name":"NAME", "resource_type":"RESOURCETYPE", "interface_type":"INTERFACETYPE", "unit":"UNIT", "value":VALUE }

ID = 1
DEVICEID = 1
NAME = Wohnzimmer 1
RESOURCETYPE = gobi.a.swt | gobi.a.light.swt | gobi.a.light.dim | gobi.s.tmp | gobi.s.pow
INTERFACETYPE = core.s | core.a
UNIT = °C
VALUE = 22.0
```

```
MEASUREMENT := { "datetime":TIMESTAMP, "value":VALUE }

TIMESTAMP = 1392459117
VALUE = 42.0
```

```
GROUP := { "id":ID, "name":"NAME", "resources":[RESOURCE], "rules":[RULE] }

ID = 1
NAME = Good Temps
```

```
RULE := { "id": RULE_ID, "name": "NAME", "conditions": { CONDITIONS }, "actions": [ACTIONS], "enabled": ENABLED }
ACTIONS := RESOURCE
RESOURCE := {id: RES_ID, value: VALUE }
CONDITIONS := ANY | NONE | GREATER | LESS | EQUAL | UNEQUAL | STATES
ANY := "any": [{ "conditions": CONDITIONS }]
NONE := "none": [{ "conditions": CONDITIONS }]
GREATER := "greater": [RESOURCE]
LESS := "less": [RESOURCE]
EQUAL := "equal": [RESOURCE]
UNEQUAL := "unequal": [RESOURCE]
STATES := "states": [STATE]

NAME = hodor
RULE_ID = 1
RES_ID = 1
VALUE = 2.0
STATE => siehe STATE (bei PATCH/POST hier nur die ID des States)
ENABLED => TRUE | FALSE

Bsp:
{"enabled": 1, "conditions":{"equal":[{"id":1,"value":10},{"id":1,"value":10}],"any":[{"conditions":{"equal":[{"id":1,"value":10},{"id":1,"value":10}],"any":[{"conditions":{"equal":[{"id":1,"value":10},{"id":2,"value":10}]}}]}}]},"name":"rule1","actions":[{"value":13,"id":13}]}

```

```
STATE := { "id": STATE_ID, "name": "NAME", "conditions": { CONDITIONS }}

NAME = Nacht
STATE_ID = 1
CONDITIONS => siehe RULE::CONDITIONS
```

```
PSK := { "id": ID, "uuid": UUID, "psk": PSK, "desc": DESC }

ID = 1
UUID = "60176ec8-1875-465d-83c9-1fe97edab53d"
PSK = "ABCDEFGHIJKLMNOP"
DESC = "Temperaturgerät 1"
```

```
NOTIFICATION := { "id": ID, "text": TEXT, "datetime": TIMESTAMP}

ID = 1
TEXT = "Neues Gerät mit UUID: #{uuid} gefunden"
TIMESTAMP = 1392459117
```

# API
## Name
* Name des Servers (keine authentifizierung noetig)

```
GET /name
{ "name":"Gobi Server on HOSTNAME" }
```

## User
### Login/Logout
* Login (keine authentifizierung noetig)

```
POST /login { "username": "hodor", "password": "hodor123" }
SESSION => 201
{ "error": "Unauthorized" } => 401
```

* Logout

```
DELETE /login
=> 204
```

### Benutzer
* Liste aller Benutzer

```
GET /users
[USER] => 200
```

* Neuen Benutzer anlegen (keine authentifizierung noetig)

```
POST /users {"username": "peter", "password":"topsecret", "email":"peter@pan.de"}
USER => 201
{ "error": { $validation_errors } } => 400
```

* Daten eines Benutzers abfragen

```
GET /users/:id
USER => 200
{ "error": "Not Found" } => 404
```

* Daten eines Benutzers ändern

```
PATCH /users/:id PARAM
=> 204
{ "error": { "email": ["has already been taken"] } } => 400
{ "error": "Not Found" } => 404

PARAM kann einer oder Kombination aus folgenden sein:
{ "email": "foo@bar.de" }
{ "username": "asdf@foo.bar" }
{ "password": "topsecret" }
```

* Benutzer löschen

```
DELETE /users/:id
=> 204
```

## Geräte
### Geräte
* Liste aller Geräte

```
GET /devices
[DEVICE] => 200

Optional:
&limit=50 => 50 Geräte
&limit=0,50 => 50 Geräte ab 0
&limit=50,50 => 50 Geräte ab 50
```

* Daten eines Gerätes abfragen

```
GET /devices/:id
DEVICE => 200
{ "error": "Not Found" } => 404
```

* Daten eines Gerätes ändern

```
PATCH /devices/:id PARAM
=> 204
{ "error": { $validation_errors } } => 400
{ "error": "Not Found" } => 404

PARAM kann einer oder Kombination aus folgenden sein:
{ "name": "Fancy Device" }
{ "status": "STATUS" } # siehe Device object
```

* Gerät löschen

```
DELETE /devices/:id
=> 204
```

### Geräte Ressourcen
* siehe Ressourcen: /devices/:id/resources

### Geräte Ressourcen-Messwerte
* siehe Ressourcen-Messwerte: /devices/:id/resources

## Ressourcen
### Ressourcen

* Liste aller Ressourcen

```
GET /resources
[RESOURCE] => 200
```

* Daten einer Ressource

```
GET /resources/:id
RESOURCE => 200
```

* Daten einer Ressource ändern

```
PATCH /resources/:id PARAM
=> 204
{ "error": { $validation_errors } } => 400
{ "error": "Not Found" } => 404

PARAM kann einer oder Kombination aus folgenden sein:
{ "name": "Fancy Device" }
{ "value": 2.0 } => nur erlaubt bei core.a
```

## Ressourcen Messwerte

```
GET /resources/:id/measurements&from=TIMESTAMP&to=TIMESTAMP
[MEASUREMENT] => 200

Optional:
&granularity=SECONDS => default: (to-from)/80
```

## Gruppen
### Gruppen
* Liste aller Gruppen

```
GET /groups
[GROUP] => 200

Optional:
&limit=50 => 50 Gruppen
&limit=0,50 => 50 Gruppen ab 0
&limit=50,50 => 50 Gruppen ab 50
```

* Gruppe erstellen

```
POST /groups { "name":"Gruppe", "resources":[1,2,3,4], "rules":[1,2,3] } (Required: name; Optional: resources, rules)
GROUP => 201
{"error":"invalid resources"} => 400
```

* Daten einer Gruppe

```
GET /groups/:id
GROUP => 200
{"error":"Not Found"} => 404
```

* Daten einer Gruppe ändern

```
PATCH /groups/:id PARAM
=> 204
{ "error": { $validation_errors } } => 400
{ "error": "Not Found" } => 404

PARAM kann einer oder Kombination aus folgenden sein:
{ "name": "Fancy Device" }
{ "resources": [1,2,3] } (IDs der Ressourcen die in der Gruppe bleiben sollen)
{ "rules": [1,2,3] } (IDs der Regeln die in der Gruppe bleiben sollen
```

* Gruppe löschen

```
DELETE /groups/:id
=> 204

```

### Gruppen Ressourcen
* siehe Ressourcen: /groups/:id/resources

### Gruppen Ressourcen-Messwerte
* siehe Ressourcen-Messwerte: /groups/:id/resources

### Gruppen Regeln
* Liste aller Regeln der Gruppe

```
GET /groups/:id/rules
[RULE] => 200

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Daten einer Regel aus einer Gruppe

```
GET /groups/:id/rules/:id
RULE => 200
```

## Pre-Shared Key
* Liste aller Pre-Shared Keys

```
GET /psk
[PSK]
```

* Pre-Shared Key löschen

```
DELETE /psk/:id
=> 204
```

* Pre-Shared Key hinzufügen

```
POST /psk { PSK } (Required: uuid{36}, psk{16}; Optional: desc)
=> 204
{ "error": { $validation_errors } } => 400
```

## Regeln
### Regeln
* Liste aller Regeln

```
GET /rules
[RULE] => 200

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Neue Regel erstellen

```
POST /rules RULE
RULE => 201

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Daten einer Regel

```
GET /rules/:id
RULE => 200

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Eine Regel löschen

```
DELETE /rules/:id
=> 204
```

* Eine Regel ändern

```
PATCH /rules/:id PARAM
=> 204

PARAM kann einer oder Kombination aus folgenden sein:
{ "name": "Fancy Group" }
{ "conditions": { CONDITIONS } } # siehe Rule object
{ "actions": [ACTIONS] } # siehe Rule object
{ "enabled": true|false }
```

### States
* Liste aller States

```
GET /states
[STATE] => 200

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Neuen State erstellen

```
POST /states STATE
STATE => 201

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Daten eines State

```
GET /states/:id
STATE => 200

RESOURCE entspricht dabei dem RESOURCE Objekt
```

* Einen State löschen

```
DELETE /states/:id
=> 204
```

* Einen State ändern

```
PATCH /states/:id PARAM
=> 204

PARAM kann einer oder Kombination aus folgenden sein:
{ "name": "Fancy State" }
{ "conditions": { CONDITIONS } } # siehe State object
```

## Notifications
### Notifications

* Liste aller Nachrichten

```
GET /notifications
[NOTIFICATION] => 200

Optional:
&read=0 => Alle ungelesenen Nachrichten
&read=1 => Alle Nachrichten (default)
```
* Eine Nachricht löschen

```
DELETE /notifications/:id
=> 204
```
