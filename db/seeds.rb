# Sets up a database of several fake-devices

TEMPERATURE_TYPE = 'gobi.s.tmp'
SWITCH_TYPE = 'gobi.a.swt'
POWER_TYPE = 'gobi.s.pow'
HUMIDITY_TYPE = 'gobi.s.hum'

SENSOR_IF = 'core.s'
ACTUATOR_IF = 'core.a'

# Reset all models
Device.delete_all
Resource.delete_all
TorfResource.delete_all
Group.delete_all
User.delete_all

puts 'create devices'
Device.create(
  [
    { id: 1, name: 'Temperatur-Sensor Wohnzimmer', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 2, name: 'Umgebungssensor Küche', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 3, name: 'Wetter-Station Garten', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 4, name: 'Temperatur-Sensor Büro', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 5, name: 'Temperatur-Sensor Schlafzimmer', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 6, name: 'Temperatur-Sensor Flur', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 7, name: 'Umgebungssensor Bad', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 8, name: 'Temperatur-Sensor Büro', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 9, name: 'Umgebungssensor WC', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 10, name: 'GOBI Ofen', address: 'fe80::2000:aff:fea7:f7a', status: :active },

    { id: 100, name: 'GOBI Heimkino-Anlage', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 101, name: 'Lichtschalter Flur', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 102, name: 'Lichtschalter Flur', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 103, name: 'Brunnen-Kontrolle Garten', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 104, name: 'Hauptschalter Rechner', address: 'fe80::2000:aff:fea7:f7a', status: :active },

    { id: 200, name: 'Stromzähler Schlafzimmer', address: 'fe80::2000:aff:fea7:f7a', status: :active },
    { id: 201, name: 'Stromzähler Küche', address: 'fe80::2000:aff:fea7:f7a', status: :active },
  ]
)

puts 'create resources'
Resource.create(
  [
    { id: 1, name: 'Wohnzimmer', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 1 },
    { id: 2, name: 'Küche', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 2 },
    { id: 3, name: 'Garten', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 3 },
    { id: 4, name: 'Büro', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 4 },
    { id: 5, name: 'Schlafzimmer', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 5 },
    { id: 6, name: 'Flur', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 6 },
    { id: 7, name: 'Bad', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 7 },
    { id: 8, name: 'Garten', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 8 },
    { id: 9, name: 'WC', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 9 },
    { id: 10, name: 'Ofen', resource_type: TEMPERATURE_TYPE, interface_type: SENSOR_IF, path: '/s/temp', device_id: 10 },

    { id: 100, name: 'Heimkino-Anlage', resource_type: SWITCH_TYPE, interface_type: ACTUATOR_IF, path: '/a/sw', device_id: 100 },
    { id: 101, name: 'Licht Flur', resource_type: SWITCH_TYPE, interface_type: ACTUATOR_IF, path: '/a/sw', device_id: 101 },
    { id: 102, name: 'Licht Küche', resource_type: SWITCH_TYPE, interface_type: ACTUATOR_IF, path: '/a/sw', device_id: 102 },
    { id: 103, name: 'Brunnen Garten', resource_type: SWITCH_TYPE, interface_type: ACTUATOR_IF, path: '/a/sw', device_id: 103 },
    { id: 104, name: 'Alle Rechner', resource_type: SWITCH_TYPE, interface_type: ACTUATOR_IF, path: '/a/sw', device_id: 104 },

    { id: 200, name: 'Heimkino-Anlage', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 100 },
    { id: 201, name: 'Arbeitsrechner', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 104 },
    { id: 202, name: 'Home-Server, NAS', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 104 },
    { id: 203, name: 'Nachttisch', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 200 },
    { id: 204, name: 'Bad', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 7 },
    { id: 205, name: 'Ofen', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 10 },
    { id: 206, name: 'Küchenzeile', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 201 },
    { id: 207, name: 'Brunnen Garten', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 103 },
    { id: 208, name: 'Licht Küche', resource_type: POWER_TYPE, interface_type: SENSOR_IF, path: '/s/pow', device_id: 201 },

    { id: 300, name: 'Küche', resource_type: HUMIDITY_TYPE, interface_type: SENSOR_IF, path: '/s/hum', device_id: 2 },
    { id: 301, name: 'Außen', resource_type: HUMIDITY_TYPE, interface_type: SENSOR_IF, path: '/s/hum', device_id: 103 },
    { id: 302, name: 'Bad', resource_type: HUMIDITY_TYPE, interface_type: SENSOR_IF, path: '/s/hum', device_id: 7 },
    { id: 303, name: 'WC', resource_type: HUMIDITY_TYPE, interface_type: SENSOR_IF, path: '/s/hum', device_id: 9 },
  ]
)

puts 'create groups'
groups = {}
groups[:wohnzimmer] = Group.create({name: "Wohnzimmer" })
groups[:schlafzimmer] = Group.create({name: "Schlafzimmer" })
groups[:flur] = Group.create({name: "Flur" })
groups[:kueche] = Group.create({name: "Küche" })
groups[:garten] = Group.create({name: "Garten" })
groups[:bad] = Group.create({name: "Bad" })
groups[:wc] = Group.create({name: "WC" })

groups[:all_temps] = Group.create({name: "Temperatur-Sensoren" })
groups[:all_pows] = Group.create({name: "Stromzähler" })
groups[:all_switches] = Group.create({name: "Schalter" })

def add_basic_resources_to_device(device)
  Resource.create(
    [
      { name: '', resource_type: 'dev.info', interface_type: SENSOR_IF, path: '/d/name', device_id: device.id }
    ]
  )
end

puts 'add resources to groups'

groups[:wohnzimmer].resources.replace Resource.where("id in (?)", [1,100,200])
groups[:schlafzimmer].resources.replace Resource.where("id in (?)", [5,203])
groups[:flur].resources.replace Resource.where("id in (?)", [6,101])
groups[:kueche].resources.replace Resource.where("id in (?)", [2,102,300])
groups[:garten].resources.replace Resource.where("id in (?)", [8,103,301])
groups[:bad].resources.replace Resource.where("id in (?)", [7,204,302])
groups[:wc].resources.replace Resource.where("id in (?)", [7,204,302])

groups[:all_temps].resources.replace Resource.where("id in (?)", (1..10).to_a)
groups[:all_pows].resources.replace Resource.where("id in (?)", (200..208).to_a)
groups[:all_switches].resources.replace Resource.where("id in (?)", (300..303).to_a)


puts 'create user'
User.create(
  [
    { id: 1, username: 'hodor', password: 'hodor123', email: 'hodor@foo.de' }
  ]
)

def generate_measurement_samples(resource_type, data_range)
  possible_data = data_range.to_a
  Resource.where("resource_type = ?", resource_type).each do |res|
    (0..48).each do |time_offset|
      res.add_measurement(possible_data.sample, (Time.now - time_offset.hours).to_datetime)
    end
  end
end

puts 'generate random temperature data => disabled'
# Generate random temperature data for the last two days
# generate_measurement_samples(TEMPERATURE_TYPE, (14..26))

puts 'generate random switch settings => disabled'
# Generate random switch settings for the last two days
# generate_measurement_samples(SWITCH_TYPE, (0..1))

puts 'generate random power data => disabled'
# Generate random switch settings for the last two days
# generate_measurement_samples(POWER_TYPE, (0..1500))

puts 'generate random humidity data => disabled'
# Generate random switch settings for the last two days
# generate_measurement_samples(HUMIDITY_TYPE, (0..100))

puts 'create rules'

Torf.create_rule(
  name: 'Brunnen Kälteabschaltung',
  conditions: [
    Less.new(torf_resource_id: 3, value: 2),
  ],
  actions: [
    { torf_resource_id: 103, value: 0 },
  ]
)

Torf.create_rule(
  name: 'Brunnen Aktivierung Sommer',
  conditions: [
    Greater.new(torf_resource_id: 3, value: 18),
  ],
  actions: [
    { torf_resource_id: 103, value: 1 },
  ]
)

Torf.create_rule(
  name: 'Strom sparen - Ofen',
  conditions: [
    Greater.new(torf_resource_id: 205, value: 500),
  ],
  actions: [
    { torf_resource_id: 100, value: 0 },
  ]
)
