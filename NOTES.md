# Notes

Running log of Google Cloud decisions: bucket names, layout, regions, and why.

## Week 12 — Cloud Storage layout

### Storage classes

- Standard: data accessed all the time
- Nearline: roughly once every 30 days
- Coldline: roughly once every 90 days
- Archive: roughly once a year

### Bucket and layout

Bucket: `ronald-equity-analytics-raw-dev` (naming: `<owner>-<project>-<layer>-<env>`)

```
ronald-equity-analytics-raw-dev/
└── raw/
    └── prices/
        └── ingest_date=2026-10-11/
            └── prices.csv
```

- `raw/`: the raw layer. The data stays unchanged, exactly as it arrived.
- `prices/`: the kind of data (daily prices).
- `ingest_date=...`: the day the file was loaded.

### How I'll upload

I would use the command line:

```bash
gcloud storage cp data/prices.csv \
  gs://ronald-equity-analytics-raw-dev/raw/prices/ingest_date=$(date +%F)/prices.csv
```

If I used the UI instead, I would create the bucket `ronald-equity-analytics-raw-dev`, then create 3 folders:
`ronald-equity-analytics-raw-dev > raw > prices > ingest_date=...` (type the date manually), and upload or drag the file into that folder.

### Partition key

I would partition by `ingest_date=` because each date holds different information, and queries can skip the folders that are not needed.

`ingest_date` is the day the file was loaded, and it is part of the path. `price_date` is a column inside the data, the trading day. In Week 22 the BigQuery table is partitioned by `price_date`, which is a different thing from this folder name.

### Lifecycle rule

The bucket has one lifecycle rule: after an object is 30 days old, change its storage class from Standard to Nearline (`SetStorageClass` → `NEARLINE`, condition `age: 30`).

Nearline storage is cheaper because the data is expected to be read less often than Standard data.

Prices in `europe-west2` (London), from the Cloud Storage pricing page:

| | Standard | Nearline |
|---|---|---|
| Storage, per GiB per month | $0.023 | $0.013 |
| Retrieval, per GiB read | none | $0.01 |
| Minimum storage duration | none | 30 days |

What it saves: $0.010 per GiB per month.

- `prices.csv` is 33,556 bytes (about 0.00003 GiB), so the saving is about $0.0000003 a month. It is effectively nothing today.
- At 100 GiB the bill would fall from $2.30 to $1.30 a month, a saving of $1.00.

What it costs:

- Every read of Nearline data costs $0.01 per GiB, which is the same as the monthly saving. Reading all of the data once a month cancels out the saving, so Nearline only pays off for data read less often than that.
- An object deleted or rewritten before it has been in Nearline for 30 days is still charged for the full 30 days (the minimum storage duration).

## Week 12 — BigQuery dataset

### Locations

| | Name | Location |
|---|---|---|
| Cloud Storage bucket | `ronald-equity-analytics-raw-dev` | `europe-west2` (London) |
| BigQuery dataset | `market_elt` | `europe-west2` (London) |

Both are in `europe-west2`. An external table reads its data straight from the bucket, so the dataset and the bucket have to be in the same location. A bucket in one location and a dataset in another will not query each other.

### Native and external tables

- A native table keeps its data inside BigQuery, in BigQuery's own storage. Queries on it are fast, and it can be partitioned and clustered.
- An external table keeps its data in Cloud Storage. BigQuery stores only the table definition (the schema and where the files are) and reads the files each time you query it.

| | Native | External |
|---|---|---|
| Where the data lives | Inside BigQuery storage | Stays in Cloud Storage |
| Query speed | Faster | Slower, the file is read on every query |
| Partitioning and clustering | Yes | Limited, mostly by folder layout |
| Storage cost | BigQuery storage prices | Cloud Storage prices only |
| New data | Has to be loaded | A new file in the folder appears at once |

External pros: one raw copy of the data, no load step, cheap to store.
External cons: slower, fewer features, and the table breaks or changes if the file is deleted or changed.
Native pros: fast, cheaper to query repeatedly, a stable snapshot.
Native cons: a second copy of the data that has to be kept up to date, and BigQuery storage costs on top of the bucket.

For the `raw` layer I will use an external table over `prices.csv`: the file stays in the bucket exactly as it arrived, and the table is only a way to query it. Native tables built from it can come later for the layers I query often.
