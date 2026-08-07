/// Case folding for search.
///
/// SQLite's built-in `lower()` and `LIKE` only fold ASCII, so a Cyrillic name
/// stored as `Договор` never matched a query typed as `ДОГОВОР`. Both the
/// stored `nameFolded` column and the query are folded here instead, in Dart,
/// which is Unicode-aware.
String foldSearchText(String value) => value.trim().toLowerCase();
