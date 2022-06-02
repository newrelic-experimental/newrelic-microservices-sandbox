import gzip
import json
import logging
import time

import tinydb
from tinydb import Query
from tinydb.storages import MemoryStorage


db = tinydb.TinyDB(storage=MemoryStorage)
# db = tinydb.TinyDB("data/superheroes_store.json")
with gzip.open("data/superheroes.json.gz", "r") as f:
    json_data = json.load(f)

logging.info(f"read {len(json_data)} records from file. loading...")
start = time.perf_counter()
for entry in json_data:
    db.insert(entry)
end = time.perf_counter()
logging.info("done loading")
total = len(db.all())

logging.info(f"inserted {total} records in {end - start:0.4f} seconds")

Superheroes = Query()
