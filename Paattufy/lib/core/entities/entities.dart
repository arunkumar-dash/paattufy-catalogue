// Domain entities shared across features (TP §3, `core/entities`).
//
// The Drift row classes are the entities; re-exporting them here gives every
// feature one import for the cross-feature contract and keeps `drift`
// query-building details out of presentation code.
export '../database/app_database.dart'
    show
        Song,
        ExcludedFolder,
        SongGroup,
        GroupCondition,
        GroupStaticItem,
        GroupRef,
        GroupOverride,
        QueueItem,
        QueuePointerRow,
        PlaybackStateRow,
        PlayStat,
        LyricsRecord,
        SongAudioFeatures,
        RemoteCatalogueEntry,
        DownloadRecord;
