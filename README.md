# ConvertTo-Influxdb
converts a influx export CSV formatted to a format influx can import

## Data source format
Export a influx measurement like

`influx -database old -format csv -execute "select * from temperature" > /tmp/influx_export_temperature.csv`

or create a CSV in the format 
````
name,time,standort,value
temperatur,1538630108757483380,Wohnzimmer,22
temperatur,1538632808475044614,Wohnzimmer,23
````
# Usage
## Convert CSV file
`ConvertTo-Influx.ps1 -Path /tmp/temperature.csv -Database private > /tmp/temperature.influx`
