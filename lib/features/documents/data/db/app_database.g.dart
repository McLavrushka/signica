// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DocumentRowsTable extends DocumentRows
    with TableInfo<$DocumentRowsTable, DocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameFoldedMeta = const VerificationMeta(
    'nameFolded',
  );
  @override
  late final GeneratedColumn<String> nameFolded = GeneratedColumn<String>(
    'name_folded',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstPagePreviewPathMeta =
      const VerificationMeta('firstPagePreviewPath');
  @override
  late final GeneratedColumn<String> firstPagePreviewPath =
      GeneratedColumn<String>(
        'first_page_preview_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastPagePreviewPathMeta =
      const VerificationMeta('lastPagePreviewPath');
  @override
  late final GeneratedColumn<String> lastPagePreviewPath =
      GeneratedColumn<String>(
        'last_page_preview_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSignedMeta = const VerificationMeta(
    'isSigned',
  );
  @override
  late final GeneratedColumn<bool> isSigned = GeneratedColumn<bool>(
    'is_signed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_signed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameFolded,
    filePath,
    firstPagePreviewPath,
    lastPagePreviewPath,
    pageCount,
    createdAt,
    isSigned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_folded')) {
      context.handle(
        _nameFoldedMeta,
        nameFolded.isAcceptableOrUnknown(data['name_folded']!, _nameFoldedMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('first_page_preview_path')) {
      context.handle(
        _firstPagePreviewPathMeta,
        firstPagePreviewPath.isAcceptableOrUnknown(
          data['first_page_preview_path']!,
          _firstPagePreviewPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstPagePreviewPathMeta);
    }
    if (data.containsKey('last_page_preview_path')) {
      context.handle(
        _lastPagePreviewPathMeta,
        lastPagePreviewPath.isAcceptableOrUnknown(
          data['last_page_preview_path']!,
          _lastPagePreviewPathMeta,
        ),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_signed')) {
      context.handle(
        _isSignedMeta,
        isSigned.isAcceptableOrUnknown(data['is_signed']!, _isSignedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameFolded: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_folded'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      firstPagePreviewPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_page_preview_path'],
      )!,
      lastPagePreviewPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_page_preview_path'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSigned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_signed'],
      )!,
    );
  }

  @override
  $DocumentRowsTable createAlias(String alias) {
    return $DocumentRowsTable(attachedDatabase, alias);
  }
}

class DocumentRow extends DataClass implements Insertable<DocumentRow> {
  final String id;
  final String name;

  /// Search index for [name], folded through `foldSearchText`. Derived, always
  /// written together with the name — never edited on its own. The empty
  /// default exists so `ALTER TABLE ... ADD COLUMN` can run on existing rows;
  /// the v2 migration backfills them right after.
  final String nameFolded;
  final String filePath;
  final String firstPagePreviewPath;
  final String? lastPagePreviewPath;
  final int pageCount;
  final DateTime createdAt;
  final bool isSigned;
  const DocumentRow({
    required this.id,
    required this.name,
    required this.nameFolded,
    required this.filePath,
    required this.firstPagePreviewPath,
    this.lastPagePreviewPath,
    required this.pageCount,
    required this.createdAt,
    required this.isSigned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['name_folded'] = Variable<String>(nameFolded);
    map['file_path'] = Variable<String>(filePath);
    map['first_page_preview_path'] = Variable<String>(firstPagePreviewPath);
    if (!nullToAbsent || lastPagePreviewPath != null) {
      map['last_page_preview_path'] = Variable<String>(lastPagePreviewPath);
    }
    map['page_count'] = Variable<int>(pageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_signed'] = Variable<bool>(isSigned);
    return map;
  }

  DocumentRowsCompanion toCompanion(bool nullToAbsent) {
    return DocumentRowsCompanion(
      id: Value(id),
      name: Value(name),
      nameFolded: Value(nameFolded),
      filePath: Value(filePath),
      firstPagePreviewPath: Value(firstPagePreviewPath),
      lastPagePreviewPath: lastPagePreviewPath == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPagePreviewPath),
      pageCount: Value(pageCount),
      createdAt: Value(createdAt),
      isSigned: Value(isSigned),
    );
  }

  factory DocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameFolded: serializer.fromJson<String>(json['nameFolded']),
      filePath: serializer.fromJson<String>(json['filePath']),
      firstPagePreviewPath: serializer.fromJson<String>(
        json['firstPagePreviewPath'],
      ),
      lastPagePreviewPath: serializer.fromJson<String?>(
        json['lastPagePreviewPath'],
      ),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSigned: serializer.fromJson<bool>(json['isSigned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameFolded': serializer.toJson<String>(nameFolded),
      'filePath': serializer.toJson<String>(filePath),
      'firstPagePreviewPath': serializer.toJson<String>(firstPagePreviewPath),
      'lastPagePreviewPath': serializer.toJson<String?>(lastPagePreviewPath),
      'pageCount': serializer.toJson<int>(pageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSigned': serializer.toJson<bool>(isSigned),
    };
  }

  DocumentRow copyWith({
    String? id,
    String? name,
    String? nameFolded,
    String? filePath,
    String? firstPagePreviewPath,
    Value<String?> lastPagePreviewPath = const Value.absent(),
    int? pageCount,
    DateTime? createdAt,
    bool? isSigned,
  }) => DocumentRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameFolded: nameFolded ?? this.nameFolded,
    filePath: filePath ?? this.filePath,
    firstPagePreviewPath: firstPagePreviewPath ?? this.firstPagePreviewPath,
    lastPagePreviewPath: lastPagePreviewPath.present
        ? lastPagePreviewPath.value
        : this.lastPagePreviewPath,
    pageCount: pageCount ?? this.pageCount,
    createdAt: createdAt ?? this.createdAt,
    isSigned: isSigned ?? this.isSigned,
  );
  DocumentRow copyWithCompanion(DocumentRowsCompanion data) {
    return DocumentRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameFolded: data.nameFolded.present
          ? data.nameFolded.value
          : this.nameFolded,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      firstPagePreviewPath: data.firstPagePreviewPath.present
          ? data.firstPagePreviewPath.value
          : this.firstPagePreviewPath,
      lastPagePreviewPath: data.lastPagePreviewPath.present
          ? data.lastPagePreviewPath.value
          : this.lastPagePreviewPath,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSigned: data.isSigned.present ? data.isSigned.value : this.isSigned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFolded: $nameFolded, ')
          ..write('filePath: $filePath, ')
          ..write('firstPagePreviewPath: $firstPagePreviewPath, ')
          ..write('lastPagePreviewPath: $lastPagePreviewPath, ')
          ..write('pageCount: $pageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSigned: $isSigned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameFolded,
    filePath,
    firstPagePreviewPath,
    lastPagePreviewPath,
    pageCount,
    createdAt,
    isSigned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameFolded == this.nameFolded &&
          other.filePath == this.filePath &&
          other.firstPagePreviewPath == this.firstPagePreviewPath &&
          other.lastPagePreviewPath == this.lastPagePreviewPath &&
          other.pageCount == this.pageCount &&
          other.createdAt == this.createdAt &&
          other.isSigned == this.isSigned);
}

class DocumentRowsCompanion extends UpdateCompanion<DocumentRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> nameFolded;
  final Value<String> filePath;
  final Value<String> firstPagePreviewPath;
  final Value<String?> lastPagePreviewPath;
  final Value<int> pageCount;
  final Value<DateTime> createdAt;
  final Value<bool> isSigned;
  final Value<int> rowid;
  const DocumentRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameFolded = const Value.absent(),
    this.filePath = const Value.absent(),
    this.firstPagePreviewPath = const Value.absent(),
    this.lastPagePreviewPath = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSigned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentRowsCompanion.insert({
    required String id,
    required String name,
    this.nameFolded = const Value.absent(),
    required String filePath,
    required String firstPagePreviewPath,
    this.lastPagePreviewPath = const Value.absent(),
    required int pageCount,
    required DateTime createdAt,
    this.isSigned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       filePath = Value(filePath),
       firstPagePreviewPath = Value(firstPagePreviewPath),
       pageCount = Value(pageCount),
       createdAt = Value(createdAt);
  static Insertable<DocumentRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameFolded,
    Expression<String>? filePath,
    Expression<String>? firstPagePreviewPath,
    Expression<String>? lastPagePreviewPath,
    Expression<int>? pageCount,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSigned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameFolded != null) 'name_folded': nameFolded,
      if (filePath != null) 'file_path': filePath,
      if (firstPagePreviewPath != null)
        'first_page_preview_path': firstPagePreviewPath,
      if (lastPagePreviewPath != null)
        'last_page_preview_path': lastPagePreviewPath,
      if (pageCount != null) 'page_count': pageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (isSigned != null) 'is_signed': isSigned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? nameFolded,
    Value<String>? filePath,
    Value<String>? firstPagePreviewPath,
    Value<String?>? lastPagePreviewPath,
    Value<int>? pageCount,
    Value<DateTime>? createdAt,
    Value<bool>? isSigned,
    Value<int>? rowid,
  }) {
    return DocumentRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFolded: nameFolded ?? this.nameFolded,
      filePath: filePath ?? this.filePath,
      firstPagePreviewPath: firstPagePreviewPath ?? this.firstPagePreviewPath,
      lastPagePreviewPath: lastPagePreviewPath ?? this.lastPagePreviewPath,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      isSigned: isSigned ?? this.isSigned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameFolded.present) {
      map['name_folded'] = Variable<String>(nameFolded.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (firstPagePreviewPath.present) {
      map['first_page_preview_path'] = Variable<String>(
        firstPagePreviewPath.value,
      );
    }
    if (lastPagePreviewPath.present) {
      map['last_page_preview_path'] = Variable<String>(
        lastPagePreviewPath.value,
      );
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSigned.present) {
      map['is_signed'] = Variable<bool>(isSigned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFolded: $nameFolded, ')
          ..write('filePath: $filePath, ')
          ..write('firstPagePreviewPath: $firstPagePreviewPath, ')
          ..write('lastPagePreviewPath: $lastPagePreviewPath, ')
          ..write('pageCount: $pageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSigned: $isSigned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DocumentRowsTable documentRows = $DocumentRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [documentRows];
}

typedef $$DocumentRowsTableCreateCompanionBuilder =
    DocumentRowsCompanion Function({
      required String id,
      required String name,
      Value<String> nameFolded,
      required String filePath,
      required String firstPagePreviewPath,
      Value<String?> lastPagePreviewPath,
      required int pageCount,
      required DateTime createdAt,
      Value<bool> isSigned,
      Value<int> rowid,
    });
typedef $$DocumentRowsTableUpdateCompanionBuilder =
    DocumentRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> nameFolded,
      Value<String> filePath,
      Value<String> firstPagePreviewPath,
      Value<String?> lastPagePreviewPath,
      Value<int> pageCount,
      Value<DateTime> createdAt,
      Value<bool> isSigned,
      Value<int> rowid,
    });

class $$DocumentRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameFolded => $composableBuilder(
    column: $table.nameFolded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstPagePreviewPath => $composableBuilder(
    column: $table.firstPagePreviewPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPagePreviewPath => $composableBuilder(
    column: $table.lastPagePreviewPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSigned => $composableBuilder(
    column: $table.isSigned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameFolded => $composableBuilder(
    column: $table.nameFolded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstPagePreviewPath => $composableBuilder(
    column: $table.firstPagePreviewPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPagePreviewPath => $composableBuilder(
    column: $table.lastPagePreviewPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSigned => $composableBuilder(
    column: $table.isSigned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentRowsTable> {
  $$DocumentRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameFolded => $composableBuilder(
    column: $table.nameFolded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get firstPagePreviewPath => $composableBuilder(
    column: $table.firstPagePreviewPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastPagePreviewPath => $composableBuilder(
    column: $table.lastPagePreviewPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSigned =>
      $composableBuilder(column: $table.isSigned, builder: (column) => column);
}

class $$DocumentRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentRowsTable,
          DocumentRow,
          $$DocumentRowsTableFilterComposer,
          $$DocumentRowsTableOrderingComposer,
          $$DocumentRowsTableAnnotationComposer,
          $$DocumentRowsTableCreateCompanionBuilder,
          $$DocumentRowsTableUpdateCompanionBuilder,
          (
            DocumentRow,
            BaseReferences<_$AppDatabase, $DocumentRowsTable, DocumentRow>,
          ),
          DocumentRow,
          PrefetchHooks Function()
        > {
  $$DocumentRowsTableTableManager(_$AppDatabase db, $DocumentRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameFolded = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> firstPagePreviewPath = const Value.absent(),
                Value<String?> lastPagePreviewPath = const Value.absent(),
                Value<int> pageCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSigned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRowsCompanion(
                id: id,
                name: name,
                nameFolded: nameFolded,
                filePath: filePath,
                firstPagePreviewPath: firstPagePreviewPath,
                lastPagePreviewPath: lastPagePreviewPath,
                pageCount: pageCount,
                createdAt: createdAt,
                isSigned: isSigned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> nameFolded = const Value.absent(),
                required String filePath,
                required String firstPagePreviewPath,
                Value<String?> lastPagePreviewPath = const Value.absent(),
                required int pageCount,
                required DateTime createdAt,
                Value<bool> isSigned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentRowsCompanion.insert(
                id: id,
                name: name,
                nameFolded: nameFolded,
                filePath: filePath,
                firstPagePreviewPath: firstPagePreviewPath,
                lastPagePreviewPath: lastPagePreviewPath,
                pageCount: pageCount,
                createdAt: createdAt,
                isSigned: isSigned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentRowsTable,
      DocumentRow,
      $$DocumentRowsTableFilterComposer,
      $$DocumentRowsTableOrderingComposer,
      $$DocumentRowsTableAnnotationComposer,
      $$DocumentRowsTableCreateCompanionBuilder,
      $$DocumentRowsTableUpdateCompanionBuilder,
      (
        DocumentRow,
        BaseReferences<_$AppDatabase, $DocumentRowsTable, DocumentRow>,
      ),
      DocumentRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DocumentRowsTableTableManager get documentRows =>
      $$DocumentRowsTableTableManager(_db, _db.documentRows);
}
