# Bixi API Reference

Bixi exposes data via **GBFS** (General Bikeshare Feed Specification) v2.2 — an open standard shared with Citibike, Capital Bikeshare, Lyft, etc. Patterns transfer.

No auth, no rate limits, plain JSON over HTTPS.

---

## Discovery

Start here. Lists all available feeds in `en` and `fr`:

```
https://gbfs.velobixi.com/gbfs/2-2/gbfs.json
```

## Feeds

| Feed                  | URL                                                                    | Refresh   | Purpose                                         |
| --------------------- | ---------------------------------------------------------------------- | --------- | ----------------------------------------------- |
| `system_information`  | [link](https://gbfs.velobixi.com/gbfs/2-2/en/system_information.json)  | rare      | system metadata (timezone, contact, system_id)  |
| `station_information` | [link](https://gbfs.velobixi.com/gbfs/2-2/en/station_information.json) | rare      | static per-station: id, name, lat/lon, capacity |
| `station_status`      | [link](https://gbfs.velobixi.com/gbfs/2-2/en/station_status.json)      | ~10s      | live per-station: bike/dock counts, flags       |
| `vehicle_types`       | [link](https://gbfs.velobixi.com/gbfs/2-2/en/vehicle_types.json)       | rare      | defines bike types referenced in status         |
| `system_alerts`       | [link](https://gbfs.velobixi.com/gbfs/2-2/en/system_alerts.json)       | as needed | service disruptions                             |

Every payload carries `last_updated` (epoch seconds) and `ttl: 10`. Don't poll faster than that.

For French, swap `/en/` for `/fr/`. Only `name` fields differ.

---

## Vehicle types

Five types — more than the simple "regular vs e-bike" mental model.

| ID   | Form factor   | Propulsion      | Notes                             |
| ---- | ------------- | --------------- | --------------------------------- |
| `9`  | bicycle       | human           | classic Bixi                      |
| `14` | cargo_bicycle | human           | cargo                             |
| `4`  | bicycle       | electric_assist | e-bike                            |
| `7`  | bicycle       | electric_assist | e-bike                            |
| `11` | bicycle       | electric_assist | e-bike, `max_range_meters: 70000` |

E-bike count = sum of types `4 + 7 + 11`, or just trust `num_ebikes_available` (it's a rollup of the same).

---

## `station_status` per-station fields

The hot feed. One entry per station inside `data.stations[]`.

| Field                       | Meaning                                                         |
| --------------------------- | --------------------------------------------------------------- |
| `station_id`                | join key into `station_information`                             |
| `num_bikes_available`       | **total** rideable bikes — classic + electric combined (gotcha) |
| `num_ebikes_available`      | e-bikes only                                                    |
| `vehicle_types_available[]` | per-type breakdown (`vehicle_type_id` → `count`)                |
| `num_docks_available`       | empty docks (return capacity)                                   |
| `num_bikes_disabled`        | broken bikes — _not_ counted in available                       |
| `num_docks_disabled`        | broken docks — _not_ counted in available                       |
| `is_installed`              | `0` = decommissioned/inactive station                           |
| `is_renting`                | `1` = can rent from this station                                |
| `is_returning`              | `1` = can return to this station                                |
| `is_charging`               | station can recharge e-bikes                                    |
| `last_reported`             | epoch seconds, this station's last self-report                  |

**Derived counts:**

- Classic bikes = `num_bikes_available - num_ebikes_available`
- Total slots in use = `num_bikes_available + num_bikes_disabled + num_docks_available + num_docks_disabled` (should equal `capacity` from `station_information`)

---

## `station_information` per-station fields

Static metadata. Cache it.

| Field                            | Meaning                            |
| -------------------------------- | ---------------------------------- |
| `station_id`                     | join key                           |
| `external_id`                    | UUID, stable across renames        |
| `name`                           | human-readable, language-dependent |
| `short_name`                     | numeric code, e.g. `6001`          |
| `lat`, `lon`                     | WGS84 decimal degrees              |
| `capacity`                       | total docks                        |
| `rental_methods`                 | e.g. `["CREDITCARD","KEY"]`        |
| `has_kiosk`                      | physical payment terminal present  |
| `electric_bike_surcharge_waiver` | pricing flag                       |

---

## Recipes

### Single station snapshot

```bash
curl -s https://gbfs.velobixi.com/gbfs/2-2/en/station_status.json \
  | jq '.data.stations[] | select(.station_id=="15")'
```

### All stations: name, location, current bikes

```bash
# Build a lookup of static info, then enrich live status with it.
INFO=$(curl -s https://gbfs.velobixi.com/gbfs/2-2/en/station_information.json)
STATUS=$(curl -s https://gbfs.velobixi.com/gbfs/2-2/en/station_status.json)

jq -n --argjson info "$INFO" --argjson status "$STATUS" '
  ($info.data.stations | map({key: .station_id, value: .}) | from_entries) as $byId
  | $status.data.stations
  | map({
      id: .station_id,
      name: $byId[.station_id].name,
      lat: $byId[.station_id].lat,
      lon: $byId[.station_id].lon,
      classic: (.num_bikes_available - .num_ebikes_available),
      ebikes: .num_ebikes_available,
      docks: .num_docks_available
    })
'
```

### Stations with e-bikes right now

```bash
curl -s https://gbfs.velobixi.com/gbfs/2-2/en/station_status.json \
  | jq '.data.stations[] | select(.num_ebikes_available > 0) | {station_id, num_ebikes_available}'
```

### Stations with empty docks (somewhere to return)

```bash
curl -s https://gbfs.velobixi.com/gbfs/2-2/en/station_status.json \
  | jq '.data.stations[] | select(.num_docks_available > 0) | {station_id, num_docks_available}'
```

### Coords as CSV

```bash
curl -s https://gbfs.velobixi.com/gbfs/2-2/en/station_information.json \
  | jq -r '.data.stations[] | [.station_id, .name, .lat, .lon] | @csv'
```

---

## Minimal pipeline

1. Fetch `station_information` once, refresh hourly+.
2. Poll `station_status` every 10–30s.
3. Index information by `station_id` for O(1) joins.
4. Done.

---

## Gotchas

- `num_bikes_available` is **classic + electric combined**. Subtract `num_ebikes_available` for classic-only.
- "Available" excludes disabled. `disabled + available` ≠ `capacity` if a station is partially out of service — use `station_information.capacity` as ground truth for total physical docks.
- `is_installed: 0` stations are inactive — filter them out of "live availability" views.
- Disabled bikes still occupy docks; they reduce both rentable bikes _and_ returnable docks.
- `last_reported` is per-station; the feed's `last_updated` is the freshness of the aggregate. Check both before trusting counts.
- Bixi shuts down for winter (~mid-November to mid-April). Off-season the feed may be stale or zeroed out.
- Historical trip CSVs live at <https://bixi.com/en/open-data/> — separate dataset, not GBFS.

---

## References

- GBFS spec v2.2: <https://github.com/MobilityData/gbfs/blob/v2.2/gbfs.md>
- Bixi open data: <https://bixi.com/en/open-data/>
