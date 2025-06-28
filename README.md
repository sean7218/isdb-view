# IndexstoreDBView (isdb-view)

A simple CLI that you can list all the index-db symbols

```
swift run isdb-view list-symbols \
    --store-path /path/to/.index-store \
    --database-path /path/to/.index-db \
    --library-path /path/to/libIndexStore.dylib
```

1. depend on (indexstore-db)[https://github.com/swiftlang/indexstore-db] to view the database
